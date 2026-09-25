import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/audio/tactile_audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  test('SFX audio context mixes with music without taking audio focus', () {
    final context = TactileAudioService.sfxAudioContextForTesting;

    expect(context.android.audioFocus, AndroidAudioFocus.none);
    expect(context.iOS.options, contains(AVAudioSessionOptions.mixWithOthers));
  });
}
