import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';

void main() {
  group('AdRewardModel & AdRewardTracking Tests', () {
    test('AdRewardTracking default constructor has zero counts', () {
      const tracking = AdRewardTracking();
      expect(tracking.dailyWatches[AdRewardType.offlineProgressBoost], 0);
      expect(tracking.dailyWatches[AdRewardType.marketQuotaReset], 0);
      expect(tracking.dailyWatches[AdRewardType.caravanBonus], 0);
      expect(tracking.dailyWatches[AdRewardType.celestialBlessing], 0);
      expect(tracking.dailyWatches[AdRewardType.migrationLegacy], 0);
      expect(tracking.totalAdsWatched, 0);
    });

    test('AdRewardTracking recordWatch increments count and updates lastWatchTime', () {
      final now = DateTime(2026, 8, 26, 12, 0);
      const tracking = AdRewardTracking();
      final updated = tracking.recordWatch(AdRewardType.offlineProgressBoost, timestamp: now);

      expect(updated.getWatchCount(AdRewardType.offlineProgressBoost), 1);
      expect(updated.totalAdsWatched, 1);
      expect(updated.lastWatchTimes[AdRewardType.offlineProgressBoost], now);
    });

    test('AdRewardTracking resets on new day', () {
      final day1 = DateTime(2026, 8, 25, 12, 0);
      final day2 = DateTime(2026, 8, 26, 8, 0);

      var tracking = const AdRewardTracking();
      tracking = tracking.recordWatch(AdRewardType.marketQuotaReset, timestamp: day1);
      expect(tracking.getWatchCount(AdRewardType.marketQuotaReset), 1);

      final checked = tracking.checkDailyReset(currentDate: day2);
      expect(checked.getWatchCount(AdRewardType.marketQuotaReset), 0);
      expect(checked.lastResetDate.day, 26);
    });

    test('AdRewardTracking json serialization roundtrip', () {
      final now = DateTime(2026, 8, 26, 12, 0);
      final tracking = const AdRewardTracking().recordWatch(
        AdRewardType.caravanBonus,
        timestamp: now,
      );

      final json = tracking.toJson();
      final restored = AdRewardTracking.fromJson(json);

      expect(restored.getWatchCount(AdRewardType.caravanBonus), 1);
      expect(restored.totalAdsWatched, 1);
    });
  });

  group('MockAdRewardService Tests', () {
    test('MockAdRewardService returns success and records callback', () async {
      final service = MockAdRewardService(shouldSucceed: true);
      expect(service.isAdAvailable(AdRewardType.offlineProgressBoost), true);

      final result = await service.showRewardedAd(AdRewardType.offlineProgressBoost);
      expect(result, true);
      expect(service.adHistory.length, 1);
      expect(service.adHistory.first, AdRewardType.offlineProgressBoost);
    });

    test('MockAdRewardService simulates network failure when configured', () async {
      final service = MockAdRewardService(shouldSucceed: false);
      final result = await service.showRewardedAd(AdRewardType.marketQuotaReset);
      expect(result, false);
    });
  });
}
