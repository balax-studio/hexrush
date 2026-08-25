import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../../../domain/models/building_model.dart';
import '../../../domain/models/hex_tile_model.dart';
import '../hex_map_game.dart';
import '../renderers/voxel_isometric_renderer.dart';

class HexTileComponent extends PositionComponent {
  final HexAxial coord;
  HexTileModel tileModel;
  bool isSelected;
  String season;
  bool isZud;
  bool isNight;

  final void Function(HexAxial coord)? onTileTapped;

  double _animTimer = 0.0;
  double _bounceTimer = 0.0;
  static const double _bounceDuration = 0.25;

  double _buildBounceTimer = 0.0;
  static const double _buildBounceDuration = 0.35;

  // Sis Dağılma & Keşif Efekti (Fog of War Reveal Engine)
  double _revealTimer = 0.0;
  static const double _revealDuration = 0.65;

  // Organik Mevsim Geçişi (Season Cross-Fade & Melting Engine)
  String _previousSeason = 'SPRING';
  String _currentSeason = 'SPRING';
  double _seasonTransitionTimer = 0.0;
  static const double _seasonTransitionDuration = 2.0;

  static const double hexRadius = 52.0;
  static const double baseDepth3D = 20.0;

  // Pre-allocated corner arrays for zero-GC rendering
  final List<Offset> _corners = List.filled(6, Offset.zero);
  final List<Offset> _groundCorners = List.filled(6, Offset.zero);
  final List<Offset> _mistCorners = List.filled(6, Offset.zero);

  // Zero-GC Reusable static drawing tools
  static final Paint _sharedFillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _sharedStrokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _highlightPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _selectBorderPaint = Paint()
    ..color = const Color(0xFFFFD700)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;
  static final Paint _warmPaint = Paint()
    ..color = const Color(0x55F97316)
    ..style = PaintingStyle.fill;
  static final Paint _badgeShadowPaint = Paint()..color = Colors.black;

  static final Path _fogPath = Path();
  static final Path _wallPath = Path();
  static final Path _topPath = Path();

  HexTileComponent({
    required this.coord,
    required this.tileModel,
    required this.isSelected,
    required this.season,
    required this.isZud,
    this.isNight = false,
    this.onTileTapped,
  })  : _previousSeason = season,
        _currentSeason = season,
        super(
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

    // Sis Açılma Geçişi Tespiti (Fog -> Discovered)
    if (tileModel.isFog && !newTileModel.isFog) {
      _revealTimer = _revealDuration;
    }

    // Mevsim Değişimi Geçişi Tespiti
    if (newSeason != _currentSeason) {
      _previousSeason = _currentSeason;
      _currentSeason = newSeason;
      _seasonTransitionTimer = _seasonTransitionDuration;
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
    if (_revealTimer > 0) {
      _revealTimer = (_revealTimer - dt).clamp(0.0, _revealDuration);
    }
    if (_seasonTransitionTimer > 0) {
      _seasonTransitionTimer = (_seasonTransitionTimer - dt).clamp(0.0, _seasonTransitionDuration);
    }
  }

  @override
  void render(Canvas canvas) {
    // Frustum / Viewport Culling: Ekran dışındaki karoları çizme
    final game = findGame();
    if (game is HexMapGame) {
      final Rect bounds = game.visibleWorldBounds;
      if (position.x < bounds.left ||
          position.x > bounds.right ||
          position.y < bounds.top ||
          position.y > bounds.bottom) {
        return;
      }
    }

    // Dokunsal Pop / Yaylanma zıplaması
    double bounceOffset = 0.0;
    if (_bounceTimer > 0) {
      final double progress = 1.0 - (_bounceTimer / _bounceDuration);
      bounceOffset = math.sin(progress * math.pi) * 8.0;
    } else if (_buildBounceTimer > 0) {
      final double progress = 1.0 - (_buildBounceTimer / _buildBounceDuration);
      bounceOffset = math.sin(progress * math.pi) * 12.0;
    }

    final double elevation = getBiomeElevation(tileModel.biome, isFog: tileModel.isFog) + bounceOffset;
    final Offset center = Offset(size.x / 2, size.y / 2 - elevation);
    HexMath.getHexCornersInto(_corners, center, hexSize: hexRadius, yScale: HexMath.defaultYScale);

    // 1. TAM SİSLİ KARO
    if (tileModel.isFog) {
      _renderVoxelFog(canvas, _corners, center, alpha: 1.0, floatY: 0.0);
      return;
    }

    // 2. SİS DAĞILMA GEÇİŞİ (0.65s Organic Dissolve & Ground Rise)
    if (_revealTimer > 0) {
      final double progress = 1.0 - (_revealTimer / _revealDuration);
      final double eased = Curves.easeOutCubic.transform(progress);

      // Yükselen zemin (Aşağıdan yumuşakça yükselerek belirir)
      final double groundElevation = elevation - (1.0 - eased) * 14.0;
      final Offset groundCenter = Offset(size.x / 2, size.y / 2 - groundElevation);
      HexMath.getHexCornersInto(_groundCorners, groundCenter, hexSize: hexRadius, yScale: HexMath.defaultYScale);

      _render3DExtrudedWalls(canvas, _groundCorners, groundElevation);
      _renderIsometricTopFace(canvas, _groundCorners, groundCenter);
      _renderVoxelObjects(canvas, groundCenter, _groundCorners);
      _renderBrutalistBadges(canvas, groundCenter);

      // Yukarı doğru dağılarak kaybolan sis katmanı
      final double mistAlpha = (1.0 - eased).clamp(0.0, 1.0);
      final double mistFloatY = eased * 30.0;
      _renderVoxelFog(canvas, _corners, center, alpha: mistAlpha, floatY: mistFloatY);
      return;
    }

    // 3. NORMAL AÇIK KARO RENDER
    _render3DExtrudedWalls(canvas, _corners, elevation);
    _renderIsometricTopFace(canvas, _corners, center);
    _renderVoxelObjects(canvas, center, _corners);

    // İnşaat / Yükseltme Sırasında Voksel Toz Patlaması (Construction Poof)
    if (_buildBounceTimer > 0) {
      final double progress = 1.0 - (_buildBounceTimer / _buildBounceDuration);
      VoxelIsometricRenderer.drawVoxelConstructionPoof(canvas, center, progress);
    }

    _renderBrutalistBadges(canvas, center);
  }

  static double getBiomeElevation(TileBiome biome, {bool isFog = false}) {
    if (isFog) return 0.0;
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

  void _renderVoxelFog(
    Canvas canvas,
    List<Offset> corners,
    Offset center, {
    double alpha = 1.0,
    double floatY = 0.0,
  }) {
    if (alpha <= 0.01) return;

    final Offset mistCenter = Offset(center.dx, center.dy - floatY);
    HexMath.getHexCornersInto(_mistCorners, mistCenter, hexSize: hexRadius, yScale: HexMath.defaultYScale);

    _fogPath
      ..reset()
      ..moveTo(_mistCorners[0].dx, _mistCorners[0].dy);
    for (int i = 1; i < 6; i++) {
      _fogPath.lineTo(_mistCorners[i].dx, _mistCorners[i].dy);
    }
    _fogPath.close();

    _sharedFillPaint
      ..color = const Color(0xFF0F172A).withValues(alpha: (0.92 * alpha).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawPath(_fogPath, _sharedFillPaint);

    _sharedStrokePaint
      ..color = const Color(0xFF1E293B).withValues(alpha: alpha.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(_fogPath, _sharedStrokePaint);

    // 3D Voksel Canlı Sis Kubbesi, Gizem Işıltıları ve Keşif Fısıltıları
    final int seed = (coord.q * 37 + coord.r * 19).abs();
    final int distFromCenter = HexMath.hexDistance(coord, const HexAxial(0, 0));
    final bool isBorderFog = distFromCenter <= 5;

    VoxelIsometricRenderer.drawVoxelMysteryFog(
      canvas,
      mistCenter,
      seed: seed,
      hiddenBiome: tileModel.biome,
      hasShrine: tileModel.hasShrine,
      isBorderFog: isBorderFog,
      animTime: _animTimer,
      alpha: alpha,
      disperseRise: floatY,
    );
  }

  void _render3DExtrudedWalls(Canvas canvas, List<Offset> corners, double elevation) {
    final double wallH = baseDepth3D + elevation;
    final (wallLeft, wallRight, bedrock) = _getBiome3DWallColors(tileModel.biome);

    _sharedFillPaint.style = PaintingStyle.fill;
    for (int i = 1; i <= 3; i++) {
      final pA = corners[i];
      final pB = corners[(i + 1) % 6];

      _wallPath
        ..reset()
        ..moveTo(pA.dx, pA.dy)
        ..lineTo(pB.dx, pB.dy)
        ..lineTo(pB.dx, pB.dy + wallH)
        ..lineTo(pA.dx, pA.dy + wallH)
        ..close();

      final Color col = i == 1
          ? wallLeft
          : (i == 2 ? wallRight : bedrock);

      _sharedFillPaint.color = col;
      canvas.drawPath(_wallPath, _sharedFillPaint);
    }
  }

  void _renderIsometricTopFace(Canvas canvas, List<Offset> corners, Offset center) {
    _topPath
      ..reset()
      ..moveTo(corners[0].dx, corners[0].dy);
    for (int i = 1; i < 6; i++) {
      _topPath.lineTo(corners[i].dx, corners[i].dy);
    }
    _topPath.close();

    final int seed = (coord.q * 37 + coord.r * 19).abs();
    Color topColor = _getBiomeTopColor(tileModel.biome, seed);
    if (isNight) {
      topColor = Color.lerp(topColor, const Color(0xFF0F172A), 0.45)!;
    }
    _sharedFillPaint
      ..style = PaintingStyle.fill
      ..color = topColor;
    canvas.drawPath(_topPath, _sharedFillPaint);

    _highlightPaint.color = Colors.white.withValues(alpha: isNight ? 0.05 : 0.12);
    canvas.drawPath(_topPath, _highlightPaint);

    if (tileModel.isWarmed) {
      canvas.drawPath(_topPath, _warmPaint);
    }

    // Seçili Karo Neo-Brutalist Sarı Vurgusu
    if (isSelected) {
      canvas.drawPath(_topPath, _selectBorderPaint);
    }
  }

  void _renderVoxelObjects(Canvas canvas, Offset center, List<Offset> corners) {
    final int seed = (coord.q * 37 + coord.r * 19).abs();

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
        case BuildingType.shrine:
          VoxelIsometricRenderer.drawVoxelAncientShrine(
            canvas,
            center,
            shrineType: tileModel.shrine,
            animTime: _animTimer,
            isNight: isNight,
          );
          break;
        default:
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
  }

  void _renderLivingForest(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    final bool isAutumn = season == 'AUTUMN';

    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelTree(
          canvas,
          Offset(center.dx - 8, center.dy - 6),
          scale: 1.1,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelBirchTree(
          canvas,
          Offset(center.dx + 10, center.dy + 2),
          scale: 0.8,
          animTime: _animTimer,
        );
        VoxelIsometricRenderer.drawVoxelMushroom(
          canvas,
          Offset(center.dx + 4, center.dy + 8),
          scale: 0.9,
        );
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelPine(
          canvas,
          Offset(center.dx, center.dy - 6),
          scale: 1.15,
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
        // Ara sıra dinlenen yalnız koyun
        if (seed % 2 == 0) {
          VoxelIsometricRenderer.drawVoxelSheep(
            canvas,
            Offset(center.dx - 4, center.dy - 2),
            animTime: _animTimer,
            seed: seed * 11 + 3,
            scale: 0.85,
          );
        }
        break;

      case 1:
        // Anne Koyun & Küçük Kuzu Sürüsü
        VoxelIsometricRenderer.drawVoxelSheep(
          canvas,
          Offset(center.dx + 6, center.dy - 3),
          animTime: _animTimer,
          seed: seed,
          scale: 0.95,
        );
        VoxelIsometricRenderer.drawVoxelSheep(
          canvas,
          Offset(center.dx - 10, center.dy + 5),
          animTime: _animTimer,
          seed: seed * 19 + 7,
          scale: 0.72,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx + 12, center.dy + 8),
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
        // Ağaç altında otlayan koyun
        if (seed % 3 == 0) {
          VoxelIsometricRenderer.drawVoxelSheep(
            canvas,
            Offset(center.dx + 4, center.dy + 4),
            animTime: _animTimer,
            seed: seed * 13 + 5,
            scale: 0.85,
          );
        }
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
      topColor: const Color(0xFFBAE6FD).withValues(alpha: 0.7),
      leftColor: const Color(0xFF7DD3FC).withValues(alpha: 0.5),
      rightColor: const Color(0xFF38BDF8).withValues(alpha: 0.5),
    );

    if (seed % 3 == 0) {
      VoxelIsometricRenderer.drawVoxelLeapingFish(
        canvas,
        center,
        animTime: _animTimer,
        seed: seed,
      );
    }
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

    if (b.type != BuildingType.shrine && b.type != BuildingType.bridge) {
      _drawBadge(
        canvas,
        center.dx,
        center.dy + 16,
        'LV.${b.level}',
        const Color(0xFF0F172A),
        const Color(0xFFFFD700),
      );
    }

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

    canvas.drawRect(rect.shift(const Offset(2, 2)), _badgeShadowPaint);
    _sharedFillPaint
      ..style = PaintingStyle.fill
      ..color = bg;
    canvas.drawRect(rect, _sharedFillPaint);
    _sharedStrokePaint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRect(rect, _sharedStrokePaint);

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
    final double blend = _seasonTransitionTimer > 0
        ? (1.0 - (_seasonTransitionTimer / _seasonTransitionDuration)).clamp(0.0, 1.0)
        : 1.0;

    final Color fromColor = _getBiomeTopColorForSeason(biome, _previousSeason, false, seed);
    final Color toColor = _getBiomeTopColorForSeason(biome, _currentSeason, isZud, seed);

    return Color.lerp(fromColor, toColor, blend) ?? toColor;
  }

  Color _getBiomeTopColorForSeason(TileBiome biome, String targetSeason, bool targetZud, int seed) {
    final bool isWinter = targetSeason == 'WINTER' || targetZud;
    final bool isAutumn = targetSeason == 'AUTUMN';
    final bool isSummer = targetSeason == 'SUMMER';

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
    final double blend = _seasonTransitionTimer > 0
        ? (1.0 - (_seasonTransitionTimer / _seasonTransitionDuration)).clamp(0.0, 1.0)
        : 1.0;

    final (fL, fR, fB) = _getBiome3DWallColorsForSeason(biome, _previousSeason, false);
    final (tL, tR, tB) = _getBiome3DWallColorsForSeason(biome, _currentSeason, isZud);

    return (
      Color.lerp(fL, tL, blend) ?? tL,
      Color.lerp(fR, tR, blend) ?? tR,
      Color.lerp(fB, tB, blend) ?? tB,
    );
  }

  (Color, Color, Color) _getBiome3DWallColorsForSeason(TileBiome biome, String targetSeason, bool targetZud) {
    final bool isWinter = targetSeason == 'WINTER' || targetZud;
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
