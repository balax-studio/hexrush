import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../renderers/voxel_isometric_renderer.dart';

/// Gökyüzünde süzülen ve kanat çırpan 3D Voxel Kuşlar / Martılar
class FlyingVoxelBirdComponent extends PositionComponent {
  FlyingVoxelBirdComponent({
    required Vector2 startPos,
    this.flightSpeed = 35.0,
    this.flightRadius = 240.0,
  }) : super(position: startPos, priority: 90);

  final double flightSpeed;
  final double flightRadius;
  double _time = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  static final Paint _groundShadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.12)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    // 3'lü kuş sürüsü (V formasyonu)
    final double baseWingAnim = _time * 12.0;

    for (int i = 0; i < 3; i++) {
      // Dairesel / eliptik süzülme rotası
      final double birdOffset = i * 0.35;
      final double t = (_time * 0.4) + birdOffset;

      final double ox = math.cos(t) * flightRadius + (i == 1 ? -16.0 : (i == 2 ? 16.0 : 0.0));
      final double oy = math.sin(t) * (flightRadius * 0.45) - 60.0 + (i * 8.0);
      final double flap = baseWingAnim + i * 1.2;

      // Kuşun yerdeki hafif minik gölgesi
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ox, oy + 70.0), width: 8.0, height: 4.0),
        _groundShadowPaint,
      );

      // 3D Voxel Kuş
      VoxelIsometricRenderer.drawVoxelBird(
        canvas,
        Offset(ox, oy),
        wingAnim: flap,
        scale: 0.9 + (i == 0 ? 0.2 : 0.0),
      );
    }
  }
}
