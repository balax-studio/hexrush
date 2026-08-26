import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../domain/models/building_model.dart';
import '../../../domain/models/hex_tile_model.dart';
import '../../../domain/services/symbiosis_engine.dart';
import '../hex_map_game.dart';
import '../renderers/voxel_isometric_renderer.dart';

class HexTileComponent extends PositionComponent {
  final HexAxial coord;
  HexTileModel tileModel;
  bool isSelected;
  bool isInWorkerRange;
  bool isHarvestHighlight;
  String season;
  bool isZud;
  bool isNight;
  String themePalette;

  // Zero-GC Cached Paint Objects
  static final Paint _workerRangeBorderPaint = Paint()
    ..color = const Color(0x6638BDF8) // Translucent sky blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  static final Paint _harvestTargetBorderPaint = Paint()
    ..color = const Color(0xFF38BDF8) // Solid sky blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  static final Paint _harvestTargetFillPaint = Paint()
    ..color = const Color(0x2A38BDF8)
    ..style = PaintingStyle.fill;

  final void Function(HexAxial coord)? onTileTapped;

  double _animTimer = 0.0;
  double get tileAnimTime => _animTimer + ((coord.q * 37 + coord.r * 19).abs() % 100) * 0.05;
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
    ..color = const Color(0xFFF97316)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  static final Paint _warmFillPaint = Paint()
    ..color = const Color(0x22F97316)
    ..style = PaintingStyle.fill;
  static final Paint _badgeShadowPaint = Paint()..color = Colors.black;
  static final Paint _unownedTopScrimPaint = Paint()
    ..color = const Color(0x18020617)
    ..style = PaintingStyle.fill;
  static final Paint _unownedBorderPaint = Paint()
    ..color = const Color(0x3A000000)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _ownedTerritoryBorderPaint = Paint()
    ..color = const Color(0x55D97706)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  static final Path _fogPath = Path();
  static final Path _wallPath = Path();
  static final Path _topPath = Path();

  HexTileComponent({
    required this.coord,
    required this.tileModel,
    required this.isSelected,
    this.isInWorkerRange = false,
    this.isHarvestHighlight = false,
    required this.season,
    required this.isZud,
    this.isNight = false,
    this.themePalette = 'basalt',
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
    bool newIsInWorkerRange = false,
    bool newIsHarvestHighlight = false,
    required String newSeason,
    required bool newIsZud,
    bool? newIsNight,
    String? newThemePalette,
  }) {
    if (!isSelected && newIsSelected) {
      triggerTapBounce();
    }
    if (newThemePalette != null) {
      themePalette = newThemePalette;
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
    isInWorkerRange = newIsInWorkerRange;
    isHarvestHighlight = newIsHarvestHighlight;
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

    // 3. NORMAL AÇIK KARO RENDER (Sahip Olunan Parlak/Canlı, Sahip Olunmayan Karartılmış/Silik)
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
      case TileBiome.celestialCrater:
        return 14.0;
      case TileBiome.kurganValley:
        return 16.0;
      case TileBiome.crystalChasm:
        return 8.0;
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

    final double highlightAlpha = !tileModel.isOwned
        ? (isNight ? 0.02 : 0.05)
        : (isNight ? 0.05 : 0.12);
    _highlightPaint.color = Colors.white.withValues(alpha: highlightAlpha);
    canvas.drawPath(_topPath, _highlightPaint);

    // Sahipsiz / Keşfedilmiş Arazi: Silikleştirme ve karartma zemin katmanı
    if (!tileModel.isOwned) {
      canvas.drawPath(_topPath, _unownedTopScrimPaint);
      canvas.drawPath(_topPath, _unownedBorderPaint);
    } else if (!isSelected) {
      canvas.drawPath(_topPath, _ownedTerritoryBorderPaint);
    }

    if (tileModel.isWarmed) {
      canvas.drawPath(_topPath, _warmFillPaint);
      canvas.drawPath(_topPath, _warmPaint);
    }

    // İşçi Kulübesi 4 Hex Menzili Aurası
    if (isInWorkerRange && !isSelected) {
      canvas.drawPath(_topPath, _workerRangeBorderPaint);
    }

    // Menzil İçindeki Üretim Yapısı Vurgusu
    if (isHarvestHighlight && !isSelected) {
      canvas.drawPath(_topPath, _harvestTargetFillPaint);
      canvas.drawPath(_topPath, _harvestTargetBorderPaint);
    }

    // Seçili Karo Neo-Brutalist Sarı Vurgusu
    if (isSelected) {
      canvas.drawPath(_topPath, _selectBorderPaint);
    }
  }

  void _renderVoxelObjects(Canvas canvas, Offset center, List<Offset> corners) {
    final int seed = (coord.q * 37 + coord.r * 19).abs();
    final double tTime = tileAnimTime;
    final double windWave = VoxelIsometricRenderer.getSteppeWindWave(tTime, coord.q, coord.r);
    final double tapProgress = _bounceTimer > 0 ? (1.0 - (_bounceTimer / _bounceDuration)) : 0.0;

    if (tileModel.hasShrine) {
      VoxelIsometricRenderer.drawVoxelAncientShrine(
        canvas,
        center,
        shrineType: tileModel.shrine,
        animTime: tTime,
        isNight: isNight,
      );
    } else if (tileModel.hasBuilding) {
      final b = tileModel.building!;
      final int bVar = b.variant != 0 ? b.variant : ((tileModel.coord.q * 17 + tileModel.coord.r * 31).abs() % 3);

      switch (b.type) {
        case BuildingType.castle:
          VoxelIsometricRenderer.drawVoxelCastle(canvas, center, b.level, isNight: isNight);
          VoxelIsometricRenderer.drawVoxelSmokePlume(
            canvas,
            Offset(center.dx + 12, center.dy - 26),
            animTime: tTime,
            seed: seed,
            windWave: windWave,
            scale: 1.1,
          );
          if (isNight) {
            VoxelIsometricRenderer.drawVoxelHearthFirelight(
              canvas,
              Offset(center.dx, center.dy - 4),
              animTime: tTime,
              seed: seed,
              radius: 12.0,
            );
          }
          break;
        case BuildingType.corn:
          VoxelIsometricRenderer.drawVoxelCropField(canvas, center, animTime: tTime, variant: bVar);
          break;
        case BuildingType.barley:
          VoxelIsometricRenderer.drawVoxelBarleyField(canvas, center, animTime: tTime, variant: bVar);
          break;
        case BuildingType.pasture:
          VoxelIsometricRenderer.drawVoxelPasture(canvas, center, animTime: tTime, variant: bVar);
          break;
        case BuildingType.orchard:
          VoxelIsometricRenderer.drawVoxelOrchard(canvas, center, animTime: tTime, variant: bVar);
          break;
        case BuildingType.quarry:
          VoxelIsometricRenderer.drawVoxelQuarry(canvas, center, variant: bVar);
          break;
        case BuildingType.resinCamp:
          VoxelIsometricRenderer.drawVoxelResinCamp(canvas, center, animTime: tTime, variant: bVar);
          break;
        case BuildingType.lumberjack:
          VoxelIsometricRenderer.drawVoxelLumberjack(canvas, center, variant: bVar);
          break;
        case BuildingType.windmill:
          VoxelIsometricRenderer.drawVoxelWindmill(canvas, center, tTime, isNight: isNight, variant: bVar);
          break;
        case BuildingType.sawmill:
          VoxelIsometricRenderer.drawVoxelSawmill(canvas, center, variant: bVar);
          break;
        case BuildingType.bakery:
          VoxelIsometricRenderer.drawVoxelBakery(canvas, center, tTime, isNight: isNight, variant: bVar);
          VoxelIsometricRenderer.drawVoxelSmokePlume(
            canvas,
            Offset(center.dx + 8 * VoxelIsometricRenderer.cosIso, center.dy - 28.0 - 4 * VoxelIsometricRenderer.sinIso),
            animTime: tTime,
            seed: seed,
            windWave: windWave,
            scale: 0.9,
          );
          if (isNight) {
            VoxelIsometricRenderer.drawVoxelHearthFirelight(
              canvas,
              Offset(center.dx, center.dy - 2),
              animTime: tTime,
              seed: seed,
              radius: 8.0,
            );
          }
          break;
        case BuildingType.furniture:
          VoxelIsometricRenderer.drawVoxelFurniture(canvas, center, variant: bVar);
          break;
        case BuildingType.worker:
          VoxelIsometricRenderer.drawVoxelLumberjack(canvas, center, variant: bVar);
          break;
        case BuildingType.watchtower:
          VoxelIsometricRenderer.drawVoxelWatchtower(canvas, center, isNight: isNight, animTime: tTime);
          break;
        case BuildingType.mine:
          VoxelIsometricRenderer.drawVoxelMine(canvas, center, animTime: tTime, isNight: isNight, variant: bVar);
          break;
        case BuildingType.bridge:
          VoxelIsometricRenderer.drawVoxelBridge(canvas, center);
          break;
        case BuildingType.fisherman:
          VoxelIsometricRenderer.drawVoxelFishermanBoat(canvas, center, animTime: tTime, isNight: isNight);
          break;
        case BuildingType.fishermanHut:
          VoxelIsometricRenderer.drawVoxelFishermanHut(canvas, center, animTime: tTime, isNight: isNight);
          break;
        case BuildingType.shrine:
          VoxelIsometricRenderer.drawVoxelAncientShrine(
            canvas,
            center,
            shrineType: tileModel.shrine,
            animTime: tTime,
            isNight: isNight,
          );
          break;

        // Özel Binalar
        case BuildingType.oasisCistern:
          VoxelIsometricRenderer.drawVoxelOasisCistern(canvas, center, animTime: tTime);
          break;
        case BuildingType.caravanserai:
          VoxelIsometricRenderer.drawVoxelCaravanserai(canvas, center, animTime: tTime);
          break;
        case BuildingType.astrolabe:
          VoxelIsometricRenderer.drawVoxelAstrolabe(canvas, center, animTime: tTime);
          break;
        case BuildingType.reindeerSanctuary:
          VoxelIsometricRenderer.drawVoxelReindeerSanctuary(canvas, center, animTime: tTime);
          break;
        case BuildingType.geothermalBath:
          VoxelIsometricRenderer.drawVoxelGeothermalBath(canvas, center, animTime: tTime);
          break;
        case BuildingType.permafrostDig:
          VoxelIsometricRenderer.drawVoxelPermafrostDig(canvas, center, animTime: tTime);
          break;
        case BuildingType.steamVent:
          VoxelIsometricRenderer.drawVoxelSteamVent(canvas, center, animTime: tTime);
          VoxelIsometricRenderer.drawVoxelGeyserBurst(
            canvas,
            Offset(center.dx, center.dy - 6),
            animTime: tTime,
            seed: seed,
          );
          break;
        case BuildingType.obsidianForge:
          VoxelIsometricRenderer.drawVoxelObsidianForge(canvas, center, animTime: tTime);
          VoxelIsometricRenderer.drawVoxelSmokePlume(
            canvas,
            Offset(center.dx, center.dy - 20),
            animTime: tTime,
            seed: seed,
            windWave: windWave,
            scale: 1.15,
            smokeColor: const Color(0xFF64748B),
          );
          break;
        case BuildingType.herbalistYurt:
          VoxelIsometricRenderer.drawVoxelHerbalistYurt(canvas, center, animTime: tTime);
          if (isNight) {
            VoxelIsometricRenderer.drawVoxelHearthFirelight(
              canvas,
              Offset(center.dx, center.dy - 2),
              animTime: tTime,
              seed: seed,
              radius: 7.0,
            );
          }
          break;
        case BuildingType.scribeWorkshop:
          VoxelIsometricRenderer.drawVoxelScribeWorkshop(canvas, center, animTime: tTime);
          break;
        case BuildingType.celestialAnvil:
          VoxelIsometricRenderer.drawVoxelCelestialAnvil(canvas, center, animTime: tTime);
          break;
        case BuildingType.ancestralTotem:
          VoxelIsometricRenderer.drawVoxelAncestralTotem(canvas, center, animTime: tTime);
          break;
        case BuildingType.prismaticResonator:
          VoxelIsometricRenderer.drawVoxelPrismaticResonator(canvas, center, animTime: tTime);
          break;
      }
    } else {
      switch (tileModel.biome) {
        case TileBiome.meadow:
          _renderLivingMeadow(canvas, center, seed, windWave: windWave, tapProgress: tapProgress);
          break;
        case TileBiome.forest:
          _renderLivingForest(canvas, center, seed, tapProgress: tapProgress);
          break;
        case TileBiome.mountain:
          _renderLivingMountain(canvas, center, seed, windWave: windWave);
          break;
        case TileBiome.sea:
          _renderLivingSea(canvas, center, corners, seed, tapProgress: tapProgress);
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
          _renderLivingWetland(canvas, center, seed, tapProgress: tapProgress);
          break;
        case TileBiome.celestialCrater:
          _renderLivingCrater(canvas, center, seed);
          break;
        case TileBiome.kurganValley:
          _renderLivingKurgan(canvas, center, seed);
          break;
        case TileBiome.crystalChasm:
          _renderLivingChasm(canvas, center, seed);
          break;
      }
    }

    // 1. Ata Kurganı Balbal Dikilitaşı
    if (tileModel.ancestralKurgan != null) {
      VoxelIsometricRenderer.drawVoxelAncestralBalbal(
        canvas,
        center,
        animTime: tTime,
        level: tileModel.ancestralKurgan!.formerLevel,
      );
    }

    // 2. Ekolojik Biyom Simbiyoz Parçacıkları
    if (tileModel.symbiosis != SymbiosisType.none) {
      VoxelIsometricRenderer.drawVoxelSymbiosisSparks(
        canvas,
        center,
        animTime: tTime,
        type: tileModel.symbiosis,
      );
    }

    // 3. Yaylak-Kışlak Toprak Nefesi ve Bereket Patlaması Aurası
    if (tileModel.isResting) {
      final double breathPulse = 0.35 + 0.25 * math.sin(tTime * 2.0);
      VoxelIsometricRenderer.drawIsoCube(
        canvas,
        Offset(center.dx, center.dy - 2.0),
        w: 12.0,
        d: 12.0,
        h: 1.5,
        topColor: const Color(0xFF22C55E).withValues(alpha: breathPulse),
        leftColor: const Color(0xFF16A34A).withValues(alpha: breathPulse * 0.7),
        rightColor: const Color(0xFF15803D).withValues(alpha: breathPulse * 0.5),
      );
    } else if (tileModel.restTimeAccumulated >= 10.0) {
      final double boostPulse = 0.45 + 0.35 * math.sin(tTime * 4.0);
      VoxelIsometricRenderer.drawIsoCube(
        canvas,
        Offset(center.dx, center.dy - 3.0),
        w: 14.0,
        d: 14.0,
        h: 2.0,
        topColor: const Color(0xFFFACC15).withValues(alpha: boostPulse),
        leftColor: const Color(0xFFEAB308).withValues(alpha: boostPulse * 0.7),
        rightColor: const Color(0xFFCA8A04).withValues(alpha: boostPulse * 0.5),
      );
    }
  }

  void _renderLivingForest(Canvas canvas, Offset center, int seed, {double tapProgress = 0.0}) {
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
          animTime: tileAnimTime,
        );
        VoxelIsometricRenderer.drawVoxelPebbles(
          canvas,
          Offset(center.dx - 10, center.dy + 6),
          scale: 0.9,
        );
        break;
    }

    // Dokunulduğunda Savrulan Yapraklar (Tactile Leaf Scatter)
    if (tapProgress > 0.0) {
      VoxelIsometricRenderer.drawVoxelLeafScatter(canvas, center, progress: tapProgress, seed: seed);
    }

    if (isNight && seed % 2 == 0) {
      VoxelIsometricRenderer.drawVoxelFireflies(
        canvas,
        center,
        animTime: tileAnimTime,
        seed: seed,
      );
    }
  }

  void _renderLivingMeadow(
    Canvas canvas,
    Offset center,
    int seed, {
    double windWave = 0.0,
    double tapProgress = 0.0,
  }) {
    final int variant = seed % 8;
    final double tTime = tileAnimTime;
    final bool isSpring = season == 'SPRING';
    final bool flip = seed % 2 == 0;

    void drawGrass(Offset pos, {double scale = 1.0}) {
      VoxelIsometricRenderer.drawIsoCube(
        canvas,
        pos,
        w: 3.0 * scale,
        d: 3.0 * scale,
        h: 5.0 * scale,
        topColor: const Color(0xFF84CC16),
        leftColor: const Color(0xFF65A30D),
        rightColor: const Color(0xFF4D7C0F),
      );
    }

    switch (variant) {
      case 0:
        // Saf Bozkır & Dinlenen Tek Koyun (0 Çiçek)
        drawGrass(Offset(center.dx + 6, center.dy + 6), scale: 0.9);
        drawGrass(Offset(center.dx - 8, center.dy + 4), scale: 0.8);
        drawGrass(Offset(center.dx - 4, center.dy + 8), scale: 0.75);
        drawGrass(Offset(center.dx + 2, center.dy - 8), scale: 0.85);
        drawGrass(Offset(center.dx - 10, center.dy - 5), scale: 0.7);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 8, center.dy - 4), scale: 0.75);

        if (seed % 2 == 0) {
          VoxelIsometricRenderer.drawVoxelSheep(
            canvas,
            Offset(center.dx - 2, center.dy - 2),
            animTime: tTime,
            seed: seed * 11 + 3,
            scale: 0.85,
          );
        }
        break;

      case 1:
        // Nadir Çiçek Vadisi & Koyun Sürüsü (2 Çiçek - Baharda Gelincikli) [Nadir Çiçek 1/8]
        VoxelIsometricRenderer.drawVoxelSheep(
          canvas,
          Offset(center.dx + 6, center.dy - 3),
          animTime: tTime,
          seed: seed,
          scale: 0.95,
        );
        VoxelIsometricRenderer.drawVoxelSheep(
          canvas,
          Offset(center.dx - 10, center.dy + 5),
          animTime: tTime,
          seed: seed * 19 + 7,
          scale: 0.72,
        );
        VoxelIsometricRenderer.drawVoxelFlowers(
          canvas,
          Offset(center.dx + 12, center.dy + 8),
          flowerColor: const Color(0xFF38BDF8),
          scale: 0.8,
        );
        if (isSpring) {
          VoxelIsometricRenderer.drawVoxelSpringPoppies(canvas, Offset(center.dx - 6, center.dy - 8), scale: 0.85);
        } else {
          VoxelIsometricRenderer.drawVoxelFlowers(
            canvas,
            Offset(center.dx - 6, center.dy - 8),
            flowerColor: const Color(0xFFFBBF24),
            scale: 0.75,
          );
        }
        drawGrass(Offset(center.dx - 2, center.dy + 8), scale: 0.85);
        drawGrass(Offset(center.dx + 8, center.dy - 9), scale: 0.9);
        drawGrass(Offset(center.dx - 12, center.dy - 2), scale: 0.75);
        break;

      case 2:
        // Asil Bozkır Yılkı Atı & Çakıllar (0 Çiçek)
        VoxelIsometricRenderer.drawVoxelHorse(
          canvas,
          Offset(center.dx, center.dy),
          animTime: tTime,
          seed: seed,
          scale: 0.95,
          flipX: flip,
          startleProgress: tapProgress,
        );
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx - 8, center.dy + 6), scale: 0.8);
        drawGrass(Offset(center.dx + 10, center.dy - 2), scale: 1.0);
        drawGrass(Offset(center.dx + 8, center.dy + 6), scale: 0.8);
        drawGrass(Offset(center.dx - 2, center.dy + 2), scale: 0.9);
        drawGrass(Offset(center.dx - 12, center.dy + 4), scale: 0.7);

        if (seed % 3 == 0) {
          VoxelIsometricRenderer.drawVoxelSheep(
            canvas,
            Offset(center.dx + 2, center.dy + 3),
            animTime: tTime,
            seed: seed * 13 + 5,
            scale: 0.85,
          );
        }
        break;

      case 3:
        // Rüzgarlı Geniş Otlak Örtüsü & Çakıllar (0 Çiçek)
        drawGrass(Offset(center.dx, center.dy), scale: 1.0);
        drawGrass(Offset(center.dx - 10, center.dy - 3), scale: 0.85);
        drawGrass(Offset(center.dx + 11, center.dy - 4), scale: 0.8);
        drawGrass(Offset(center.dx - 5, center.dy + 7), scale: 0.9);
        drawGrass(Offset(center.dx + 7, center.dy + 6), scale: 0.75);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx - 7, center.dy - 5), scale: 0.85);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 6, center.dy - 7), scale: 0.7);
        break;

      case 4:
        // Vadi Kıyısı Tekil Kır Çiçeği & Çimen Vadisi (1 Çiçek) [Nadir Çiçek 2/8]
        if (isSpring) {
          VoxelIsometricRenderer.drawVoxelSpringPoppies(canvas, Offset(center.dx - 6, center.dy - 4), scale: 0.85);
        } else {
          VoxelIsometricRenderer.drawVoxelFlowers(
            canvas,
            Offset(center.dx - 6, center.dy - 4),
            flowerColor: seed % 2 == 0 ? const Color(0xFFA855F7) : const Color(0xFF38BDF8),
            scale: 0.8,
          );
        }
        drawGrass(Offset(center.dx, center.dy), scale: 0.95);
        drawGrass(Offset(center.dx - 12, center.dy - 2), scale: 0.85);
        drawGrass(Offset(center.dx + 12, center.dy - 2), scale: 0.75);
        drawGrass(Offset(center.dx + 2, center.dy + 8), scale: 0.8);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.75);
        break;

      case 5:
        // Otlayan Yılkı Atı veya Koyun & Çiçeksiz Bozkır (0 Çiçek)
        if (seed % 2 == 0) {
          VoxelIsometricRenderer.drawVoxelHorse(
            canvas,
            Offset(center.dx + 2, center.dy - 2),
            animTime: tTime,
            seed: seed * 7 + 1,
            scale: 0.9,
            flipX: !flip,
            startleProgress: tapProgress,
          );
        } else {
          VoxelIsometricRenderer.drawVoxelSheep(
            canvas,
            Offset(center.dx - 3, center.dy + 2),
            animTime: tTime,
            seed: seed * 5 + 3,
            scale: 0.9,
          );
        }
        drawGrass(Offset(center.dx - 8, center.dy - 6), scale: 0.85);
        drawGrass(Offset(center.dx + 10, center.dy + 5), scale: 0.9);
        drawGrass(Offset(center.dx - 6, center.dy + 8), scale: 0.75);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 6, center.dy - 7), scale: 0.75);
        break;

      case 6:
        // Saf Bozkır Çimi & Dinlenen Kuzu (0 Çiçek)
        drawGrass(Offset(center.dx - 7, center.dy + 4), scale: 0.95);
        drawGrass(Offset(center.dx + 8, center.dy + 5), scale: 0.8);
        drawGrass(Offset(center.dx - 5, center.dy - 6), scale: 0.75);
        drawGrass(Offset(center.dx + 1, center.dy + 8), scale: 0.85);
        drawGrass(Offset(center.dx + 4, center.dy - 5), scale: 0.8);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx - 8, center.dy - 4), scale: 0.8);

        if (seed % 3 == 1) {
          VoxelIsometricRenderer.drawVoxelSheep(
            canvas,
            Offset(center.dx - 1, center.dy - 1),
            animTime: tTime,
            seed: seed * 9 + 4,
            scale: 0.8,
          );
        }
        break;

      case 7:
      default:
        // Bozkır Taş Höyüğü & Yabani Otlar (0 Çiçek)
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx - 7, center.dy + 3), scale: 0.85);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 9, center.dy - 4), scale: 0.8);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx - 4, center.dy + 8), scale: 0.75);
        drawGrass(Offset(center.dx + 2, center.dy + 7), scale: 0.9);
        drawGrass(Offset(center.dx - 8, center.dy - 6), scale: 0.8);
        drawGrass(Offset(center.dx + 6, center.dy + 2), scale: 0.75);
        drawGrass(Offset(center.dx - 2, center.dy - 2), scale: 0.85);
        break;
    }

    // Bozkırda Yuvarlanan Çalı (Tumbleweed)
    VoxelIsometricRenderer.drawVoxelTumbleweed(
      canvas,
      center,
      animTime: tileAnimTime,
      seed: seed,
      windWave: windWave,
    );

    if (isNight && seed % 4 == 0) {
      VoxelIsometricRenderer.drawVoxelFireflies(
        canvas,
        center,
        animTime: tileAnimTime,
        seed: seed,
      );
    }
  }

  void _renderLivingMountain(Canvas canvas, Offset center, int seed, {double windWave = 0.0}) {
    VoxelIsometricRenderer.drawVoxelMountainVariant(
      canvas,
      center,
      seed,
      season: season,
      isZud: isZud,
      animTime: tileAnimTime,
    );
    // Zirve Toz Kar Sürgünü
    VoxelIsometricRenderer.drawVoxelSnowDrift(
      canvas,
      Offset(center.dx, center.dy - 24),
      animTime: tileAnimTime,
      windWave: windWave,
      seed: seed,
    );
    if (seed % 2 == 0) {
      VoxelIsometricRenderer.drawVoxelPebbles(
        canvas,
        Offset(center.dx + 14, center.dy + 8),
        scale: 0.75,
      );
    }
  }

  void _renderLivingSea(
    Canvas canvas,
    Offset center,
    List<Offset> corners,
    int seed, {
    double tapProgress = 0.0,
  }) {
    final bool isWinter = season == 'WINTER' || isZud;
    if (isWinter) {
      VoxelIsometricRenderer.drawVoxelIceFloes(canvas, center, scale: 0.9, animTime: tileAnimTime);
      return;
    }

    VoxelIsometricRenderer.drawVoxelShorelineWaves(
      canvas,
      center,
      corners,
      animTime: tileAnimTime,
      seed: seed,
    );

    final double waveOffset = math.sin(tileAnimTime * 2.0 + (seed % 5)) * 3.5;
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
        animTime: tileAnimTime,
        seed: seed,
      );
    }

    // Dokunulduğunda Su Dalgası Halkaları (Tactile Water Ripple)
    if (tapProgress > 0.0) {
      VoxelIsometricRenderer.drawVoxelWaterRipple(canvas, center, progress: tapProgress);
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

    // Sıcaklık Serabı
    VoxelIsometricRenderer.drawVoxelDesertHeatShimmer(canvas, center, animTime: tileAnimTime, seed: seed);

    // Her çöl karosunda uçuşan toz parçacığı olmasın, sadece nadir rüzgarlı karolarda (1/5)
    if (seed % 5 == 0) {
      VoxelIsometricRenderer.drawVoxelDesertDust(canvas, center, animTime: tileAnimTime, seed: seed);
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
        VoxelIsometricRenderer.drawVoxelPine(canvas, Offset(center.dx - 6, center.dy - 4), scale: 0.65, animTime: tileAnimTime);
        VoxelIsometricRenderer.drawVoxelLichenRocks(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.8);
        break;
    }
    // Her tundra karosunda parıltı olmasın, sadece nadir buzul karolarında (1/5)
    if (seed % 5 == 0) {
      VoxelIsometricRenderer.drawVoxelIceSparkles(canvas, center, animTime: tileAnimTime, seed: seed);
    }
  }

  void _renderLivingVolcano(Canvas canvas, Offset center, int seed) {
    final int variant = seed % 4;
    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelObsidianPillars(canvas, Offset(center.dx - 6, center.dy - 2), scale: 0.95, animTime: tileAnimTime);
        VoxelIsometricRenderer.drawVoxelMagmaVent(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.85, animTime: tileAnimTime);
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelMagmaVent(canvas, center, scale: 1.1, animTime: tileAnimTime);
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelObsidianPillars(canvas, center, scale: 1.15, animTime: tileAnimTime);
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelObsidianPillars(canvas, Offset(center.dx + 6, center.dy - 4), scale: 0.9, animTime: tileAnimTime);
        VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx - 8, center.dy + 4), scale: 0.8);
        break;
    }
    VoxelIsometricRenderer.drawVoxelVolcanoEmbers(canvas, center, animTime: tileAnimTime, seed: seed);
    VoxelIsometricRenderer.drawVoxelGeyserBurst(canvas, Offset(center.dx, center.dy - 12), animTime: tileAnimTime, seed: seed);
  }

  void _renderLivingWetland(Canvas canvas, Offset center, int seed, {double tapProgress = 0.0}) {
    final int variant = seed % 4;
    switch (variant) {
      case 0:
        VoxelIsometricRenderer.drawVoxelReeds(canvas, Offset(center.dx - 6, center.dy - 2), scale: 0.95, animTime: tileAnimTime);
        VoxelIsometricRenderer.drawVoxelWaterLilies(canvas, Offset(center.dx + 8, center.dy + 4), scale: 0.85);
        break;
      case 1:
        VoxelIsometricRenderer.drawVoxelReeds(canvas, center, scale: 1.1, animTime: tileAnimTime);
        break;
      case 2:
        VoxelIsometricRenderer.drawVoxelWaterLilies(canvas, Offset(center.dx - 4, center.dy), scale: 1.0);
        VoxelIsometricRenderer.drawVoxelLeapingFish(canvas, Offset(center.dx + 8, center.dy + 4), animTime: tileAnimTime, seed: seed);
        break;
      case 3:
      default:
        VoxelIsometricRenderer.drawVoxelReeds(canvas, Offset(center.dx + 6, center.dy - 4), scale: 0.9, animTime: tileAnimTime);
        VoxelIsometricRenderer.drawVoxelBirchTree(canvas, Offset(center.dx - 8, center.dy + 4), scale: 0.6, animTime: tileAnimTime);
        break;
    }
    VoxelIsometricRenderer.drawVoxelDragonflies(canvas, center, animTime: tileAnimTime, seed: seed);

    // Dokunulduğunda Su Dalgası Halkaları (Tactile Water Ripple)
    if (tapProgress > 0.0) {
      VoxelIsometricRenderer.drawVoxelWaterRipple(canvas, center, progress: tapProgress);
    }
  }

  void _renderLivingCrater(Canvas canvas, Offset center, int seed) {
    final double tTime = tileAnimTime;
    VoxelIsometricRenderer.drawVoxelCelestialCraterGround(canvas, center, scale: 1.0, animTime: tTime);
    VoxelIsometricRenderer.drawVoxelCelestialStardust(canvas, center, animTime: tTime, seed: seed);
  }

  void _renderLivingKurgan(Canvas canvas, Offset center, int seed) {
    final double tTime = tileAnimTime;
    VoxelIsometricRenderer.drawVoxelKurganBalbals(canvas, center, scale: 1.0, animTime: tTime);
    if (seed % 2 == 0) {
      VoxelIsometricRenderer.drawVoxelPebbles(canvas, Offset(center.dx + 10, center.dy + 6), scale: 0.9);
    }
  }

  void _renderLivingChasm(Canvas canvas, Offset center, int seed) {
    final double tTime = tileAnimTime;
    VoxelIsometricRenderer.drawVoxelCrystalChasmGround(canvas, center, scale: 1.0, animTime: tTime);
    VoxelIsometricRenderer.drawVoxelCelestialStardust(canvas, center, animTime: tTime, seed: seed + 3);
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

    Color topColor = Color.lerp(fromColor, toColor, blend) ?? toColor;

    // Sahipsiz / Keşfedilmiş Arazi: Hafif atmosferik sis tonlaması
    if (!tileModel.isOwned) {
      topColor = Color.lerp(topColor, const Color(0xFF0F172A), 0.14)!;
    }

    return topColor;
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
          baseColor = const Color(0xFFD97706);
        } else if (isSummer) {
          baseColor = const Color(0xFF84CC16);
        } else {
          baseColor = const Color(0xFF22C55E);
        }
        break;

      case TileBiome.forest:
        if (isWinter) {
          baseColor = const Color(0xFF94A3B8);
        } else if (isAutumn) {
          baseColor = const Color(0xFFEA580C);
        } else if (isSummer) {
          baseColor = const Color(0xFF15803D);
        } else {
          baseColor = const Color(0xFF16A34A);
        }
        break;

      case TileBiome.mountain:
        if (isWinter) {
          baseColor = const Color(0xFFF1F5F9);
        } else if (isAutumn) {
          baseColor = const Color(0xFF78350F);
        } else {
          baseColor = const Color(0xFF64748B);
        }
        break;

      case TileBiome.sea:
        if (isWinter) {
          baseColor = const Color(0xFFBAE6FD);
        } else if (isAutumn) {
          baseColor = const Color(0xFF0369A1);
        } else {
          baseColor = const Color(0xFF0284C7);
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
          baseColor = const Color(0xFFFBBF24);
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
          baseColor = const Color(0xFF64748B);
        } else if (isAutumn) {
          baseColor = const Color(0xFF84CC16);
        } else {
          baseColor = const Color(0xFF0D9488);
        }
        break;

      case TileBiome.celestialCrater:
        baseColor = const Color(0xFF1E1B4B);
        break;

      case TileBiome.kurganValley:
        baseColor = const Color(0xFF475569);
        break;

      case TileBiome.crystalChasm:
        baseColor = const Color(0xFF065F46);
        break;
    }

    // Aktif tema paleti atmosferik harmanlama (Zero-GC deterministik tonlama)
    final theme = NeoBrutalistTheme.getTheme(themePalette);
    if (theme.id != 'basalt') {
      switch (theme.id) {
        case 'kurgan':
          baseColor = Color.lerp(baseColor, const Color(0xFFB91C1C), 0.08)!;
          break;
        case 'jade':
          baseColor = Color.lerp(baseColor, const Color(0xFF059669), 0.07)!;
          break;
        case 'tengri':
          baseColor = Color.lerp(baseColor, const Color(0xFF0284C7), 0.07)!;
          break;
        case 'khagan':
          baseColor = Color.lerp(baseColor, const Color(0xFFD97706), 0.07)!;
          break;
      }
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

    var (wL, wR, wB) = (
      Color.lerp(fL, tL, blend) ?? tL,
      Color.lerp(fR, tR, blend) ?? tR,
      Color.lerp(fB, tB, blend) ?? tB,
    );

    // Sahipsiz / Keşfedilmiş Arazi: 3D duvarlarda kapalı/derinlik tonlaması
    if (!tileModel.isOwned) {
      wL = Color.lerp(wL, const Color(0xFF0F172A), 0.35)!;
      wR = Color.lerp(wR, const Color(0xFF0F172A), 0.35)!;
      wB = Color.lerp(wB, const Color(0xFF020617), 0.35)!;
    }

    final theme = NeoBrutalistTheme.getTheme(themePalette);
    if (theme.id != 'basalt') {
      wB = Color.lerp(wB, theme.slateBorder, 0.18)!;
      wL = Color.lerp(wL, theme.surfaceLight, 0.12)!;
      wR = Color.lerp(wR, theme.surface, 0.12)!;
    }

    return (wL, wR, wB);
  }

  (Color, Color, Color) _getBiome3DWallColorsForSeason(TileBiome biome, String targetSeason, bool targetZud) {
    final bool isWinter = targetSeason == 'WINTER' || targetZud;
    switch (biome) {
      case TileBiome.meadow:
        if (isWinter) {
          return (const Color(0xFFCBD5E1), const Color(0xFF94A3B8), const Color(0xFF475569));
        }
        return (const Color(0xFF4D7C0F), const Color(0xFF3F6212), const Color(0xFF5C3A21));

      case TileBiome.forest:
        if (isWinter) {
          return (const Color(0xFFCBD5E1), const Color(0xFF94A3B8), const Color(0xFF475569));
        }
        return (const Color(0xFF166534), const Color(0xFF14532D), const Color(0xFF451A03));

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

      case TileBiome.celestialCrater:
        return (const Color(0xFF312E81), const Color(0xFF1E1B4B), const Color(0xFF0F0E2A));

      case TileBiome.kurganValley:
        return (const Color(0xFF334155), const Color(0xFF1E293B), const Color(0xFF0F172A));

      case TileBiome.crystalChasm:
        return (const Color(0xFF047857), const Color(0xFF065F46), const Color(0xFF022C22));
    }
  }
}
