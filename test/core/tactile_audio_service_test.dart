import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/audio/tactile_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SFX audio context mixes with music without taking audio focus', () {
    final context = TactileAudioService.sfxAudioContextForTesting;

    expect(context.android.audioFocus, AndroidAudioFocus.none);
    expect(context.iOS.options, contains(AVAudioSessionOptions.mixWithOthers));
  });

  test('music starts even if one SFX player fails to initialize', () async {
    final originalPlatform = AudioplayersPlatformInterface.instance;
    final originalGlobalPlatform = GlobalAudioplayersPlatformInterface.instance;
    final originalAudioCache = AudioCache.instance;
    final platform = _FailingSfxAudioPlatform();
    AudioplayersPlatformInterface.instance = platform;
    GlobalAudioplayersPlatformInterface.instance = _TestGlobalAudioPlatform();
    AudioCache.instance = _TestAudioCache();
    final service = TactileAudioService.forTesting();

    addTearDown(() async {
      service.dispose();
      await Future<void>.delayed(Duration.zero);
      AudioplayersPlatformInterface.instance = originalPlatform;
      GlobalAudioplayersPlatformInterface.instance = originalGlobalPlatform;
      AudioCache.instance = originalAudioCache;
    });

    service.updateSettings(isMusicEnabled: true);
    await service.startBackgroundMusic();
    await service.play(TactileSoundType.tap);

    expect(platform.failedSfxInitialization, isTrue);
    expect(platform.resumeCallsBeforeSource, 0);
    expect(platform.musicSourceLoads, 1);
  });
}

class _TestAudioCache extends AudioCache {
  @override
  Future<String> loadPath(String fileName) async => '/test/assets/$fileName';
}

class _FailingSfxAudioPlatform implements AudioplayersPlatformInterface {
  final Map<String, StreamController<AudioEvent>> _events = {};
  final Set<String> _sources = {};
  var _failedSfxInitialization = false;
  var musicSourceLoads = 0;
  var resumeCallsBeforeSource = 0;

  bool get failedSfxInitialization => _failedSfxInitialization;

  @override
  Future<void> create(String playerId) async {}

  @override
  Stream<AudioEvent> getEventStream(String playerId) => _events
      .putIfAbsent(
        playerId,
        () => StreamController<AudioEvent>.broadcast(sync: true),
      )
      .stream;

  @override
  Future<void> dispose(String playerId) async {}

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {
    if (!_failedSfxInitialization && releaseMode == ReleaseMode.stop) {
      _failedSfxInitialization = true;
      throw PlatformException(code: 'transient_sfx_initialization_failure');
    }
  }

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
    String? mimeType,
  }) async {
    _sources.add(playerId);
    if (url.contains('steppe_chill_loop.mp3')) musicSourceLoads++;
    _events[playerId]?.add(
      const AudioEvent(eventType: AudioEventType.prepared, isPrepared: true),
    );
  }

  @override
  Future<void> setAudioContext(String playerId, AudioContext context) async {}

  @override
  Future<void> resume(String playerId) async {
    if (!_sources.contains(playerId)) resumeCallsBeforeSource++;
  }

  @override
  Future<void> pause(String playerId) async {}

  @override
  Future<void> stop(String playerId) async {}

  @override
  Future<void> release(String playerId) async {}

  @override
  Future<void> setVolume(String playerId, double volume) async {}

  @override
  Future<int?> getCurrentPosition(String playerId) async => 0;

  @override
  Future<int?> getDuration(String playerId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestGlobalAudioPlatform implements GlobalAudioplayersPlatformInterface {
  @override
  Future<void> init() async {}

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {}

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() => const Stream.empty();

  @override
  Future<void> emitGlobalLog(String message) async {}

  @override
  Future<void> emitGlobalError(String code, String message) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
