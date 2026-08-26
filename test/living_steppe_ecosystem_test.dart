import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/presentation/flame/renderers/voxel_isometric_renderer.dart';
import 'package:hex_rush/presentation/flame/components/steppe_messenger_component.dart';

void main() {
  group('Living Steppe Ecosystem Tests', () {
    test('Global Steppe Wind Wave returns bounded values across space and time', () {
      for (double t = 0.0; t < 10.0; t += 0.5) {
        for (int q = -5; q <= 5; q++) {
          for (int r = -5; r <= 5; r++) {
            final double wave = VoxelIsometricRenderer.getSteppeWindWave(t, q, r);
            expect(wave, greaterThanOrEqualTo(-1.0));
            expect(wave, lessThanOrEqualTo(1.0));
          }
        }
      }
    });

    test('Steppe Wind Wave produces procedural phase difference between adjacent coordinates', () {
      const double t = 2.5;
      final double waveCenter = VoxelIsometricRenderer.getSteppeWindWave(t, 0, 0);
      final double waveEast = VoxelIsometricRenderer.getSteppeWindWave(t, 1, 0);
      final double waveNorth = VoxelIsometricRenderer.getSteppeWindWave(t, 0, 1);

      // Komşu karolar aynı anda aynı genliğe sahip olamaz (senkronize rüzgar yasağı)
      expect(waveCenter, isNot(equals(waveEast)));
      expect(waveCenter, isNot(equals(waveNorth)));
    });

    test('Living Steppe Canvas rendering methods execute cleanly without throwing', () {
      final PictureRecorder recorder = PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // 1. Duman Pufu
      VoxelIsometricRenderer.drawVoxelSmokePlume(
        canvas,
        const Offset(100, 100),
        animTime: 1.5,
        seed: 42,
        windWave: 0.5,
        scale: 1.0,
      );

      // 2. Gece Ocak Kor Parıltısı
      VoxelIsometricRenderer.drawVoxelHearthFirelight(
        canvas,
        const Offset(100, 100),
        animTime: 2.0,
        seed: 13,
        radius: 12.0,
      );

      // 3. Dokunsal Su Dalgası Halkaları
      VoxelIsometricRenderer.drawVoxelWaterRipple(
        canvas,
        const Offset(100, 100),
        progress: 0.5,
      );

      // 4. Orman Dokunma Yaprak Savrulması
      VoxelIsometricRenderer.drawVoxelLeafScatter(
        canvas,
        const Offset(100, 100),
        progress: 0.4,
        seed: 7,
      );

      // 5. Çöl Serabı
      VoxelIsometricRenderer.drawVoxelDesertHeatShimmer(
        canvas,
        const Offset(100, 100),
        animTime: 3.0,
        seed: 19,
      );

      // 6. Dağ Zirvesi Toz Kar Sürgünü
      VoxelIsometricRenderer.drawVoxelSnowDrift(
        canvas,
        const Offset(100, 100),
        animTime: 4.0,
        windWave: 0.8,
        seed: 31,
      );

      // 7. Gayzer Buhar Pufu
      VoxelIsometricRenderer.drawVoxelGeyserBurst(
        canvas,
        const Offset(100, 100),
        animTime: 1.2,
        seed: 23,
      );

      // 8. Bozkır Yuvarlanan Çalı (Tumbleweed)
      VoxelIsometricRenderer.drawVoxelTumbleweed(
        canvas,
        const Offset(100, 100),
        animTime: 2.1,
        seed: 11,
        windWave: 0.4,
      );

      // 9. At Dokunma İrkintisi & Sırt Kuşu
      VoxelIsometricRenderer.drawVoxelHorse(
        canvas,
        const Offset(100, 100),
        animTime: 1.0,
        scale: 1.0,
        seed: 8, // pose = 2 (kuşlu)
        startleProgress: 0.5,
      );

      final Picture picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('SteppeMessengerComponent initializes and updates without errors', () {
      final messenger = SteppeMessengerComponent();
      expect(messenger.priority, equals(160));

      // Simüle güncelleme döngüsü
      messenger.update(1.0);
      messenger.update(15.0);
      expect(messenger, isNotNull);
    });
  });
}
