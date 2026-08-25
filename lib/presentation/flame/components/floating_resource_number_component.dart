import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Karoların üzerinden gökyüzüne doğru süzülen 3D "Juicy" Kaynak Sayı Baloncukları
class FloatingResourceNumberComponent extends PositionComponent {
  final String text;
  final Color textColor;
  final Color bgColor;
  final double duration;

  double _elapsed = 0.0;
  final Vector2 _initialPos;

  FloatingResourceNumberComponent({
    required Vector2 position,
    required this.text,
    this.textColor = Colors.black,
    this.bgColor = const Color(0xFFFFD700),
    this.duration = 1.4,
  })  : _initialPos = position.clone(),
        super(position: position, priority: 200);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    final double progress = (_elapsed / duration).clamp(0.0, 1.0);
    // Yukarı doğru yavaşlayarak süzülme
    final double easeY = (1.0 - math.pow(1.0 - progress, 2).toDouble()) * 32.0;
    position = Vector2(_initialPos.x, _initialPos.y - easeY);
  }

  static final Paint _shadowPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _bgPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void render(Canvas canvas) {
    final double progress = (_elapsed / duration).clamp(0.0, 1.0);
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);

    // Pop / Bounce Ölçeklendirmesi (0 -> 1.15 -> 1.0)
    double scale = 1.0;
    if (progress < 0.25) {
      scale = (progress / 0.25) * 1.15;
    } else if (progress < 0.45) {
      scale = 1.15 - ((progress - 0.25) / 0.2) * 0.15;
    }

    canvas.save();
    canvas.scale(scale);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor.withValues(alpha: alpha),
        fontSize: 11.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.3,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

    const double padX = 7.0;
    const double padY = 3.5;
    final Rect rect = Rect.fromCenter(
      center: Offset.zero,
      width: textPainter.width + padX * 2,
      height: textPainter.height + padY * 2,
    );

    // 1. Sert Siyah Gölge
    _shadowPaint.color = Colors.black.withValues(alpha: alpha * 0.8);
    canvas.drawRect(
      rect.shift(const Offset(2.0, 2.0)),
      _shadowPaint,
    );

    // 2. Arka Plan Kartı
    _bgPaint.color = bgColor.withValues(alpha: alpha);
    canvas.drawRect(
      rect,
      _bgPaint,
    );

    // 3. Siyah Çerçeve
    _borderPaint.color = Colors.black.withValues(alpha: alpha);
    canvas.drawRect(
      rect,
      _borderPaint,
    );

    // 4. Metin
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }
}
