import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../hex_map_game.dart';
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
    this.minX = -950.0,
    this.maxX = 950.0,
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
    // Hafif izometrik y ekseni kayması (gerçekçi rüzgar akışı)
    position.y += speed * 0.22 * dt;
    if (position.x > maxX) {
      position.x = minX;
      position.y -= (maxX - minX) * 0.22;
    }
  }

  static final Paint _groundShadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.16)
    ..style = PaintingStyle.fill;
  static final Paint _innerGroundShadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.08)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    // Frustum / Viewport Culling: Ekran dışındaki bulutları çizme
    final game = findGame();
    if (game is HexMapGame) {
      final Rect bounds = game.visibleWorldBounds;
      if (position.x < bounds.left - 100 ||
          position.x > bounds.right + 100 ||
          position.y < bounds.top - 100 ||
          position.y > bounds.bottom + 100) {
        return;
      }
    }

    final Offset center = Offset(size.x / 2, size.y / 2);

    // Yeryüzüne vuran yumuşak çift katmanlı hacimsel bulut gölgesi
    final Offset shadowCenter = Offset(center.dx + 12 * cloudScale, center.dy + 85 * cloudScale);
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: 64 * cloudScale,
        height: 26 * cloudScale,
      ),
      _innerGroundShadowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: shadowCenter,
        width: 44 * cloudScale,
        height: 18 * cloudScale,
      ),
      _groundShadowPaint,
    );

    // 3D Voxel Bulut Gövdesi
    VoxelIsometricRenderer.drawVoxelCloud(canvas, center, scale: cloudScale);
  }
}
