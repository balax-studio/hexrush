import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/steppe_lore_tree_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('5 Major Mechanics Integration & Economy Test Suite', () {
    test('1. İpek Yolu Elçi Siparişleri (Trade Orders) generation, fulfillment & 30m lock', () {
      final initialOrders = EconomyCalculator.generateInitialTradeOrders();
      expect(initialOrders.length, equals(3));
      expect(initialOrders.any((o) => o.title.contains('Bizans')), isTrue);
      expect(initialOrders.first.rewardCrowns, equals(0));
      expect(initialOrders.first.buffDurationSeconds, equals(1800)); // 30 dk (3x)
      expect(initialOrders.first.requiredResources['wood'], equals(8000.0)); // 100x

      final order = initialOrders.first;
      final notifier = GameStateNotifier();

      // Set resources high enough to fulfill 100x
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(
          food: 50000.0,
          wood: 50000.0,
          flour: 50000.0,
          plank: 50000.0,
          bread: 50000.0,
          furniture: 50000.0,
          stone: 50000.0,
          iron: 50000.0,
          fish: 50000.0,
          kumis: 50000.0,
          felt: 50000.0,
          damascusSteel: 50000.0,
          crowns: 5,
        ),
      );

      final beforeCrowns = notifier.state.resources.crowns;
      final bool success = notifier.fulfillTradeOrder(order.id);
      expect(success, isTrue);
      // Taç kazanılmamalı (0 taç)
      expect(notifier.state.resources.crowns, equals(beforeCrowns));
      // Altın Çağ hız buff'ı aktifleşmeli
      expect(notifier.state.frenzyTimer, greaterThanOrEqualTo(1800));

      // Sipariş kilitli olmalı (30 dk / 1800s bekleme)
      final fulfilledOrder = notifier.state.progression.activeTradeOrders.firstWhere((o) => o.id == order.id);
      expect(fulfilledOrder.isFulfilled, isTrue);
      expect(fulfilledOrder.isLocked(), isTrue);
      expect(fulfilledOrder.getRemainingSeconds(), greaterThan(1700));

      // Günlük 10x katlanma ve yeni sipariş testi
      final nextOrder = EconomyCalculator.generateTradeOrderForSlot(0, dailyCycleIndex: 1);
      expect(nextOrder.requiredResources['wood'], equals(80000.0)); // 10x of 8000
    });

    test('2. Orhun Bitig & Göçebe Bilgelik Ağacı (Lore Tech Tree)', () {
      final allNodes = SteppeLoreNode.defaultLoreTree;
      expect(allNodes.length, equals(12));

      final rootNode = allNodes.firstWhere((n) => n.id == 'lore_logistics_1');
      expect(rootNode.costWisdom, equals(30000.0));

      final notifier = GameStateNotifier();
      // Set wisdom to unlock
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(wisdom: 100000.0),
      );

      final bool unlockSuccess = notifier.unlockSteppeLore(rootNode.id);
      expect(unlockSuccess, isTrue);
      expect(notifier.state.progression.unlockedLoreIds.contains(rootNode.id), isTrue);
      expect(notifier.state.resources.wisdom, equals(70000.0));

      // 2. kanun açıldığında Ulu Töre Kanunu (q_lore_1) görevi otomatik senkronize olmalı
      final rootNode2 = allNodes.firstWhere((n) => n.id == 'lore_weather_1');
      notifier.unlockSteppeLore(rootNode2.id);
      final loreQuest = notifier.state.quests.firstWhere((q) => q.id == 'q_lore_1');
      expect(loreQuest.currentAmount, equals(2));
      expect(loreQuest.isCompleted, isTrue);
    });

    test('3. Lojistik Kurgan Mahzenleri (Granary Vault) radius 3 buffer bonus', () {
      final tiles = <String, HexTileModel>{
        '0,0': const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.granaryVault,
            level: 1,
          ),
        ),
      };

      // Within distance 2 -> Should receive +50% bonus
      final bonusNear = EconomyCalculator.getGranaryVaultBufferBonus(const HexAxial(1, 1), tiles);
      expect(bonusNear, equals(1.5));

      // Beyond distance 3 -> Should receive 1.0 (no bonus)
      final bonusFar = EconomyCalculator.getGranaryVaultBufferBonus(const HexAxial(5, 5), tiles);
      expect(bonusFar, equals(1.0));
    });

    test('4. İleri Bozkır Zanaatı (Advanced Converters Yields & Rates)', () {
      final tiles = <HexTileModel>[
        const HexTileModel(
          coord: HexAxial(0, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(type: BuildingType.castle, level: 1),
        ),
        const HexTileModel(
          coord: HexAxial(0, 1),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.kumisYurt,
            level: 1,
          ),
        ),
        const HexTileModel(
          coord: HexAxial(1, 0),
          biome: TileBiome.meadow,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.feltTentWorkshop,
            level: 1,
          ),
        ),
        const HexTileModel(
          coord: HexAxial(1, 1),
          biome: TileBiome.mountain,
          state: TileState.owned,
          building: BuildingModel(
            type: BuildingType.damascusForge,
            level: 1,
          ),
        ),
      ];

      final rates = EconomyCalculator.calculateNetRates(
        tiles: tiles,
        globalMultiplier: 1.0,
        seasonMultiplier: 1.0,
        shrineMultiplier: 1.0,
      );

      expect(rates.kumis, greaterThan(0));
      expect(rates.felt, greaterThan(0));
      expect(rates.damascusSteel, greaterThan(0));
    });

    test('5. Büyük Göç Sefer Diyarları (Multi-Realm Progression)', () {
      final altayMods = EconomyCalculator.getMigrationRealmModifiers('altay');
      expect(altayMods['stone_mult'], equals(2.0));
      expect(altayMods['damascus_steel_mult'], equals(2.0));

      final idilMods = EconomyCalculator.getMigrationRealmModifiers('idil');
      expect(idilMods['food_mult'], equals(2.0));
      expect(idilMods['kumis_mult'], equals(1.5));

      final karakumMods = EconomyCalculator.getMigrationRealmModifiers('karakum');
      expect(karakumMods['crowns_mult'], equals(2.0));
      expect(karakumMods['felt_mult'], equals(1.5));

      final notifier = GameStateNotifier();
      notifier.selectMigrationRealm('karakum');
      expect(notifier.state.progression.activeRealmId, equals('karakum'));
    });
  });
}
