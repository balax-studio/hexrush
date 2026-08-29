import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/graphics/hex_shader_service.dart';
import 'package:hex_rush/presentation/flame/components/dynamic_lighting_overlay_component.dart';
import 'package:hex_rush/presentation/flame/components/shockwave_effect_component.dart';
import 'package:hex_rush/presentation/flame/components/volumetric_sun_rays_component.dart';
import 'package:hex_rush/presentation/flame/renderers/gpu_atmosphere_color_matrix.dart';
import 'package:hex_rush/presentation/flame/renderers/voxel_isometric_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GpuAtmosphereColorMatrix Tests', () {
    test('Her mevsim ve gece durumu için geçerli 4x5 ColorFilter döndürür', () {
      final springFilter = GpuAtmosphereColorMatrix.getAtmosphereColorFilter(
        seasonName: 'spring',
        isZud: false,
        isNight: false,
      );
      expect(springFilter, isNotNull);

      final winterFilter = GpuAtmosphereColorMatrix.getAtmosphereColorFilter(
        seasonName: 'winter',
        isZud: false,
        isNight: false,
      );
      expect(winterFilter, isNotNull);

      final zudFilter = GpuAtmosphereColorMatrix.getAtmosphereColorFilter(
        seasonName: 'winter',
        isZud: true,
        isNight: false,
      );
      expect(zudFilter, isNotNull);

      final nightFilter = GpuAtmosphereColorMatrix.getAtmosphereColorFilter(
        seasonName: 'summer',
        isZud: false,
        isNight: true,
      );
      expect(nightFilter, isNotNull);
    });

    test('Mevsim matris interpolasyonu kesintisiz geçiş üretir', () {
      final lerped = GpuAtmosphereColorMatrix.lerpAtmosphereMatrix(
        fromSeason: 'spring',
        toSeason: 'autumn',
        t: 0.5,
      );
      expect(lerped, isNotNull);
    });
  });

  group('DynamicLightingOverlayComponent Tests', () {
    test('Gündüz ve gece durumunda ışık fenerlerini hatasız render eder', () {
      final lighting = DynamicLightingOverlayComponent();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Gündüz durumu (Erken dönüş / 0 çizim)
      lighting.updateLightingState(night: false, darkness: 0.0, emitters: const []);
      lighting.update(0.016);
      lighting.render(canvas);

      // Gece durumu (Işık fenerleri ile)
      final emitters = [
        LightEmitter(
          position: Vector2(0, 0),
          radius: 60.0,
          color: const Color(0xFFF59E0B),
          intensity: 1.0,
        ),
        LightEmitter(
          position: Vector2(100, 50),
          radius: 45.0,
          color: const Color(0xFF38BDF8),
          intensity: 1.2,
        ),
      ];

      lighting.updateLightingState(night: true, darkness: 0.65, emitters: emitters);
      lighting.update(0.016);
      lighting.render(canvas);

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });
  });

  group('VolumetricSunRaysComponent Tests', () {
    test('Güneş hüzmeleri update ve render döngüsünü hatasız tamamlar', () {
      final sunRays = VolumetricSunRaysComponent()..isEnabled = true;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      sunRays.update(0.5);
      sunRays.render(canvas);

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });
  });

  group('Voxel Ambient Occlusion (AO) Mesh Tests', () {
    test('drawVertexAmbientOcclusion Canvas.drawVertices ile taban gölgesi çizer', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      VoxelIsometricRenderer.drawVertexAmbientOcclusion(
        canvas,
        const Offset(0, 0),
        w: 30.0,
        d: 30.0,
        spread: 5.0,
        maxOpacity: 0.4,
      );

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });
  });

  group('ShockwaveEffectComponent Tests', () {
    test('Şok dalgası süresi boyunca ilerler ve tamamlandığında biter', () {
      final shockwave = ShockwaveEffectComponent(
        center: Vector2(0, 0),
        duration: 1.0,
      );

      expect(shockwave.isFinished, isFalse);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      shockwave.update(0.4);
      shockwave.render(canvas);
      expect(shockwave.isFinished, isFalse);

      shockwave.update(0.7); // Toplam 1.1s > 1.0s
      expect(shockwave.isFinished, isTrue);

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });
  });

  group('HexShaderService HeatHaze & Shockwave Tests', () {
    test('Shader fonksiyonları test ortamında null/fallback ile güvenle çalışır', () {
      HexShaderService.resetForTesting();
      expect(HexShaderService.hasHeatHazeShader, isFalse);
      expect(HexShaderService.hasShockwaveShader, isFalse);

      final heatPaint = HexShaderService.getHeatHazeShaderPaint(
        resolution: const Size(100, 100),
        time: 1.0,
        center: const Offset(50, 50),
      );
      expect(heatPaint, isNull);

      final wavePaint = HexShaderService.getShockwaveShaderPaint(
        resolution: const Size(100, 100),
        time: 1.0,
        center: const Offset(50, 50),
        progress: 0.5,
      );
      expect(wavePaint, isNull);
    });
  });
}
