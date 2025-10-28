import 'dart:io';

/// AdMob Configuration
/// Replace test IDs with your real AdMob IDs
class AdMobConfig {
  // ============================================
  // 🔴 REPLACE THESE WITH YOUR REAL ADMOB IDS
  // ============================================

  /// Android Rewarded Ad ID
  /// Get from: https://apps.admob.com/
  static const String _androidRewardedAdId = 'ca-app-pub-3940256099942544/5224354917'; // TEST ID

  /// iOS Rewarded Ad ID
  /// Get from: https://apps.admob.com/
  static const String _iOSRewardedAdId = 'ca-app-pub-3940256099942544/1712485313'; // TEST ID

  // ============================================
  // Don't modify below this line
  // ============================================

  /// Get Rewarded Ad ID based on platform
  static String get rewardedAdId {
    if (Platform.isAndroid) {
      return _androidRewardedAdId;
    } else if (Platform.isIOS) {
      return _iOSRewardedAdId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Check if using test IDs
  static bool get isUsingTestIds {
    return _androidRewardedAdId.contains('3940256099942544');
  }
}