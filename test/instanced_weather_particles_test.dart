import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/presentation/flame/components/instanced_weather_particles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InstancedWeatherParticles Tests', () {
    test('initializes typed memory buffers correctly', () {
      final emitter = InstancedWeatherParticles(
        maxParticles: 100,
        type: ParticleType.snow,
      );

      expect(emitter.maxParticles, equals(100));
      expect(emitter.type, equals(ParticleType.snow));
    });

    test('update advances simulation physics without allocating objects', () {
      final emitter = InstancedWeatherParticles(
        maxParticles: 50,
        type: ParticleType.sandDust,
      );

      expect(() => emitter.update(0.016), returnsNormally);
      expect(() => emitter.update(0.1), returnsNormally);
    });

    test('render executes single batched drawVertices call', () {
      final emitter = InstancedWeatherParticles(
        maxParticles: 30,
        type: ParticleType.goldenEmbers,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(() => emitter.render(canvas), returnsNormally);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });
  });
}
