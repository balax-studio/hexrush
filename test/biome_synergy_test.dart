import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Biome & Adjacency Synergy Tests', () {
    test('Farm next to Wetland receives +30% Irrigation boost', () {
      const farmTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn, level: 1),
      );

      final neighbors = [
        const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.wetland,
          state: TileState.owned,
        ),
      ];

      final mult = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: farmTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(mult, closeTo(1.30, 0.001));

      final labels = EconomyCalculator.getActiveSynergyLabels(
        targetTile: farmTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(labels.length, 1);
      expect(labels.first, contains('Sulama Bereketi'));
    });

    test('Mine next to Volcano receives +50% Geothermal boost', () {
      const mineTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.mountain,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.mine, level: 1),
      );

      final neighbors = [
        const HexTileModel(
          coord: HexAxial(0, 1),
          biome: TileBiome.volcano,
          state: TileState.owned,
        ),
      ];

      final mult = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: mineTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(mult, closeTo(1.50, 0.001));

      final labels = EconomyCalculator.getActiveSynergyLabels(
        targetTile: mineTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(labels.length, 1);
      expect(labels.first, contains('Jeotermal Dökümhane'));
    });

    test('Farm next to Desert suffers -20% Drought penalty', () {
      const farmTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn, level: 1),
      );

      final neighbors = [
        const HexTileModel(
          coord: HexAxial(-1, 0),
          biome: TileBiome.desert,
          state: TileState.owned,
        ),
      ];

      final mult = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: farmTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(mult, closeTo(0.80, 0.001));

      final labels = EconomyCalculator.getActiveSynergyLabels(
        targetTile: farmTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(labels.length, 1);
      expect(labels.first, contains('Kuraklık'));
    });

    test('Windmill next to Desert receives +40% Silk Road Trade boost', () {
      const windmillTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.desert,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.windmill, level: 1),
      );

      final neighbors = [
        const HexTileModel(
          coord: HexAxial(0, -1),
          biome: TileBiome.desert,
          state: TileState.owned,
        ),
      ];

      final mult = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: windmillTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(mult, closeTo(1.40, 0.001));
    });

    test('Foggy neighbor tiles do not grant synergies', () {
      const mineTile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.mountain,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.mine, level: 1),
      );

      final neighbors = [
        const HexTileModel(
          coord: HexAxial(0, 1),
          biome: TileBiome.volcano,
          state: TileState.fog,
        ),
      ];

      final mult = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: mineTile,
        neighborTiles: neighbors,
        season: 'SPRING',
        isZud: false,
      );

      expect(mult, closeTo(1.0, 0.001));
    });
  });
}
