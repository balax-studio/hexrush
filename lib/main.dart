import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'core/config/admob_config.dart';
import 'core/graphics/hex_shader_service.dart';
import 'domain/services/ad_reward_service.dart';
import 'presentation/screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HexShaderService.initialize();

  if (AdMobConfig.isSupportedPlatform) {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
      await MobileAds.instance.initialize();
      GoogleMobileAdsRewardService.instance.preloadAd();
    } catch (_) {}
  }

  runApp(
    const ProviderScope(
      child: HexRushApp(),
    ),
  );
}

class HexRushApp extends StatelessWidget {
  const HexRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HexRush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFFFD54F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD54F),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
