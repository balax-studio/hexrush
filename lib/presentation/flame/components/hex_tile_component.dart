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

  double _buildBounceTimer = 0.0;
  static const double _buildBounceDuration = 0.35;

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

    final bool buildingAdded = !tileModel.hasBuilding && newTileModel.hasBuilding;
    final bool buildingUpgraded = tileModel.hasBuilding &&
        newTileModel.hasBuilding &&
        newTileModel.building!.level > tileModel.building!.level;
    if (buildingAdded || buildingUpgraded) {
      _buildBounceTimer = _buildBounceDuration;
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
    if (_buildBounceTimer > 0) {
      _buildBounceTimer = (_buildBounceTimer - dt).clamp(0.0, _buildBounceDuration);
    }
  }

  @override
  void render(Canvas canvas) {
    // Dokunsal Pop / Yaylanma zıplaması
    double bounceOffset = 0.0;
    if (_bounceTimer > 0) {
      final double progress = 1.0 - (_bounceTimer / _bounceDuration);
      bounceOffset = math.sin(progress * math.pi) * 8.0;
    } else if (_buildBounceTimer > 0) {
      final double progress = 1.0 - (_buildBounceTimer / _buildBounceDuration);
      bounceOffset = math.sin(progress * math.pi) * 12.0;
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
    _renderVoxelObjects(canvas, center, corners);
    _renderRoads(canvas, center);

    // İnşaat / Yükseltme Sırasında Voksel Toz Patlaması (Construction Poof)
    if (_buildBounceTimer > 0) {
      final double progress = 1.0 - (_buildBounceTimer / _buildBounceDuration);
      VoxelIsometricRenderer.drawVoxelConstructionPoof(canvas, center, progress);
    }

    _renderBrutalistBadges(canvas, center);
  }

  double _getBiomeElevation(TileBiome biome) {
    if (tileModel.isFog) return 0.0;
    switch (biome) {
      case TileBiome.sea:
      case TileBiome.wetland:
        return 0.0;
      case TileBiome.meadow:
      case TileBiome.desert:
        return 10.0;
      case TileBiome.forest:
      case TileBiome.tundra:
        return 12.0;
      case TileBiome.mountain:
      case TileBiome.volcano:
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

    // 3D Voksel Canlı Sis Kubbesi, Gizem Işıltıları ve Keşif Fısıltıları
    final int seed = (coord.q * 37 + coord.r * 19).abs();
    final int distFromCenter = HexMath.hexDistance(coord, const HexAxial(0, 0));
    final bool isBorderFog = distFromCenter <= 5;

    VoxelIsometricRenderer.drawVoxelMysteryFog(
      canvas,
      center,
      seed: seed,
      hiddenBiome: tileModel.biome,
      hasShrine: tileModel.hasShrine,
      isBorderFog: isBorderFog,
      animTime: _animTimer,
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

    final int seed = (coord.q * 37 + coord.r * 19).abs();
    Color topColor = _getBiomeTopColor(tileModel.biome, seed);
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

  void _renderVoxelObjects(Canvas canvas, Offset center, List<Offset> corners) {
    final int seed = (coord.q * 31 + coord.r * 17).abs();

    if (tileModel.hasShrine) {
      VoxelIsometricRenderer.drawVoxelAncientShrine(
        canvas,
        center,
        shrineType: tileModel.shrine,
        animTime: _animTimer,
        isNight: isNight,
      );
    } else if (tileModel.hasBuilding) {
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
          VoxelIsometricRenderer.drawVoxelWatchtower(canvas, center, isNight: isNight, animTime: _animTimer);
          break;
        case BuildingType.mine:
          VoxelIsometricRenderer.drawVoxelMine(canvas, center, animTime: _animTimer, isNight: isNight);
          break;
        case BuildingType.bridge:
          VoxelIsometricRenderer.drawVoxelBridge(canvas, center);
          break;
        case BuildingType.fisherman:
          VoxelIsometricRenderer.drawVoxelFishermanBoat(canvas, center, animTime: _animTimer, isNight: isNight);
          break;
        case BuildingType.fishermanHut:
          VoxelIsometricRenderer.drawVoxelFishermanHut(canvas, center, animTime: _animTimer, isNight: isNight);
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
          _renderLivingSea(canvas, center, corners, seed);
          break;
        case TileBiome.desert:
          _renderLivingDesert(canvas, center, seed);
          break;
        case TileBiome.tundra:
          _renderLivingTundra(canvas, center, seed);
          break;
        case TileBiome.volcano:
          _renderLivingVolcano(canvas, center, seed);
          break;
        case TileBiome.wetland:
          _renderLivingWetland(canvas, center, seed);
          break;
      }
    }

    if (isNight && (tileModel.biome == TileBiome.forest || tileModel.biome == TileBiome.meadow || tileModel.biome == TileBiome.wetland)) {
      VoxelIsometricRenderer.drawVoxelFireflies(canvas, center, animTime: _animTimer, seed: seed);
    }
  }

  void _renderLivingForest(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    final bool isAutumn = season == 'AUTUMN';

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
        if (isAutumn) {
          VoxelIsometricRenderer.drawVoxelAutumnFoliage(canvas, Offset(center.dx + 4, center.dy + 6), scale: 0.85);
        } else {
          VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 6, center.dy + 6), scale: 0.85);
        }
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
          animTime: _animTimer,
          seed: seed,
          scale: 0.85,
        );
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelTree(
          canvas,
          Offset(center.dx + 6, center.dy - 4),
          scale: 1.05,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelPebbles(
          canvas,
          Offset(center.dx - 10, center.dy + 6),
          scale: 0.9,
        );
        break;
    }
  }

  void _renderLivingMeadow(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    final bool isSpring = season == 'SPRING';

    switch (variant) {
      case 0:
        if (isSpring) {
          VoxelIsometricRenderer.drawVoxelSpringPoppies(canvas, Offset(center.dx - 6, center.dy + 2), scale: 0.9);
        } else {
          VoxelIsometricRenderer.drawVoxelFlowers(
            canvas,
            Offset(center.dx - 8, center.dy + 4),
            flowerColor: const Color(0xFFFBBF24),
            scale: 0.85,
          );
        }
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx + 10, center.dy - 6),
          flowerColor: const Color(0xFFF43F5E),
          scale: 0.75,
        );
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelSheep(
          canvas,
          Offset(center.dx + 4, center.dy),
          animTime: _animTimer,
          seed: seed,
          scale: 0.9,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx - 12, center.dy - 4),
          flowerColor: const Color(0xFF38BDF8),
          scale: 0.8,
        );
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelTree(
          canvas,
          Offset(center.dx - 10, center.dy - 6),
          scale: 0.75,
          animTime: _animTimer,
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
    VoxelIsometricRenderer.drawVoxelMountainVariant(
      canvas,
      center,
      seed,
      season: season,
      isZud: isZud,
      animTime: _animTimer,
    );
    if (seed % 2 == 0) {
      VoxelIsometricRenderer.drawVoxelPebbles(
        canvas,
        Offset(center.dx + 14, center.dy + 8),
        scale: 0.75,
      );
    }
  }

  void _renderLivingSea(Canvas canvas, Offset center, List<Offset> corners, int seed) {
    final bool isWinter = season == 'WINTER' || isZud;
    if (isWinter) {
      VoxelIsometricRenderer.drawVoxelIceFloes(canvas, center, scale: 0.9, animTime: _animTimer);
      return;
    }

    // Doğal Kıyı Şeridi ve Dinamik Dalga Köpükleri
    VoxelIsometricRenderer.drawVoxelShorelineWaves(
      canvas,
      center,
      corners,
      animTime: _animTimer,
      seed: seed,
    );

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

    VoxelIsometricRenderer.drawVoxelLeapingFish(
      canvas,
      center,
      animTime: _animTimer,
      seed: seed,
    );
  }

  void _renderLivingDesert(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelSandDunes(canvas, Offset(center.dx - 4, center.dy + 2), scale: 0.9);
        VoxelIsometricRenderer.drawVoxelCactus(canvas, Offset(center.dx + 12, center.dy - 6), scale: 0.85);
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelCactus(canvas, Offset(center.dx - 6, center.dy), scale: 1.05);
        VoxelIsometricRenderer.drawVoxelDesertShrub(canvas, Offset(center.dx + 10, center.dy + 4), scale: 0.9);
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelSandDunes(canvas, center, scale: 1.1);
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelDesertShrub(canvas, Offset(center.dx - 8, center.dy - 4), scale: 1.0);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.8);
        break;
    }
  }

  void _renderLivingTundra(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelPermafrostSpire(canvas, Offset(center.dx - 4, center.dy - 2), scale: 0.95);
        VoxelIsometricRenderer.drawVoxelLichenRocks(canvas, Offset(center.dx + 10, center.dy + 6), scale: 0.85);
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelLichenRocks(canvas, Offset(center.dx - 6, center.dy), scale: 1.0);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 8, center.dy - 6), scale: 0.9);
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelPermafrostSpire(canvas, center, scale: 1.1);
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelPine(canvas, Offset(center.dx - 6, center.dy - 4), scale: 0.65, animTime: _animTimer);
        VoxelIsometricRenderer.drawVoxelLichenRocks(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.8);
        break;
    }
  }

  void _renderLivingVolcano(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelObsidianPillars(canvas, Offset(center.dx - 6, center.dy - 2), scale: 0.95, animTime: _animTimer);
        VoxelIsometricRenderer.drawVoxelMagmaVent(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.85, animTime: _animTimer);
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelMagmaVent(canvas, center, scale: 1.1, animTime: _animTimer);
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelObsidianPillars(canvas, center, scale: 1.15, animTime: _animTimer);
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelObsidianPillars(canvas, Offset(center.dx + 6, center.dy - 4), scale: 0.9, animTime: _animTimer);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx - 8, center.dy + 4), scale: 0.8);
        break;
    }
  }

  void _renderLivingWetland(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelReeds(canvas, Offset(center.dx - 6, center.dy - 2), scale: 0.95, animTime: _animTimer);
        VoxelIsometricRenderer.drawVoxelWaterLilies(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.85);
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelReeds(canvas, center, scale: 1.1, animTime: _animTimer);
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelWaterLilies(canvas, Offset(center.dx - 4, center.dy), scale: 1.0);
        VoxelIsometricRenderer.drawVoxelLeapingFish(canvas, Offset(center.dx + 8, center.dy + 4), animTime: _animTimer, seed: seed);
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelReeds(canvas, Offset(center.dx + 6, center.dy - 4), scale: 0.9, animTime: _animTimer);
        VoxelIsometricRenderer.drawVoxelBirchTree(canvas, Offset(center.dx - 8, center.dy + 4), scale: 0.6, animTime: _animTimer);
        break;
    }
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

  Color _getBiomeTopColor(TileBiome biome, int seed) {
    final bool isWinter = season == 'WINTER' || isZud;
    final bool isAutumn = season == 'AUTUMN';
    final bool isSummer = season == 'SUMMER';

    Color baseColor;
    switch (biome) {
      case TileBiome.meadow:
        if (isWinter) {
          baseColor = const Color(0xFFE2E8F0);
        } else if (isAutumn) {
          baseColor = const Color(0xFFFBBF24);
        } else if (isSummer) {
          baseColor = const Color(0xFF4ADE80);
        } else {
          baseColor = const Color(0xFF86EFAC);
        }
        break;

      case TileBiome.forest:
        if (isWinter) {
          baseColor = const Color(0xFFCBD5E1);
        } else if (isAutumn) {
          baseColor = const Color(0xFFEA580C);
        } else if (isSummer) {
          baseColor = const Color(0xFF16A34A);
        } else {
          baseColor = const Color(0xFF22C55E);
        }
        break;

      case TileBiome.mountain:
        if (isWinter) {
          baseColor = const Color(0xFFF8FAFC);
        } else if (isAutumn) {
          baseColor = const Color(0xFF78350F);
        } else {
          baseColor = const Color(0xFF94A3B8);
        }
        break;

      case TileBiome.sea:
        if (isWinter) {
          baseColor = const Color(0xFFBAE6FD);
        } else if (isAutumn) {
          baseColor = const Color(0xFF0284C7);
        } else {
          baseColor = const Color(0xFF38BDF8);
        }
        break;

      case TileBiome.desert:
        if (isWinter) {
          baseColor = const Color(0xFFFEF08A);
        } else if (isAutumn) {
          baseColor = const Color(0xFFD97706);
        } else if (isSummer) {
          baseColor = const Color(0xFFF59E0B);
        } else {
          baseColor = const Color(0xFFFDE047);
        }
        break;

      case TileBiome.tundra:
        if (isWinter) {
          baseColor = const Color(0xFFE0F2FE);
        } else if (isAutumn) {
          baseColor = const Color(0xFFC084FC);
        } else {
          baseColor = const Color(0xFF93C5FD);
        }
        break;

      case TileBiome.volcano:
        baseColor = const Color(0xFF1E293B);
        break;

      case TileBiome.wetland:
        if (isWinter) {
          baseColor = const Color(0xFF94A3B8);
        } else if (isAutumn) {
          baseColor = const Color(0xFFA3E635);
        } else {
          baseColor = const Color(0xFF34D399);
        }
        break;
    }

    // Doğal Ton Çeşitliliği (Procedural Shade Variance): Bitişik aynı biyomların mozaik gibi ayrışmasını sağlar
    final int shadeVariant = seed % 4;
    switch (shadeVariant) {
      case 0:
        return baseColor;
      case 1:
        return Color.lerp(baseColor, Colors.white, 0.09)!;
      case 2:
        return Color.lerp(baseColor, const Color(0xFF0F172A), 0.08)!;
      case 3:
      default:
        return Color.lerp(baseColor, const Color(0xFFFDE047), 0.07)!;
    }
  }

  (Color, Color, Color) _getBiome3DWallColors(TileBiome biome) {
    final bool isWinter = season == 'WINTER' || isZud;
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

      case TileBiome.desert:
        return (const Color(0xFFD97706), const Color(0xFFB45309), const Color(0xFF78350F));

      case TileBiome.tundra:
        return (const Color(0xFF60A5FA), const Color(0xFF3B82F6), const Color(0xFF1D4ED8));

      case TileBiome.volcano:
        return (const Color(0xFF0F172A), const Color(0xFF020617), const Color(0xFF450A0A));

      case TileBiome.wetland:
        return (const Color(0xFF059669), const Color(0xFF047857), const Color(0xFF064E3B));
    }
  }
}
