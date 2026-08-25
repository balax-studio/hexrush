import 'package:flutter/services.dart';

enum TactileSoundType {
  tap,
  build,
  conquer,
  reward,
  upgrade,
  market,
  error,
}

/// HexRush Taktil Ses ve Haptik Motoru
/// Arkeolojik Bozkır Neo-Brutalizm standartlarına uygun organik sesler ve dokunsal geri bildirimler.
class TactileAudioService {
  static final TactileAudioService instance = TactileAudioService._internal();
  factory TactileAudioService() => instance;
  TactileAudioService._internal();

  bool _isSoundEnabled = true;
  bool _isHapticsEnabled = true;

  void updateSettings({bool? isSoundEnabled, bool? isHapticsEnabled}) {
    if (isSoundEnabled != null) _isSoundEnabled = isSoundEnabled;
    if (isHapticsEnabled != null) _isHapticsEnabled = isHapticsEnabled;
  }

  /// Taktil Geri Bildirim Oynatır
  Future<void> play(TactileSoundType type) async {
    // 1. Dokunsal Haptik Titreşim
    if (_isHapticsEnabled) {
      try {
        switch (type) {
          case TactileSoundType.tap:
          case TactileSoundType.market:
            await HapticFeedback.lightImpact();
            break;
          case TactileSoundType.build:
          case TactileSoundType.conquer:
            await HapticFeedback.mediumImpact();
            break;
          case TactileSoundType.reward:
          case TactileSoundType.upgrade:
            await HapticFeedback.heavyImpact();
            break;
          case TactileSoundType.error:
            await HapticFeedback.vibrate();
            break;
        }
      } catch (_) {
        // Test veya desteklenmeyen platformlarda güvenli atlama
      }
    }

    // 2. Ses Efekti (Organik Taktil Klik/Geri Bildirim)
    if (_isSoundEnabled) {
      try {
        switch (type) {
          case TactileSoundType.tap:
          case TactileSoundType.build:
          case TactileSoundType.conquer:
          case TactileSoundType.reward:
          case TactileSoundType.upgrade:
          case TactileSoundType.market:
          case TactileSoundType.error:
            await SystemSound.play(SystemSoundType.click);
            break;
        }
      } catch (_) {
        // Platform ses sağlayıcısı hatasız sessizce devam eder
      }
    }
  }

  void dispose() {}
}
