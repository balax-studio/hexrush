import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/game_state.dart';
import 'package:hex_rush/domain/models/game_state_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/flame/components/season_weather_particle_emitter.dart';
import 'package:hex_rush/presentation/flame/renderers/voxel_isometric_renderer.dart';
import 'package:hex_rush/presentation/providers/game_state_notifier.dart';
import 'package:hex_rush/presentation/widgets/season_transition_banner.dart';
import 'package:hex_rush/presentation/widgets/tactile_dialog_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Season Weather & Atmospheric Particle Emitter Tests', () {
    test('SeasonWeatherParticleEmitter initializes and transitions between all 4 seasons', () {
      final emitter = SeasonWeatherParticleEmitter(
        particleCount: 70,
      );

      // Advance frames in Spring
      emitter.update(0.5);

      // Transition to Summer
      emitter.setSeason('SUMMER', newIsZud: false);
      emitter.update(1.0);

      // Transition to Autumn
      emitter.setSeason('AUTUMN', newIsZud: false);
      emitter.update(1.0);

      // Transition to Winter
      emitter.setSeason('WINTER', newIsZud: false);
      emitter.update(1.0);

      // Transition to Zud Blizzard
      emitter.setSeason('WINTER', newIsZud: true);
      expect(emitter.isZud, isTrue);
      emitter.update(1.0);

      // Render onto canvas without exception
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      emitter.render(canvas);
      pictureRecorder.endRecording();
    });
  });

  group('Seasonal Foliage & Voxel Renderer Tests', () {
    test('VoxelIsometricRenderer draws trees with seasonal variations without throw', () {
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      for (final season in ['SPRING', 'SUMMER', 'AUTUMN', 'WINTER']) {
        // Standard Tree
        VoxelIsometricRenderer.drawVoxelTree(
          canvas,
          const Offset(100, 100),
          season: season,
          isZud: false,
        );

        // Birch Tree
        VoxelIsometricRenderer.drawVoxelBirchTree(
          canvas,
          const Offset(150, 150),
          season: season,
          isZud: false,
        );

        // Pine Tree
        VoxelIsometricRenderer.drawVoxelPine(
          canvas,
          const Offset(200, 200),
          season: season,
          isZud: false,
        );
      }

      // Zud Blizzard condition
      VoxelIsometricRenderer.drawVoxelTree(
        canvas,
        const Offset(100, 100),
        season: 'WINTER',
        isZud: true,
      );

      pictureRecorder.endRecording();
    });
  });

  group('SeasonTransitionBanner Widget Tests', () {
    testWidgets('SeasonTransitionBanner reacts to season changes with spring banner', (tester) async {
      final notifier = GameStateNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  SeasonTransitionBanner(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Trigger season change
      notifier.state = notifier.state.copyWith(
        season: const SeasonModel(current: 'SUMMER', isZud: false, year: 2),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SeasonTransitionBanner), findsOneWidget);
      expect(find.textContaining('YAZ'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });
  });

  group('NeoTactileDialog Route Tests', () {
    testWidgets('showNeoTactileDialog animates in with tactile spring curves', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showNeoTactileDialog<void>(
                    context: context,
                    builder: (ctx) => const AlertDialog(
                      title: Text('BAŞARILI GEÇİŞ'),
                      content: Text('SwiftUI Yaylanma Fiziği Aktif'),
                    ),
                  );
                },
                child: const Text('AÇ'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('AÇ'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('BAŞARILI GEÇİŞ'), findsOneWidget);
      expect(find.text('SwiftUI Yaylanma Fiziği Aktif'), findsOneWidget);

      // Close dialog
      await tester.tapAt(const Offset(10, 10)); // tap barrier
      await tester.pumpAndSettle();
    });
  });
}
