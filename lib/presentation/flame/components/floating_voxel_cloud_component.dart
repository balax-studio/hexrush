import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../renderers/voxel_isometric_renderer.dart';

/// 3D Voxel Gökyüzü Bulutu (Adayı süsleyen yüzen 3D bulutlar)
class FloatingVoxelCloudComponent extends PositionComponent {
  final double speed;
  final double cloudScale;
  final double minX;
  final double maxX;

  FloatingVoxelCloudComponent({
    required Vector2 initialPosition,
    this.speed = 12.0,
    this.cloudScale = 1.0,
    this.minX = -350.0,
    this.maxX = 350.0,
  }) : super(
          position: initialPosition,
          size: Vector2(40 * cloudScale, 30 * cloudScale),
          anchor: Anchor.center,
          priority: 3000, // Highest layer above world
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    if (position.x > maxX) {
      position.x = minX;
    }
  }

  static final Paint _groundShadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.15)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    final Offset center = Offset(size.x / 2, size.y / 2);

    // Yeryüzüne vuran yumuşak bulut gölgesi
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 70 * cloudScale),
        width: 36 * cloudScale,
        height: 14 * cloudScale,
      ),
      _groundShadowPaint,
    );

    // 3D Voxel Bulut Gövdesi
    VoxelIsometricRenderer.drawVoxelCloud(canvas, center, scale: cloudScale);
  }
}
