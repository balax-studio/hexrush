import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/admob_config.dart';
import '../models/ad_reward_model.dart';

abstract class IAdRewardService {
  Future<bool> showRewardedAd(AdRewardType type);
  bool isAdAvailable(AdRewardType type);
}

class MockAdRewardService implements IAdRewardService {
  final bool shouldSucceed;
  final List<AdRewardType> adHistory = [];

  MockAdRewardService({this.shouldSucceed = true});

  @override
  bool isAdAvailable(AdRewardType type) => true;

  @override
  Future<bool> showRewardedAd(AdRewardType type) async {
    if (shouldSucceed) {
      adHistory.add(type);
      return true;
    }
    return false;
  }
}

/// Google AdMob Ödüllü Reklam Entegrasyon Servisi
class GoogleMobileAdsRewardService implements IAdRewardService {
  static final GoogleMobileAdsRewardService instance = GoogleMobileAdsRewardService._internal();

  GoogleMobileAdsRewardService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// Reklamı önceden belleğe yükler
  void preloadAd() {
    if (!AdMobConfig.isSupportedPlatform || _isLoading || _rewardedAd != null) {
      return;
    }

    final adUnitId = AdMobConfig.rewardedAdUnitId;
    if (adUnitId.isEmpty) return;

    _isLoading = true;
    try {
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoading = false;
          },
        ),
      );
    } catch (_) {
      _isLoading = false;
    }
  }

  @override
  bool isAdAvailable(AdRewardType type) {
    if (!AdMobConfig.isSupportedPlatform) return true;
    return _rewardedAd != null;
  }

  @override
  Future<bool> showRewardedAd(AdRewardType type) async {
    if (!AdMobConfig.isSupportedPlatform) {
      return true;
    }

    if (_rewardedAd == null) {
      preloadAd();
      return false;
    }

    final completer = Completer<bool>();
    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        preloadAd();
        if (!completer.isCompleted) {
          completer.complete(userEarnedReward);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        preloadAd();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (adWithoutView, reward) {
          userEarnedReward = true;
        },
      );
    } catch (_) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }
}

/// Reklam Servisi Fabrikası
class AdRewardServiceFactory {
  static IAdRewardService? _overrideService;

  static void setOverrideService(IAdRewardService? service) {
    _overrideService = service;
  }

  static IAdRewardService get defaultService {
    if (_overrideService != null) return _overrideService!;
    if (AdMobConfig.isSupportedPlatform) {
      return GoogleMobileAdsRewardService.instance;
    }
    return MockAdRewardService();
  }
}
