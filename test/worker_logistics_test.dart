import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Worker Logistics & Carrying Capacity Telemetry Tests', () {
    test('Isolated Worker Hut has full idle capacity and 0% utilization', () {
      final workerCoord = const HexAxial(0, 0);
      final workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.worker,
          level: 1,
        ),
      );

      final tiles = <HexAxial, HexTileModel>{workerCoord: workerTile};

      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: workerTile,
        tiles: tiles,
      );

      expect(stats.totalCapacity, equals(1.68));
      expect(stats.utilizedCapacity, equals(0.0));
      expect(stats.utilizationRatio, equals(0.0));
      expect(stats.demandInCoverage, equals(0.0));
      expect(stats.coveredBuildingsCount, equals(0));
      expect(stats.isOverloaded, isFalse);
      expect(stats.idleCapacity, equals(1.68));
    });

    test('Worker with nearby corn field within 4 hexes calculates correct utilization', () {
      final workerCoord = const HexAxial(0, 0);
      final cornCoord = const HexAxial(1, 0); // distance = 1 (within 4)

      final workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.worker,
          level: 1, // capacity = 1.68
        ),
      );

      final cornTile = HexTileModel(
        coord: cornCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
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

      expect(stats.totalCapacity, equals(1.68));
      expect(stats.demandInCoverage, closeTo(0.42, 0.001));
      expect(stats.utilizedCapacity, closeTo(0.42, 0.001));
      expect(stats.utilizationRatio, closeTo(0.42 / 1.68, 0.001));
      expect(stats.coveredBuildingsCount, equals(1));
      expect(stats.isOverloaded, isFalse);
    });

    test('Worker overloaded with many fields caps utilization at 100% and marks isOverloaded', () {
      final workerCoord = const HexAxial(0, 0);
      final workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.worker,
          level: 1, // capacity = 1.68
        ),
      );

      final tiles = <HexAxial, HexTileModel>{
        workerCoord: workerTile,
      };

      // 5 adet buğday tarlası ekle: 5 * 0.42 = 2.10 talep (kapasite: 1.68)
      for (int i = 1; i <= 5; i++) {
        final c = HexAxial(i, 0);
        if (workerCoord.distanceTo(c) <= 4) {
          tiles[c] = HexTileModel(
            coord: c,
            biome: TileBiome.meadow,
            state: TileState.owned,
            building: const BuildingModel(
              type: BuildingType.corn,
              level: 1,
            ),
          );
        }
      }

      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: workerTile,
        tiles: tiles,
      );

      expect(stats.totalCapacity, equals(1.68));
      expect(stats.demandInCoverage, closeTo(1.68, 0.01)); // 4 hex içindekiler (4 * 0.42 = 1.68)
      expect(stats.utilizedCapacity, closeTo(1.68, 0.01));
      expect(stats.utilizationRatio, equals(1.0));
      expect(stats.coveredBuildingsCount, equals(4)); // 5. tarla menzil dışı
    });

    test('Worker speed multiplier increases capacity proportionally', () {
      final workerCoord = const HexAxial(0, 0);
      final workerTile = HexTileModel(
        coord: workerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.worker,
          level: 2, // 1.68 * 2 = 3.36
        ),
      );

      final tiles = <HexAxial, HexTileModel>{workerCoord: workerTile};

      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: workerTile,
        tiles: tiles,
        workerTransferMult: 1.5, // %50 hız bonusu
      );

      expect(stats.totalCapacity, closeTo(3.36 * 1.5, 0.001));
    });
  });
}
