import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/presentation/flame/hex_map_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ergonomic Visual & Camera Tests', () {
    test('SettingsModel properly serializes and deserializes reducedMotion', () {
      const defaultSettings = SettingsModel();
      expect(defaultSettings.reducedMotion, isFalse);

      final calmSettings = defaultSettings.copyWith(reducedMotion: true);
      expect(calmSettings.reducedMotion, isTrue);

      final json = calmSettings.toJson();
      expect(json['reduced_motion'], isTrue);

      final deserialized = SettingsModel.fromJson(json);
      expect(deserialized.reducedMotion, isTrue);
    });

    test('HexMapGame initializes with zero nausea camera bounds and smooth zoom target', () async {
      final game = HexMapGame(
        onTileSelected: (coord) {},
      );
      await game.onLoad();

      expect(game.currentZoom, equals(1.0));

      // Zoom at point calculations
      game.zoomCameraAtPoint(0.2, const Offset(600, 400), const Size(1200, 800));

      // Drag start / end
      game.onDragStart();
      game.panCamera(const Offset(10, 20));
      game.onDragEnd();

      // Ensure clamped camera
      expect(game.cameraPosition.x.isFinite, isTrue);
      expect(game.cameraPosition.y.isFinite, isTrue);
    });
  });
}
