import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/data/save_repository.dart';
import 'package:hex_rush/domain/models/ad_reward_model.dart';
import 'package:hex_rush/domain/models/game_state.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/services/ad_reward_service.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AdReward State & Persistence Tests', () {
    test('GameState holds adTracking and copyWith updates it', () {
      final initial = GameState(tiles: const {});
      expect(initial.adTracking.totalAdsWatched, 0);

      final updated = initial.copyWith(
        adTracking: initial.adTracking.recordWatch(AdRewardType.caravanBonus),
      );
      expect(updated.adTracking.totalAdsWatched, 1);
      expect(updated.adTracking.getWatchCount(AdRewardType.caravanBonus), 1);
    });

    test('SaveRepository saves and loads adTracking correctly', () async {
      final now = DateTime(2026, 8, 26, 15, 30);
      final tracking = const AdRewardTracking().recordWatch(
        AdRewardType.offlineProgressBoost,
        timestamp: now,
      );

      await SaveRepository.saveGame(
        resources: const ResourcesModel(),
        progression: const ProgressionModel(),
        season: const SeasonModel(),
        settings: const SettingsModel(),
        tiles: const [],
        adTracking: tracking,
      );

      final bundle = await SaveRepository.loadGame();
      expect(bundle, isNotNull);
      expect(bundle!.adTracking.getWatchCount(AdRewardType.offlineProgressBoost), 1);
      expect(bundle.adTracking.totalAdsWatched, 1);
    });

    test('GameStateNotifier.claimAdReward grants offline boost correctly', () async {
      final notifier = GameStateNotifier();
      final mockAdService = MockAdRewardService(shouldSucceed: true);

      // Verify claiming offline boost
      final success = await notifier.claimAdReward(
        AdRewardType.offlineProgressBoost,
        adService: mockAdService,
      );

      expect(success, true);
      expect(notifier.state.adTracking.getWatchCount(AdRewardType.offlineProgressBoost), 1);
      expect(notifier.state.activeToast, isNotNull);
    });

    test('GameStateNotifier.claimAdReward fails gracefully if ad service fails', () async {
      final notifier = GameStateNotifier();
      final mockAdService = MockAdRewardService(shouldSucceed: false);

      final success = await notifier.claimAdReward(
        AdRewardType.caravanBonus,
        adService: mockAdService,
      );

      expect(success, false);
      expect(notifier.state.adTracking.getWatchCount(AdRewardType.caravanBonus), 0);
    });
  });
}
