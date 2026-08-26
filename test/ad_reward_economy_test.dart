import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';

void main() {
  group('Ad Reward Economy Calculator Tests', () {
    test('getMaxDailyWatches returns ethical non-spam limits', () {
      expect(
        EconomyCalculator.getMaxDailyWatches(AdRewardType.offlineProgressBoost),
        3,
      );
      expect(
        EconomyCalculator.getMaxDailyWatches(AdRewardType.marketQuotaReset),
        2,
      );
      expect(
        EconomyCalculator.getMaxDailyWatches(AdRewardType.caravanBonus),
        3,
      );
      expect(
        EconomyCalculator.getMaxDailyWatches(AdRewardType.celestialBlessing),
        2,
      );
      expect(
        EconomyCalculator.getMaxDailyWatches(AdRewardType.migrationLegacy),
        1,
      );
    });

    test('getAdRewardDiminishingReturn applies soft drop curve', () {
      expect(EconomyCalculator.getAdRewardDiminishingReturn(0), 1.0);
      expect(EconomyCalculator.getAdRewardDiminishingReturn(1), 0.8);
      expect(EconomyCalculator.getAdRewardDiminishingReturn(2), 0.6);
      expect(EconomyCalculator.getAdRewardDiminishingReturn(3), 0.4);
      expect(EconomyCalculator.getAdRewardDiminishingReturn(10), 0.4);
    });

    test('calculateCaravanAdBonus scales dynamically with castle level and rate', () {
      final bonusLvl1 = EconomyCalculator.calculateCaravanAdBonus(
        castleLevel: 1,
        crowns: 0,
        dailyWatches: 0,
      );

      expect(bonusLvl1['wood'], greaterThanOrEqualTo(20.0));
      expect(bonusLvl1['food'], greaterThanOrEqualTo(20.0));

      final bonusLvl5 = EconomyCalculator.calculateCaravanAdBonus(
        castleLevel: 5,
        crowns: 2,
        dailyWatches: 0,
      );
      expect(bonusLvl5['wood']!, greaterThan(bonusLvl1['wood']!));
    });

    test('calculateOfflineAdBoostedGains returns 1.5x of offline gains', () {
      const original = OfflineGainsResult(
        seconds: 3600,
        food: 50.0,
        wood: 40.0,
        stone: 20.0,
      );

      final boosted = EconomyCalculator.calculateOfflineAdBoostedGains(original);
      expect(boosted.food, 75.0);
      expect(boosted.wood, 60.0);
      expect(boosted.stone, 30.0);
      expect(boosted.seconds, 3600);
    });
  });
}
