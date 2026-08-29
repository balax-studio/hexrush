import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../../../domain/models/combat_model.dart';
import '../components/hex_tile_component.dart';
import '../renderers/voxel_isometric_renderer.dart';

/// Kulelerden fırlatılan 3D Voksel Ok ve Mermi Parçacıkları (Zero-GC)
class VoxelProjectileComponent extends PositionComponent {
  final CombatProjectileInstance projectile;
  final Vector2 targetPixelPos;
  final double Function(HexAxial)? getElevation;

  double _progress = 0.0;
  final double _speed = 1.6; // Saniyede tam mesafe katetme katsayısı (~0.62 sn uçuş)
  late final Vector2 _startPixelPos;
  double _angle = 0.0;

  static final Paint _trailPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  VoxelProjectileComponent({
    required this.projectile,
    required this.targetPixelPos,
    this.getElevation,
  }) : super(
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 2800,
        ) {
    final startPixel = HexMath.hexToPixel(projectile.sourceTowerCoord, hexSize: HexTileComponent.hexRadius);
    final double elev = getElevation?.call(projectile.sourceTowerCoord) ?? 0.0;
    _startPixelPos = Vector2(startPixel.dx, startPixel.dy - elev - 28.0); // Kule mazgalından başla
    position = _startPixelPos;
  }

  bool get isFinished => _progress >= 1.0;

  @override
  void update(double dt) {
    super.update(dt);
    _progress += dt * _speed;

    if (_progress < 1.0) {
      final double t = _progress;
      final Vector2 linear = _startPixelPos + (targetPixelPos - _startPixelPos) * t;
      // Parabolik yay (Arc)
      final double arcHeight = math.sin(t * math.pi) * 32.0;
      final Vector2 nextPos = Vector2(linear.x, linear.y - arcHeight);

      // Uçuş açısını hesapla
      _angle = math.atan2(nextPos.y - position.y, nextPos.x - position.x);
      position = nextPos;
    } else {
      removeFromParent();
    }
  }

  static void _drawCube(
    Canvas canvas,
    double x,
    double y,
    double w,
    double d,
    double h,
    Color baseColor,
  ) {
    final top = baseColor;
    final left = Color.fromARGB(
      baseColor.alpha,
      (baseColor.red * 0.72).round(),
      (baseColor.green * 0.72).round(),
      (baseColor.blue * 0.72).round(),
    );
    final right = Color.fromARGB(
      baseColor.alpha,
      (baseColor.red * 0.86).round(),
      (baseColor.green * 0.86).round(),
      (baseColor.blue * 0.86).round(),
    );

    VoxelIsometricRenderer.drawIsoCube(
      canvas,
      Offset(x, y),
      w: w,
      d: d,
      h: h,
      topColor: top,
      leftColor: left,
      rightColor: right,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double cx = size.x / 2;
    final double cy = size.y / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_angle);

    // Işıltılı Uçuş İzi / Kuyruk Parıltısı (Zero-GC static paint)
    _trailPaint.strokeWidth = projectile.isAoE ? 3.0 : 2.0;
    _trailPaint.color = projectile.isAoE
        ? const Color(0x99F97316)
        : const Color(0xAAFEF08A);
    canvas.drawLine(const Offset(-14, 0), const Offset(0, 0), _trailPaint);

    if (projectile.isAoE) {
      // Alevli Mancınık Güllesi
      _drawCube(canvas, 0, 0, 8, 8, 8, const Color(0xFFF97316));
      _drawCube(canvas, 0, 0, 5, 5, 5, const Color(0xFFFEF08A));
    } else {
      // Voksel Bozkır Oku (Büyük, net seçilebilir ok)
      // Ok gövdesi (Ahşap mil)
      _drawCube(canvas, 0, 0, 14, 2.5, 2.5, const Color(0xFFD97706));
      // Ok ucu (Demir temren)
      _drawCube(canvas, 7, 0, 4, 4, 4, const Color(0xFFF8FAFC));
      // Ok tüyü (Kırmızı savaş yelesi)
      _drawCube(canvas, -7, 0, 3, 3, 3, const Color(0xFFDC2626));
    }

    canvas.restore();
  }
}
