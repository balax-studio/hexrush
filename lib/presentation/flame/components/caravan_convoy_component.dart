import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../../../domain/models/caravan_route_model.dart';
import '../renderers/voxel_isometric_renderer.dart';

/// Flame Component rendering animated voxel caravan pack camels traversing trade corridors
class CaravanConvoyComponent extends PositionComponent {
  final CaravanRoute route;
  final double hexRadius;
  double _progress = 0.0;
  double _animTimer = 0.0;

  CaravanConvoyComponent({
    required this.route,
    this.hexRadius = 32.0,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
    // Kervan hızı: 12 saniyede bir rotayı tamamlar
    _progress = (_progress + (dt / 12.0)) % 1.0;
  }

  @override
  void render(Canvas canvas) {
    final startCenter = HexMath.hexToPixel(route.startCoord, hexSize: hexRadius, yScale: HexMath.defaultYScale);
    final endCenter = HexMath.hexToPixel(route.endCoord, hexSize: hexRadius, yScale: HexMath.defaultYScale);

    // Kervanın haritadaki anlık konumu (Lerp)
    final double curX = startCenter.dx + (endCenter.dx - startCenter.dx) * _progress;
    final double curY = startCenter.dy + (endCenter.dy - startCenter.dy) * _progress;
    final bool flipX = endCenter.dx < startCenter.dx;

    // 1. Yol İzi / İpek Yolu Toz Hattı
    final Paint linePaint = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(startCenter, endCenter, linePaint);

    // 2. Voksel Deve Çizimi
    VoxelIsometricRenderer.drawVoxelCaravanCamel(
      canvas,
      Offset(curX, curY),
      animTime: _animTimer,
      walkCycle: _progress * 8.0,
      flipX: flipX,
    );
  }
}
