import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Impeller Donanım Hızlandırmalı Volumetrik Güneş Hüzmeleri (Sun Shafts / God-Rays)
/// BlendMode.plus (Additive GPU Blending) ile bulutların arasından bozkıra vuran altın ışık demetleri oluşturur.
class VolumetricSunRaysComponent extends Component {
  double _time = 0.0;
  bool isEnabled = true;
  double intensity = 0.35; // 0.0 to 1.0

  static final Paint _rayPaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.plus;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (!isEnabled || intensity <= 0.01) return;

    final double alphaBase = (0.22 * intensity).clamp(0.0, 0.45);

    // 3 adet 45 derece açılı süzülen ışık bandı
    for (int i = 0; i < 3; i++) {
      final double phase = (_time * 0.08 + i * 0.33) % 1.0;
      final double xOffset = -600.0 + (phase * 1200.0);
      final double beamWidth = 90.0 + (i * 35.0);
      final double breath = 0.8 + 0.2 * math.sin(_time * 0.6 + i * 1.5);
      final double currentAlpha = alphaBase * breath;

      final Path rayPath = Path()
        ..moveTo(xOffset, -900)
        ..lineTo(xOffset + beamWidth, -900)
        ..lineTo(xOffset + beamWidth + 650, 900)
        ..lineTo(xOffset + 650, 900)
        ..close();

      final shader = ui.Gradient.linear(
        Offset(xOffset, -900),
        Offset(xOffset + 650, 900),
        [
          const Color(0xFFFDE68A).withValues(alpha: currentAlpha * 1.2), // Warm pale gold
          const Color(0xFFF59E0B).withValues(alpha: currentAlpha * 0.6),
          Colors.transparent,
        ],
        [0.0, 0.65, 1.0],
      );

      _rayPaint.shader = shader;
      canvas.drawPath(rayPath, _rayPaint);
    }
  }
}
