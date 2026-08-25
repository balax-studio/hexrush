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
  bool isNight;

  double _animTimer = 0.0;
  double _bounceTimer = 0.0;
  static const double _bounceDuration = 0.25;

  static const double hexRadius = 52.0;
  static const double baseDepth3D = 20.0;

  HexTileComponent({
    required this.coord,
    required this.tileModel,
    required this.isSelected,
    required this.season,
    required this.isZud,
    this.isNight = false,
  }) : super(
          position: Vector2(
            HexMath.hexToPixel(coord, hexSize: hexRadius).dx,
            HexMath.hexToPixel(coord, hexSize: hexRadius).dy,
          ),
          size: Vector2(hexRadius * 2.2, hexRadius * 2.5),
          anchor: Anchor.center,
        );

  void triggerTapBounce() {
    _bounceTimer = _bounceDuration;
  }

  void updateData({
    required HexTileModel newTileModel,
    required bool newIsSelected,
    required String newSeason,
    required bool newIsZud,
    bool? newIsNight,
  }) {
    if (!isSelected && newIsSelected) {
      triggerTapBounce();
    }
    tileModel = newTileModel;
    isSelected = newIsSelected;
    season = newSeason;
    isZud = newIsZud;
    if (newIsNight != null) isNight = newIsNight;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
    if (_bounceTimer > 0) {
      _bounceTimer = (_bounceTimer - dt).clamp(0.0, _bounceDuration);
    }
  }

  @override
  void render(Canvas canvas) {
    // Dokunsal Pop / Yaylanma zıplaması
    double bounceOffset = 0.0;
    if (_bounceTimer > 0) {
      final double progress = 1.0 - (_bounceTimer / _bounceDuration);
      bounceOffset = math.sin(progress * math.pi) * 8.0;
    }

    final double elevation = _getBiomeElevation(tileModel.biome) + bounceOffset;
    final Offset center = Offset(size.x / 2, size.y / 2 - elevation);
    final corners = HexMath.getHexCorners(center, hexSize: hexRadius, yScale: HexMath.defaultYScale);

    if (tileModel.isFog) {
      _renderVoxelFog(canvas, corners, center);
      return;
    }

    _render3DExtrudedWalls(canvas, corners, elevation);
    _renderIsometricTopFace(canvas, corners, center);
    _renderVoxelObjects(canvas, center);
    _renderRoads(canvas, center);
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

    final Paint fogFill = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fogFill);

    final Paint border = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, border);

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

    Color topColor = _getBiomeTopColor(tileModel.biome);
    if (isNight) {
      topColor = Color.lerp(topColor, const Color(0xFF0F172A), 0.45)!;
    }
    canvas.drawPath(topPath, Paint()..color = topColor);

    final Paint highlight = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.05 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(topPath, highlight);

    if (tileModel.isWarmed) {
      final Paint warm = Paint()
        ..color = const Color(0x55F97316)
        ..style = PaintingStyle.fill;
      canvas.drawPath(topPath, warm);
    }

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

  void _renderRoads(Canvas canvas, Offset center) {
    // Şato ve diğer binalar arasında minik bağlantı patikası
    if (tileModel.isOwned && tileModel.hasBuilding && coord != const HexAxial(0, 0)) {
      final castlePixel = HexMath.hexToPixel(const HexAxial(0, 0), hexSize: hexRadius);
      final myPixel = HexMath.hexToPixel(coord, hexSize: hexRadius);
      final Offset dir = Offset(castlePixel.dx - myPixel.dx, castlePixel.dy - myPixel.dy);

      final double len = math.sqrt(dir.dx * dir.dx + dir.dy * dir.dy);
      if (len > 0 && len < hexRadius * 2.2) {
        final Offset roadEnd = Offset(center.dx + (dir.dx / len) * 20.0, center.dy + (dir.dy / len) * 20.0);
        VoxelIsometricRenderer.drawVoxelRoadSegment(canvas, center, roadEnd);
      }
    }
  }

  void _renderVoxelObjects(Canvas canvas, Offset center) {
    final int seed = (coord.q * 31 + coord.r * 17).abs();

    if (tileModel.hasBuilding) {
      final b = tileModel.building!;
      switch (b.type) {
        case BuildingType.castle:
          VoxelIsometricRenderer.drawVoxelCastle(canvas, center, b.level, isNight: isNight);
          break;
        case BuildingType.corn:
          VoxelIsometricRenderer.drawVoxelCropField(canvas, center, animTime: _animTimer);
          break;
        case BuildingType.lumberjack:
          VoxelIsometricRenderer.drawVoxelLumberjack(canvas, center);
          break;
        case BuildingType.windmill:
          VoxelIsometricRenderer.drawVoxelWindmill(canvas, center, _animTimer, isNight: isNight);
          break;
        case BuildingType.sawmill:
          VoxelIsometricRenderer.drawVoxelSawmill(canvas, center);
          break;
        case BuildingType.bakery:
          VoxelIsometricRenderer.drawVoxelBakery(canvas, center, _animTimer, isNight: isNight);
          break;
        case BuildingType.furniture:
          VoxelIsometricRenderer.drawVoxelFurniture(canvas, center);
          break;
        case BuildingType.worker:
          VoxelIsometricRenderer.drawVoxelLumberjack(canvas, center);
          break;
        case BuildingType.watchtower:
          VoxelIsometricRenderer.drawVoxelWatchtower(canvas, center, isNight: isNight);
          break;
        case BuildingType.mine:
          VoxelIsometricRenderer.drawVoxelMine(canvas, center);
          break;
        case BuildingType.bridge:
          VoxelIsometricRenderer.drawVoxelBridge(canvas, center);
          break;
        case BuildingType.fisherman:
          VoxelIsometricRenderer.drawVoxelLumberjack(canvas, center); // Geçici olarak oduncu görseli
          break;
        case BuildingType.fishermanHut:
          VoxelIsometricRenderer.drawVoxelBakery(canvas, center, _animTimer, isNight: isNight); // Geçici olarak fırın görseli
          break;
      }
    } else {
      switch (tileModel.biome) {
        case TileBiome.meadow:
          _renderLivingMeadow(canvas, center, seed);
          break;
        case TileBiome.forest:
          _renderLivingForest(canvas, center, seed);
          break;
        case TileBiome.mountain:
          _renderLivingMountain(canvas, center, seed);
          break;
        case TileBiome.sea:
          _renderLivingSea(canvas, center, seed);
          break;
      }
    }

    // Gece Ateşböcekleri (Orman ve Çayırlarda)
    if (isNight && (tileModel.biome == TileBiome.forest || tileModel.biome == TileBiome.meadow)) {
      VoxelIsometricRenderer.drawVoxelFireflies(canvas, center, animTime: _animTimer, seed: seed);
    }
  }

  void _renderLivingForest(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;

    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelTree(
          canvas,
          Offset(center.dx - 6, center.dy + 4),
          scale: 0.95,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelPine(
          canvas,
          Offset(center.dx + 12, center.dy - 6),
          scale: 0.85,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelMushroom(canvas, Offset(center.dx - 14, center.dy - 2), scale: 0.9);
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelBirchTree(
          canvas,
          Offset(center.dx - 8, center.dy + 2),
          scale: 1.0,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelBirchTree(
          canvas,
          Offset(center.dx + 10, center.dy - 8),
          scale: 0.75,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 6, center.dy + 6), scale: 0.85);
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelPine(
          canvas,
          Offset(center.dx + 10, center.dy - 4),
          scale: 1.0,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelPine(
          canvas,
          Offset(center.dx - 12, center.dy - 8),
          scale: 0.7,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelDeer(
          canvas,
          Offset(center.dx - 2, center.dy + 6),
          animTime: _animTimer + seed,
          scale: 0.85,
        );
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelTree(
          canvas,
          Offset(center.dx - 4, center.dy + 2),
          scale: 1.0,
          foliageTint: const Color(0xFF34D399),
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelTree(
          canvas,
          Offset(center.dx + 12, center.dy - 4),
          scale: 0.75,
          foliageTint: const Color(0xFFFBBF24),
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx - 12, center.dy + 8),
          flowerColor: const Color(0xFFF43F5E),
          scale: 0.9,
        );
        break;
    }
  }

  void _renderLivingMeadow(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;

    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelSheep(
          canvas,
          Offset(center.dx - 2, center.dy + 2),
          animTime: _animTimer + seed,
          scale: 0.9,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx + 12, center.dy - 6),
          flowerColor: const Color(0xFFEC4899),
          scale: 0.8,
        );
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx - 8, center.dy + 2),
          flowerColor: const Color(0xFFEF4444),
          scale: 0.9,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx + 8, center.dy - 4),
          flowerColor: const Color(0xFF38BDF8),
          scale: 0.85,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx - 2, center.dy - 8),
          flowerColor: const Color(0xFFFACC15),
          scale: 0.8,
        );
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelPebbles(
          canvas,
          Offset(center.dx - 4, center.dy + 2),
          scale: 0.95,
        );
        VoxelIsometricRenderer.drawIsoCube(
          canvas,
          Offset(center.dx + 10, center.dy - 4),
          w: 4.0,
          d: 4.0,
          h: 7.0,
          topColor: const Color(0xFFA3E635),
          leftColor: const Color(0xFF84CC16),
          rightColor: const Color(0xFF65A30D),
        );
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelBirchTree(
          canvas,
          Offset(center.dx - 6, center.dy - 2),
          scale: 0.65,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx + 8, center.dy + 4),
          flowerColor: const Color(0xFFA855F7),
          scale: 0.85,
        );
        break;
    }
  }

  void _renderLivingMountain(Canvas canvas, Offset center, int seed) {
    VoxelIsometricRenderer.drawVoxelMountain(canvas, center);
    if (seed % 2 == 0) {
      VoxelIsometricRenderer.drawVoxelPebbles(
        canvas,
        Offset(center.dx + 14, center.dy + 8),
        scale: 0.75,
      );
    }
  }

  void _renderLivingSea(Canvas canvas, Offset center, int seed) {
    final double waveOffset = math.sin(_animTimer * 2.0 + (seed % 5)) * 3.5;
    VoxelIsometricRenderer.drawIsoCube(
      canvas,
      Offset(center.dx + waveOffset, center.dy),
      w: 14.0,
      d: 5.0,
      h: 2.0,
      topColor: const Color(0xFFBAE6FD),
      leftColor: const Color(0xFF7DD3FC),
      rightColor: const Color(0xFF38BDF8),
    );

    // Sıçrayan Gümüş Balıklar
    VoxelIsometricRenderer.drawVoxelLeapingFish(
      canvas,
      center,
      animTime: _animTimer,
      seed: seed,
    );
  }

  void _renderBrutalistBadges(Canvas canvas, Offset center) {
    if (!tileModel.hasBuilding) return;
    final b = tileModel.building!;

    _drawBadge(
      canvas,
      center.dx,
      center.dy + 16,
      'LV.${b.level}',
      const Color(0xFF0F172A),
      const Color(0xFFFFD700),
    );

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

    canvas.drawRect(rect.shift(const Offset(2, 2)), Paint()..color = Colors.black);
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
        return isWinter ? const Color(0xFFE2E8F0) : const Color(0xFF86EFAC);
      case TileBiome.forest:
        return isWinter ? const Color(0xFFCBD5E1) : const Color(0xFF4ADE80);
      case TileBiome.mountain:
        return isWinter ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8);
      case TileBiome.sea:
        return isWinter ? const Color(0xFF60A5FA) : const Color(0xFF38BDF8);
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
