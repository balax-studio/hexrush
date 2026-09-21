import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/hex/hex_math.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Kutlu Tapınak Dağılımı ve Mesafe Testleri (11 Tapınak, Min Mesafe >= 7)', () {
    test('Harita başlangıcında tam 11 adet Kutlu Tapınak üretilmelidir', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(gameStateProvider);
      final shrineTiles = state.tiles.values.where((t) => t.hasShrine).toList();

      expect(shrineTiles.length, equals(11),
          reason: 'Haritada tam olarak 11 adet Kutlu Tapınak bulunmalıdır.');
    });

    test('Her iki Kutlu Tapınak arasındaki mesafe en az 7 karo olmalıdır', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(gameStateProvider);
      final shrineTiles = state.tiles.values.where((t) => t.hasShrine).toList();

      expect(shrineTiles.length, equals(11));

      for (int i = 0; i < shrineTiles.length; i++) {
        for (int j = i + 1; j < shrineTiles.length; j++) {
          final tileA = shrineTiles[i];
          final tileB = shrineTiles[j];
          final distance = HexMath.hexDistance(tileA.coord, tileB.coord);

          expect(distance >= 7, isTrue,
              reason:
                  'Tapınak ${tileA.coord} ile ${tileB.coord} arasındaki mesafe $distance, asgari 7 olmalıdır.');
        }
      }
    });

    test('Kutlu Tapınaklar merkez şatoda veya geçersiz arazilerde olamaz', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(gameStateProvider);
      final centerTile = state.tiles[const HexAxial(0, 0)]!;

      expect(centerTile.hasShrine, isFalse, reason: 'Merkez şatoda tapınak olamaz.');

      for (final t in state.tiles.values.where((t) => t.hasShrine)) {
        expect(t.biome, isNot(equals(TileBiome.sea)), reason: 'Denizde tapınak olamaz.');
        expect(t.biome, isNot(equals(TileBiome.mountain)), reason: 'Dağda tapınak olamaz.');
      }
    });

    test('Şatoya 4 hex uzaktaki ilk tapınak speedBoost olmalı, diğer tapınaklar geçerli tür havuzunda olmalıdır', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(gameStateProvider);
      const center = HexAxial(0, 0);

      final dist4Shrine = state.tiles.values.firstWhere(
        (t) => HexMath.hexDistance(center, t.coord) == 4 && t.hasShrine,
      );
      expect(dist4Shrine.shrine, equals(ShrineType.speedBoost),
          reason: 'Şatoya 4 hex uzaktaki ilk tapınak Lojistik & Taşıma Bonusu (speedBoost) olmalıdır.');

      final shrineTiles = state.tiles.values.where((t) => t.hasShrine).toList();
      final validShrines = shrineTiles.where((t) => t.shrine != ShrineType.none).length;
      expect(validShrines, equals(11));
    });
  });

  group('Kutlu Tapınak Özellik ve Yüzde Bonusları Testleri', () {
    test('ShrineTypeExtension başlık ve x2/x3 kat formatlarını doğru döner', () {
      expect(ShrineType.foodBoost.titleTr, equals('Gıda Bereketi'));
      expect(ShrineType.foodBoost.getFormattedBonusTr(4, 2.0), equals('x2 (2 Kat) Gıda Bereketi (+%200)'));
      expect(ShrineType.foodBoost.getFormattedBonusTr(4, 3.0), equals('x3 (3 Kat) Gıda Bereketi (+%300)'));

      expect(ShrineType.woodBoost.titleTr, equals('Odun Bereketi'));
      expect(ShrineType.woodBoost.getFormattedBonusTr(4, 2.0), equals('x2 (2 Kat) Odun Bereketi (+%200)'));

      expect(ShrineType.stoneBoost.titleTr, equals('Taş Bereketi'));
      expect(ShrineType.stoneBoost.getFormattedBonusTr(4, 3.0), equals('x3 (3 Kat) Taş Bereketi (+%300)'));

      expect(ShrineType.speedBoost.titleTr, equals('Lojistik Hızı'));
      expect(ShrineType.speedBoost.getFormattedBonusTr(4, 2.0), equals('x2 (2 Kat) Lojistik Hızı (+%200)'));
    });

    test('BuildingType enum içinde shrine bulunmamalıdır (Kadim Sunak kaldırıldı)', () {
      final typeNames = BuildingType.values.map((e) => e.name).toList();
      expect(typeNames.contains('shrine'), isFalse,
          reason: 'Kadim Sunak bir bina tipi olmamalı, Kutlu Tapınak karo özelliği olmalıdır.');
    });

    test('Büyük Göçte sahip olunan her Kutlu Tapınak Taç dökümünde yer alır', () {
      final tiles = [
        const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          shrine: ShrineType.foodBoost,
        ),
        const HexTileModel(
          coord: HexAxial(2, 0),
          biome: TileBiome.forest,
          state: TileState.owned,
          shrine: ShrineType.woodBoost,
        ),
      ];

      final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
        tiles: tiles,
        resources: const ResourcesModel(),
        castleLevel: 1,
      );

      // 2 adet sahip olunan Kutlu Tapınak = 2 Taç bina/tapınak kategorisinde
      expect(breakdown.buildingAndShrineCrowns, greaterThanOrEqualTo(2));
    });

    test('Lojistik/Taşıma Tapınakları sadece taşıma kapasitesini x2 veya x3 katlar, üretimi etkilemez', () {
      final baseMap = <HexAxial, HexTileModel>{
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.worker, level: 1),
        ),
        const HexAxial(1, 0): const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.forest,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.lumberjack, level: 1),
        ),
      };

      final baseWorkerMult = EconomyCalculator.getWorkerTransferMultiplier(tiles: baseMap);
      expect(baseWorkerMult, equals(1.0));

      // Lojistik tapınağı x3 (3 Kat) taşıma kapasitesi ile eklensin (komşu aura çakışması olmaması için (5,0) konumuna konur)
      final mapWithTransportShrine = <HexAxial, HexTileModel>{
        ...baseMap,
        const HexAxial(5, 0): const HexTileModel(
          coord: HexAxial(5, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          shrine: ShrineType.speedBoost,
          shrineMultiplierValue: 3.0,
        ),
      };

      final boostedWorkerMult = EconomyCalculator.getWorkerTransferMultiplier(tiles: mapWithTransportShrine);
      expect(boostedWorkerMult, equals(3.0),
          reason: 'Lojistik tapınağı aktifken taşıma katsayısı tam olarak x3 olmalıdır.');

      // Üretim debisi kontrolü: Taşıma tapınağı oduncu üretim hızını artırmamalıdır.
      final lumberRateNoShrine = EconomyCalculator.calculateTileEffectiveProductionRate(
        tile: baseMap[const HexAxial(1, 0)]!,
        tileMap: baseMap,
        globalMultiplier: 1.0,
      );
      final lumberRateWithShrine = EconomyCalculator.calculateTileEffectiveProductionRate(
        tile: mapWithTransportShrine[const HexAxial(1, 0)]!,
        tileMap: mapWithTransportShrine,
        globalMultiplier: 1.0,
      );

      expect(lumberRateWithShrine, equals(lumberRateNoShrine),
          reason: 'Lojistik tapınağı hammadde üretim debisini değiştirmemeli, sadece taşıma kapasitesini artırmalıdır.');
    });

    test('Taş Bereketi tapınağı taş üretimi yapan binaları x2/x3 katlar', () {
      final mapWithStoneShrine = <HexAxial, HexTileModel>{
        const HexAxial(0, 0): const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.mountain,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.quarry, level: 1),
        ),
        const HexAxial(1, 0): const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          shrine: ShrineType.stoneBoost,
          shrineMultiplierValue: 2.0,
        ),
      };

      final mult = EconomyCalculator.calculateResourceShrineMultiplier(
        tiles: mapWithStoneShrine,
        resourceType: 'stone',
      );
      expect(mult, equals(2.0), reason: 'Taş bereketi tapınağı taş çarpanını x2 yapmalıdır.');
    });
  });
}
