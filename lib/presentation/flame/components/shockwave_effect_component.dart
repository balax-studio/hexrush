import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/graphics/hex_shader_service.dart';

/// Bozkır Borusu, Sunak Keşfi ve Kadim Göç Tetikleyicisi için Impeller Şok Dalgası Efekti
class ShockwaveEffectComponent extends Component {
  Vector2 center;
  double duration;
  double _elapsed = 0.0;
  bool isFinished = false;

  ShockwaveEffectComponent({
    required this.center,
    this.duration = 1.2,
  });

  void trigger({required Vector2 atPosition}) {
    center = atPosition;
    _elapsed = 0.0;
    isFinished = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isFinished) return;

    _elapsed += dt;
    if (_elapsed >= duration) {
      isFinished = true;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (isFinished) return;

    final double progress = (_elapsed / duration).clamp(0.0, 1.0);
    const Size effectSize = Size(600, 600);

    final paint = HexShaderService.getShockwaveShaderPaint(
      resolution: effectSize,
      time: _elapsed,
      center: Offset(center.x, center.y),
      progress: progress,
    );

    if (paint != null) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(center.x, center.y),
          width: effectSize.width,
          height: effectSize.height,
        ),
        paint,
      );
    } else {
      // Fallback: Standart halka çizimi (Shader desteklenmeyen ortamlar / testler)
      final double ringRadius = progress * 180.0;
      final double alpha = (1.0 - progress) * 0.7;
      final fallbackPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 * (1.0 - progress * 0.5)
        ..color = const Color(0xFFFBBF24).withValues(alpha: alpha);

      canvas.drawCircle(Offset(center.x, center.y), ringRadius, fallbackPaint);
    }
  }
}
