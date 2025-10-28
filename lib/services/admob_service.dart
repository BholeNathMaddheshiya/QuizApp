import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

class AdMobService {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  /// Load rewarded ad
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Rewarded Ad loaded successfully');
          _rewardedAd = ad;
          _isAdLoaded = true;

          // Set full screen content callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print('❌ Ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('❌ Failed to load rewarded ad: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Show rewarded ad and handle reward
  Future<bool> showRewardedAd() async {
    if (_rewardedAd != null && _isAdLoaded) {
      bool adWatched = false;

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎁 User earned reward: ${reward.amount} ${reward.type}');
          adWatched = true;
        },
      );

      return adWatched;
    } else {
      print('⚠️ Rewarded ad not ready yet');
      return false;
    }
  }

  /// Check if ad is loaded
  bool get isAdLoaded => _isAdLoaded;

  /// Dispose ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}