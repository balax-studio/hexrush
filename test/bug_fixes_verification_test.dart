import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/ancestral_kurgan_model.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Bug Fixes Verification Suite (BUG-001 to BUG-004)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('BUG-001: claimOfflineGains properly credits standard and 1.5x boosted resources', () async {
      final notifier = container.read(gameStateProvider.notifier);
      final initialFood = container.read(gameStateProvider).resources.food;
      final initialWood = container.read(gameStateProvider).resources.wood;

      const gains = OfflineGainsResult(
        seconds: 3600,
        food: 20.0,
        wood: 10.0,
        stone: 5.0,
        iron: 0.0,
        flour: 0.0,
        plank: 0.0,
        bread: 0.0,
        furniture: 0.0,
      );

      // Standard claim
      await notifier.claimOfflineGains(gains, isBoosted: false);
      expect(container.read(gameStateProvider).resources.food, equals(initialFood + 20.0));
      expect(container.read(gameStateProvider).resources.wood, equals(initialWood + 10.0));

      // 1.5x Boosted claim
      final foodBeforeBoost = container.read(gameStateProvider).resources.food;
      await notifier.claimOfflineGains(gains, isBoosted: true);
      expect(container.read(gameStateProvider).resources.food, equals(foodBeforeBoost + 30.0)); // 20 * 1.5 = 30
    });

    test('BUG-004: demolishBuilding collects accumulated resources before dismantling building', () {
      final notifier = container.read(gameStateProvider.notifier);
      const coord = HexAxial(1, 0);

      // Place a corn tile with 25.0 accumulated resources
      final tile = HexTileModel(
        coord: coord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.corn,
          level: 1,
          accumulatedResource: 25.0,
        ),
      );

      final tiles = Map<HexAxial, HexTileModel>.from(container.read(gameStateProvider).tiles);
      tiles[coord] = tile;
      notifier.state = notifier.state.copyWith(tiles: tiles);

      final initialFood = container.read(gameStateProvider).resources.food;
      final success = notifier.demolishBuilding(coord);
      expect(success, isTrue);

      final finalState = container.read(gameStateProvider);
      // Food should include: 25.0 (accumulated harvest) + refund (half base cost of corn = 5.0)
      expect(finalState.resources.food, equals(initialFood + 25.0 + 5.0));
      expect(finalState.tiles[coord]!.hasBuilding, isFalse);
    });

    test('BUG-003: resetGame deduplicates Ancestral Kurgans on identical tile coordinates', () {
      final notifier = container.read(gameStateProvider.notifier);
      const coord = HexAxial(1, 0);

      // Add existing kurgan at (1, 0)
      const existingKurgan = AncestralKurgan(
        id: 'kurgan_0_1_0',
        coord: coord,
        formerBuildingType: BuildingType.corn,
        formerLevel: 1,
        relicTitle: 'CORN Kalıntısı',
        bonusMultiplier: 0.05,
        isDiscovered: true,
      );

      // Now build a level 3 lumberjack on the same tile (1, 0)
      final lumberTile = HexTileModel(
        coord: coord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.lumberjack,
          level: 3,
        ),
      );

      final tiles = Map<HexAxial, HexTileModel>.from(container.read(gameStateProvider).tiles);
      tiles[coord] = lumberTile;
      notifier.state = notifier.state.copyWith(
        tiles: tiles,
        discoveredKurgans: [existingKurgan],
      );

      notifier.resetGame();

      final postResetState = container.read(gameStateProvider);
      // Kurgans at (1, 0) must be exactly 1, not 2
      final kurgansAtCoord = postResetState.discoveredKurgans.where((k) => k.coord == coord).toList();
      expect(kurgansAtCoord.length, equals(1));
      expect(kurgansAtCoord.first.formerLevel, equals(3));
      expect(kurgansAtCoord.first.bonusMultiplier, closeTo(0.15, 0.001));
    });
  });
}
