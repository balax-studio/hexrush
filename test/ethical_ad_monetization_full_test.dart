import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/data/save_repository.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Ethical Ad Monetization End-to-End Suite', () {
    test('All ad reward types have valid daily limits and soft diminishing curves', () {
      for (final type in AdRewardType.values) {
        final maxWatches = EconomyCalculator.getMaxDailyWatches(type);
        expect(maxWatches, greaterThan(0));
        expect(maxWatches, lessThanOrEqualTo(4)); // Ethical non-spam constraint
      }

      // Verify soft diminishing returns
      expect(EconomyCalculator.getAdRewardDiminishingReturn(0), 1.0);
      expect(EconomyCalculator.getAdRewardDiminishingReturn(1), 0.8);
      expect(EconomyCalculator.getAdRewardDiminishingReturn(2), 0.6);
      expect(EconomyCalculator.getAdRewardDiminishingReturn(3), 0.4);
    });

    test('Full lifecycle: Watch ads -> Enforce daily limits -> Persist to save -> Next day reset', () async {
      final notifier = GameStateNotifier();
      final mockService = MockAdRewardService(shouldSucceed: true);

      // 1. Caravan bonus watch 1
      final w1 = await notifier.claimAdReward(AdRewardType.caravanBonus, adService: mockService);
      expect(w1, true);
      expect(notifier.state.adTracking.getWatchCount(AdRewardType.caravanBonus), 1);

      // 2. Caravan bonus watch 2
      final w2 = await notifier.claimAdReward(AdRewardType.caravanBonus, adService: mockService);
      expect(w2, true);
      expect(notifier.state.adTracking.getWatchCount(AdRewardType.caravanBonus), 2);

      // 3. Caravan bonus watch 3 (Max limit = 3)
      final w3 = await notifier.claimAdReward(AdRewardType.caravanBonus, adService: mockService);
      expect(w3, true);
      expect(notifier.state.adTracking.getWatchCount(AdRewardType.caravanBonus), 3);

      // 4. Caravan bonus watch 4 (Should be blocked ethically)
      final w4 = await notifier.claimAdReward(AdRewardType.caravanBonus, adService: mockService);
      expect(w4, false);
      expect(notifier.state.adTracking.getWatchCount(AdRewardType.caravanBonus), 3);
      expect(notifier.state.activeToast, contains('azami bereket sınırına ulaşıldı'));

      // 5. Verify save persistence
      final savedBundle = await SaveRepository.loadGame();
      expect(savedBundle, isNotNull);
      expect(savedBundle!.adTracking.getWatchCount(AdRewardType.caravanBonus), 3);

      // 6. Next day reset simulation
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final resetTracking = savedBundle.adTracking.checkDailyReset(currentDate: tomorrow);
      expect(resetTracking.getWatchCount(AdRewardType.caravanBonus), 0);
    });

    test('Celestial Blessing boosts shrineMultiplier and stays within ethical limits', () async {
      final notifier = GameStateNotifier();
      final mockService = MockAdRewardService(shouldSucceed: true);
      final initialMultiplier = notifier.state.shrineMultiplier;

      final success = await notifier.claimAdReward(AdRewardType.celestialBlessing, adService: mockService);
      expect(success, true);
      expect(notifier.state.shrineMultiplier, greaterThan(initialMultiplier));
    });

    test('Migration Legacy increments permanent tamgas', () async {
      final notifier = GameStateNotifier();
      final mockService = MockAdRewardService(shouldSucceed: true);
      final initialTamgas = notifier.state.resources.tamgas;

      final success = await notifier.claimAdReward(AdRewardType.migrationLegacy, adService: mockService);
      expect(success, true);
      expect(notifier.state.resources.tamgas, initialTamgas + 1);
    });
  });
}
