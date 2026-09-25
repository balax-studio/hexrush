import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Resource Breakdown (Üretim & Tüketim Dökümü) Tests', () {
    test('Empty realm returns empty producers and consumers with 0 net rate', () {
      final tiles = <HexAxial, HexTileModel>{};

      final breakdown = EconomyCalculator.calculateResourceBreakdown(
        resourceKey: 'food',
        tiles: tiles,
        castleLevel: 1,
        crowns: 0,
      );

      expect(breakdown.producers, isEmpty);
      expect(breakdown.consumers, isEmpty);
      expect(breakdown.totalProduction, equals(0.0));
      expect(breakdown.totalConsumption, equals(0.0));
      expect(breakdown.netRate, equals(0.0));
    });

    test('Winter wood breakdown includes active heating as consumption', () {
      const coord = HexAxial(0, 0);
      final breakdown = EconomyCalculator.calculateResourceBreakdown(
        resourceKey: 'wood',
        tiles: {
          coord: const HexTileModel(
            coord: coord,
            biome: TileBiome.forest,
            state: TileState.owned,
            isWarmed: true,
            building: BuildingModel(type: BuildingType.lumberjack, level: 1),
          ),
        },
        castleLevel: 1,
        crowns: 0,
        season: 'WINTER',
      );

      expect(breakdown.totalConsumption, greaterThan(0.0));
      expect(breakdown.consumers.any((c) => c.customLabel == 'Isıtma'), isTrue);
    });

    test('Food breakdown lists gross production, consumption, transport loss, and net income', () {
      const cornCoord = HexAxial(0, 0);
      const windmillCoord = HexAxial(1, 0);
      const bakeryCoord = HexAxial(2, 0);
      const castleCoord = HexAxial(0, 3);

      final tiles = <HexAxial, HexTileModel>{
        castleCoord: const HexTileModel(
          coord: castleCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        cornCoord: const HexTileModel(
          coord: cornCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.corn,
            level: 10,
          ),
        ),
        windmillCoord: const HexTileModel(
          coord: windmillCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.windmill,
            level: 5,
          ),
        ),
        bakeryCoord: const HexTileModel(
          coord: bakeryCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.bakery,
            level: 3,
          ),
        ),
      };

      final foodBreakdown = EconomyCalculator.calculateResourceBreakdown(
        resourceKey: 'food',
        tiles: tiles,
        castleLevel: 1,
        crowns: 0,
      );

      // Producers should have Corn
      expect(foodBreakdown.producers.length, equals(1));
      expect(foodBreakdown.producers.first.buildingType, equals(BuildingType.corn));
      expect(foodBreakdown.producers.first.level, equals(10));
      expect(foodBreakdown.totalProduction, greaterThan(0.0));

      // Consumers should have Windmill (consumes rate * 0.5) and Bakery (consumes rate * 0.4)
      expect(foodBreakdown.consumers.length, equals(2));
      final consumerTypes = foodBreakdown.consumers.map((c) => c.buildingType).toSet();
      expect(consumerTypes, contains(BuildingType.windmill));
      expect(consumerTypes, contains(BuildingType.bakery));
      expect(foodBreakdown.totalConsumption, greaterThan(0.0));
      expect(
        foodBreakdown.netRate,
        equals(
          foodBreakdown.totalProduction -
              foodBreakdown.totalConsumption -
              foodBreakdown.totalUntransported,
        ),
      );
      expect(
        foodBreakdown.producers.first.rate,
        greaterThan(foodBreakdown.producers.first.untransportedRate),
      );
    });

    test('Wood breakdown correctly lists lumberjack as producer and sawmill/damascusForge as consumers', () {
      const lumberCoord = HexAxial(0, 0);
      const sawmillCoord = HexAxial(1, 0);
      const forgeCoord = HexAxial(2, 0);
      const castleCoord = HexAxial(0, 3);

      final tiles = <HexAxial, HexTileModel>{
        castleCoord: const HexTileModel(
          coord: castleCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        lumberCoord: const HexTileModel(
          coord: lumberCoord,
          biome: TileBiome.forest,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.lumberjack,
            level: 8,
          ),
        ),
        sawmillCoord: const HexTileModel(
          coord: sawmillCoord,
          biome: TileBiome.forest,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.sawmill,
            level: 4,
          ),
        ),
        forgeCoord: const HexTileModel(
          coord: forgeCoord,
          biome: TileBiome.mountain,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.damascusForge,
            level: 1,
          ),
        ),
      };

      final woodBreakdown = EconomyCalculator.calculateResourceBreakdown(
        resourceKey: 'wood',
        tiles: tiles,
        castleLevel: 1,
        crowns: 0,
      );

      expect(woodBreakdown.producers.length, equals(1));
      expect(woodBreakdown.producers.first.buildingType, equals(BuildingType.lumberjack));

      expect(woodBreakdown.consumers.length, equals(2));
      final consumerTypes = woodBreakdown.consumers.map((c) => c.buildingType).toSet();
      expect(consumerTypes, contains(BuildingType.sawmill));
      expect(consumerTypes, contains(BuildingType.damascusForge));
    });

    test('Flour breakdown shows windmill as producer and bakery as consumer', () {
        const windmillCoord = HexAxial(0, 0);
        const bakeryCoord = HexAxial(1, 0);
        const castleCoord = HexAxial(0, 3);

        final tiles = <HexAxial, HexTileModel>{
          castleCoord: const HexTileModel(
            coord: castleCoord,
            biome: TileBiome.meadow,
            state: TileState.owned,
            building: BuildingModel(type: BuildingType.castle, level: 1),
          ),
          windmillCoord: const HexTileModel(
          coord: windmillCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.windmill,
            level: 4,
          ),
        ),
        bakeryCoord: const HexTileModel(
          coord: bakeryCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.bakery,
            level: 2,
          ),
        ),
      };

      final flourBreakdown = EconomyCalculator.calculateResourceBreakdown(
        resourceKey: 'flour',
        tiles: tiles,
        castleLevel: 1,
        crowns: 0,
      );

      expect(flourBreakdown.producers.length, equals(1));
      expect(flourBreakdown.producers.first.buildingType, equals(BuildingType.windmill));

      expect(flourBreakdown.consumers.length, equals(1));
      expect(flourBreakdown.consumers.first.buildingType, equals(BuildingType.bakery));
    });
  });
}
