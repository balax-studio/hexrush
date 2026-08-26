import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../hex_map_game.dart';
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
    // Frustum / Viewport Culling: Ekran dışındaki kuşları çizme
    final game = findGame();
    if (game is HexMapGame) {
      final Rect bounds = game.visibleWorldBounds;
      if (position.x < bounds.left - flightRadius ||
          position.x > bounds.right + flightRadius ||
          position.y < bounds.top - flightRadius ||
          position.y > bounds.bottom + flightRadius) {
        return;
      }
    }

    // 140 saniyelik dinamik sürü döngüsü (Tekdüze 3 kuş yerine: Yalnız Kartal, İkili Turna, Dörtlü Kırlangıç, İkili Martı)
    final int flockCycle = (_time ~/ 35) % 4;

    switch (flockCycle) {
      case 0:
        // 1. Yalnız Süzülen Asil Bozkır Kartalı (1 Adet, Geniş ve Yavaş Süzülüş)
        final double t = _time * 0.22;
        final double ox = math.cos(t) * (flightRadius * 1.3);
        final double oy = math.sin(t * 1.1) * (flightRadius * 0.6) - 100.0;
        final double flap = math.sin(_time * 3.5) * 0.4;

        canvas.drawOval(
          Rect.fromCenter(center: Offset(ox, oy + 110.0), width: 14.0, height: 6.0),
          _groundShadowPaint,
        );

        VoxelIsometricRenderer.drawVoxelBird(
          canvas,
          Offset(ox, oy),
          wingAnim: flap,
          scale: 1.45,
          bodyColor: const Color(0xFF78350F),
          wingColor: const Color(0xFF92400E),
          wingTipColor: const Color(0xFF451A03),
        );
        break;

      case 1:
        // 2. İkili Göçmen Turna Çifti (2 Adet, Çapraz Uçuş Rotası)
        for (int i = 0; i < 2; i++) {
          final double t = (_time * 0.35) + (i * 0.28);
          final double ox = math.cos(t) * flightRadius + (i == 1 ? -24.0 : 0.0);
          final double oy = math.sin(t * 0.8) * (flightRadius * 0.5) - 70.0 + (i * 12.0);
          final double flap = _time * 8.0 + (i * 1.5);

          canvas.drawOval(
            Rect.fromCenter(center: Offset(ox, oy + 80.0), width: 9.0, height: 4.5),
            _groundShadowPaint,
          );

          VoxelIsometricRenderer.drawVoxelBird(
            canvas,
            Offset(ox, oy),
            wingAnim: flap,
            scale: 1.15,
            bodyColor: const Color(0xFFF1F5F9),
            wingColor: const Color(0xFFE2E8F0),
            wingTipColor: const Color(0xFF334155),
          );
        }
        break;

      case 2:
        // 3. Neşeli Kırlangıç Dörtlüsü (4 Adet, Dalgalı Oyun Uçuşu)
        for (int i = 0; i < 4; i++) {
          final double t = (_time * 0.48) + (i * 0.18);
          final double ox = math.cos(t) * (flightRadius * 0.85) + (i % 2 == 0 ? i * 14.0 : -i * 14.0);
          final double oy = math.sin(t * 1.3) * (flightRadius * 0.4) - 50.0 + (i * 6.0);
          final double flap = _time * 14.0 + (i * 2.0);

          canvas.drawOval(
            Rect.fromCenter(center: Offset(ox, oy + 60.0), width: 6.0, height: 3.0),
            _groundShadowPaint,
          );

          VoxelIsometricRenderer.drawVoxelBird(
            canvas,
            Offset(ox, oy),
            wingAnim: flap,
            scale: 0.75,
            bodyColor: const Color(0xFF1E293B),
            wingColor: const Color(0xFF334155),
            wingTipColor: const Color(0xFF64748B),
          );
        }
        break;

      case 3:
      default:
        // 4. Kıyı Martıları (2 Adet, Yumuşak Süzülme)
        for (int i = 0; i < 2; i++) {
          final double t = (_time * 0.3) + (i * 0.4);
          final double ox = math.sin(t) * (flightRadius * 1.1) + (i * 20.0);
          final double oy = math.cos(t * 0.9) * (flightRadius * 0.45) - 60.0 + (i * 10.0);
          final double flap = _time * 6.0 + (i * 1.8);

          canvas.drawOval(
            Rect.fromCenter(center: Offset(ox, oy + 70.0), width: 8.0, height: 4.0),
            _groundShadowPaint,
          );

          VoxelIsometricRenderer.drawVoxelBird(
            canvas,
            Offset(ox, oy),
            wingAnim: flap,
            scale: 0.95,
            bodyColor: const Color(0xFFFFFFFF),
            wingColor: const Color(0xFFF8FAFC),
            wingTipColor: const Color(0xFFCBD5E1),
          );
        }
        break;
    }
  }
}
