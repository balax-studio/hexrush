import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/caravan_route_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Kut Multiplier & Prestige Scaling Tests', () {
    test('calculateKutMultiplier returns 1.0 for initial state with 0 tamga and migrations', () {
      final kut = EconomyCalculator.calculateKutMultiplier(
        tamgas: 0,
        totalMigrations: 0,
        victoryMilestones: {},
        activeOaths: [],
      );
      expect(kut, equals(1.0));
    });

    test('calculateKutMultiplier scales smoothly with tamgas (diminishing returns, no hyper-inflation)', () {
      final kut10 = EconomyCalculator.calculateKutMultiplier(tamgas: 10, totalMigrations: 1);
      final kut50 = EconomyCalculator.calculateKutMultiplier(tamgas: 50, totalMigrations: 5);
      final kut200 = EconomyCalculator.calculateKutMultiplier(tamgas: 200, totalMigrations: 10);

      expect(kut10, greaterThan(1.0));
      expect(kut50, greaterThan(kut10));
      expect(kut200, greaterThan(kut50));
      expect(kut200, lessThan(50.0));
    });

    test('calculateKutMultiplier includes +25% per victory milestone and +15% per active oath', () {
      final baseKut = EconomyCalculator.calculateKutMultiplier(
        tamgas: 20,
        totalMigrations: 2,
        victoryMilestones: const {'culturalBenguTas': false},
        activeOaths: const [],
      );

      final withVictory = EconomyCalculator.calculateKutMultiplier(
        tamgas: 20,
        totalMigrations: 2,
        victoryMilestones: const {'culturalBenguTas': true},
        activeOaths: const [],
      );

      final withVictoryAndOath = EconomyCalculator.calculateKutMultiplier(
        tamgas: 20,
        totalMigrations: 2,
        victoryMilestones: const {'culturalBenguTas': true},
        activeOaths: const ['oath_of_iron'],
      );

      expect(withVictory, closeTo(baseKut + 0.25, 0.001));
      expect(withVictoryAndOath, closeTo(withVictory + 0.15, 0.001));
    });

    test('getGlobalMultiplier scales with kutMultiplier without creating zero/negative rates', () {
      final normal = EconomyCalculator.getGlobalMultiplier(
        castleLevel: 1,
        crowns: 0,
        kutMultiplier: 1.0,
      );
      final boosted = EconomyCalculator.getGlobalMultiplier(
        castleLevel: 1,
        crowns: 0,
        kutMultiplier: 2.5,
      );

      expect(boosted, equals(normal * 2.5));
    });
  });

  group('Endgame Victory Conditions & Verification Tests', () {
    test('checkCulturalVictoryProgress validates 500 wisdom, 100 damascus steel, and 3 lores', () {
      const resIncomplete = ResourcesModel(wisdom: 400, damascusSteel: 50);
      const resComplete = ResourcesModel(wisdom: 550, damascusSteel: 120);

      expect(
        EconomyCalculator.checkCulturalVictoryProgress(
          resources: resIncomplete,
          unlockedLoreIds: const ['lore_1', 'lore_2'],
        ),
        isFalse,
      );

      expect(
        EconomyCalculator.checkCulturalVictoryProgress(
          resources: resComplete,
          unlockedLoreIds: const ['lore_1', 'lore_2', 'lore_3'],
        ),
        isTrue,
      );
    });

    test('checkSilkRoadVictoryProgress validates 3 caravan routes, 100 kumis, and 100 felt', () {
      const res = ResourcesModel(kumis: 120, felt: 110);
      final routes = [
        const CaravanRoute(id: '1', startCoord: HexAxial(0, 0), endCoord: HexAxial(0, 1)),
        const CaravanRoute(id: '2', startCoord: HexAxial(0, 1), endCoord: HexAxial(1, 1)),
        const CaravanRoute(id: '3', startCoord: HexAxial(1, 1), endCoord: HexAxial(2, 1)),
      ];

      expect(
        EconomyCalculator.checkSilkRoadVictoryProgress(routes: routes, resources: res),
        isTrue,
      );

      expect(
        EconomyCalculator.checkSilkRoadVictoryProgress(routes: routes.take(2).toList(), resources: res),
        isFalse,
      );
    });

    test('checkRealmConquestProgress validates 20 tiles and diversity across biomes', () {
      expect(
        EconomyCalculator.checkRealmConquestProgress(
          cumulativeBiomeCounts: {'meadow': 5, 'forest': 5, 'mountain': 5},
          ownedCount: 20,
        ),
        isTrue,
      );

      expect(
        EconomyCalculator.checkRealmConquestProgress(
          cumulativeBiomeCounts: {'meadow': 18, 'forest': 1, 'mountain': 1},
          ownedCount: 20,
        ),
        isFalse,
      );
    });
  });

  group('Bottleneck & Soft-Lock Prevention Guard Tests', () {
    test('calculateAdvancedCraftingYield respects 15 units sacred reserve floor', () {
      // With low food (10 units), kumis workshop should not craft to preserve food
      const lowFoodRes = ResourcesModel(food: 10.0);
      final yieldLow = EconomyCalculator.calculateAdvancedCraftingYield(
        buildingType: BuildingType.kumisYurt,
        resources: lowFoodRes,
      );
      expect(yieldLow['consumed_food'], equals(0.0));
      expect(yieldLow['gained_kumis'], equals(0.0));

      // With sufficient food (30 units), kumis workshop crafts normally
      const highFoodRes = ResourcesModel(food: 30.0);
      final yieldHigh = EconomyCalculator.calculateAdvancedCraftingYield(
        buildingType: BuildingType.kumisYurt,
        resources: highFoodRes,
      );
      expect(yieldHigh['consumed_food'], equals(1.0));
      expect(yieldHigh['gained_kumis'], greaterThan(0.0));
    });

    test('resetGame seeds safe floor starting resources based on active realm', () {
      final notifier = GameStateNotifier();
      notifier.selectMigrationRealm('altay');

      // Add dummy tiles for migration eligibility (Otağ Sv. 5 ve 12 Karo)
      final updatedTiles = Map<HexAxial, HexTileModel>.from(notifier.state.tiles);
      for (int i = 1; i <= 11; i++) {
        final coord = HexAxial(i, 0);
        updatedTiles[coord] = HexTileModel(
          coord: coord,
          biome: TileBiome.mountain,
          state: TileState.owned,
          building: const BuildingModel(type: BuildingType.mine, level: 1),
        );
      }
      notifier.state = notifier.state.copyWith(
        tiles: updatedTiles,
        progression: notifier.state.progression.copyWith(castleLevel: 5, ownedCount: 12),
      );

      notifier.resetGame();

      // Verify safe floor starting resources in Altay realm
      expect(notifier.state.resources.food, greaterThanOrEqualTo(50.0));
      expect(notifier.state.resources.wood, greaterThanOrEqualTo(50.0));
      expect(notifier.state.resources.stone, greaterThanOrEqualTo(50.0));
      expect(notifier.state.resources.iron, greaterThanOrEqualTo(30.0));
    });
  });

  group('GameStateNotifier Victory Claim & Advanced Quests Tests', () {
    test('claimCulturalVictory consumes resources and awards Tamgas, Crowns and Kut Multiplier', () {
      final notifier = GameStateNotifier();

      notifier.state = notifier.state.copyWith(
        resources: notifier.state.resources.copyWith(
          wisdom: 600.0,
          damascusSteel: 150.0,
        ),
        progression: notifier.state.progression.copyWith(
          unlockedLoreIds: ['lore_1', 'lore_2', 'lore_3'],
        ),
      );

      final success = notifier.claimCulturalVictory();
      expect(success, isTrue);
      expect(notifier.state.progression.victoryMilestones['culturalBenguTas'], isTrue);
      expect(notifier.state.resources.tamgas, greaterThanOrEqualTo(10));
      expect(notifier.state.resources.crowns, greaterThanOrEqualTo(15));
      expect(notifier.state.progression.kutMultiplier, greaterThan(1.2));
    });

    test('advanced quest types (caravan, lore, damascus) are included in initial quests', () {
      final notifier = GameStateNotifier();
      final quests = notifier.state.quests;

      expect(quests.any((q) => q.id == 'q_runic_1'), isTrue);
      expect(quests.any((q) => q.id == 'q_caravan_1'), isTrue);
      expect(quests.any((q) => q.id == 'q_damascus_1'), isTrue);
    });

    test('toggleOath toggles oath in activeOaths and recalculates kutMultiplier', () {
      final notifier = GameStateNotifier();
      expect(notifier.state.progression.activeOaths.contains('oath_of_iron'), isFalse);

      notifier.toggleOath('oath_of_iron');
      expect(notifier.state.progression.activeOaths.contains('oath_of_iron'), isTrue);
      expect(notifier.state.progression.kutMultiplier, greaterThan(1.1));

      notifier.toggleOath('oath_of_iron');
      expect(notifier.state.progression.activeOaths.contains('oath_of_iron'), isFalse);
    });

    test('building unlock tiers scale progressively across 1, 2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50', () {
      expect(BuildingType.corn.requiredCastleLevel, equals(1));
      expect(BuildingType.granaryVault.requiredCastleLevel, equals(2));
      expect(BuildingType.windmill.requiredCastleLevel, equals(5));
      expect(BuildingType.runicStele.requiredCastleLevel, equals(5));
      expect(BuildingType.orchard.requiredCastleLevel, equals(10));
      expect(BuildingType.mine.requiredCastleLevel, equals(15));
      expect(BuildingType.bakery.requiredCastleLevel, equals(15));
      expect(BuildingType.feltTentWorkshop.requiredCastleLevel, equals(20));
      expect(BuildingType.caravanserai.requiredCastleLevel, equals(25));
      expect(BuildingType.kumisYurt.requiredCastleLevel, equals(30));
      expect(BuildingType.permafrostDig.requiredCastleLevel, equals(35));
      expect(BuildingType.damascusForge.requiredCastleLevel, equals(40));
      expect(BuildingType.astrolabe.requiredCastleLevel, equals(45));
      expect(BuildingType.celestialAnvil.requiredCastleLevel, equals(50));
    });

    test('initial state guarantees forest and mountain in radius 1 to prevent resource soft-lock', () {
      final notifier = GameStateNotifier();
      final tiles = notifier.state.tiles;

      final adjacentTiles = const HexAxial(0, 0).neighbors.map((c) => tiles[c]).whereType<HexTileModel>().toList();
      expect(adjacentTiles.any((t) => t.biome == TileBiome.forest), isTrue);
      expect(adjacentTiles.any((t) => t.biome == TileBiome.mountain), isTrue);
      expect(adjacentTiles.any((t) => t.biome == TileBiome.meadow), isTrue);
    });
  });
}
