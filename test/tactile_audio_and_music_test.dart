import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/audio/tactile_audio_service.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tactile Audio & Relaxing Music System Tests', () {
    test('SettingsModel properly serializes and deserializes music settings', () {
      const original = SettingsModel(
        language: 'tr',
        sfxVolume: 0.75,
        sfxMuted: false,
        musicVolume: 0.55,
        musicMuted: true,
      );

      final json = original.toJson();
      expect(json['music_volume'], 0.55);
      expect(json['music_muted'], true);

      final deserialized = SettingsModel.fromJson(json);
      expect(deserialized.musicVolume, 0.55);
      expect(deserialized.musicMuted, true);
    });

    test('TactileAudioService updates settings cleanly without errors', () {
      final service = TactileAudioService.instance;
      service.updateSettings(
        isSoundEnabled: true,
        isMusicEnabled: false,
        sfxVolume: 0.9,
        musicVolume: 0.4,
      );

      expect(service.isSoundEnabled, isTrue);
      expect(service.isMusicEnabled, isFalse);
      expect(service.sfxVolume, 0.9);
      expect(service.musicVolume, 0.4);
    });

    test('TactileAudioService play method executes without throwing across all sound types', () async {
      final service = TactileAudioService.instance;
      service.updateSettings(isSoundEnabled: true, sfxVolume: 0.8);

      for (final sound in TactileSoundType.values) {
        expect(() async => await service.play(sound), returnsNormally);
      }
    });

    test('GameStateNotifier updates music volume and mute states', () {
      final notifier = GameStateNotifier();

      expect(notifier.state.settings.musicMuted, isFalse);
      expect(notifier.state.settings.musicVolume, 0.65);

      notifier.setMusicVolume(0.85);
      expect(notifier.state.settings.musicVolume, 0.85);

      notifier.toggleMusicMute();
      expect(notifier.state.settings.musicMuted, isTrue);

      notifier.toggleMusicMute();
      expect(notifier.state.settings.musicMuted, isFalse);
    });
  });
}
