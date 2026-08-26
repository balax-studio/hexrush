import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../renderers/voxel_isometric_renderer.dart';

class _SparkleParticle {
  Vector2 pos;
  Vector2 velocity;
  Color color;
  double size;
  double life;
  double maxLife;

  _SparkleParticle({
    required this.pos,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
  }) : life = maxLife;
}

/// Karodan doğrudan tek tıkla hasat yapıldığında patlayan Neo-Brutalist Voksel Işıltı & Hasat Efekti
class HarvestSparkleEmitter extends PositionComponent {
  final List<_SparkleParticle> _particles = [];
  final double duration;
  double _elapsed = 0.0;

  HarvestSparkleEmitter({
    required Vector2 centerPosition,
    this.duration = 0.9,
    int particleCount = 12,
    bool isGolden = false,
  }) : super(position: centerPosition, priority: 215) {
    final rand = math.Random();
    final colors = isGolden
        ? [
            const Color(0xFFFFD700),
            const Color(0xFFFBBF24),
            const Color(0xFFFDE047),
            Colors.white,
          ]
        : [
            const Color(0xFF10B981),
            const Color(0xFF34D399),
            const Color(0xFF6EE7B7),
            const Color(0xFFFDE047),
            Colors.white,
          ];

    for (int i = 0; i < particleCount; i++) {
      final double angle = (i / particleCount) * math.pi * 2 + rand.nextDouble() * 0.5;
      final double speed = 36.0 + rand.nextDouble() * 55.0;
      final double vx = math.cos(angle) * speed;
      final double vy = math.sin(angle) * speed * 0.58; // İzometrik derinlik

      _particles.add(
        _SparkleParticle(
          pos: Vector2(0, 0),
          velocity: Vector2(vx, vy - (26.0 + rand.nextDouble() * 32.0)),
          color: colors[rand.nextInt(colors.length)],
          size: 4.0 + rand.nextDouble() * 3.5,
          maxLife: 0.55 + rand.nextDouble() * 0.4,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    for (final p in _particles) {
      p.life -= dt;
      p.pos += p.velocity * dt;
      p.velocity.y += 92.0 * dt; // Yerçekimi
      p.velocity.x *= 0.92; // Hava sürtünmesi
    }
  }

  static final Paint _sparkleFlarePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      if (p.life <= 0) continue;
      final double alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final double scale = alpha;

      // 1. Minyatür 3D Voksel Işıltı Küpü
      VoxelIsometricRenderer.drawIsoCube(
        canvas,
        Offset(p.pos.x, p.pos.y),
        w: p.size * scale,
        d: p.size * scale,
        h: p.size * scale,
        topColor: p.color.withValues(alpha: alpha),
        leftColor: p.color.withValues(alpha: alpha * 0.8),
        rightColor: p.color.withValues(alpha: alpha * 0.6),
        drawShadow: false,
      );

      // 2. Parıldayan Yıldız/Tamga Işıltı Haçı (Flare Cross)
      if (scale > 0.45) {
        _sparkleFlarePaint.color = Colors.white.withValues(alpha: alpha * 0.7);
        final double flareLen = p.size * scale * 1.4;
        canvas.drawLine(
          Offset(p.pos.x - flareLen, p.pos.y),
          Offset(p.pos.x + flareLen, p.pos.y),
          _sparkleFlarePaint,
        );
        canvas.drawLine(
          Offset(p.pos.x, p.pos.y - flareLen),
          Offset(p.pos.x, p.pos.y + flareLen),
          _sparkleFlarePaint,
        );
      }
    }
  }
}
