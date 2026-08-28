import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../../../domain/models/combat_model.dart';
import '../components/hex_tile_component.dart';
import '../renderers/voxel_isometric_renderer.dart';

/// 3D Voxel Düşman Akıncı Bileşeni (Steppe Raider / Shadow Wolf / Siege Ram / Erlik Champion)
/// Harita sınırından Şatoya doğru en kısa yoldan ilerleyen, sağlık çubuğu olan Zero-GC Flame bileşeni.
class VoxelEnemyComponent extends PositionComponent {
  final CombatEnemyInstance enemy;
  final double Function(HexAxial)? getElevation;

  double _animTime = 0.0;
  bool _flipX = false;
  Vector2 _currentPixelPos = Vector2.zero();
  Vector2 _targetPixelPos = Vector2.zero();
  double _moveProgress = 0.0;

  static final Paint _hpBgPaint = Paint()
    ..color = const Color(0xFF020617)
    ..style = PaintingStyle.fill;

  static final Paint _hpFillPaint = Paint()
    ..color = const Color(0xFFEF4444)
    ..style = PaintingStyle.fill;

  static final Paint _shadowPaint = Paint()
    ..color = const Color(0x44020617)
    ..style = PaintingStyle.fill;

  VoxelEnemyComponent({
    required this.enemy,
    this.getElevation,
  }) : super(
          size: Vector2(36, 36),
          anchor: Anchor.center,
          priority: 2600,
        ) {
    _initPosition();
  }

  void _initPosition() {
    final curPixel = HexMath.hexToPixel(enemy.currentCoord, hexSize: HexTileComponent.hexRadius);
    final double elev = getElevation?.call(enemy.currentCoord) ?? 0.0;
    _currentPixelPos = Vector2(curPixel.dx, curPixel.dy - elev);
    position = _currentPixelPos;

    if (enemy.pathIndex + 1 < enemy.path.length) {
      final nextCoord = enemy.path[enemy.pathIndex + 1];
      final nextPixel = HexMath.hexToPixel(nextCoord, hexSize: HexTileComponent.hexRadius);
      final double nextElev = getElevation?.call(nextCoord) ?? 0.0;
      _targetPixelPos = Vector2(nextPixel.dx, nextPixel.dy - nextElev);
      _flipX = _targetPixelPos.x < _currentPixelPos.x;
    } else {
      _targetPixelPos = _currentPixelPos;
    }
  }

  void updateEnemyData(CombatEnemyInstance updated) {
    final bool coordChanged = updated.currentCoord != enemy.currentCoord;
    if (coordChanged) {
      _currentPixelPos = position.clone();
      final curPixel = HexMath.hexToPixel(updated.currentCoord, hexSize: HexTileComponent.hexRadius);
      final double elev = getElevation?.call(updated.currentCoord) ?? 0.0;
      _targetPixelPos = Vector2(curPixel.dx, curPixel.dy - elev);
      _moveProgress = 0.0;
      _flipX = _targetPixelPos.x < _currentPixelPos.x;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;

    if (_currentPixelPos != _targetPixelPos) {
      _moveProgress = math.min(1.0, _moveProgress + (dt * enemy.speed * 1.5));
      position = _currentPixelPos + (_targetPixelPos - _currentPixelPos) * _moveProgress;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double cx = size.x / 2;
    final double cy = size.y / 2;
    final double bob = math.sin(_animTime * 10.0) * 1.8;

    canvas.save();
    canvas.translate(cx, cy + bob);

    if (_flipX) {
      canvas.scale(-1.0, 1.0);
    }

    // 1. Zemin Gölgesi
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 12), width: 20, height: 8),
      _shadowPaint,
    );

    // 2. Voksel Düşman Gövdesi
    switch (enemy.type) {
      case CombatEnemyType.steppeRaider:
        _renderSteppeRaider(canvas);
        break;
      case CombatEnemyType.shadowWolf:
        _renderShadowWolf(canvas);
        break;
      case CombatEnemyType.siegeRam:
        _renderSiegeRam(canvas);
        break;
      case CombatEnemyType.erlikChampion:
        _renderErlikChampion(canvas);
        break;
    }

    canvas.restore();

    // 3. Sağlık Barı (HP Bar)
    _renderHealthBar(canvas, cx);
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

  void _renderSteppeRaider(Canvas canvas) {
    // At gövdesi (Koyu Kızıl / Yağmacı Atı)
    _drawCube(canvas, 0, 4, 14, 7, 7, const Color(0xFF7F1D1D));
    // At başı
    _drawCube(canvas, 6, -1, 6, 6, 6, const Color(0xFF991B1B));
    // Yağmacı Savaşçı
    _drawCube(canvas, -1, -6, 6, 6, 8, const Color(0xFF1E293B));
    // Miğfer & Yay
    _drawCube(canvas, -1, -11, 4, 4, 4, const Color(0xFFD97706));
    _drawCube(canvas, 4, -4, 2, 8, 2, const Color(0xFF78350F));
  }

  void _renderShadowWolf(Canvas canvas) {
    // Gölge Kurt (Karanlık Mor & Göz Işıltısı)
    _drawCube(canvas, 0, 4, 12, 6, 6, const Color(0xFF1E1B4B));
    _drawCube(canvas, 5, 0, 5, 5, 5, const Color(0xFF312E81));
    // Kırmızı göz
    _drawCube(canvas, 7, -1, 2, 2, 2, const Color(0xFFEF4444));
    // Kuyruk
    _drawCube(canvas, -6, 2, 4, 3, 3, const Color(0xFF4338CA));
  }

  void _renderSiegeRam(Canvas canvas) {
    // Koçbaşı (Ağır Ahşap & Demir Başlık)
    _drawCube(canvas, 0, 2, 18, 10, 8, const Color(0xFF451A03));
    _drawCube(canvas, 8, 0, 6, 8, 8, const Color(0xFF64748B));
    // Taşıyıcı zırhlılar
    _drawCube(canvas, -4, 5, 4, 4, 6, const Color(0xFF1E293B));
    _drawCube(canvas, 4, 5, 4, 4, 6, const Color(0xFF1E293B));
  }

  void _renderErlikChampion(Canvas canvas) {
    // Erlik Şampiyonu (Ağır Kara Zırh & Boynuzlu Miğfer)
    _drawCube(canvas, 0, 2, 14, 10, 14, const Color(0xFF0F172A));
    _drawCube(canvas, 0, -8, 8, 8, 8, const Color(0xFFDC2626));
    // Boynuzlar
    _drawCube(canvas, -4, -12, 3, 3, 5, const Color(0xFFF59E0B));
    _drawCube(canvas, 4, -12, 3, 3, 5, const Color(0xFFF59E0B));
    // Çift Başlı Balta
    _drawCube(canvas, 7, -4, 3, 12, 3, const Color(0xFFE2E8F0));
  }

  void _renderHealthBar(Canvas canvas, double cx) {
    const double barWidth = 24.0;
    const double barHeight = 3.5;
    final double left = cx - (barWidth / 2);
    const double top = -10.0;

    // Arka plan
    canvas.drawRect(Rect.fromLTWH(left - 0.5, top - 0.5, barWidth + 1.0, barHeight + 1.0), _hpBgPaint);

    // Kalan Can
    final double fillW = (barWidth * enemy.hpPercentage).clamp(0.0, barWidth);
    canvas.drawRect(Rect.fromLTWH(left, top, fillW, barHeight), _hpFillPaint);
  }
}
