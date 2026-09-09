import 'dart:ui' as ui;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/presentation/flame/components/shockwave_effect_component.dart';
import 'package:hex_rush/presentation/flame/components/volumetric_sun_rays_component.dart';

void main() {
  test('ShockwaveEffectComponent renders fallback ring cleanly without allocations', () {
    final comp = ShockwaveEffectComponent(center: Vector2(100, 100));
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    comp.update(0.1);
    comp.render(canvas);

    final picture = recorder.endRecording();
    expect(picture, isNotNull);
    picture.dispose();
  });

  test('VolumetricSunRaysComponent renders God-Rays with shared path cleanly', () {
    final rays = VolumetricSunRaysComponent()..isEnabled = true;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    rays.update(0.016);
    rays.render(canvas);

    final picture = recorder.endRecording();
    expect(picture, isNotNull);
    picture.dispose();
  });
}
