import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/config/admob_config.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';

void main() {
  group('AdMob Integration & Configuration Tests', () {
    test('verifies production Android and iOS AdMob IDs match user credentials', () {
      // Android
      expect(AdMobConfig.androidAppId, 'ca-app-pub-2626843024156194~1659251897');
      expect(AdMobConfig.androidRewardedAdUnitId, 'ca-app-pub-2626843024156194/1935573746');

      // iOS
      expect(AdMobConfig.iosAppId, 'ca-app-pub-2626843024156194~3040771858');
      expect(AdMobConfig.iosRewardedAdUnitId, 'ca-app-pub-2626843024156194/1443629474');
    });

    test('verifies Google official test rewarded ad IDs are present for development', () {
      expect(AdMobConfig.testAndroidRewardedAdUnitId, 'ca-app-pub-3940256099942544/5224354917');
      expect(AdMobConfig.testIosRewardedAdUnitId, 'ca-app-pub-3940256099942544/1712485313');
    });

    test('verifies AdRewardServiceFactory returns a valid service and supports override', () async {
      final defaultService = AdRewardServiceFactory.defaultService;
      expect(defaultService, isNotNull);

      final mockService = MockAdRewardService();
      AdRewardServiceFactory.setOverrideService(mockService);
      expect(AdRewardServiceFactory.defaultService, same(mockService));

      final success = await AdRewardServiceFactory.defaultService.showRewardedAd(AdRewardType.offlineProgressBoost);
      expect(success, isTrue);

      // Reset override
      AdRewardServiceFactory.setOverrideService(null);
    });
  });
}
