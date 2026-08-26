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
