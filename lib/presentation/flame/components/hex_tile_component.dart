import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../../../domain/models/building_model.dart';
import '../../../domain/models/hex_tile_model.dart';
import '../renderers/voxel_isometric_renderer.dart';

class HexTileComponent extends PositionComponent {
  final HexAxial coord;
  HexTileModel tileModel;
  bool isSelected;
  String season;
  bool isZud;

  double _animTimer = 0.0;

  static const double hexRadius = 52.0;
  static const double baseDepth3D = 20.0; // 3D Ekstrüzyon Derinliği

  HexTileComponent({
    required this.coord,
    required this.tileModel,
    required this.isSelected,
    required this.season,
    required this.isZud,
  }) : super(
          position: Vector2(
            HexMath.hexToPixel(coord, hexSize: hexRadius).dx,
            HexMath.hexToPixel(coord, hexSize: hexRadius).dy,
          ),
          size: Vector2(hexRadius * 2.2, hexRadius * 2.5),
          anchor: Anchor.center,
        );

  void updateData({
    required HexTileModel newTileModel,
    required bool newIsSelected,
    required String newSeason,
    required bool newIsZud,
  }) {
    tileModel = newTileModel;
    isSelected = newIsSelected;
    season = newSeason;
    isZud = newIsZud;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
  }

  @override
  void render(Canvas canvas) {
    final double elevation = _getBiomeElevation(tileModel.biome);
    final Offset center = Offset(size.x / 2, size.y / 2 - elevation);
    final corners = HexMath.getHexCorners(center, hexSize: hexRadius, yScale: HexMath.defaultYScale);

    if (tileModel.isFog) {
      _renderVoxelFog(canvas, corners, center);
      return;
    }

    _render3DExtrudedWalls(canvas, corners, elevation);
    _renderIsometricTopFace(canvas, corners, center);
    _renderVoxelObjects(canvas, center);
    _renderBrutalistBadges(canvas, center);
  }

  double _getBiomeElevation(TileBiome biome) {
    if (tileModel.isFog) return 0.0;
    switch (biome) {
      case TileBiome.sea:
        return 0.0;
      case TileBiome.meadow:
      case TileBiome.forest:
        return 12.0;
      case TileBiome.mountain:
        return 20.0;
    }
  }

  void _renderVoxelFog(Canvas canvas, List<Offset> corners, Offset center) {
    final Path path = Path()..moveTo(corners[0].dx, corners[0].dy);
    for (int i = 1; i < 6; i++) {
      path.lineTo(corners[i].dx, corners[i].dy);
    }
    path.close();

    // Koyu monolitik sis kütlesi
    final Paint fogFill = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fogFill);

    final Paint border = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, border);

    // Kilit Voxel İkonu
    VoxelIsometricRenderer.drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 6),
      w: 8.0,
      d: 8.0,
      h: 8.0,
      topColor: const Color(0xFF475569),
      leftColor: const Color(0xFF334155),
      rightColor: const Color(0xFF1E293B),
    );
  }

  void _render3DExtrudedWalls(Canvas canvas, List<Offset> corners, double elevation) {
    final double wallH = baseDepth3D + elevation;
    final (wallLeft, wallRight, bedrock) = _getBiome3DWallColors(tileModel.biome);

    // Güney & Güneydoğu & Güneybatı 3D Yan Duvar Fasetleri
    for (int i = 1; i <= 3; i++) {
      final pA = corners[i];
      final pB = corners[(i + 1) % 6];

      final Path wallPath = Path()
        ..moveTo(pA.dx, pA.dy)
        ..lineTo(pB.dx, pB.dy)
        ..lineTo(pB.dx, pB.dy + wallH)
        ..lineTo(pA.dx, pA.dy + wallH)
        ..close();

      final Color col = i == 1
          ? wallLeft
          : (i == 2 ? wallRight : bedrock);

      canvas.drawPath(wallPath, Paint()..color = col);
    }
  }

  void _renderIsometricTopFace(Canvas canvas, List<Offset> corners, Offset center) {
    final Path topPath = Path()..moveTo(corners[0].dx, corners[0].dy);
    for (int i = 1; i < 6; i++) {
      topPath.lineTo(corners[i].dx, corners[i].dy);
    }
    topPath.close();

    // Üst Yüzey Rengi (Temiz 3D Aydınlatmalı Yüzey)
    final Color topColor = _getBiomeTopColor(tileModel.biome);
    canvas.drawPath(topPath, Paint()..color = topColor);

    // İnce zarif faset ışıltısı
    final Paint highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(topPath, highlight);

    // Isıtılmış Karo Parıltısı
    if (tileModel.isWarmed) {
      final Paint warm = Paint()
        ..color = const Color(0x55F97316)
        ..style = PaintingStyle.fill;
      canvas.drawPath(topPath, warm);
    }

    // Seçim Vurgusu (İzometrik Altın Sarısı Çerçeve)
    if (isSelected) {
      final Paint selBorder = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawPath(topPath, selBorder);

      final Paint selGlow = Paint()
        ..color = const Color(0x44FFD700)
        ..style = PaintingStyle.fill;
      canvas.drawPath(topPath, selGlow);
    }
  }

  void _renderVoxelObjects(Canvas canvas, Offset center) {
    if (tileModel.hasBuilding) {
      final b = tileModel.building!;
      switch (b.type) {
        case BuildingType.castle:
          VoxelIsometricRenderer.drawVoxelCastle(canvas, center, b.level);
          break;
        case BuildingType.corn:
          VoxelIsometricRenderer.drawVoxelCropField(canvas, center);
          break;
        case BuildingType.lumberjack:
          VoxelIsometricRenderer.drawVoxelLumberjack(canvas, center);
          break;
        case BuildingType.windmill:
          VoxelIsometricRenderer.drawVoxelWindmill(canvas, center, _animTimer);
          break;
        case BuildingType.sawmill:
          VoxelIsometricRenderer.drawVoxelSawmill(canvas, center);
          break;
        case BuildingType.bakery:
          VoxelIsometricRenderer.drawVoxelBakery(canvas, center, _animTimer);
          break;
        case BuildingType.furniture:
          VoxelIsometricRenderer.drawVoxelFurniture(canvas, center);
          break;
        case BuildingType.worker:
          VoxelIsometricRenderer.drawVoxelLumberjack(canvas, center);
          break;
        case BuildingType.watchtower:
          VoxelIsometricRenderer.drawVoxelWatchtower(canvas, center);
          break;
        case BuildingType.mine:
          VoxelIsometricRenderer.drawVoxelMine(canvas, center);
          break;
        case BuildingType.bridge:
          VoxelIsometricRenderer.drawVoxelBridge(canvas, center);
          break;
      }
    } else {
      // Doğal Voxel Biyom Öğeleri
      switch (tileModel.biome) {
        case TileBiome.meadow:
          // Minik çim voxel küpleri
          VoxelIsometricRenderer.drawIsoCube(
            canvas,
            Offset(center.dx - 8, center.dy),
            w: 4.0,
            d: 4.0,
            h: 6.0,
            topColor: const Color(0xFFA3E635),
            leftColor: const Color(0xFF84CC16),
            rightColor: const Color(0xFF65A30D),
          );
          VoxelIsometricRenderer.drawIsoCube(
            canvas,
            Offset(center.dx + 6, center.dy - 4),
            w: 4.0,
            d: 4.0,
            h: 8.0,
            topColor: const Color(0xFFA3E635),
            leftColor: const Color(0xFF84CC16),
            rightColor: const Color(0xFF65A30D),
          );
          break;
        case TileBiome.forest:
          // 3D Bloklu Voxel Ağaçlar (Referans görseldeki gibi)
          VoxelIsometricRenderer.drawVoxelTree(canvas, Offset(center.dx - 4, center.dy + 4), scale: 0.95);
          VoxelIsometricRenderer.drawVoxelTree(canvas, Offset(center.dx + 12, center.dy - 6), scale: 0.7);
          break;
        case TileBiome.mountain:
          // 3D Kademeli Voxel Dağ Zirvesi
          VoxelIsometricRenderer.drawVoxelMountain(canvas, center);
          break;
        case TileBiome.sea:
          // Minik beyaz voxel dalga küpleri
          final double waveOffset = math.sin(_animTimer * 2.0) * 3.0;
          VoxelIsometricRenderer.drawIsoCube(
            canvas,
            Offset(center.dx + waveOffset, center.dy),
            w: 12.0,
            d: 4.0,
            h: 2.0,
            topColor: const Color(0xFFBAE6FD),
            leftColor: const Color(0xFF7DD3FC),
            rightColor: const Color(0xFF38BDF8),
          );
          break;
      }
    }
  }

  void _renderBrutalistBadges(Canvas canvas, Offset center) {
    if (!tileModel.hasBuilding) return;
    final b = tileModel.building!;

    // Seviye Rozeti (Voxel/Neo-Brutalist Kart)
    _drawBadge(
      canvas,
      center.dx,
      center.dy + 16,
      'LV.${b.level}',
      const Color(0xFF0F172A),
      const Color(0xFFFFD700),
    );

    // Birikmiş Üretim Rozeti
    if (b.accumulatedResource > 0) {
      _drawBadge(
        canvas,
        center.dx + 20,
        center.dy - 22,
        '+${b.accumulatedResource.toInt()}',
        const Color(0xFF10B981),
        Colors.black,
      );
    }
  }

  void _drawBadge(Canvas canvas, double x, double y, String text, Color bg, Color textCol) {
    const double w = 36.0;
    const double h = 16.0;
    final Rect rect = Rect.fromCenter(center: Offset(x, y), width: w, height: h);

    // Sert siyah gölge
    canvas.drawRect(rect.shift(const Offset(2, 2)), Paint()..color = Colors.black);
    // Kart
    canvas.drawRect(rect, Paint()..color = bg);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: textCol,
        fontSize: 9.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  Color _getBiomeTopColor(TileBiome biome) {
    final bool isWinter = season == 'WINTER';
    switch (biome) {
      case TileBiome.meadow:
        return isWinter ? const Color(0xFFE2E8F0) : const Color(0xFF86EFAC); // Canlı Diorama Yeşili
      case TileBiome.forest:
        return isWinter ? const Color(0xFFCBD5E1) : const Color(0xFF4ADE80); // Zengin Orman Yeşili
      case TileBiome.mountain:
        return isWinter ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8); // Kaya Grisi
      case TileBiome.sea:
        return isWinter ? const Color(0xFF60A5FA) : const Color(0xFF38BDF8); // Berrak Okyanus Mavisi
    }
  }

  (Color, Color, Color) _getBiome3DWallColors(TileBiome biome) {
    final bool isWinter = season == 'WINTER';
    switch (biome) {
      case TileBiome.meadow:
      case TileBiome.forest:
        if (isWinter) {
          return (const Color(0xFFCBD5E1), const Color(0xFF94A3B8), const Color(0xFF475569));
        }
        // Canlı çim kenarı + Ada altı toprak/kaya kütlesi (Referans görseldeki diorama ada tabanı)
        return (const Color(0xFF65A30D), const Color(0xFF4D7C0F), const Color(0xFF5C3A21));
      case TileBiome.mountain:
        if (isWinter) {
          return (const Color(0xFF94A3B8), const Color(0xFF64748B), const Color(0xFF334155));
        }
        return (const Color(0xFF64748B), const Color(0xFF475569), const Color(0xFF334155));
      case TileBiome.sea:
        return (const Color(0xFF0284C7), const Color(0xFF0369A1), const Color(0xFF075985));
    }
  }
}
