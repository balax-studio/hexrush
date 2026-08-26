import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/core/theme/neo_brutalist_theme.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/flame/components/hex_tile_component.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Neo-Brutalist Dynamic Theme & Title Tests', () {
    test('NeoBrutalistTheme.getTheme returns valid palettes for all 5 IDs', () {
      expect(NeoBrutalistTheme.getTheme('basalt').id, equals('basalt'));
      expect(NeoBrutalistTheme.getTheme('kurgan').id, equals('kurgan'));
      expect(NeoBrutalistTheme.getTheme('jade').id, equals('jade'));
      expect(NeoBrutalistTheme.getTheme('tengri').id, equals('tengri'));
      expect(NeoBrutalistTheme.getTheme('khagan').id, equals('khagan'));
      // Fallback for null/unknown
      expect(NeoBrutalistTheme.getTheme('unknown').id, equals('basalt'));
      expect(NeoBrutalistTheme.getTheme(null).id, equals('basalt'));
    });

    test('SettingsModel serializes and deserializes activeThemePalette and activeTitle', () {
      const original = SettingsModel(
        activeThemePalette: 'kurgan',
        activeTitle: 'conqueror',
      );

      final json = original.toJson();
      expect(json['active_theme_palette'], equals('kurgan'));
      expect(json['active_title'], equals('conqueror'));

      final deserialized = SettingsModel.fromJson(json);
      expect(deserialized.activeThemePalette, equals('kurgan'));
      expect(deserialized.activeTitle, equals('conqueror'));
    });

    test('GameStateNotifier setThemePalette updates state correctly', () {
      final notifier = GameStateNotifier();
      expect(notifier.state.settings.activeThemePalette, equals('basalt'));

      notifier.setThemePalette('jade');
      expect(notifier.state.settings.activeThemePalette, equals('jade'));
      expect(notifier.state.activeToast, contains('ALTAY YEŞİMİ'));
    });

    test('GameStateNotifier equipTitle switches title and matching palette', () {
      final notifier = GameStateNotifier();

      // 'nomad' is available by default
      final success = notifier.equipTitle('nomad');
      expect(success, isTrue);
      expect(notifier.state.settings.activeTitle, equals('nomad'));
      expect(notifier.state.settings.activeThemePalette, equals('basalt'));
    });

    test('HexTileComponent updates themePalette and renders with new palette', () {
      const tile = HexTileModel(
        coord: HexAxial(0, 0),
        biome: TileBiome.meadow,
        state: TileState.owned,
      );

      final component = HexTileComponent(
        coord: const HexAxial(0, 0),
        tileModel: tile,
        isSelected: false,
        season: 'SUMMER',
        isZud: false,
        themePalette: 'basalt',
      );

      expect(component.themePalette, equals('basalt'));

      // Update to 'jade'
      component.updateData(
        newTileModel: tile,
        newIsSelected: true,
        newSeason: 'SUMMER',
        newIsZud: false,
        newThemePalette: 'jade',
      );

      expect(component.themePalette, equals('jade'));
      expect(component.isSelected, isTrue);

      // Verify render does not crash
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      expect(() => component.render(canvas), returnsNormally);
    });
  });
}
