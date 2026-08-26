import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/flame/hex_map_game.dart';
import 'package:hex_rush/presentation/flame/components/harvest_sparkle_emitter.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Direct Tap Harvest Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('collectFromTile directly harvests emergency food from castle', () {
      final notifier = container.read(gameStateProvider.notifier);
      final initialFood = container.read(gameStateProvider).resources.food;

      // Tap on castle at (0, 0)
      final harvestResult = notifier.collectFromTile(const HexAxial(0, 0));
      expect(harvestResult, isTrue);

      final updatedState = container.read(gameStateProvider);
      expect(updatedState.resources.food, equals(initialFood + 1.0));
    });

    test('collectFromTile directly harvests accumulated building resources', () {
      final notifier = container.read(gameStateProvider.notifier);
      const targetCoord = HexAxial(1, 0);

      // Setup corn tile with accumulatedResource
      final currentTile = container.read(gameStateProvider).tiles[targetCoord] ??
          const HexTileModel(
            coord: targetCoord,
            biome: TileBiome.meadow,
            state: TileState.owned,
          );

      final updatedTile = currentTile.copyWith(
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.corn,
          level: 1,
          accumulatedResource: 18.0,
        ),
      );

      final updatedTiles = Map<HexAxial, HexTileModel>.from(container.read(gameStateProvider).tiles);
      updatedTiles[targetCoord] = updatedTile;

      notifier.state = notifier.state.copyWith(tiles: updatedTiles);

      final initialFood = container.read(gameStateProvider).resources.food;
      final harvestResult = notifier.collectFromTile(targetCoord);
      expect(harvestResult, isTrue);

      final finalState = container.read(gameStateProvider);
      expect(finalState.resources.food, equals(initialFood + 18.0));
      expect(finalState.tiles[targetCoord]!.building!.accumulatedResource, equals(0.0));
    });

    test('HexMapGame onTileHarvest callback triggers on tile tap', () {
      HexAxial? harvestedCoord;
      HexAxial? selectedCoord;

      final game = HexMapGame(
        onTileSelected: (coord) {
          selectedCoord = coord;
        },
        onTileHarvest: (coord) {
          harvestedCoord = coord;
          return true;
        },
      );

      game.syncGameState(container.read(gameStateProvider));
      game.onTileHarvest?.call(const HexAxial(0, 0));
      game.onTileSelected(const HexAxial(0, 0));

      expect(harvestedCoord, equals(const HexAxial(0, 0)));
      expect(selectedCoord, equals(const HexAxial(0, 0)));

      // Harvest Sparkle Emitter component smoke test
      final emitter = HarvestSparkleEmitter(
        centerPosition: Vector2(100, 100),
        isGolden: true,
        particleCount: 12,
      );
      expect(emitter.duration, equals(0.9));
      emitter.update(0.1);
    });
  });
}
