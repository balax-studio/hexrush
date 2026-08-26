import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/domain/models/steppe_lore_tree_model.dart';
import 'package:hex_rush/domain/models/trade_order_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('5 Major Mechanics Integration & Economy Test Suite', () {
    test('1. İpek Yolu Elçi Siparişleri (Trade Orders) generation and fulfillment', () {
      final initialOrders = EconomyCalculator.generateInitialTradeOrders();
      expect(initialOrders.length, equals(3));
      expect(initialOrders.any((o) => o.title.contains('Bizans')), isTrue);

      final order = initialOrders.first;
      final notifier = GameStateNotifier();

      // Set resources high enough to fulfill
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(
          food: 500.0,
          wood: 500.0,
          flour: 500.0,
          plank: 500.0,
          bread: 500.0,
          furniture: 500.0,
          stone: 500.0,
          iron: 500.0,
          fish: 500.0,
          kumis: 500.0,
          felt: 500.0,
          damascusSteel: 500.0,
          crowns: 0,
        ),
      );

      final beforeCrowns = notifier.state.resources.crowns;
      final bool success = notifier.fulfillTradeOrder(order.id);
      expect(success, isTrue);
      expect(notifier.state.resources.crowns, greaterThanOrEqualTo(beforeCrowns + order.rewardCrowns));
      expect(notifier.state.frenzyTimer, greaterThan(0));
    });

    test('2. Orhun Bitig & Göçebe Bilgelik Ağacı (Lore Tech Tree)', () {
      final allNodes = SteppeLoreNode.defaultLoreTree;
      expect(allNodes.length, equals(12));

      final rootNode = allNodes.firstWhere((n) => n.id == 'lore_logistics_1');
      expect(rootNode.costWisdom, equals(30.0));

      final notifier = GameStateNotifier();
      // Set wisdom to unlock
      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(wisdom: 200.0),
      );

      final bool unlockSuccess = notifier.unlockSteppeLore(rootNode.id);
      expect(unlockSuccess, isTrue);
      expect(notifier.state.progression.unlockedLoreIds.contains(rootNode.id), isTrue);
      expect(notifier.state.resources.wisdom, equals(170.0));
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
