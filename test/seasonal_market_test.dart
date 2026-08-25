import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Seasonal Dynamic Market Economy Tests', () {
    test('EconomyCalculator.getMarketRecipes computes seasonal trade values', () {
      const resources = ResourcesModel(flour: 50.0, bread: 50.0, furniture: 50.0, iron: 50.0, stone: 50.0);

      // 1. Spring: Flour to Stone gets +25% bonus (10 Stone)
      final springRecipes = EconomyCalculator.getMarketRecipes(
        season: 'SPRING',
        resources: resources,
      );
      final springFlour = springRecipes.firstWhere((r) => r['key'] == 'flour_to_stone');
      expect(springFlour['gainStone'], equals(10.0));
      expect(springFlour['seasonTag'], contains('İLKBAHAR'));

      // 2. Winter: Bread to Iron gets +60% bonus (8 Iron)
      final winterRecipes = EconomyCalculator.getMarketRecipes(
        season: 'WINTER',
        resources: resources,
      );
      final winterBread = winterRecipes.firstWhere((r) => r['key'] == 'bread_to_iron');
      expect(winterBread['gainIron'], equals(8.0));
      expect(winterBread['seasonTag'], contains('KARA KIŞ'));

      // 3. Zud: Bread to Iron gets +100% emergency bonus (10 Iron)
      final zudRecipes = EconomyCalculator.getMarketRecipes(
        season: 'WINTER',
        isZud: true,
        resources: resources,
      );
      final zudBread = zudRecipes.firstWhere((r) => r['key'] == 'bread_to_iron');
      expect(zudBread['gainIron'], equals(10.0));
      expect(zudBread['seasonTag'], contains('ZUD BORANI'));

      // 4. Autumn: Furniture to Stone gets +40% bonus (21 Stone) & Crown discount
      final autumnRecipes = EconomyCalculator.getMarketRecipes(
        season: 'AUTUMN',
        resources: resources,
      );
      final autumnFurniture = autumnRecipes.firstWhere((r) => r['key'] == 'furniture_to_stone');
      expect(autumnFurniture['gainStone'], equals(21.0));
      expect(autumnFurniture['seasonTag'], contains('SONBAHAR'));

      final autumnCrown = autumnRecipes.firstWhere((r) => r['key'] == 'iron_stone_to_crown');
      expect(autumnCrown['costIron'], equals(20.0));
      expect(autumnCrown['seasonTag'], contains('KURULTAY'));
    });

    test('Merchant title adds +20% cumulative boost to seasonal market gains', () {
      const resources = ResourcesModel(bread: 50.0);

      // Winter Bread (8 Iron base) * 1.20 Merchant = 10 Iron
      final merchantWinterRecipes = EconomyCalculator.getMarketRecipes(
        season: 'WINTER',
        isMerchant: true,
        resources: resources,
      );
      final breadRecipe = merchantWinterRecipes.firstWhere((r) => r['key'] == 'bread_to_iron');
      expect(breadRecipe['gainIron'], equals(10.0));
    });

    test('GameStateNotifier.executeMarketTrade applies current season exchange rate', () {
      final notifier = GameStateNotifier();
      // Set to Winter with Bread
      notifier.state = notifier.state.copyWith(
        season: const SeasonModel(current: 'WINTER', year: 1),
        resources: notifier.state.resources.copyWith(bread: 20.0, iron: 0.0),
      );

      final success = notifier.executeMarketTrade('bread_to_iron');
      expect(success, isTrue);
      expect(notifier.state.resources.bread, equals(10.0));
      // In Winter, 10 Bread gives 8 Iron
      expect(notifier.state.resources.iron, equals(8.0));
      notifier.dispose();
    });
  });
}
