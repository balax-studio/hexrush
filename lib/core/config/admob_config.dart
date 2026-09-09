import 'package:flutter/foundation.dart';

/// Google AdMob Yapılandırması ve Kimlik Yönetimi
class AdMobConfig {
  AdMobConfig._();

  // Android AdMob Kimlikleri
  static const String androidAppId = 'ca-app-pub-2626843024156194~1659251897';
  static const String androidRewardedAdUnitId = 'ca-app-pub-2626843024156194/1935573746';

  // iOS (Apple) AdMob Kimlikleri
  static const String iosAppId = 'ca-app-pub-2626843024156194~3040771858';
  static const String iosRewardedAdUnitId = 'ca-app-pub-2626843024156194/1443629474';

  // Google Resmi Test Ödüllü Reklam Kimlikleri (Hesap Güvenliği için Debug'da kullanılır)
  static const String testAndroidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testIosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  /// Platforma ve derleme türüne (Debug/Release) göre doğru reklam birimini döndürür.
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';

    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    if (kDebugMode) {
      // Geliştirme/test esnasında AdMob kısıtlamalarını önlemek için test reklamları kullanılır
      if (isAndroid) return testAndroidRewardedAdUnitId;
      if (isIOS) return testIosRewardedAdUnitId;
      return '';
    }

    // Canlı / Release modunda gerçek reklam birimleri kullanılır
    if (isAndroid) return androidRewardedAdUnitId;
    if (isIOS) return iosRewardedAdUnitId;
    return '';
  }

  /// Platformun mobil reklamları destekleyip desteklemediğini kontrol eder
  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }
}
