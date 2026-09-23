import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';

void main() {
  group('Lojistik Kademe ve Katma Değer Önceliklendirme Testleri', () {
    test('BuildingType.logisticsPriority hiyerarşisi doğru sıralanmalıdır', () {
      // Tier 4 binaları en yüksek önceliğe sahip olmalıdır
      expect(BuildingType.kumisYurt.logisticsPriority, 50);
      expect(BuildingType.damascusForge.logisticsPriority, 50);
      expect(BuildingType.feltTentWorkshop.logisticsPriority, 50);

      // Tier 3 binalar orta-yüksek öncelikte olmalıdır
      expect(BuildingType.bakery.logisticsPriority, 30);
      expect(BuildingType.furniture.logisticsPriority, 30);

      // Tier 2 binalar orta öncelikte olmalıdır
      expect(BuildingType.windmill.logisticsPriority, 15);
      expect(BuildingType.sawmill.logisticsPriority, 15);

      // Tier 1 temel tarım/hammadde binaları taban öncelikte olmalıdır
      expect(BuildingType.corn.logisticsPriority, 5);
      expect(BuildingType.barley.logisticsPriority, 5);
      expect(BuildingType.lumberjack.logisticsPriority, 5);

      // Kımız Otağı Mısır Tarlasından daha yüksek önceliğe sahip olmalıdır
      expect(
        BuildingType.kumisYurt.logisticsPriority,
        greaterThan(BuildingType.corn.logisticsPriority),
      );
    });

    test('Ambar kapasitesi kısıtlı olduğunda Kımız Mısırdan önce taşınmalıdır', () {
      final origin = HexAxial(0, 0); // Gıda Ambarı
      final cornCoord = HexAxial(1, 0); // Mısır Tarlası (Mesafe 1)
      final kumisCoord = HexAxial(2, 0); // Kımız Otağı (Mesafe 2)

      final tiles = <HexAxial, HexTileModel>{
        origin: HexTileModel(
          coord: origin,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: const BuildingModel(
            type: BuildingType.granaryVault,
            level: 1, // Kapasite: 33.6
          ),
        ),
        cornCoord: HexTileModel(
          coord: cornCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: const BuildingModel(
            type: BuildingType.corn,
            level: 5,
          ),
        ),
        kumisCoord: HexTileModel(
          coord: kumisCoord,
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: const BuildingModel(
            type: BuildingType.kumisYurt,
            level: 1,
          ),
        ),
      };

      // Mısır 40 talep ediyor, Kımız 10 talep ediyor.
      final producerDemands = <HexAxial, double>{
        cornCoord: 40.0,
        kumisCoord: 10.0,
      };

      final untransported = EconomyCalculator.allocateGreedyLogistics(
        tiles: tiles,
        producerDemands: producerDemands,
        workerTransferMult: 1.0,
      );

      // Kımız (10.0 talep) önce işlenir -> 10.0'ı taşınır, untransported = 0.0 kalır!
      expect(untransported[kumisCoord], 0.0,
          reason: 'Kımız yüksek öncelikli olduğu için tamamı taşınmalıdır');
      expect(untransported[cornCoord], greaterThan(0.0),
          reason: 'Mısır kalan kapasiteyi almalı ve arta kalan taşınamamış görünmelidir');
    });
  });
}
