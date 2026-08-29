import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Işık Kaynağı Veri Modeli
class LightEmitter {
  final Vector2 position;
  final double radius;
  final Color color;
  final double intensity;

  const LightEmitter({
    required this.position,
    this.radius = 48.0,
    this.color = const Color(0xFFF59E0B),
    this.intensity = 1.0,
  });
}

/// Impeller Donanım Tabanlı 2.5D Gece Işıklandırması ve Fener Komponenti
/// BlendMode.colorDodge / BlendMode.screen & RadialGradient ile geceleri Otağ, Kule ve Fırınların etrafını aydınlatır.
class DynamicLightingOverlayComponent extends Component {
  bool isNight = false;
  double nightDarkness = 0.0;
  double _animTime = 0.0;

  final List<LightEmitter> _emitters = [];

  // Zero-GC Pre-allocated Paint Objects
  static final Paint _darkOverlayPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF030712);

  static final Paint _lightHolePaint = Paint()
    ..style = PaintingStyle.fill
    ..blendMode = BlendMode.screen;

  void updateLightingState({
    required bool night,
    required double darkness,
    required List<LightEmitter> emitters,
  }) {
    isNight = night;
    nightDarkness = darkness.clamp(0.0, 0.75);
    _emitters
      ..clear()
      ..addAll(emitters);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;
  }

  @override
  void render(Canvas canvas) {
    if (!isNight && nightDarkness <= 0.01) return;

    final double alpha = nightDarkness;
    if (alpha <= 0.01) return;

    // 1. Ekran / Harita boyutunda karanlık gece tülü
    const Rect bounds = Rect.fromLTRB(-1200, -1000, 1200, 1000);

    // 2. Işık kaynakları varsa Impeller Donanım Kompozitlemesi uygula
    if (_emitters.isNotEmpty) {
      canvas.saveLayer(bounds, Paint());

      // Karanlık zemin
      _darkOverlayPaint.color = const Color(0xFF030712).withValues(alpha: alpha);
      canvas.drawRect(bounds, _darkOverlayPaint);

      // Noktasal ışık fenerlerini del ve aydınlat
      for (final emitter in _emitters) {
        final double flicker = 1.0 + 0.06 * math.sin(_animTime * 2.2 + emitter.position.x);
        final double r = emitter.radius * flicker;

        final shader = ui.Gradient.radial(
          Offset(emitter.position.x, emitter.position.y),
          r,
          [
            emitter.color.withValues(alpha: (0.75 * emitter.intensity * alpha).clamp(0.0, 1.0)),
            emitter.color.withValues(alpha: (0.28 * emitter.intensity * alpha).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
          [0.0, 0.55, 1.0],
        );

        _lightHolePaint.shader = shader;
        canvas.drawCircle(Offset(emitter.position.x, emitter.position.y), r, _lightHolePaint);
      }

      canvas.restore();
    } else {
      // Işık kaynağı yoksa düz yumuşak gece örtüsü
      _darkOverlayPaint.color = const Color(0xFF030712).withValues(alpha: alpha);
      canvas.drawRect(bounds, _darkOverlayPaint);
    }
  }
}
