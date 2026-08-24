import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../renderers/voxel_isometric_renderer.dart';

class _PoofParticle {
  Vector2 pos;
  Vector2 velocity;
  Color color;
  double size;
  double life;
  double maxLife;

  _PoofParticle({
    required this.pos,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
  }) : life = maxLife;
}

/// Yeni bir karo fethedildiğinde veya bina kurulduğunda patlayan 3D Voxel Duman & Kutlama Partikülleri
class TileConquerPoofEmitter extends PositionComponent {
  final List<_PoofParticle> _particles = [];
  final double duration;
  double _elapsed = 0.0;

  TileConquerPoofEmitter({
    required Vector2 centerPosition,
    this.duration = 1.0,
    int particleCount = 14,
  }) : super(position: centerPosition, priority: 210) {
    final rand = math.Random();
    final colors = [
      Colors.white,
      const Color(0xFFFDE047),
      const Color(0xFF86EFAC),
      const Color(0xFF67E8F9),
      const Color(0xFFF472B6),
    ];

    for (int i = 0; i < particleCount; i++) {
      final double angle = (i / particleCount) * math.pi * 2 + rand.nextDouble() * 0.4;
      final double speed = 35.0 + rand.nextDouble() * 55.0;
      final double vx = math.cos(angle) * speed;
      final double vy = math.sin(angle) * speed * 0.6; // İzometrik basıklık

      _particles.add(
        _PoofParticle(
          pos: Vector2(0, 0),
          velocity: Vector2(vx, vy - (15.0 + rand.nextDouble() * 20.0)),
          color: colors[rand.nextInt(colors.length)],
          size: 4.0 + rand.nextDouble() * 3.5,
          maxLife: 0.6 + rand.nextDouble() * 0.4,
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
      p.velocity.y += 90.0 * dt; // Yerçekimi ivmesi
      p.velocity.x *= 0.94; // Hava direnci
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      if (p.life <= 0) continue;
      final double alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final double scale = alpha;

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
    }
  }
}
