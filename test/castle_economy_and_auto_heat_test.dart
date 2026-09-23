import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';

void main() {
  group('Castle Dynamic Multi-Resource Economy Tests', () {
    test('Level 1 -> 2 requires only food', () {
      final costs = EconomyCalculator.getCastleUpgradeCost(2);
      expect(costs['food'], equals(50.0));
      expect(costs.containsKey('wood'), isFalse);
      expect(costs.containsKey('stone'), isFalse);

      const resInsufficient = ResourcesModel(food: 40.0);
      expect(EconomyCalculator.canAffordCastleUpgrade(resInsufficient, 2), isFalse);

      const resSufficient = ResourcesModel(food: 50.0);
      expect(EconomyCalculator.canAffordCastleUpgrade(resSufficient, 2), isTrue);

      final deducted = EconomyCalculator.deductCastleUpgradeCost(resSufficient, 2);
      expect(deducted.food, equals(0.0));
    });

    test('Level 2 -> 3 requires food and wood', () {
      final costs = EconomyCalculator.getCastleUpgradeCost(3);
      expect(costs['food'], equals(75.0));
      expect(costs['wood'], equals(25.0));
      expect(costs.containsKey('stone'), isFalse);

      const resNoWood = ResourcesModel(food: 100.0, wood: 10.0);
      expect(EconomyCalculator.canAffordCastleUpgrade(resNoWood, 3), isFalse);

      const resWithWood = ResourcesModel(food: 75.0, wood: 25.0);
      expect(EconomyCalculator.canAffordCastleUpgrade(resWithWood, 3), isTrue);

      final deducted = EconomyCalculator.deductCastleUpgradeCost(resWithWood, 3);
      expect(deducted.food, equals(0.0));
      expect(deducted.wood, equals(0.0));
    });

    test('Level 5 -> 6 requires stone, flour, plank, wisdom', () {
      final costs = EconomyCalculator.getCastleUpgradeCost(6);
      expect(costs['food']! > 0, isTrue);
      expect(costs['wood']! > 0, isTrue);
      expect(costs['stone'], equals(20.0));
      expect(costs['flour'], equals(15.0));
      expect(costs['plank'], equals(15.0));
      expect(costs['wisdom'], equals(10.0));
      expect(costs.containsKey('iron'), isFalse);
    });

    test('Level 15 -> 16 requires iron, bread, fish', () {
      final costs = EconomyCalculator.getCastleUpgradeCost(16);
      expect(costs['iron'], equals(15.0));
      expect(costs['bread'], equals(15.0));
      expect(costs['fish'], equals(20.0));
    });
  });

  group('Winter Warm & Auto-Heat Wood Consumption Tests', () {
    test('Winter warm wood cost returns 5.0 base', () {
      final cost = EconomyCalculator.getWinterWarmWoodCost([]);
      expect(cost, equals(5.0));
    });

    test('getHeatingWoodConsumptionRate scales with level and applies discounts', () {
      final lvl1 = EconomyCalculator.getHeatingWoodConsumptionRate(buildingLevel: 1);
      final lvl5 = EconomyCalculator.getHeatingWoodConsumptionRate(buildingLevel: 5);
      final lvl10 = EconomyCalculator.getHeatingWoodConsumptionRate(buildingLevel: 10);

      expect(lvl1, closeTo(0.10, 0.001));
      expect(lvl5, closeTo(0.18, 0.001));
      expect(lvl10, closeTo(0.28, 0.001));
      expect(lvl5 > lvl1, isTrue);
      expect(lvl10 > lvl5, isTrue);
    });

    test('Warmed tile maintains positive production in winter/zud', () {
      final unWarmedMult = EconomyCalculator.getSeasonProductionMultiplier(
        season: 'WINTER',
        isZud: true,
        isTileWarmed: false,
      );
      final warmedMult = EconomyCalculator.getSeasonProductionMultiplier(
        season: 'WINTER',
        isZud: true,
        isTileWarmed: true,
      );

      expect(unWarmedMult, equals(0.60));
      expect(warmedMult, equals(1.50));
      expect(warmedMult > unWarmedMult, isTrue);
    });
  });
}
