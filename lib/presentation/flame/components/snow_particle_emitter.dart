import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SnowParticleEmitter extends Component {
  final int particleCount;
  final math.Random _random = math.Random();
  final List<_SnowFlake> _flakes = [];
  bool isActive = false;
  bool isZud = false;

  SnowParticleEmitter({this.particleCount = 60});

  @override
  Future<void> onLoad() async {
    _initFlakes();
  }

  void _initFlakes() {
    _flakes.clear();
    for (int i = 0; i < particleCount; i++) {
      _flakes.add(_SnowFlake(
        x: (_random.nextDouble() - 0.5) * 800,
        y: (_random.nextDouble() - 0.5) * 800,
        radius: _random.nextDouble() * 2.5 + 1.0,
        speedY: _random.nextDouble() * 40 + 20,
        speedX: (_random.nextDouble() - 0.5) * 15,
        opacity: _random.nextDouble() * 0.6 + 0.3,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    final double speedMult = isZud ? 2.5 : 1.0;

    for (final flake in _flakes) {
      flake.y += flake.speedY * speedMult * dt;
      flake.x += flake.speedX * speedMult * dt;

      if (flake.y > 400) {
        flake.y = -400;
        flake.x = (_random.nextDouble() - 0.5) * 800;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final flake in _flakes) {
      paint.color = Colors.white.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(flake.x, flake.y), flake.radius, paint);
    }
  }
}

class _SnowFlake {
  double x;
  double y;
  final double radius;
  final double speedY;
  final double speedX;
  final double opacity;

  _SnowFlake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedY,
    required this.speedX,
    required this.opacity,
  });
}
