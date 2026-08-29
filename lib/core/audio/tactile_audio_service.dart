import 'dart:io' show Platform;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

enum TactileSoundType {
  tap,
  build,
  conquer,
  harvest,
  upgrade,
  horn,
  market,
  frenzy,
  demolish,
  reward,
  seasonChange,
  stoneClick,
  error,
  warning,
}

/// HexRush Taktil Ses ve Müzik Motoru (Acoustic Archeological Steppe Audio Engine)
/// Arkeolojik Bozkır Neo-Brutalizm standartlarına uygun organik ses efektleri, dokunsal haptik ve rahatlatıcı arka plan müziği.
class TactileAudioService {
  static final TactileAudioService instance = TactileAudioService._internal();
  factory TactileAudioService() => instance;
  TactileAudioService._internal();

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isHapticsEnabled = true;
  double _sfxVolume = 0.8;
  double _musicVolume = 0.65;

  AudioPlayer? _musicPlayer;
  bool _isMusicPlaying = false;
  bool _isPluginSupported = true;

  // SFX Player Pool (Zero-GC, Düşük Gecikme, Eşzamanlı Oynatma)
  static const int _sfxPoolSize = 6;
  final List<AudioPlayer> _sfxPool = [];
  int _sfxPoolIndex = 0;
  bool _isInitialized = false;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isHapticsEnabled => _isHapticsEnabled;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Unit test ortamında plugin çağrılarını bypass et
    if (!kIsWeb) {
      try {
        if (Platform.environment.containsKey('FLUTTER_TEST') ||
            Platform.environment['FLUTTER_TEST'] == 'true') {
          _isPluginSupported = false;
          return;
        }
      } catch (_) {}
    }

    try {
      _musicPlayer = AudioPlayer();
      _musicPlayer?.setReleaseMode(ReleaseMode.loop);

      for (int i = 0; i < _sfxPoolSize; i++) {
        final player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        _sfxPool.add(player);
      }
    } catch (_) {
      _isPluginSupported = false;
    }
  }

  void updateSettings({
    bool? isSoundEnabled,
    bool? isMusicEnabled,
    bool? isHapticsEnabled,
    double? sfxVolume,
    double? musicVolume,
  }) {
    if (isSoundEnabled != null) _isSoundEnabled = isSoundEnabled;
    if (isHapticsEnabled != null) _isHapticsEnabled = isHapticsEnabled;
    if (sfxVolume != null) _sfxVolume = sfxVolume.clamp(0.0, 1.0);

    if (musicVolume != null) {
      _musicVolume = musicVolume.clamp(0.0, 1.0);
      try {
        if (_isPluginSupported) {
          _musicPlayer?.setVolume(_musicVolume);
        }
      } catch (_) {}
    }

    if (isMusicEnabled != null) {
      _isMusicEnabled = isMusicEnabled;
      if (!_isMusicEnabled) {
        pauseBackgroundMusic();
      } else {
        resumeBackgroundMusic();
      }
    }
  }

  /// Rahatlatıcı Bozkır Arka Plan Müziğini Başlatır / Döngüye Alır
  Future<void> startBackgroundMusic() async {
    init();
    if (!_isMusicEnabled || !_isPluginSupported) return;

    try {
      if (_musicPlayer != null) {
        await _musicPlayer!.setVolume(_musicVolume);
        await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer!.play(AssetSource('audio/steppe_chill_loop.wav'));
        _isMusicPlaying = true;
      }
    } catch (_) {
      _isPluginSupported = false;
    }
  }

  /// Müziği Duraklatır
  Future<void> pauseBackgroundMusic() async {
    if (!_isPluginSupported) return;
    try {
      if (_musicPlayer != null && _isMusicPlaying) {
        await _musicPlayer!.pause();
        _isMusicPlaying = false;
      }
    } catch (_) {}
  }

  /// Müziği Devam Ettirir
  Future<void> resumeBackgroundMusic() async {
    init();
    if (!_isMusicEnabled || !_isPluginSupported) return;

    try {
      if (_musicPlayer != null) {
        await _musicPlayer!.setVolume(_musicVolume);
        await _musicPlayer!.resume();
        _isMusicPlaying = true;
      } else {
        await startBackgroundMusic();
      }
    } catch (_) {
      await startBackgroundMusic();
    }
  }

  /// Organik Taktil Ses Efekti ve Haptik Geri Bildirim Oynatır
  Future<void> play(TactileSoundType type) async {
    // 1. Dokunsal Haptik Titreşim
    if (_isHapticsEnabled) {
      try {
        switch (type) {
          case TactileSoundType.tap:
          case TactileSoundType.market:
          case TactileSoundType.stoneClick:
          case TactileSoundType.harvest:
            await HapticFeedback.lightImpact();
            break;
          case TactileSoundType.build:
          case TactileSoundType.conquer:
          case TactileSoundType.demolish:
          case TactileSoundType.seasonChange:
            await HapticFeedback.mediumImpact();
            break;
          case TactileSoundType.reward:
          case TactileSoundType.upgrade:
          case TactileSoundType.horn:
          case TactileSoundType.frenzy:
            await HapticFeedback.heavyImpact();
            break;
          case TactileSoundType.error:
          case TactileSoundType.warning:
            await HapticFeedback.vibrate();
            break;
        }
      } catch (_) {
        // Test veya desteklenmeyen platformlarda güvenli atlama
      }
    }

    // 2. Ses Efekti (Organik Akustik Taktil Sesler)
    if (_isSoundEnabled && _sfxVolume > 0.0) {
      init();
      final String? assetPath = _getAssetForSoundType(type);

      if (_isPluginSupported && assetPath != null && _sfxPool.isNotEmpty) {
        try {
          final player = _sfxPool[_sfxPoolIndex];
          _sfxPoolIndex = (_sfxPoolIndex + 1) % _sfxPool.length;

          await player.setVolume(_sfxVolume);
          await player.stop();
          await player.play(AssetSource(assetPath));
          return;
        } catch (_) {
          _isPluginSupported = false;
        }
      }

      // Fallback: Standart sistem sesi
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  String? _getAssetForSoundType(TactileSoundType type) {
    switch (type) {
      case TactileSoundType.tap:
        return 'audio/tap.wav';
      case TactileSoundType.build:
        return 'audio/build.wav';
      case TactileSoundType.conquer:
        return 'audio/conquer.wav';
      case TactileSoundType.harvest:
        return 'audio/harvest.wav';
      case TactileSoundType.upgrade:
        return 'audio/upgrade.wav';
      case TactileSoundType.horn:
        return 'audio/horn.wav';
      case TactileSoundType.market:
        return 'audio/market.wav';
      case TactileSoundType.frenzy:
        return 'audio/frenzy.wav';
      case TactileSoundType.demolish:
        return 'audio/demolish.wav';
      case TactileSoundType.reward:
        return 'audio/reward.wav';
      case TactileSoundType.seasonChange:
        return 'audio/season_change.wav';
      case TactileSoundType.stoneClick:
        return 'audio/tap.wav';
      case TactileSoundType.error:
      case TactileSoundType.warning:
        return 'audio/error.wav';
    }
  }

  void dispose() {
    try {
      _musicPlayer?.dispose();
      for (final p in _sfxPool) {
        p.dispose();
      }
      _sfxPool.clear();
    } catch (_) {}
  }
}
