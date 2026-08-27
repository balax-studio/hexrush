import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('EconomyCalculator Tests', () {
    test('getGlobalMultiplier calculates correctly with castle level and crowns', () {
      final mult1 = EconomyCalculator.getGlobalMultiplier(castleLevel: 1, crowns: 0);
      expect(mult1, equals(1.0));

      final mult2 = EconomyCalculator.getGlobalMultiplier(castleLevel: 2, crowns: 10);
      // Castle Lvl 2: 1.0 + (2-1)*0.01 = 1.01
      // Crowns 10: 1.0 + 10*0.05 = 1.50
      // Total: 1.01 * 1.50 = 1.515
      expect(mult2, closeTo(1.515, 0.0001));
    });

    test('getCastleUpgradeCost requires wood after level 2', () {
      final costLvl2 = EconomyCalculator.getCastleUpgradeCost(2);
      expect(costLvl2['food'], equals(50.0));
      expect(costLvl2['wood'], equals(0.0));

      final costLvl3 = EconomyCalculator.getCastleUpgradeCost(3);
      expect(costLvl3['food'], equals(75.0));
      expect(costLvl3['wood'], equals(25.0));

      final costLvl4 = EconomyCalculator.getCastleUpgradeCost(4);
      expect(costLvl4['food'], closeTo(112.5, 0.01));
      expect(costLvl4['wood'], closeTo(37.5, 0.01));
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
