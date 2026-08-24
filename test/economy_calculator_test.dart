import 'package:flutter_test/flutter_test.dart';
import 'package:hex_idle/core/hex/hex_coordinates.dart';
import 'package:hex_idle/domain/economy/economy_calculator.dart';
import 'package:hex_idle/domain/models/building_model.dart';
import 'package:hex_idle/domain/models/hex_tile_model.dart';

void main() {
  group('EconomyCalculator Tests', () {
    test('getGlobalMultiplier calculates correctly with castle level and crowns', () {
      final mult1 = EconomyCalculator.getGlobalMultiplier(castleLevel: 1, crowns: 0);
      expect(mult1, equals(1.0));

      final mult2 = EconomyCalculator.getGlobalMultiplier(castleLevel: 2, crowns: 10);
      // Castle Lvl 2: 1.0 + (2-1)*0.25 = 1.25
      // Crowns 10: 1.0 + 10*0.05 = 1.50
      // Total: 1.25 * 1.50 = 1.875
      expect(mult2, equals(1.875));
    });

    test('getSeasonProductionMultiplier returns expected multipliers', () {
      expect(EconomyCalculator.getSeasonProductionMultiplier(season: 'SPRING', isZud: false, isTileWarmed: false), equals(1.25));
      expect(EconomyCalculator.getSeasonProductionMultiplier(season: 'SUMMER', isZud: false, isTileWarmed: false), equals(1.10));
      expect(EconomyCalculator.getSeasonProductionMultiplier(season: 'AUTUMN', isZud: false, isTileWarmed: false), equals(1.00));
      expect(EconomyCalculator.getSeasonProductionMultiplier(season: 'WINTER', isZud: false, isTileWarmed: false), equals(0.80));
      expect(EconomyCalculator.getSeasonProductionMultiplier(season: 'WINTER', isZud: true, isTileWarmed: false), equals(0.60));
      expect(EconomyCalculator.getSeasonProductionMultiplier(season: 'WINTER', isZud: true, isTileWarmed: true), equals(1.50));
    });

    test('calculateOfflineGains respects 8 hour limit and worker status', () {
      final tiles = [
        const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
      ];

      // Test without worker (capped at 30 seconds of production)
      final gainsNoWorker = EconomyCalculator.calculateOfflineGains(
        tiles: tiles,
        elapsedSeconds: 3600.0,
        globalMultiplier: 1.0,
      );
      expect(gainsNoWorker.food, closeTo(0.42 * 30.0, 0.01));

      // Test with worker (uncapped for elapsed seconds up to 8h)
      final tilesWithWorker = [
        ...tiles,
        const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.worker),
        ),
      ];

      final gainsWithWorker = EconomyCalculator.calculateOfflineGains(
        tiles: tilesWithWorker,
        elapsedSeconds: 100.0,
        globalMultiplier: 1.0,
      );
      expect(gainsWithWorker.food, closeTo(0.42 * 100.0, 0.01));
    });
  });
}
