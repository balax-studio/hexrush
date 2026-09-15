import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Worker Logistics & Carrying Capacity Telemetry Tests', () {
    test('Isolated Worker Hut has full idle capacity and 0% utilization', () {
      const workerCoord = HexAxial(0, 0);
      const workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.worker,
          level: 1,
        ),
      );

      final tiles = <HexAxial, HexTileModel>{workerCoord: workerTile};

      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: workerTile,
        tiles: tiles,
      );

      expect(stats.totalCapacity, equals(3.36));
      expect(stats.utilizedCapacity, equals(0.0));
      expect(stats.utilizationRatio, equals(0.0));
      expect(stats.demandInCoverage, equals(0.0));
      expect(stats.coveredBuildingsCount, equals(0));
      expect(stats.isOverloaded, isFalse);
      expect(stats.idleCapacity, equals(3.36));
    });

    test('Worker with nearby corn field within 4 hexes calculates correct utilization', () {
      const workerCoord = HexAxial(0, 0);
      const cornCoord = HexAxial(1, 0); // distance = 1 (within 4)

      const workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.worker,
          level: 1, // capacity = 3.36
        ),
      );

      const cornTile = HexTileModel(
        coord: cornCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.corn,
          level: 1, // rate = 0.42
        ),
      );

      final tiles = <HexAxial, HexTileModel>{
        workerCoord: workerTile,
        cornCoord: cornTile,
      };

      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: workerTile,
        tiles: tiles,
      );

      expect(stats.totalCapacity, equals(3.36));
      expect(stats.demandInCoverage, closeTo(0.7245, 0.001));
      expect(stats.utilizedCapacity, closeTo(0.7245, 0.001));
      expect(stats.utilizationRatio, closeTo(0.7245 / 3.36, 0.001));
      expect(stats.coveredBuildingsCount, equals(1));
      expect(stats.isOverloaded, isFalse);
    });

    test('Worker overloaded with many fields caps utilization at 100% and marks isOverloaded', () {
      const workerCoord = HexAxial(0, 0);
      const workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.worker,
          level: 1, // capacity = 3.36
        ),
      );

      final tiles = <HexAxial, HexTileModel>{
        workerCoord: workerTile,
      };

      // 5 adet buğday tarlası (level 2) ekle: 4 tanesi menzilde
      for (int i = 1; i <= 5; i++) {
        final c = HexAxial(i, 0);
        if (workerCoord.distanceTo(c) <= 4) {
          tiles[c] = HexTileModel(
            coord: c,
            biome: TileBiome.meadow,
            state: TileState.owned,
            building: const BuildingModel(
              type: BuildingType.corn,
              level: 2,
            ),
          );
        }
      }

      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: workerTile,
        tiles: tiles,
      );

      expect(stats.totalCapacity, equals(3.36));
      expect(stats.demandInCoverage, greaterThan(3.36));
      expect(stats.utilizedCapacity, closeTo(3.36, 0.01));
      expect(stats.utilizationRatio, equals(1.0));
      expect(stats.isOverloaded, isTrue);
      expect(stats.coveredBuildingsCount, equals(4)); // 5. tarla menzil dışı
    });

    test('Worker speed multiplier increases capacity proportionally', () {
      const workerCoord = HexAxial(0, 0);
      const workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.worker,
          level: 2, // 3.36 * 2 = 6.72
        ),
      );

      final tiles = <HexAxial, HexTileModel>{workerCoord: workerTile};

      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: workerTile,
        tiles: tiles,
        workerTransferMult: 1.5, // %50 hız bonusu
      );

      expect(stats.totalCapacity, closeTo(6.72 * 1.5, 0.001));
    });
  });
}
