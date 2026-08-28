import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/hexpedia_entry_model.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';

void main() {
  group('Hexpedia 36 Yapı ve Arama Testleri', () {
    test('HexpediaRepository tüm 36 yapıyı içermeli ve toplam rehber sayısı 40+ olmalı', () {
      final entries = HexpediaRepository.getAllEntries();
      expect(entries.length, greaterThanOrEqualTo(40));

      final buildingEntries = HexpediaRepository.getByCategory(HexpediaCategory.buildings);
      expect(buildingEntries.length, greaterThanOrEqualTo(36));

      // 36 yapının her birinin BuildingType ile eşleşen bir ID veya etikete sahip olduğunu doğrula
      final buildingIds = buildingEntries.map((e) => e.id).toSet();
      expect(buildingIds.contains('bld_corn'), isTrue);
      expect(buildingIds.contains('bld_barley'), isTrue);
      expect(buildingIds.contains('bld_pasture'), isTrue);
      expect(buildingIds.contains('bld_orchard'), isTrue);
      expect(buildingIds.contains('bld_quarry'), isTrue);
      expect(buildingIds.contains('bld_resin_camp'), isTrue);
      expect(buildingIds.contains('bld_windmill'), isTrue);
      expect(buildingIds.contains('bld_bakery'), isTrue);
      expect(buildingIds.contains('bld_lumberjack'), isTrue);
      expect(buildingIds.contains('bld_sawmill'), isTrue);
      expect(buildingIds.contains('bld_furniture'), isTrue);
      expect(buildingIds.contains('bld_worker'), isTrue);
      expect(buildingIds.contains('bld_watchtower'), isTrue);
      expect(buildingIds.contains('bld_mine'), isTrue);
      expect(buildingIds.contains('bld_bridge'), isTrue);
      expect(buildingIds.contains('bld_fisherman'), isTrue);
      expect(buildingIds.contains('bld_fisherman_hut'), isTrue);
      expect(buildingIds.contains('bld_oasis_cistern'), isTrue);
      expect(buildingIds.contains('bld_caravanserai'), isTrue);
      expect(buildingIds.contains('bld_astrolabe'), isTrue);
      expect(buildingIds.contains('bld_reindeer_sanctuary'), isTrue);
      expect(buildingIds.contains('bld_geothermal_bath'), isTrue);
      expect(buildingIds.contains('bld_permafrost_dig'), isTrue);
      expect(buildingIds.contains('bld_steam_vent'), isTrue);
      expect(buildingIds.contains('bld_obsidian_forge'), isTrue);
      expect(buildingIds.contains('bld_herbalist_yurt'), isTrue);
      expect(buildingIds.contains('bld_scribe_workshop'), isTrue);
      expect(buildingIds.contains('bld_celestial_anvil'), isTrue);
      expect(buildingIds.contains('bld_ancestral_totem'), isTrue);
      expect(buildingIds.contains('bld_prismatic_resonator'), isTrue);
      expect(buildingIds.contains('bld_granary_vault'), isTrue);
      expect(buildingIds.contains('bld_kumis_yurt'), isTrue);
      expect(buildingIds.contains('bld_felt_tent_workshop'), isTrue);
      expect(buildingIds.contains('bld_damascus_forge'), isTrue);
      expect(buildingIds.contains('bld_runic_stele'), isTrue);
    });

    test('Türkçe karakter toleranslı arama doğru çalışmalı', () {
      // Şam Çeliği araması ("sam" veya "Şam" ile bulunmalı)
      final resultsSam = HexpediaRepository.search('sam');
      expect(resultsSam.any((e) => e.id == 'bld_damascus_forge'), isTrue);

      final resultsSamTr = HexpediaRepository.search('Şam');
      expect(resultsSamTr.any((e) => e.id == 'bld_damascus_forge'), isTrue);

      // Kımız araması ("kimiz" veya "kımız")
      final resultsKimiz = HexpediaRepository.search('kimiz');
      expect(resultsKimiz.any((e) => e.id == 'bld_kumis_yurt'), isTrue);

      // Değirmen araması ("degirmen")
      final resultsDegirmen = HexpediaRepository.search('degirmen');
      expect(resultsDegirmen.any((e) => e.id == 'bld_windmill'), isTrue);

      // Fırın araması ("firin")
      final resultsFirin = HexpediaRepository.search('firin');
      expect(resultsFirin.any((e) => e.id == 'bld_bakery'), isTrue);

      // İngilizce arama
      final resultsBakery = HexpediaRepository.search('bakery');
      expect(resultsBakery.any((e) => e.id == 'bld_bakery'), isTrue);
    });
  });

  group('Büyük Göç (Sıfırlama) Miras Dağılım Hesaplama Testleri', () {
    test('calculateResetCrownsBreakdown doğru taç dağılımı vermeli', () {
      final tiles = [
        const HexTileModel(coord: HexAxial(0, 0), isOwned: true, hasBuilding: true, building: BuildingModel(type: BuildingType.castle, level: 6)),
        const HexTileModel(coord: HexAxial(1, 0), isOwned: true, hasBuilding: true, building: BuildingModel(type: BuildingType.corn, level: 5)),
        const HexTileModel(coord: HexAxial(0, 1), isOwned: true, hasBuilding: true, building: BuildingModel(type: BuildingType.quarry, level: 10)),
        const HexTileModel(coord: HexAxial(-1, 0), isOwned: true, hasShrine: true),
        const HexTileModel(coord: HexAxial(0, -1), isOwned: true),
      ];

      const resources = ResourcesModel(
        food: 10000,
        wood: 12000,
        stone: 5000,
      );

      final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
        tiles: tiles,
        resources: resources,
        castleLevel: 6,
      );

      // 5 Karo / 5 = 1 Hex Taç
      expect(breakdown.hexCrowns, equals(1));

      // Toplam hammadde = 27,000 -> 20,000 üzeri = 2 Resource Taç
      expect(breakdown.resourceCrowns, equals(2));

      // Binalar ve Sunaklar: 1 Sunak + (6 Otağ ~/ 2 = 3) + (15 Bina Seviyesi ~/ 15 = 1) = 5 Taç
      expect(breakdown.buildingAndShrineCrowns, equals(5));

      // Toplam = 1 + 2 + 5 = 8 Taç
      expect(breakdown.totalCrowns, equals(8));
    });

    test('calculateKutMultiplier kümülatif çarpanı doğru hesaplamalı', () {
      final kut = EconomyCalculator.calculateKutMultiplier(
        tamgas: 10,
        totalMigrations: 2,
        victoryMilestones: {'culturalBenguTas': true},
        activeOaths: ['oath_of_iron'],
      );

      // 1.0 (baz) + 0.40 (10 tamga * 0.04) + 0.10 (2 göç * 0.05) + 0.25 (1 zafer) + 0.15 (1 and) = 1.90x
      expect(kut, closeTo(1.90, 0.01));
    });
  });
}
