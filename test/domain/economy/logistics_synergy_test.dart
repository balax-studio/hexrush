import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Logistics Scaling & Granary Synergy Tests', () {
    test('Castle carries with scaled capacity based on level', () {
      final castleLvl1 = const BuildingModel(
        type: BuildingType.castle,
        level: 1,
      );
      final castleLvl10 = const BuildingModel(
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
      final centerCoord = const HexAxial(0, 0);
      final granaryTile = HexTileModel(
        coord: centerCoord,
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: const BuildingModel(
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
  });
}
