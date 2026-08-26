import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Worker Range (4 Hex Radius) & Gathering Tests', () {
    test('HexAxial.distanceTo calculates correct hex distance', () {
      const origin = HexAxial(0, 0);

      // Neighbor distance
      expect(origin.distanceTo(const HexAxial(1, 0)), equals(1));
      expect(origin.distanceTo(const HexAxial(0, 1)), equals(1));
      expect(origin.distanceTo(const HexAxial(-1, 1)), equals(1));

      // 4 hex range boundary
      expect(origin.distanceTo(const HexAxial(4, 0)), equals(4));
      expect(origin.distanceTo(const HexAxial(2, 2)), equals(4));
      expect(origin.distanceTo(const HexAxial(-4, 4)), equals(4));

      // Beyond 4 hex range
      expect(origin.distanceTo(const HexAxial(5, 0)), equals(5));
      expect(origin.distanceTo(const HexAxial(3, 3)), equals(6));
    });

    test('calculateOfflineGains respects 4-hex worker coverage distance', () {
      // Corn at (0, 0)
      const cornTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn, level: 1),
      );

      // 1. Worker at distance 2 (inside 4-hex range) -> unconstrained gathering
      const workerNear = HexTileModel(
        coord: HexAxial(2, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.worker),
      );

      final gainsNear = EconomyCalculator.calculateOfflineGains(
        tiles: [cornTile, workerNear],
        elapsedSeconds: 100.0,
        globalMultiplier: 1.0,
      );
      expect(gainsNear.food, closeTo(0.42 * 100.0, 0.01));

      // 2. Worker at distance 5 (outside 4-hex range) -> capped at 30 seconds
      const workerFar = HexTileModel(
        coord: HexAxial(5, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.worker),
      );

      final gainsFar = EconomyCalculator.calculateOfflineGains(
        tiles: [cornTile, workerFar],
        elapsedSeconds: 3600.0,
        globalMultiplier: 1.0,
      );
      expect(gainsFar.food, closeTo(0.42 * 30.0, 0.01));
    });

    test('GameStateNotifier game loop: in-range building auto-harvests, far building accumulates', () {
      final notifier = GameStateNotifier();

      // Set up custom test state:
      // Castle at (0, 0) (Range covers up to distance 4)
      // Corn 1 at (2, 0) -> distance 2 (Inside Castle range)
      // Corn 2 at (6, 0) -> distance 6 (Outside Castle and Worker range)
      final tiles = <HexAxial, HexTileModel>{
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        const HexAxial(2, 0): const HexTileModel(
          coord: HexAxial(2, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
        const HexAxial(6, 0): const HexTileModel(
          coord: HexAxial(6, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
      };

      notifier.state = notifier.state.copyWith(
        tiles: tiles,
        resources: const ResourcesModel(food: 0.0, wood: 0.0),
      );

      // Trigger one game loop second
      notifier.testTick();

      final state = notifier.state;

      // In-range Corn at (2, 0): resources transferred to inventory
      expect(state.resources.food, greaterThan(0.0));

      // Far Corn at (6, 0): resources accumulated in building
      final farCorn = state.tiles[const HexAxial(6, 0)]!;
      expect(farCorn.building!.accumulatedResource, greaterThan(0.0));

      // Now add a Worker Hut at (5, 0) (distance 1 to Corn 2)
      final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
      updatedTiles[const HexAxial(5, 0)] = const HexTileModel(
        coord: HexAxial(5, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.worker, level: 1),
      );

      notifier.state = notifier.state.copyWith(tiles: updatedTiles);

      final foodBefore = notifier.state.resources.food;
      notifier.testTick();

      // With worker hut at (5, 0), Corn 2 at (6, 0) is now within range and automatically collected!
      expect(notifier.state.resources.food, greaterThan(foodBefore));
    });

    test('Player can manually collect accumulated resources from out-of-range building', () {
      final notifier = GameStateNotifier();

      final tiles = <HexAxial, HexTileModel>{
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        const HexAxial(6, 0): const HexTileModel(
          coord: HexAxial(6, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.lumberjack,
            level: 1,
            accumulatedResource: 15.0,
          ),
        ),
      };

      notifier.state = notifier.state.copyWith(
        tiles: tiles,
        resources: const ResourcesModel(food: 0.0, wood: 0.0),
      );

      // Collect manually
      final collected = notifier.collectFromTile(const HexAxial(6, 0));
      expect(collected, isTrue);
      expect(notifier.state.resources.wood, equals(15.0));
      expect(notifier.state.tiles[const HexAxial(6, 0)]!.building!.accumulatedResource, equals(0.0));
    });
  });
}
