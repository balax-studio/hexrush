import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Logistics Scaling & Granary Synergy Tests', () {
    test('Castle carries with scaled capacity based on level', () {
      const castleLvl1 = BuildingModel(
        type: BuildingType.castle,
        level: 1,
      );
      const castleLvl10 = BuildingModel(
        type: BuildingType.castle,
        level: 10,
      );

      expect(castleLvl1.baseCarryingCapacity, 3.0);
      expect(castleLvl1.currentCarryingCapacity, 3.0);
      // Level 10 has milestone boost 2^1 = 2 -> 3.0 * 10 * 2 = 60.0
      expect(castleLvl10.currentCarryingCapacity, 60.0);
    });

    test('getWorkerTransferMultiplier scales with castleLevel and globalMultiplier', () {
      final multLvl1 = EconomyCalculator.getWorkerTransferMultiplier(
        castleLevel: 1,
      );
      final multLvl10 = EconomyCalculator.getWorkerTransferMultiplier(
        castleLevel: 10,
      );

      // Castle Level 10 gives +10% bonus -> globalMultiplier 1.10
      expect(multLvl1, 1.0);
      expect(multLvl10, 1.10);
    });

    test('GranaryVault gains +20% logistics synergy per neighboring food producer', () {
      const centerCoord = HexAxial(0, 0);
      const granaryTile = HexTileModel(
        coord: centerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(
          type: BuildingType.granaryVault,
          level: 1,
        ),
      );

      // Harita oluştur
      final Map<HexAxial, HexTileModel> tiles = {
        centerCoord: granaryTile,
      };

      // 0 komşu varken çarpan 1.0
      expect(
        EconomyCalculator.calculateGranarySynergyMultiplier(granaryTile, tiles),
        1.0,
      );

      // 2 komşu gıda üreticisi ekle (Mısır ve Mera)
      final n1Coord = centerCoord.neighbors[0];
      final n2Coord = centerCoord.neighbors[1];

      tiles[n1Coord] = HexTileModel(
        coord: n1Coord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.corn,
          level: 1,
        ),
      );

      tiles[n2Coord] = HexTileModel(
        coord: n2Coord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
          type: BuildingType.pasture,
          level: 1,
        ),
      );

      // 2 gıda üreticisi -> 1.0 + (2 * 0.20) = 1.40 (+%40)
      expect(
        EconomyCalculator.calculateGranarySynergyMultiplier(granaryTile, tiles),
        closeTo(1.40, 0.001),
      );
    });

    test('Castle transport matches the 1 per second used by the game tick', () {
      const producerCoord = HexAxial(0, 0);
      const castleCoord = HexAxial(1, 0);
      final tiles = <HexAxial, HexTileModel>{
        producerCoord: const HexTileModel(
          coord: producerCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
        castleCoord: const HexTileModel(
          coord: castleCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 10),
        ),
      };

      final remaining = EconomyCalculator.allocateGreedyLogistics(
        tiles: tiles,
        producerDemands: {producerCoord: 2.0},
      );

      expect(remaining[producerCoord], 1.0);
    });

    test('Owned shrine contributes logistics capacity to rate estimates', () {
      const producerCoord = HexAxial(0, 0);
      const shrineCoord = HexAxial(1, 0);
      final tiles = <HexAxial, HexTileModel>{
        producerCoord: const HexTileModel(
          coord: producerCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.corn, level: 1),
        ),
        shrineCoord: const HexTileModel(
          coord: shrineCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          shrine: ShrineType.foodBoost,
        ),
      };

      final remaining = EconomyCalculator.allocateGreedyLogistics(
        tiles: tiles,
        producerDemands: {producerCoord: 5.0},
      );

      expect(remaining[producerCoord], 0.0);
    });

    test('Granary utilization excludes non-food producers', () {
      const granaryCoord = HexAxial(0, 0);
      const lumberCoord = HexAxial(1, 0);
      final granary = const HexTileModel(
        coord: granaryCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.granaryVault, level: 1),
      );
      final stats = EconomyCalculator.calculateWorkerLogisticsStats(
        workerTile: granary,
        tiles: {
          granaryCoord: granary,
          lumberCoord: const HexTileModel(
            coord: lumberCoord,
            biome: TileBiome.forest,
            state: TileState.owned,
            building: BuildingModel(type: BuildingType.lumberjack, level: 1),
          ),
        },
      );

      expect(stats.utilizationRatio, 0.0);
      expect(stats.coveredBuildingsCount, 0);
    });
  });
}
