import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/hex_tile_model.dart';

/// 3D Voxel / Isometric Canlı Diorama Çizim Motoru
/// Rüzgar salınımı, gece pencereleri, ateşböcekleri, sıçrayan balıklar, taş patikalar ve partiküller.
class VoxelIsometricRenderer {
  static const double isoAngle = 30.0 * (math.pi / 180.0);
  static final double cosIso = math.cos(isoAngle);
  static final double sinIso = math.sin(isoAngle);

  // Reusable Zero-GC rendering pools
  static final Paint _sharedFillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _sharedStrokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _cubeShadowPaint = Paint()..style = PaintingStyle.fill;

  static final Path _cubeShadowPath = Path();
  static final Path _cubeLeftPath = Path();
  static final Path _cubeRightPath = Path();
  static final Path _cubeTopPath = Path();
  static final Path _sharedPath = Path();
  static final Path _sharedPath2 = Path();

  /// 3D İzometrik Küp / Prizma çizer (Zero-GC, Zero-Heap-Allocations)
  static void drawIsoCube(
    Canvas canvas,
    Offset baseCenter, {
    required double w,
    required double d,
    required double h,
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
    bool drawShadow = false,
    double shadowOpacity = 0.25,
  }) {
    final double dxR = (w * 0.5) * cosIso;
    final double dyR = (w * 0.5) * sinIso;
    final double dxL = -(d * 0.5) * cosIso;
    final double dyL = (d * 0.5) * sinIso;

    final double bx = baseCenter.dx;
    final double by = baseCenter.dy;

    final double bFrontX = bx;
    final double bFrontY = by + dyR + dyL;
    final double bRightX = bx + dxR;
    final double bRightY = by + dyR - dyL;
    final double bLeftX = bx + dxL;
    final double bLeftY = by - dyR + dyL;
    final double bBackX = bx + dxR + dxL;
    final double bBackY = by - dyR - dyL;

    // Zemin temas gölgesi
    if (drawShadow) {
      _cubeShadowPaint.color = Colors.black.withValues(alpha: shadowOpacity);
      _cubeShadowPath
        ..reset()
        ..moveTo(bFrontX, bFrontY + 2)
        ..lineTo(bRightX + 4, bRightY + 2)
        ..lineTo(bBackX + 4, bBackY + 2)
        ..lineTo(bLeftX - 4, bLeftY + 2)
        ..close();
      canvas.drawPath(_cubeShadowPath, _cubeShadowPaint);
    }

    final double tFrontY = bFrontY - h;
    final double tRightY = bRightY - h;
    final double tLeftY = bLeftY - h;
    final double tBackY = bBackY - h;

    // 1. Sol Yüzey
    _cubeLeftPath
      ..reset()
      ..moveTo(bLeftX, bLeftY)
      ..lineTo(bFrontX, bFrontY)
      ..lineTo(bFrontX, tFrontY)
      ..lineTo(bLeftX, tLeftY)
      ..close();
    _sharedFillPaint.color = leftColor;
    canvas.drawPath(_cubeLeftPath, _sharedFillPaint);

    // 2. Sağ Yüzey
    _cubeRightPath
      ..reset()
      ..moveTo(bFrontX, bFrontY)
      ..lineTo(bRightX, bRightY)
      ..lineTo(bRightX, tRightY)
      ..lineTo(bFrontX, tFrontY)
      ..close();
    _sharedFillPaint.color = rightColor;
    canvas.drawPath(_cubeRightPath, _sharedFillPaint);

    // 3. Üst Yüzey
    _cubeTopPath
      ..reset()
      ..moveTo(bFrontX, tFrontY)
      ..lineTo(bRightX, tRightY)
      ..lineTo(bBackX, tBackY)
      ..lineTo(bLeftX, tLeftY)
      ..close();
    _sharedFillPaint.color = topColor;
    canvas.drawPath(_cubeTopPath, _sharedFillPaint);
  }

  // --- RÜZGARLA SALINAN AĞAÇLAR (WIND SWAY) ---

  /// Rüzgarla hafifçe salınan Meşe Ağacı
  static void drawVoxelTree(
    Canvas canvas,
    Offset baseCenter, {
    double scale = 1.0,
    Color? foliageTint,
    double animTime = 0.0,
    double windFactor = 1.0,
  }) {
    final double windSway = math.sin(animTime * 2.5 + baseCenter.dx * 0.04) * (2.2 * windFactor * scale);

    final double trunkW = 6.0 * scale;
    final double trunkH = 16.0 * scale;
    drawIsoCube(
      canvas,
      baseCenter,
      w: trunkW,
      d: trunkW,
      h: trunkH,
      topColor: const Color(0xFF9A5E35),
      leftColor: const Color(0xFF784522),
      rightColor: const Color(0xFF5A3114),
      drawShadow: true,
    );

    final Offset foliageCenter = Offset(baseCenter.dx + windSway * 0.5, baseCenter.dy - trunkH + 4 * scale);
    final Color top = foliageTint ?? const Color(0xFF86EFAC);
    final Color mid = foliageTint != null ? foliageTint.withValues(alpha: 0.85) : const Color(0xFF22C55E);
    final Color dark = foliageTint != null ? foliageTint.withValues(alpha: 0.65) : const Color(0xFF15803D);

    drawIsoCube(
      canvas,
      foliageCenter,
      w: 22.0 * scale,
      d: 22.0 * scale,
      h: 12.0 * scale,
      topColor: top,
      leftColor: mid,
      rightColor: dark,
    );

    drawIsoCube(
      canvas,
      Offset(foliageCenter.dx + windSway * 0.3, foliageCenter.dy - 10 * scale),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 10.0 * scale,
      topColor: top,
      leftColor: mid,
      rightColor: dark,
    );

    drawIsoCube(
      canvas,
      Offset(foliageCenter.dx + windSway * 0.6, foliageCenter.dy - 18 * scale),
      w: 10.0 * scale,
      d: 10.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFBBF7D0),
      leftColor: mid,
      rightColor: dark,
    );
  }

  /// Rüzgarla salınan Beyaz Huş Ağacı
  static void drawVoxelBirchTree(
    Canvas canvas,
    Offset baseCenter, {
    double scale = 1.0,
    double animTime = 0.0,
    double windFactor = 1.0,
  }) {
    final double windSway = math.sin(animTime * 3.0 + baseCenter.dx * 0.05) * (2.8 * windFactor * scale);

    final double trunkW = 5.0 * scale;
    final double trunkH = 20.0 * scale;
    drawIsoCube(
      canvas,
      baseCenter,
      w: trunkW,
      d: trunkW,
      h: trunkH,
      topColor: const Color(0xFFF1F5F9),
      leftColor: const Color(0xFFE2E8F0),
      rightColor: const Color(0xFF94A3B8),
      drawShadow: true,
    );

    final Offset folBase = Offset(baseCenter.dx + windSway * 0.5, baseCenter.dy - trunkH + 4 * scale);
    drawIsoCube(
      canvas,
      folBase,
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 14.0 * scale,
      topColor: const Color(0xFFBEF264),
      leftColor: const Color(0xFFA3E635),
      rightColor: const Color(0xFF65A30D),
    );

    drawIsoCube(
      canvas,
      Offset(folBase.dx + windSway * 0.5, folBase.dy - 12 * scale),
      w: 10.0 * scale,
      d: 10.0 * scale,
      h: 10.0 * scale,
      topColor: const Color(0xFFD9F99D),
      leftColor: const Color(0xFFA3E635),
      rightColor: const Color(0xFF4D7C0F),
    );
  }

  /// Rüzgarla hafif salınan Çam Ağacı
  static void drawVoxelPine(
    Canvas canvas,
    Offset baseCenter, {
    double scale = 1.0,
    double animTime = 0.0,
    double windFactor = 1.0,
  }) {
    final double windSway = math.sin(animTime * 2.0 + baseCenter.dy * 0.04) * (1.6 * windFactor * scale);

    drawIsoCube(
      canvas,
      baseCenter,
      w: 5.0 * scale,
      d: 5.0 * scale,
      h: 12.0 * scale,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A270B),
      rightColor: const Color(0xFF3F1905),
      drawShadow: true,
    );

    final double startY = baseCenter.dy - 8 * scale;
    for (int i = 0; i < 3; i++) {
      final double size = (20.0 - i * 6.0) * scale;
      final double h = 8.0 * scale;
      final double sway = windSway * (i + 1) * 0.35;
      final Offset c = Offset(baseCenter.dx + sway, startY - (i * 7.0 * scale));

      drawIsoCube(
        canvas,
        c,
        w: size,
        d: size,
        h: h,
        topColor: const Color(0xFF34D399),
        leftColor: const Color(0xFF059669),
        rightColor: const Color(0xFF065F46),
      );
    }
  }

  // --- HAYVANLAR, BALIKLAR & ATEŞBÖCEKLERİ ---

  /// Sıçrayan 3D Voxel Balık & Su Köpükleri
  static void drawVoxelLeapingFish(Canvas canvas, Offset seaCenter, {required double animTime, required int seed}) {
    final double cycle = (animTime * 0.8 + seed * 1.7) % 4.0;
    if (cycle > 1.2) return; // Arada bir sıçrar

    final double progress = cycle / 1.2; // 0.0 -> 1.0
    final double jumpHeight = math.sin(progress * math.pi) * 22.0;
    final double jumpX = (progress - 0.5) * 26.0;

    final Offset fishPos = Offset(seaCenter.dx + jumpX, seaCenter.dy - jumpHeight);

    // Su Halka Köpüğü (Splash ring)
    if (progress < 0.2 || progress > 0.8) {
      _sharedStrokePaint
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(seaCenter.dx + jumpX, seaCenter.dy), width: 14.0, height: 7.0),
        _sharedStrokePaint,
      );
    }

    // Minik Gümüş Voxel Balık
    drawIsoCube(
      canvas,
      fishPos,
      w: 4.0,
      d: 7.0,
      h: 3.0,
      topColor: const Color(0xFFF1F5F9),
      leftColor: const Color(0xFF38BDF8),
      rightColor: const Color(0xFF0284C7),
      drawShadow: true,
      shadowOpacity: 0.15,
    );
  }

  /// Geceleyin Parıldayan 3D Voxel Ateşböcekleri
  static void drawVoxelFireflies(Canvas canvas, Offset center, {required double animTime, required int seed}) {
    for (int i = 0; i < 3; i++) {
      final double t = animTime * 2.0 + (seed * 1.5) + (i * 2.1);
      final double fx = center.dx + math.cos(t * 1.2) * 16.0;
      final double fy = center.dy - 12.0 + math.sin(t * 1.5) * 10.0;
      final double glow = (math.sin(t * 3.0) + 1.0) * 0.5;

      final Color fireflyColor = Color.lerp(
        const Color(0xFF84CC16),
        const Color(0xFFFEF08A),
        glow,
      )!;

      // Glow aurası
      _sharedFillPaint
        ..color = fireflyColor.withValues(alpha: 0.4 * glow)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(fx, fy), 4.0, _sharedFillPaint);

      // Çekirdek Voxel
      drawIsoCube(
        canvas,
        Offset(fx, fy),
        w: 2.0,
        d: 2.0,
        h: 2.0,
        topColor: Colors.white,
        leftColor: fireflyColor,
        rightColor: fireflyColor.withValues(alpha: 0.8),
      );
    }
  }

  /// Sevimli 3D Voxel Koyun (Organik Otlama, Çevreye Bakınma ve Zıplama Döngüsü)
  /// Sevimli & Çok Yönlü 3D Voxel Koyun (4 Davranış Modu, 4 Renk Varyantı, Bağımsız Kulak/Kuyruk)
  static void drawVoxelSheep(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
  }) {
    final int behaviorMode = seed % 4;
    final int coatVariant = ((seed * 7) ~/ 3) % 4;
    final bool hasRamHorns = (seed % 7) == 0;
    final double timeOffset = (seed * 2.37) % 20.0;
    final double t = animTime + timeOffset;

    double bobY = 0.0;
    double headTilt = 0.0;
    double headYaw = 0.0;
    double chewWobble = 0.0;
    double bodySquash = 1.0;
    double legStride = 0.0;
    double tailWag = math.sin(t * 8.0) * 1.5 * scale;
    final double earTwitchLeft = math.sin(t * 5.0 + seed).clamp(-1.0, 1.0) * 0.8 * scale;
    final double earTwitchRight = math.sin(t * 4.3 + seed * 2).clamp(-1.0, 1.0) * 0.8 * scale;

    Color woolTop;
    Color woolLeft;
    Color woolRight;

    switch (coatVariant) {
      case 1: // Kara Koyun (Black Sheep)
        woolTop = const Color(0xFF334155);
        woolLeft = const Color(0xFF1E293B);
        woolRight = const Color(0xFF0F172A);
        break;
      case 2: // Bozkır Kehribar / Kahve Koyun (Caramel Brown)
        woolTop = const Color(0xFFD97706);
        woolLeft = const Color(0xFFB45309);
        woolRight = const Color(0xFF92400E);
        break;
      case 3: // Alaca / Benekli (Patchy spotted)
        woolTop = const Color(0xFFF1F5F9);
        woolLeft = const Color(0xFFE2E8F0);
        woolRight = const Color(0xFFCBD5E1);
        break;
      case 0: // Klasik Kar Beyazı (Pure White)
      default:
        woolTop = const Color(0xFFFFFFFF);
        woolLeft = const Color(0xFFF8FAFC);
        woolRight = const Color(0xFFE2E8F0);
        break;
    }

    // Davranış Modları
    switch (behaviorMode) {
      case 0: // 1. SAKİN OTLAYICI (Grazing & Chewing)
        final double cycle = t % 7.0;
        if (cycle < 4.5) {
          headTilt = 3.5 * scale;
          chewWobble = math.sin(t * 7.0) * 0.8 * scale;
          bobY = math.sin(t * 1.5) * 0.3 * scale;
        } else {
          headTilt = -0.5 * scale;
          headYaw = math.sin(t * 2.0) * 1.5 * scale;
          chewWobble = math.sin(t * 5.0) * 0.5 * scale;
        }
        break;

      case 1: // 2. MERAKLI GÖZCÜ (Curious Watcher)
        final double cycle = t % 6.0;
        headTilt = -2.0 * scale;
        if (cycle < 3.0) {
          headYaw = 2.0 * scale;
        } else {
          headYaw = -2.0 * scale;
        }
        bobY = math.sin(t * 2.2) * 0.5 * scale;
        break;

      case 2: // 3. ZIPIR KUZU (Playful Bouncy Lamb)
        final double cycle = t % 4.5;
        scale *= 0.75;
        if (cycle < 2.0) {
          final double hopProgress = cycle / 2.0;
          bobY = math.sin(hopProgress * math.pi * 4).abs() * 3.5 * scale;
          headTilt = -2.0 * scale;
        } else if (cycle < 3.5) {
          legStride = math.sin(t * 10.0) * 2.0 * scale;
          bobY = math.sin(t * 10.0).abs() * 1.5 * scale;
        } else {
          headYaw = math.sin(t * 3.0) * 2.0 * scale;
        }
        break;

      case 3: // 4. TEMBEL / YATAN KOYUN (Sleepy Napper)
        bodySquash = 0.75;
        final double breath = math.sin(t * 1.8) * 0.5 * scale;
        bobY = -2.0 * scale + breath;
        headTilt = 2.0 * scale;
        tailWag = 0.0;
        break;
    }

    // Gövde Yünü (Voxel Wool Body)
    drawIsoCube(
      canvas,
      Offset(pos.dx, pos.dy - 3 * scale - bobY),
      w: 12.0 * scale,
      d: 10.0 * scale,
      h: 8.0 * scale * bodySquash,
      topColor: woolTop,
      leftColor: woolLeft,
      rightColor: woolRight,
      drawShadow: true,
      shadowOpacity: 0.25,
    );

    // Alaca / Benekli ise gövdeye 1 koyu benek
    if (coatVariant == 3) {
      drawIsoCube(
        canvas,
        Offset(pos.dx + 2 * cosIso * scale, pos.dy - 4 * scale - bobY - 2 * sinIso * scale),
        w: 4.0 * scale,
        d: 4.0 * scale,
        h: 4.0 * scale,
        topColor: const Color(0xFF475569),
        leftColor: const Color(0xFF334155),
        rightColor: const Color(0xFF1E293B),
      );
    }

    // Baş (Voxel Head)
    final Offset headPos = Offset(
      pos.dx - 6 * cosIso * scale + chewWobble + headYaw * cosIso,
      pos.dy - 5 * scale - bobY + 3 * sinIso * scale + headTilt + headYaw * sinIso,
    );

    drawIsoCube(
      canvas,
      headPos,
      w: 5.0 * scale,
      d: 5.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
    );

    // Pembe Burun (Pink Snout)
    drawIsoCube(
      canvas,
      Offset(headPos.dx - 3 * cosIso * scale, headPos.dy + 1 * sinIso * scale),
      w: 2.5 * scale,
      d: 2.5 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFFFDA4AF),
      leftColor: const Color(0xFFFB7185),
      rightColor: const Color(0xFFE11D48),
    );

    // Kulaklar (Ears with dynamic twitches)
    drawIsoCube(
      canvas,
      Offset(headPos.dx - 2 * cosIso * scale, headPos.dy - 3 * scale + earTwitchLeft),
      w: 1.5 * scale,
      d: 2.5 * scale,
      h: 1.5 * scale,
      topColor: const Color(0xFF475569),
      leftColor: const Color(0xFF334155),
      rightColor: const Color(0xFF1E293B),
    );
    drawIsoCube(
      canvas,
      Offset(headPos.dx + 2 * cosIso * scale, headPos.dy - 3 * scale + earTwitchRight),
      w: 2.5 * scale,
      d: 1.5 * scale,
      h: 1.5 * scale,
      topColor: const Color(0xFF475569),
      leftColor: const Color(0xFF334155),
      rightColor: const Color(0xFF1E293B),
    );

    // Kıvrık Koç Boynuzu (Ram Horns)
    if (hasRamHorns && behaviorMode != 2) {
      drawIsoCube(
        canvas,
        Offset(headPos.dx - 3 * cosIso * scale, headPos.dy - 4.5 * scale),
        w: 2.0 * scale,
        d: 3.5 * scale,
        h: 2.5 * scale,
        topColor: const Color(0xFFFBBF24),
        leftColor: const Color(0xFFD97706),
        rightColor: const Color(0xFFB45309),
      );
      drawIsoCube(
        canvas,
        Offset(headPos.dx + 3 * cosIso * scale, headPos.dy - 4.5 * scale),
        w: 3.5 * scale,
        d: 2.0 * scale,
        h: 2.5 * scale,
        topColor: const Color(0xFFFBBF24),
        leftColor: const Color(0xFFD97706),
        rightColor: const Color(0xFFB45309),
      );
    }

    // Minik Kuyruk (Wagging Tail)
    if (behaviorMode != 3) {
      drawIsoCube(
        canvas,
        Offset(pos.dx + 6 * cosIso * scale + tailWag, pos.dy - 4 * scale - bobY - 4 * sinIso * scale),
        w: 2.5 * scale,
        d: 2.5 * scale,
        h: 2.5 * scale,
        topColor: woolTop,
        leftColor: woolLeft,
        rightColor: woolRight,
      );
    }

    // Bacaklar (Feet if standing or walking)
    if (behaviorMode != 3) {
      drawIsoCube(
        canvas,
        Offset(pos.dx - 3 * cosIso * scale + legStride, pos.dy + 1 * scale),
        w: 2.0 * scale,
        d: 2.0 * scale,
        h: 3.0 * scale,
        topColor: const Color(0xFF1E293B),
        leftColor: const Color(0xFF0F172A),
        rightColor: const Color(0xFF020617),
      );
      drawIsoCube(
        canvas,
        Offset(pos.dx + 3 * cosIso * scale - legStride, pos.dy - 1 * scale),
        w: 2.0 * scale,
        d: 2.0 * scale,
        h: 3.0 * scale,
        topColor: const Color(0xFF1E293B),
        leftColor: const Color(0xFF0F172A),
        rightColor: const Color(0xFF020617),
      );
    }
  }

  /// Sevimli 3D Voxel Karaca / Geyik (Organik Asil Duruş, Eğilme ve Yaylanma)
  static void drawVoxelDeer(Canvas canvas, Offset pos, {double animTime = 0.0, double scale = 1.0, int seed = 0}) {
    final double timeOffset = (seed * 3.17) % 20.0;
    final double t = animTime * 0.9 + timeOffset;
    final int mode = seed % 3;

    double bobY = 0.0;
    double headTilt = 0.0;
    double headYaw = 0.0;

    if (mode == 0) {
      // 1. Asil Nöbet / Dikilme
      bobY = math.sin(t * 1.4) * 0.5 * scale;
      headYaw = math.sin(t * 1.8) * 1.5 * scale;
    } else if (mode == 1) {
      // 2. Eğilip Ot Yeme
      final double cycle = t % 6.0;
      if (cycle < 4.0) {
        headTilt = 4.0 * scale;
      } else {
        headTilt = -1.0 * scale;
      }
    } else {
      // 3. Zarif Yaylanma / Adım
      final double strideProgress = (t % 3.0) / 3.0;
      bobY = math.sin(strideProgress * math.pi * 2).abs() * 2.2 * scale;
    }

    drawIsoCube(
      canvas,
      Offset(pos.dx, pos.dy - 5 * scale - bobY),
      w: 12.0 * scale,
      d: 8.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF92400E),
      drawShadow: true,
      shadowOpacity: 0.25,
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx - 6 * cosIso * scale + headYaw * cosIso, pos.dy - 10 * scale - bobY + 2 * sinIso * scale + headTilt),
      w: 5.0 * scale,
      d: 5.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFFDE68A),
      leftColor: const Color(0xFFF59E0B),
      rightColor: const Color(0xFFD97706),
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx - 6 * cosIso * scale + headYaw * cosIso, pos.dy - 18 * scale - bobY + 2 * sinIso * scale + headTilt),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A270B),
      rightColor: const Color(0xFF3F1905),
    );
  }

  /// 3D Voxel Uçan Kuş
  static void drawVoxelBird(Canvas canvas, Offset pos, {required double wingAnim, double scale = 1.0}) {
    final double wingAngle = math.sin(wingAnim) * 0.5;

    drawIsoCube(
      canvas,
      pos,
      w: 5.0 * scale,
      d: 7.0 * scale,
      h: 3.5 * scale,
      topColor: const Color(0xFFFFFFFF),
      leftColor: const Color(0xFFE2E8F0),
      rightColor: const Color(0xFFCBD5E1),
    );

    final Offset leftWing = Offset(pos.dx - 4 * cosIso * scale, pos.dy - 1 * scale + wingAngle * 4);
    drawIsoCube(
      canvas,
      leftWing,
      w: 6.0 * scale,
      d: 3.0 * scale,
      h: 1.5 * scale,
      topColor: const Color(0xFFF8FAFC),
      leftColor: const Color(0xFFE2E8F0),
      rightColor: const Color(0xFF94A3B8),
    );

    final Offset rightWing = Offset(pos.dx + 4 * cosIso * scale, pos.dy - 1 * scale + wingAngle * 4);
    drawIsoCube(
      canvas,
      rightWing,
      w: 6.0 * scale,
      d: 3.0 * scale,
      h: 1.5 * scale,
      topColor: const Color(0xFFF8FAFC),
      leftColor: const Color(0xFFCBD5E1),
      rightColor: const Color(0xFF64748B),
    );
  }

  // --- PATİKA YOLLAR (ROADS) ---

  /// Karolar Arası 3D Doğal Taş / Arnavut Kaldırımı Patika Çizer
  static void drawVoxelRoadSegment(Canvas canvas, Offset start, Offset end) {
    const int steps = 5;
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final Offset pt = Offset.lerp(start, end, t)!;
      final double jitter = (i % 2 == 0 ? 1.0 : -1.0) * 1.5;
      final Offset stonePos = Offset(pt.dx + jitter * sinIso, pt.dy - jitter * cosIso);

      final Color stoneTop = i % 2 == 0 ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1);
      final Color stoneLeft = i % 2 == 0 ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final Color stoneRight = i % 2 == 0 ? const Color(0xFF64748B) : const Color(0xFF475569);

      drawIsoCube(
        canvas,
        stonePos,
        w: 7.0,
        d: 7.0,
        h: 1.5,
        topColor: stoneTop,
        leftColor: stoneLeft,
        rightColor: stoneRight,
        drawShadow: true,
        shadowOpacity: 0.15,
      );
    }
  }

  /// Doğal Kıyı Şeridi, Kumsal Saçakları ve Dinamik Beyaz Dalga Köpükleri
  static void drawVoxelShorelineWaves(
    Canvas canvas,
    Offset center,
    List<Offset> corners, {
    required double animTime,
    int seed = 0,
  }) {
    // 1. Kumsal Saçak Kenarlığı (Açık Kum Taşı Rengi)
    _sharedStrokePaint
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    _sharedPath
      ..reset()
      ..moveTo(corners[0].dx, corners[0].dy);
    for (int i = 1; i < 6; i++) {
      _sharedPath.lineTo(corners[i].dx, corners[i].dy);
    }
    _sharedPath.close();
    canvas.drawPath(_sharedPath, _sharedStrokePaint);

    // 2. Dinamik Sinüs Salınımlı Beyaz Dalga Köpüğü
    final double wavePulse1 = 0.5 + 0.5 * math.sin(animTime * 2.8 + seed);
    final double wavePulse2 = 0.5 + 0.5 * math.cos(animTime * 2.1 + seed);

    _sharedStrokePaint
      ..color = Colors.white.withValues(alpha: 0.75 * wavePulse1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _sharedPath2.reset();
    for (int i = 0; i < 6; i++) {
      final pA = corners[i];
      final pB = corners[(i + 1) % 6];
      final mid = Offset((pA.dx + pB.dx) / 2, (pA.dy + pB.dy) / 2);
      final offsetMid = Offset(
        mid.dx + (center.dx - mid.dx) * (0.15 + 0.1 * wavePulse1),
        mid.dy + (center.dy - mid.dy) * (0.15 + 0.1 * wavePulse1),
      );
      _sharedPath2.moveTo(pA.dx + (center.dx - pA.dx) * 0.1, pA.dy + (center.dy - pA.dy) * 0.1);
      _sharedPath2.quadraticBezierTo(offsetMid.dx, offsetMid.dy, pB.dx + (center.dx - pB.dx) * 0.1, pB.dy + (center.dy - pB.dy) * 0.1);
    }
    canvas.drawPath(_sharedPath2, _sharedStrokePaint);

    // 3. Merkezde Dalgalanan Köpük Parçaları
    drawIsoCube(
      canvas,
      Offset(center.dx - 12 + wavePulse2 * 4.0, center.dy - 6),
      w: 8.0,
      d: 3.0,
      h: 1.2,
      topColor: Colors.white.withValues(alpha: 0.8),
      leftColor: const Color(0xFFBAE6FD),
      rightColor: const Color(0xFF7DD3FC),
    );
  }

  // --- ÇİÇEKLER, ÇAKILLAR & MANTARLAR ---

  static void drawVoxelPebbles(Canvas canvas, Offset pos, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      pos,
      w: 6.0 * scale,
      d: 6.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF94A3B8),
      leftColor: const Color(0xFF64748B),
      rightColor: const Color(0xFF475569),
      drawShadow: true,
      shadowOpacity: 0.2,
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx + 6 * cosIso * scale, pos.dy + 4 * sinIso * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 2.5 * scale,
      topColor: const Color(0xFFCBD5E1),
      leftColor: const Color(0xFF94A3B8),
      rightColor: const Color(0xFF64748B),
    );
  }

  static void drawVoxelFlowers(Canvas canvas, Offset pos, {required Color flowerColor, double scale = 1.0}) {
    drawIsoCube(
      canvas,
      pos,
      w: 2.0 * scale,
      d: 2.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF4ADE80),
      leftColor: const Color(0xFF22C55E),
      rightColor: const Color(0xFF16A34A),
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx, pos.dy - 5.0 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 3.0 * scale,
      topColor: flowerColor,
      leftColor: flowerColor.withValues(alpha: 0.8),
      rightColor: flowerColor.withValues(alpha: 0.6),
    );
  }

  static void drawVoxelMushroom(Canvas canvas, Offset pos, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      pos,
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFFF1F5F9),
      leftColor: const Color(0xFFE2E8F0),
      rightColor: const Color(0xFFCBD5E1),
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx, pos.dy - 5.0 * scale),
      w: 7.0 * scale,
      d: 7.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFFEF4444),
      leftColor: const Color(0xFFDC2626),
      rightColor: const Color(0xFFB91C1C),
    );
  }

  // --- BİNALAR & GECE IŞIKLANDIRMASI (GLOWING WINDOWS) ---

  /// 3D Voxel Ekin / Buğday Tarlası (Çoklu Görsel Varyantlar & Rüzgar Salınımlı)
  static void drawVoxelCropField(Canvas canvas, Offset baseCenter, {double animTime = 0.0, int variant = 0}) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 38.0,
      d: 38.0,
      h: 4.0,
      topColor: const Color(0xFF854D0E),
      leftColor: const Color(0xFF713F12),
      rightColor: const Color(0xFF522C0A),
      drawShadow: true,
    );

    final Offset fieldTop = Offset(baseCenter.dx, baseCenter.dy - 4.0);
    final int v = variant % 3;

    if (v == 1) {
      // Varyant 1: Çapraz Ekinler & Saman Balyaları
      // 2 Köşede Saman Balyası
      drawIsoCube(
        canvas,
        Offset(fieldTop.dx - 12.0 * cosIso, fieldTop.dy - 12.0 * sinIso),
        w: 7.0,
        d: 7.0,
        h: 6.0,
        topColor: const Color(0xFFFACC15),
        leftColor: const Color(0xFFEAB308),
        rightColor: const Color(0xFFCA8A04),
      );
      drawIsoCube(
        canvas,
        Offset(fieldTop.dx + 12.0 * cosIso, fieldTop.dy + 8.0 * sinIso),
        w: 6.0,
        d: 6.0,
        h: 5.0,
        topColor: const Color(0xFFFEF08A),
        leftColor: const Color(0xFFFACC15),
        rightColor: const Color(0xFFCA8A04),
      );

      // Çapraz ekin sıraları
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i == -1 && j == -1) continue; // Saman balyası yeri
          final double windSway = math.sin(animTime * 3.0 + i * 1.1 + j * 0.7) * 1.6;
          final double offX = (i * 9.0 * cosIso) - (j * 7.0 * cosIso) + windSway;
          final double offY = (i * 9.0 * sinIso) + (j * 7.0 * sinIso);
          drawIsoCube(
            canvas,
            Offset(fieldTop.dx + offX, fieldTop.dy + offY),
            w: 4.5,
            d: 4.5,
            h: 8.0 + ((i + j + 3) % 2) * 2.5,
            topColor: const Color(0xFFFEF08A),
            leftColor: const Color(0xFFFACC15),
            rightColor: const Color(0xFFCA8A04),
          );
        }
      }
    } else if (v == 2) {
      // Varyant 2: Sulama Arkı & İkiz Ekin Yatağı
      // Ortadan geçen mavi sulama arkı
      drawIsoCube(
        canvas,
        Offset(fieldTop.dx, fieldTop.dy),
        w: 36.0,
        d: 5.0,
        h: 1.0,
        topColor: const Color(0xFF38BDF8),
        leftColor: const Color(0xFF0284C7),
        rightColor: const Color(0xFF0369A1),
      );

      // Sağ ve Sol yakadaki ekin dizileri
      for (int side in [-1, 1]) {
        for (int c = -1; c <= 1; c++) {
          final double windSway = math.sin(animTime * 2.8 + side * 1.5 + c * 0.9) * 1.4;
          final double offX = (c * 9.0 * cosIso) + (side * 8.0 * sinIso) + windSway;
          final double offY = (c * 9.0 * sinIso) + (side * 8.0 * cosIso);
          drawIsoCube(
            canvas,
            Offset(fieldTop.dx + offX, fieldTop.dy + offY),
            w: 4.0,
            d: 4.0,
            h: 8.5 + ((c + 2) % 2) * 2.0,
            topColor: side == 1 ? const Color(0xFFFEF08A) : const Color(0xFF86EFAC),
            leftColor: side == 1 ? const Color(0xFFFACC15) : const Color(0xFF4ADE80),
            rightColor: side == 1 ? const Color(0xFFCA8A04) : const Color(0xFF22C55E),
          );
        }
      }
    } else {
      // Varyant 0: 3x3 Klasik Sıralar & Ahşap Korkuluk Haçı
      const int rows = 3;
      const int cols = 3;

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (r == 1 && c == 1) continue; // Ortada korkuluk
          final double windSway = math.sin(animTime * 3.0 + (r * 0.8) + (c * 0.6)) * 1.5;
          final double offX = (c - 1) * 8.0 * cosIso - (r - 1) * 8.0 * cosIso + windSway;
          final double offY = (c - 1) * 8.0 * sinIso + (r - 1) * 8.0 * sinIso;
          final Offset cropPos = Offset(fieldTop.dx + offX, fieldTop.dy + offY);

          drawIsoCube(
            canvas,
            cropPos,
            w: 4.0,
            d: 4.0,
            h: 8.0 + ((r + c) % 2) * 2.0,
            topColor: const Color(0xFFFEF08A),
            leftColor: const Color(0xFFFACC15),
            rightColor: const Color(0xFFCA8A04),
          );
        }
      }

      // Ortada Korkuluk Haçı
      drawIsoCube(
        canvas,
        fieldTop,
        w: 2.5,
        d: 2.5,
        h: 11.0,
        topColor: const Color(0xFF92400E),
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF451A03),
      );
      drawIsoCube(
        canvas,
        Offset(fieldTop.dx, fieldTop.dy - 7.0),
        w: 8.0,
        d: 2.0,
        h: 2.0,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
      );
      drawIsoCube(
        canvas,
        Offset(fieldTop.dx, fieldTop.dy - 11.0),
        w: 3.5,
        d: 3.5,
        h: 3.0,
        topColor: const Color(0xFFFEF08A),
        leftColor: const Color(0xFFFACC15),
        rightColor: const Color(0xFFCA8A04),
      );
    }
  }

  /// 3D Voxel Arpa / Darı Tarlası (Çoklu Görsel Varyantlar)
  static void drawVoxelBarleyField(Canvas canvas, Offset baseCenter, {double animTime = 0.0, int variant = 0}) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 38.0,
      d: 38.0,
      h: 4.0,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A2508),
      rightColor: const Color(0xFF451A03),
      drawShadow: true,
    );

    final Offset fieldTop = Offset(baseCenter.dx, baseCenter.dy - 4.0);
    final int v = variant % 3;

    if (v == 1) {
      // Varyant 1: Ahşap Çitler & Rüzgar Flama Direği
      // Kenar ahşap çitler
      for (double side in [-1.0, 1.0]) {
        drawIsoCube(
          canvas,
          Offset(fieldTop.dx + side * 14.0 * cosIso, fieldTop.dy + side * 14.0 * sinIso),
          w: 26.0,
          d: 2.5,
          h: 4.0,
          topColor: const Color(0xFFB45309),
          leftColor: const Color(0xFF92400E),
          rightColor: const Color(0xFF78350F),
        );
      }

      // Rüzgar Flama Direği
      final Offset flagPos = Offset(fieldTop.dx - 12.0 * cosIso, fieldTop.dy - 12.0 * sinIso);
      drawIsoCube(
        canvas,
        flagPos,
        w: 2.5,
        d: 2.5,
        h: 14.0,
        topColor: const Color(0xFFCBD5E1),
        leftColor: const Color(0xFF94A3B8),
        rightColor: const Color(0xFF64748B),
      );
      final double flagWave = math.sin(animTime * 4.0) * 1.5;
      drawIsoCube(
        canvas,
        Offset(flagPos.dx + 4.0 + flagWave, flagPos.dy - 12.0),
        w: 6.0,
        d: 1.5,
        h: 3.5,
        topColor: const Color(0xFFDC2626),
        leftColor: const Color(0xFFB91C1C),
        rightColor: const Color(0xFF991B1B),
      );

      // Gür arpa başakları
      for (int r = -1; r <= 1; r++) {
        for (int c = -1; c <= 1; c++) {
          final double windSway = math.sin(animTime * 2.6 + r * 1.0 + c * 0.8) * 1.6;
          final double offX = (c * 7.5 * cosIso) - (r * 7.5 * cosIso) + windSway;
          final double offY = (c * 7.5 * sinIso) + (r * 7.5 * sinIso);
          drawIsoCube(
            canvas,
            Offset(fieldTop.dx + offX, fieldTop.dy + offY),
            w: 3.5,
            d: 3.5,
            h: 9.5 + ((r * 2 + c + 4) % 3) * 1.5,
            topColor: const Color(0xFFFDE047),
            leftColor: const Color(0xFFEAB308),
            rightColor: const Color(0xFFB45309),
          );
        }
      }
    } else if (v == 2) {
      // Varyant 2: Keten Tahıl Çuvalları & Eğimli Arpa Demetleri
      // 2 Keten Çuval
      final Offset sackPos = Offset(fieldTop.dx + 11.0 * cosIso, fieldTop.dy - 10.0 * sinIso);
      drawIsoCube(
        canvas,
        sackPos,
        w: 6.0,
        d: 6.0,
        h: 6.0,
        topColor: const Color(0xFFD97706),
        leftColor: const Color(0xFFB45309),
        rightColor: const Color(0xFF92400E),
      );
      drawIsoCube(
        canvas,
        Offset(sackPos.dx - 4.0 * cosIso, sackPos.dy + 4.0 * sinIso),
        w: 5.0,
        d: 5.0,
        h: 5.0,
        topColor: const Color(0xFFF59E0B),
        leftColor: const Color(0xFFD97706),
        rightColor: const Color(0xFFB45309),
      );

      // Eğimli arpa demetleri
      for (int i = 0; i < 7; i++) {
        final double a = i * (math.pi / 3.5);
        final double windSway = math.sin(animTime * 2.5 + i) * 1.5;
        final double px = fieldTop.dx + math.cos(a) * 10.0 * cosIso + windSway;
        final double py = fieldTop.dy + math.sin(a) * 10.0 * sinIso;
        drawIsoCube(
          canvas,
          Offset(px, py),
          w: 4.0,
          d: 4.0,
          h: 9.0 + (i % 3) * 1.5,
          topColor: const Color(0xFFFDE047),
          leftColor: const Color(0xFFEAB308),
          rightColor: const Color(0xFFB45309),
        );
      }
    } else {
      // Varyant 0: 4 Köşede Dikili Yontma Taş Sınır İşaretleri & Kehribar Başaklar
      for (final signX in [-1.0, 1.0]) {
        for (final signY in [-1.0, 1.0]) {
          final double sx = baseCenter.dx + (signX * 14.0 * cosIso) - (signY * 14.0 * cosIso);
          final double sy = baseCenter.dy + (signX * 14.0 * sinIso) + (signY * 14.0 * sinIso) - 4.0;
          drawIsoCube(
            canvas,
            Offset(sx, sy),
            w: 4.0,
            d: 4.0,
            h: 6.0,
            topColor: const Color(0xFF94A3B8),
            leftColor: const Color(0xFF64748B),
            rightColor: const Color(0xFF475569),
          );
        }
      }

      const int rows = 3;
      const int cols = 3;
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final double windSway = math.sin(animTime * 2.5 + (r * 0.9) + (c * 0.7)) * 1.8;
          final double offX = (c - 1) * 7.5 * cosIso - (r - 1) * 7.5 * cosIso + windSway;
          final double offY = (c - 1) * 7.5 * sinIso + (r - 1) * 7.5 * sinIso;
          final Offset cropPos = Offset(fieldTop.dx + offX, fieldTop.dy + offY);

          drawIsoCube(
            canvas,
            cropPos,
            w: 3.5,
            d: 3.5,
            h: 9.0 + ((r * 2 + c) % 3) * 1.5,
            topColor: const Color(0xFFFDE047),
            leftColor: const Color(0xFFEAB308),
            rightColor: const Color(0xFFB45309),
          );
        }
      }
    }
  }

  /// 3D Voxel Bozkır Otlağı / At Harası (Çoklu Görsel Varyantlar)
  static void drawVoxelPasture(Canvas canvas, Offset baseCenter, {double animTime = 0.0, int variant = 0}) {
    // Çim zemin
    drawIsoCube(
      canvas,
      baseCenter,
      w: 40.0,
      d: 40.0,
      h: 3.0,
      topColor: const Color(0xFF15803D),
      leftColor: const Color(0xFF166534),
      rightColor: const Color(0xFF14532D),
      drawShadow: true,
    );

    final Offset topCenter = Offset(baseCenter.dx, baseCenter.dy - 3.0);
    final int v = variant % 3;

    if (v == 1) {
      // Varyant 1: Alçak Taş Örgü Ağıl & İkili Otlayan Koyun Sürüsü
      // Taş örgü ağıl duvarları
      for (double side in [-1.0, 1.0]) {
        drawIsoCube(
          canvas,
          Offset(topCenter.dx + side * 14.0 * cosIso, topCenter.dy - 6.0 * sinIso),
          w: 22.0,
          d: 3.0,
          h: 4.5,
          topColor: const Color(0xFF94A3B8),
          leftColor: const Color(0xFF64748B),
          rightColor: const Color(0xFF475569),
        );
      }

      // Kuru ot yığını
      drawIsoCube(
        canvas,
        Offset(topCenter.dx - 10.0 * cosIso, topCenter.dy - 10.0 * sinIso),
        w: 8.0,
        d: 8.0,
        h: 5.0,
        topColor: const Color(0xFFFEF08A),
        leftColor: const Color(0xFFFACC15),
        rightColor: const Color(0xFFCA8A04),
      );

      // 2 Otlayan Koyun
      final double sheepBob = math.sin(animTime * 2.5) * 0.8;
      // Koyun 1
      drawIsoCube(
        canvas,
        Offset(topCenter.dx + 2.0 * cosIso, topCenter.dy + 4.0 * sinIso + sheepBob),
        w: 6.0,
        d: 5.0,
        h: 4.5,
        topColor: const Color(0xFFF8FAFC),
        leftColor: const Color(0xFFE2E8F0),
        rightColor: const Color(0xFFCBD5E1),
      );
      // Koyun 2
      drawIsoCube(
        canvas,
        Offset(topCenter.dx + 10.0 * cosIso, topCenter.dy + 8.0 * sinIso - sheepBob),
        w: 5.0,
        d: 4.0,
        h: 4.0,
        topColor: const Color(0xFFF1F5F9),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );
    } else if (v == 2) {
      // Varyant 2: Kubbeli Keçe Çoban Barınağı Otağı & Dinlenen At
      // Küçük Keçe Çadır
      final Offset tentPos = Offset(topCenter.dx - 8.0 * cosIso, topCenter.dy - 8.0 * sinIso);
      drawIsoCube(
        canvas,
        tentPos,
        w: 12.0,
        d: 12.0,
        h: 7.0,
        topColor: const Color(0xFFF1F5F9),
        leftColor: const Color(0xFFE2E8F0),
        rightColor: const Color(0xFFCBD5E1),
      );
      drawIsoCube(
        canvas,
        Offset(tentPos.dx, tentPos.dy - 7.0),
        w: 7.0,
        d: 7.0,
        h: 4.0,
        topColor: const Color(0xFFE2E8F0),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );

      // Yalama Tuz Taşı Bloğu
      drawIsoCube(
        canvas,
        Offset(topCenter.dx + 8.0 * cosIso, topCenter.dy - 8.0 * sinIso),
        w: 4.5,
        d: 4.5,
        h: 4.0,
        topColor: const Color(0xFFE0F2FE),
        leftColor: const Color(0xFFBAE6FD),
        rightColor: const Color(0xFF7DD3FC),
      );

      // Dinlenen Bozkır Atı
      final Offset horsePos = Offset(topCenter.dx + 6.0 * cosIso, topCenter.dy + 6.0 * sinIso);
      drawIsoCube(
        canvas,
        horsePos,
        w: 9.0,
        d: 5.0,
        h: 4.5,
        topColor: const Color(0xFF92400E),
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF451A03),
      );
    } else {
      // Varyant 0: Ahşap Çitler, Su Yalağı & Otlayan Bozkır Atı
      for (int i = 0; i < 4; i++) {
        final double angle = i * (math.pi / 2.0) + (math.pi / 4.0);
        final double px = topCenter.dx + math.cos(angle) * 16.0 * cosIso;
        final double py = topCenter.dy + math.sin(angle) * 16.0 * sinIso;
        drawIsoCube(
          canvas,
          Offset(px, py),
          w: 3.0,
          d: 3.0,
          h: 7.0,
          topColor: const Color(0xFFB45309),
          leftColor: const Color(0xFF92400E),
          rightColor: const Color(0xFF78350F),
        );
      }

      // Su yalağı
      final Offset troughPos = Offset(topCenter.dx - 10.0 * cosIso, topCenter.dy - 10.0 * sinIso);
      drawIsoCube(
        canvas,
        troughPos,
        w: 8.0,
        d: 5.0,
        h: 4.0,
        topColor: const Color(0xFF38BDF8),
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF451A03),
      );

      // Otlayan bozkır atı
      final double grazeBob = math.sin(animTime * 2.0) * 1.0;
      final Offset animalPos = Offset(topCenter.dx + 4.0 * cosIso, topCenter.dy + 4.0 * sinIso);

      drawIsoCube(
        canvas,
        animalPos,
        w: 8.0,
        d: 5.0,
        h: 6.0,
        topColor: const Color(0xFFF1F5F9),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );
      drawIsoCube(
        canvas,
        Offset(animalPos.dx + 4.0 * cosIso, animalPos.dy + 4.0 * sinIso + grazeBob),
        w: 4.0,
        d: 4.0,
        h: 4.0,
        topColor: const Color(0xFFE2E8F0),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF64748B),
      );
    }
  }

  /// 3D Voxel Yemişlik / Meyve Bahçesi (Çoklu Görsel Varyantlar)
  static void drawVoxelOrchard(Canvas canvas, Offset baseCenter, {double animTime = 0.0, int variant = 0}) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 38.0,
      d: 38.0,
      h: 3.5,
      topColor: const Color(0xFF166534),
      leftColor: const Color(0xFF14532D),
      rightColor: const Color(0xFF0F3D20),
      drawShadow: true,
    );

    final Offset fieldTop = Offset(baseCenter.dx, baseCenter.dy - 3.5);
    final int v = variant % 3;

    if (v == 1) {
      // Varyant 1: Ahşap Çardak / Asma Düzeni & Turuncu Kayısılar + Hasat Sepeti
      // Ahşap Çardak Sırıkları
      for (double side in [-1.0, 1.0]) {
        drawIsoCube(
          canvas,
          Offset(fieldTop.dx + side * 10.0 * cosIso, fieldTop.dy - 4.0),
          w: 20.0,
          d: 2.5,
          h: 9.0,
          topColor: const Color(0xFF78350F),
          leftColor: const Color(0xFF5A2508),
          rightColor: const Color(0xFF451A03),
        );
      }

      // 2 Yayvan Ağaç
      final List<Offset> treeOffsets = [
        Offset(-8.0 * cosIso, -4.0 * sinIso),
        Offset(8.0 * cosIso, 4.0 * sinIso),
      ];
      for (int i = 0; i < treeOffsets.length; i++) {
        final double sway = math.sin(animTime * 2.2 + i * 2.0) * 1.2;
        final Offset crownPos = Offset(fieldTop.dx + treeOffsets[i].dx + sway, fieldTop.dy + treeOffsets[i].dy - 9.0);
        drawIsoCube(
          canvas,
          crownPos,
          w: 14.0,
          d: 14.0,
          h: 8.0,
          topColor: const Color(0xFF22C55E),
          leftColor: const Color(0xFF16A34A),
          rightColor: const Color(0xFF15803D),
        );
        // Turuncu Meyveler
        drawIsoCube(
          canvas,
          Offset(crownPos.dx + 2.0, crownPos.dy - 2.0),
          w: 3.0,
          d: 3.0,
          h: 3.0,
          topColor: const Color(0xFFF97316),
          leftColor: const Color(0xFFEA580C),
          rightColor: const Color(0xFFC2410C),
        );
      }

      // Hasat Sepeti
      drawIsoCube(
        canvas,
        Offset(fieldTop.dx + 10.0 * cosIso, fieldTop.dy + 8.0 * sinIso),
        w: 5.0,
        d: 5.0,
        h: 4.5,
        topColor: const Color(0xFFD97706),
        leftColor: const Color(0xFFB45309),
        rightColor: const Color(0xFF92400E),
      );
    } else if (v == 2) {
      // Varyant 2: Heybetli Ulu Meyve Ağacı & Ahşap Meyve Kasaları
      final double sway = math.sin(animTime * 1.8) * 1.5;
      final Offset trunkPos = Offset(fieldTop.dx - 2.0 * cosIso, fieldTop.dy - 2.0 * sinIso);

      // Kalın Ağaç Gövdesi
      drawIsoCube(
        canvas,
        trunkPos,
        w: 6.0,
        d: 6.0,
        h: 9.0,
        topColor: const Color(0xFF78350F),
        leftColor: const Color(0xFF5A2508),
        rightColor: const Color(0xFF451A03),
      );

      // Geniş Heybetli Taç
      final Offset bigCrown = Offset(trunkPos.dx + sway, trunkPos.dy - 9.0);
      drawIsoCube(
        canvas,
        bigCrown,
        w: 18.0,
        d: 18.0,
        h: 12.0,
        topColor: const Color(0xFF16A34A),
        leftColor: const Color(0xFF15803D),
        rightColor: const Color(0xFF14532D),
      );

      // Meyveler
      for (int f = 0; f < 3; f++) {
        final double fx = (f - 1) * 5.0;
        final Color fCol = f % 2 == 0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
        drawIsoCube(
          canvas,
          Offset(bigCrown.dx + fx, bigCrown.dy - 2.0 - (f % 2) * 3.0),
          w: 3.0,
          d: 3.0,
          h: 3.0,
          topColor: fCol,
          leftColor: fCol,
          rightColor: fCol,
        );
      }

      // 2 Ahşap Meyve Kasası
      final Offset cratePos = Offset(fieldTop.dx + 10.0 * cosIso, fieldTop.dy + 8.0 * sinIso);
      drawIsoCube(
        canvas,
        cratePos,
        w: 7.0,
        d: 6.0,
        h: 4.5,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
      );
      drawIsoCube(
        canvas,
        Offset(cratePos.dx, cratePos.dy - 4.5),
        w: 5.5,
        d: 5.0,
        h: 4.0,
        topColor: const Color(0xFFD97706),
        leftColor: const Color(0xFFB45309),
        rightColor: const Color(0xFF92400E),
      );
    } else {
      // Varyant 0: 3 Bodur Dağ Meyve Ağacı
      final List<Offset> treeOffsets = [
        Offset(-10.0 * cosIso + 6.0 * cosIso, -10.0 * sinIso - 6.0 * sinIso),
        Offset(8.0 * cosIso - 8.0 * cosIso, 8.0 * sinIso + 8.0 * sinIso),
        Offset(10.0 * cosIso + 6.0 * cosIso, 10.0 * sinIso - 6.0 * sinIso),
      ];

      for (int i = 0; i < treeOffsets.length; i++) {
        final double sway = math.sin(animTime * 2.0 + i * 1.5) * 1.2;
        final Offset trunkPos = Offset(fieldTop.dx + treeOffsets[i].dx, fieldTop.dy + treeOffsets[i].dy);

        drawIsoCube(
          canvas,
          trunkPos,
          w: 3.5,
          d: 3.5,
          h: 6.0,
          topColor: const Color(0xFF78350F),
          leftColor: const Color(0xFF5A2508),
          rightColor: const Color(0xFF451A03),
        );

        final Offset crownPos = Offset(trunkPos.dx + sway, trunkPos.dy - 6.0);
        drawIsoCube(
          canvas,
          crownPos,
          w: 12.0,
          d: 12.0,
          h: 9.0,
          topColor: const Color(0xFF22C55E),
          leftColor: const Color(0xFF16A34A),
          rightColor: const Color(0xFF15803D),
        );

        final Color fruitColor = (i % 2 == 0) ? const Color(0xFFEF4444) : const Color(0xFFF97316);
        drawIsoCube(
          canvas,
          Offset(crownPos.dx + 2.0, crownPos.dy - 3.0),
          w: 3.0,
          d: 3.0,
          h: 3.0,
          topColor: fruitColor,
          leftColor: fruitColor,
          rightColor: fruitColor,
        );
        drawIsoCube(
          canvas,
          Offset(crownPos.dx - 3.0, crownPos.dy + 1.0),
          w: 2.5,
          d: 2.5,
          h: 2.5,
          topColor: fruitColor,
          leftColor: fruitColor,
          rightColor: fruitColor,
        );
      }
    }
  }

  /// 3D Voxel Taş Yonma Ocağı (Çoklu Görsel Varyantlar)
  static void drawVoxelQuarry(Canvas canvas, Offset baseCenter, {int variant = 0}) {
    // Taş Ocağı Basamağı 1
    drawIsoCube(
      canvas,
      baseCenter,
      w: 40.0,
      d: 40.0,
      h: 6.0,
      topColor: const Color(0xFF475569),
      leftColor: const Color(0xFF334155),
      rightColor: const Color(0xFF1E293B),
      drawShadow: true,
    );

    final int v = variant % 3;

    if (v == 1) {
      // Varyant 1: Ahşap Çıkrık Vinç / İskele & Dev Bazalt Kaya Kütlesi
      // Dev Bazalt Kaya Kütlesi
      final Offset rockPos = Offset(baseCenter.dx - 6.0 * cosIso, baseCenter.dy - 6.0 - 6.0 * sinIso);
      drawIsoCube(
        canvas,
        rockPos,
        w: 18.0,
        d: 18.0,
        h: 12.0,
        topColor: const Color(0xFF334155),
        leftColor: const Color(0xFF1E293B),
        rightColor: const Color(0xFF0F172A),
      );

      // Ahşap Vinç Direği & Bom Kolu
      final Offset cranePos = Offset(baseCenter.dx + 10.0 * cosIso, baseCenter.dy - 6.0 + 8.0 * sinIso);
      drawIsoCube(
        canvas,
        cranePos,
        w: 3.0,
        d: 3.0,
        h: 16.0,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
      );
      drawIsoCube(
        canvas,
        Offset(cranePos.dx - 6.0 * cosIso, cranePos.dy - 16.0 - 6.0 * sinIso),
        w: 14.0,
        d: 2.5,
        h: 2.5,
        topColor: const Color(0xFFD97706),
        leftColor: const Color(0xFFB45309),
        rightColor: const Color(0xFF92400E),
      );

      // Kırılmış Taş Yongaları
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 4.0 * cosIso, baseCenter.dy - 6.0),
        w: 5.0,
        d: 5.0,
        h: 3.0,
        topColor: const Color(0xFF94A3B8),
        leftColor: const Color(0xFF64748B),
        rightColor: const Color(0xFF475569),
      );
    } else if (v == 2) {
      // Varyant 2: Kemerli Maden Tüneli Girişi & Taş Arabası
      // Tünel Kemer Bloğu
      final Offset tunnelPos = Offset(baseCenter.dx - 4.0 * cosIso, baseCenter.dy - 6.0 - 4.0 * sinIso);
      drawIsoCube(
        canvas,
        tunnelPos,
        w: 20.0,
        d: 14.0,
        h: 10.0,
        topColor: const Color(0xFF64748B),
        leftColor: const Color(0xFF475569),
        rightColor: const Color(0xFF334155),
      );
      // Tünel Boşluğu (Kara Delik)
      drawIsoCube(
        canvas,
        Offset(tunnelPos.dx + 2.0 * cosIso, tunnelPos.dy + 2.0 * sinIso),
        w: 10.0,
        d: 8.0,
        h: 7.0,
        topColor: const Color(0xFF0F172A),
        leftColor: const Color(0xFF020617),
        rightColor: const Color(0xFF000000),
      );

      // Taş Yüklü El Arabası / Vagon
      final Offset cartPos = Offset(baseCenter.dx + 10.0 * cosIso, baseCenter.dy - 6.0 + 8.0 * sinIso);
      drawIsoCube(
        canvas,
        cartPos,
        w: 8.0,
        d: 6.0,
        h: 5.0,
        topColor: const Color(0xFFCBD5E1),
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF5A2508),
      );
    } else {
      // Varyant 0: Kademeli Teras & İstiflenmiş Kesme Taş Blokları
      final Offset step2 = Offset(baseCenter.dx - 4.0 * cosIso, baseCenter.dy - 6.0 - 4.0 * sinIso);
      drawIsoCube(
        canvas,
        step2,
        w: 24.0,
        d: 24.0,
        h: 8.0,
        topColor: const Color(0xFF64748B),
        leftColor: const Color(0xFF475569),
        rightColor: const Color(0xFF334155),
      );

      final Offset stackPos = Offset(baseCenter.dx + 10.0 * cosIso, baseCenter.dy - 6.0 + 10.0 * sinIso);
      drawIsoCube(
        canvas,
        stackPos,
        w: 8.0,
        d: 8.0,
        h: 8.0,
        topColor: const Color(0xFFCBD5E1),
        leftColor: const Color(0xFF94A3B8),
        rightColor: const Color(0xFF64748B),
      );
      drawIsoCube(
        canvas,
        Offset(stackPos.dx, stackPos.dy - 8.0),
        w: 6.0,
        d: 6.0,
        h: 5.0,
        topColor: const Color(0xFFE2E8F0),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );
    }
  }

  /// 3D Voxel Katran & Huş Otağı (Çoklu Görsel Varyantlar)
  static void drawVoxelResinCamp(Canvas canvas, Offset baseCenter, {double animTime = 0.0, int variant = 0}) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 38.0,
      d: 38.0,
      h: 3.0,
      topColor: const Color(0xFF14532D),
      leftColor: const Color(0xFF0F3D20),
      rightColor: const Color(0xFF0A2915),
      drawShadow: true,
    );

    final Offset topCenter = Offset(baseCenter.dx, baseCenter.dy - 3.0);
    final int v = variant % 3;

    if (v == 1) {
      // Varyant 1: 2 Beyaz Huş Ağacı & Taş Damıtma Fırını + Reçine Fıçıları
      // 2 Huş Ağacı (Beyaz Gövde, Yeşil Taç)
      final List<Offset> birchTrees = [
        Offset(topCenter.dx - 10.0 * cosIso, topCenter.dy - 6.0 * sinIso),
        Offset(topCenter.dx - 4.0 * cosIso, topCenter.dy - 12.0 * sinIso),
      ];
      for (final bp in birchTrees) {
        drawIsoCube(
          canvas,
          bp,
          w: 3.0,
          d: 3.0,
          h: 12.0,
          topColor: const Color(0xFFF8FAFC),
          leftColor: const Color(0xFFE2E8F0),
          rightColor: const Color(0xFF94A3B8),
        );
        drawIsoCube(
          canvas,
          Offset(bp.dx, bp.dy - 12.0),
          w: 10.0,
          d: 10.0,
          h: 8.0,
          topColor: const Color(0xFF4ADE80),
          leftColor: const Color(0xFF22C55E),
          rightColor: const Color(0xFF16A34A),
        );
      }

      // Taş Damıtma Fırını
      final Offset kilnPos = Offset(topCenter.dx + 8.0 * cosIso, topCenter.dy + 6.0 * sinIso);
      drawIsoCube(
        canvas,
        kilnPos,
        w: 10.0,
        d: 10.0,
        h: 7.0,
        topColor: const Color(0xFF64748B),
        leftColor: const Color(0xFF475569),
        rightColor: const Color(0xFF334155),
      );
      // Reçine Fıçısı
      drawIsoCube(
        canvas,
        Offset(topCenter.dx + 11.0 * cosIso, topCenter.dy - 6.0 * sinIso),
        w: 5.0,
        d: 5.0,
        h: 6.0,
        topColor: const Color(0xFF78350F),
        leftColor: const Color(0xFF5A2508),
        rightColor: const Color(0xFF451A03),
      );
    } else if (v == 2) {
      // Varyant 2: 4 Direkli Ahşap Hızar Sundurması & Kereste İstifi
      // Ahşap Sundurma Direkleri & Çatı
      final Offset shedPos = Offset(topCenter.dx - 4.0 * cosIso, topCenter.dy - 4.0 * sinIso);
      for (double dx in [-6.0, 6.0]) {
        for (double dy in [-6.0, 6.0]) {
          drawIsoCube(
            canvas,
            Offset(shedPos.dx + dx * cosIso, shedPos.dy + dy * sinIso),
            w: 2.0,
            d: 2.0,
            h: 9.0,
            topColor: const Color(0xFF92400E),
            leftColor: const Color(0xFF78350F),
            rightColor: const Color(0xFF5A2508),
          );
        }
      }
      // Sundurma Çatısı
      drawIsoCube(
        canvas,
        Offset(shedPos.dx, shedPos.dy - 9.0),
        w: 16.0,
        d: 16.0,
        h: 2.5,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
      );

      // Huş Kereste Tomruk İstifi
      final Offset logPos = Offset(topCenter.dx + 10.0 * cosIso, topCenter.dy + 8.0 * sinIso);
      drawIsoCube(
        canvas,
        logPos,
        w: 10.0,
        d: 5.0,
        h: 4.5,
        topColor: const Color(0xFFF8FAFC),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );
    } else {
      // Varyant 0: Beyaz Huş Kabuklu Yurt, Tüten Katran Kazanı & İstiflenmiş Huş Kütükleri
      final Offset yurtPos = Offset(topCenter.dx - 6.0 * cosIso, topCenter.dy - 6.0 * sinIso);
      drawIsoCube(
        canvas,
        yurtPos,
        w: 18.0,
        d: 18.0,
        h: 8.0,
        topColor: const Color(0xFFF1F5F9),
        leftColor: const Color(0xFFE2E8F0),
        rightColor: const Color(0xFFCBD5E1),
      );
      drawIsoCube(
        canvas,
        Offset(yurtPos.dx, yurtPos.dy - 8.0),
        w: 12.0,
        d: 12.0,
        h: 5.0,
        topColor: const Color(0xFFE2E8F0),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );

      final Offset cauldronPos = Offset(topCenter.dx + 8.0 * cosIso, topCenter.dy + 8.0 * sinIso);
      final double emberGlow = 0.7 + 0.3 * math.sin(animTime * 5.0);
      drawIsoCube(
        canvas,
        cauldronPos,
        w: 6.0,
        d: 6.0,
        h: 5.0,
        topColor: const Color(0xFF0F172A),
        leftColor: const Color(0xFF020617),
        rightColor: const Color(0xFF000000),
      );
      drawIsoCube(
        canvas,
        Offset(cauldronPos.dx, cauldronPos.dy + 2.0),
        w: 7.0,
        d: 7.0,
        h: 1.5,
        topColor: Color.fromRGBO(249, 115, 22, emberGlow),
        leftColor: const Color(0xFFEA580C),
        rightColor: const Color(0xFFC2410C),
      );

      final Offset logPos = Offset(topCenter.dx + 10.0 * cosIso, topCenter.dy - 8.0 * sinIso);
      drawIsoCube(
        canvas,
        logPos,
        w: 8.0,
        d: 5.0,
        h: 4.0,
        topColor: const Color(0xFFF8FAFC),
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF5A2508),
      );
    }
  }

  /// 3D Voxel Şato / Kale (Gece Pencereleri & Fenerler)
  static void drawVoxelCastle(Canvas canvas, Offset baseCenter, int level, {bool isNight = false}) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 36.0,
      d: 36.0,
      h: 18.0,
      topColor: const Color(0xFFCBD5E1),
      leftColor: const Color(0xFF94A3B8),
      rightColor: const Color(0xFF64748B),
      drawShadow: true,
    );

    // Kapı
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx, baseCenter.dy + 8),
      w: 10.0,
      d: 4.0,
      h: 10.0,
      topColor: const Color(0xFF1E293B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF020617),
    );

    // Kuleler
    for (final xSign in [-1.0, 1.0]) {
      final double tx = baseCenter.dx + xSign * 16.0 * cosIso;
      final double ty = baseCenter.dy - 18.0 + xSign * 16.0 * sinIso;

      drawIsoCube(
        canvas,
        Offset(tx, ty + 12),
        w: 12.0,
        d: 12.0,
        h: 24.0,
        topColor: const Color(0xFFE2E8F0),
        leftColor: const Color(0xFF94A3B8),
        rightColor: const Color(0xFF475569),
      );

      // Gece Kule Penceresi Işığı
      if (isNight) {
        drawIsoCube(
          canvas,
          Offset(tx, ty + 2),
          w: 4.0,
          d: 4.0,
          h: 4.0,
          topColor: const Color(0xFFFEF08A),
          leftColor: const Color(0xFFFBBF24),
          rightColor: const Color(0xFFF59E0B),
        );
      }

      drawIsoCube(
        canvas,
        Offset(tx, ty - 12),
        w: 14.0,
        d: 14.0,
        h: 8.0,
        topColor: const Color(0xFFEF4444),
        leftColor: const Color(0xFFDC2626),
        rightColor: const Color(0xFF991B1B),
      );
    }

    final Offset keepTop = Offset(baseCenter.dx, baseCenter.dy - 18.0);
    drawIsoCube(
      canvas,
      keepTop,
      w: 3.0,
      d: 3.0,
      h: 14.0,
      topColor: const Color(0xFFFDE047),
      leftColor: const Color(0xFFEAB308),
      rightColor: const Color(0xFFCA8A04),
    );
  }

  /// 3D Voxel Dönen Değirmen (Çoklu Görsel Varyantlar)
  static void drawVoxelWindmill(Canvas canvas, Offset baseCenter, double animTime, {bool isNight = false, int variant = 0}) {
    final int v = variant % 3;
    final Color towerTop = v == 1 ? const Color(0xFF94A3B8) : const Color(0xFFF8FAFC);
    final Color towerLeft = v == 1 ? const Color(0xFF64748B) : const Color(0xFFE2E8F0);
    final Color towerRight = v == 1 ? const Color(0xFF475569) : const Color(0xFF94A3B8);

    drawIsoCube(
      canvas,
      baseCenter,
      w: 24.0,
      d: 24.0,
      h: 26.0,
      topColor: towerTop,
      leftColor: towerLeft,
      rightColor: towerRight,
      drawShadow: true,
    );

    if (v == 1) {
      // Varyant 1: Önünde un çuvalları
      final Offset sackPos = Offset(baseCenter.dx + 12 * cosIso, baseCenter.dy + 8 * sinIso);
      drawIsoCube(
        canvas,
        sackPos,
        w: 6.0,
        d: 6.0,
        h: 5.0,
        topColor: const Color(0xFFFEF08A),
        leftColor: const Color(0xFFFACC15),
        rightColor: const Color(0xFFCA8A04),
      );
    } else if (v == 2) {
      // Varyant 2: Ahşap tahıl ambarı sundurması
      final Offset shedPos = Offset(baseCenter.dx + 12 * cosIso, baseCenter.dy - 6 * sinIso);
      drawIsoCube(
        canvas,
        shedPos,
        w: 10.0,
        d: 8.0,
        h: 12.0,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
      );
    }

    if (isNight) {
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 4 * cosIso, baseCenter.dy - 10),
        w: 4.0,
        d: 3.0,
        h: 4.0,
        topColor: const Color(0xFFFEF08A),
        leftColor: const Color(0xFFFBBF24),
        rightColor: const Color(0xFFF59E0B),
      );
    }

    final Offset roofBase = Offset(baseCenter.dx, baseCenter.dy - 26.0);
    final Color roofTop = v == 1 ? const Color(0xFFB45309) : const Color(0xFFF87171);
    final Color roofLeft = v == 1 ? const Color(0xFF92400E) : const Color(0xFFEF4444);
    final Color roofRight = v == 1 ? const Color(0xFF78350F) : const Color(0xFFB91C1C);

    drawIsoCube(
      canvas,
      roofBase,
      w: 20.0,
      d: 20.0,
      h: 10.0,
      topColor: roofTop,
      leftColor: roofLeft,
      rightColor: roofRight,
    );

    final Offset rotorHub = Offset(baseCenter.dx - 8 * cosIso, baseCenter.dy - 20.0 + 8 * sinIso);
    final double angle = animTime * (v == 2 ? 3.5 : 2.8);
    final int bladeCount = v == 2 ? 6 : 4;

    for (int i = 0; i < bladeCount; i++) {
      final double a = angle + i * (2 * math.pi / bladeCount);
      const double bLen = 16.0;
      final double bx = rotorHub.dx + bLen * math.cos(a);
      final double by = rotorHub.dy + bLen * math.sin(a) * 0.8;

      _sharedFillPaint
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.fill;
      _sharedStrokePaint
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawLine(rotorHub, Offset(bx, by), _sharedStrokePaint);
      canvas.drawCircle(Offset(bx, by), 3.0, _sharedFillPaint);
    }
    _sharedFillPaint
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(rotorHub, 3.5, _sharedFillPaint);
  }

  /// 3D Voxel Fırın (Çoklu Görsel Varyantlar)
  static void drawVoxelBakery(Canvas canvas, Offset baseCenter, double animTime, {bool isNight = false, int variant = 0}) {
    final int v = variant % 3;

    drawIsoCube(
      canvas,
      baseCenter,
      w: 28.0,
      d: 28.0,
      h: 16.0,
      topColor: const Color(0xFFE2E8F0),
      leftColor: const Color(0xFF94A3B8),
      rightColor: const Color(0xFF64748B),
      drawShadow: true,
    );

    if (v == 1) {
      // Varyant 1: Ekmek sergileme tezgahı & odun yığını
      final Offset benchPos = Offset(baseCenter.dx + 12 * cosIso, baseCenter.dy + 8 * sinIso);
      drawIsoCube(
        canvas,
        benchPos,
        w: 8.0,
        d: 5.0,
        h: 5.0,
        topColor: const Color(0xFFF59E0B),
        leftColor: const Color(0xFFD97706),
        rightColor: const Color(0xFFB45309),
      );
    } else if (v == 2) {
      // Varyant 2: Un deposu yan sundurması
      final Offset flourPos = Offset(baseCenter.dx - 10 * cosIso, baseCenter.dy + 8 * sinIso);
      drawIsoCube(
        canvas,
        flourPos,
        w: 7.0,
        d: 7.0,
        h: 6.0,
        topColor: const Color(0xFFFEF08A),
        leftColor: const Color(0xFFFDE047),
        rightColor: const Color(0xFFCA8A04),
      );
    }

    final Offset chimneyBase = Offset(baseCenter.dx + 8 * cosIso, baseCenter.dy - 16.0 - 4 * sinIso);
    drawIsoCube(
      canvas,
      chimneyBase,
      w: 8.0,
      d: 8.0,
      h: 12.0,
      topColor: const Color(0xFFF97316),
      leftColor: const Color(0xFFEA580C),
      rightColor: const Color(0xFFC2410C),
    );

    final double puffY = (animTime * 20.0) % 24.0;
    final double alpha = (1.0 - (puffY / 24.0)).clamp(0.0, 1.0);
    final double puffScale = 0.6 + (puffY / 24.0) * 0.8;

    drawIsoCube(
      canvas,
      Offset(chimneyBase.dx, chimneyBase.dy - 12.0 - puffY),
      w: 8.0 * puffScale,
      d: 8.0 * puffScale,
      h: 6.0 * puffScale,
      topColor: Colors.white.withValues(alpha: alpha * 0.9),
      leftColor: const Color(0xFFE2E8F0).withValues(alpha: alpha * 0.8),
      rightColor: const Color(0xFFCBD5E1).withValues(alpha: alpha * 0.7),
    );
  }

  /// 3D Voxel Dağ - Çoklu Prosedürel Morfoloji
  static void drawVoxelMountainVariant(
    Canvas canvas,
    Offset baseCenter,
    int variant, {
    String season = 'SPRING',
    bool isZud = false,
    double scale = 1.0,
    double animTime = 0.0,
  }) {
    final bool isWinter = season == 'WINTER' || isZud;
    final bool isSummer = season == 'SUMMER';

    final Color snowTop = isZud ? const Color(0xFFBAE6FD) : const Color(0xFFFFFFFF);
    final Color snowLeft = isZud ? const Color(0xFF7DD3FC) : const Color(0xFFE2E8F0);
    final Color snowRight = isZud ? const Color(0xFF38BDF8) : const Color(0xFFCBD5E1);

    final int type = variant % 4;
    switch (type) {
      case 0:
        // Variant 0: Çift Zirveli Sivri Masif (Twin Sharp Peaks)
        drawIsoCube(
          canvas,
          baseCenter,
          w: 38.0 * scale,
          d: 38.0 * scale,
          h: 10.0 * scale,
          topColor: isWinter ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          leftColor: const Color(0xFF475569),
          rightColor: const Color(0xFF334155),
          drawShadow: true,
        );
        final Offset leftMid = Offset(baseCenter.dx - 8.0 * scale, baseCenter.dy - 10.0 * scale);
        drawIsoCube(
          canvas,
          leftMid,
          w: 18.0 * scale,
          d: 18.0 * scale,
          h: 14.0 * scale,
          topColor: const Color(0xFF94A3B8),
          leftColor: const Color(0xFF64748B),
          rightColor: const Color(0xFF475569),
        );
        final Offset leftTop = Offset(leftMid.dx, leftMid.dy - 14.0 * scale);
        drawIsoCube(
          canvas,
          leftTop,
          w: 10.0 * scale,
          d: 10.0 * scale,
          h: isSummer ? 8.0 * scale : 14.0 * scale,
          topColor: snowTop,
          leftColor: snowLeft,
          rightColor: snowRight,
        );
        final Offset rightMid = Offset(baseCenter.dx + 10.0 * scale, baseCenter.dy - 8.0 * scale);
        drawIsoCube(
          canvas,
          rightMid,
          w: 16.0 * scale,
          d: 16.0 * scale,
          h: 11.0 * scale,
          topColor: const Color(0xFF94A3B8),
          leftColor: const Color(0xFF64748B),
          rightColor: const Color(0xFF475569),
        );
        final Offset rightTop = Offset(rightMid.dx, rightMid.dy - 11.0 * scale);
        drawIsoCube(
          canvas,
          rightTop,
          w: 8.0 * scale,
          d: 8.0 * scale,
          h: isSummer ? 6.0 * scale : 10.0 * scale,
          topColor: snowTop,
          leftColor: snowLeft,
          rightColor: snowRight,
        );
        break;

      case 1:
        // Variant 1: Katmanlı Demir Kanyonu / Kızıl Mesa (Stratified Red Mesa)
        drawIsoCube(
          canvas,
          baseCenter,
          w: 40.0 * scale,
          d: 36.0 * scale,
          h: 9.0 * scale,
          topColor: const Color(0xFF78350F),
          leftColor: const Color(0xFF5C2B09),
          rightColor: const Color(0xFF451A03),
          drawShadow: true,
        );
        final Offset step1 = Offset(baseCenter.dx, baseCenter.dy - 9.0 * scale);
        drawIsoCube(
          canvas,
          step1,
          w: 28.0 * scale,
          d: 26.0 * scale,
          h: 9.0 * scale,
          topColor: const Color(0xFFB45309),
          leftColor: const Color(0xFF92400E),
          rightColor: const Color(0xFF78350F),
        );
        final Offset step2 = Offset(baseCenter.dx, step1.dy - 9.0 * scale);
        drawIsoCube(
          canvas,
          step2,
          w: 18.0 * scale,
          d: 16.0 * scale,
          h: 8.0 * scale,
          topColor: isWinter ? snowTop : const Color(0xFFD97706),
          leftColor: isWinter ? snowLeft : const Color(0xFFB45309),
          rightColor: isWinter ? snowRight : const Color(0xFF92400E),
        );
        drawIsoCube(
          canvas,
          Offset(step2.dx + 4.0 * scale, step2.dy - 8.0 * scale),
          w: 4.0 * scale,
          d: 4.0 * scale,
          h: 3.0 * scale,
          topColor: const Color(0xFFFBBF24),
          leftColor: const Color(0xFFF59E0B),
          rightColor: const Color(0xFFD97706),
        );
        break;

      case 2:
        // Variant 2: Kraterli Volkanik Masif (Volcanic Caldera)
        drawIsoCube(
          canvas,
          baseCenter,
          w: 36.0 * scale,
          d: 36.0 * scale,
          h: 12.0 * scale,
          topColor: const Color(0xFF334155),
          leftColor: const Color(0xFF1E293B),
          rightColor: const Color(0xFF0F172A),
          drawShadow: true,
        );
        final Offset midCaldera = Offset(baseCenter.dx, baseCenter.dy - 12.0 * scale);
        drawIsoCube(
          canvas,
          midCaldera,
          w: 24.0 * scale,
          d: 24.0 * scale,
          h: 12.0 * scale,
          topColor: const Color(0xFF475569),
          leftColor: const Color(0xFF334155),
          rightColor: const Color(0xFF1E293B),
        );
        final Offset craterBase = Offset(baseCenter.dx, midCaldera.dy - 12.0 * scale);
        drawIsoCube(
          canvas,
          craterBase,
          w: 12.0 * scale,
          d: 12.0 * scale,
          h: 3.0 * scale,
          topColor: const Color(0xFFDC2626),
          leftColor: const Color(0xFFB91C1C),
          rightColor: const Color(0xFF991B1B),
        );
        drawIsoCube(
          canvas,
          Offset(craterBase.dx, craterBase.dy - 3.0 * scale),
          w: 6.0 * scale,
          d: 6.0 * scale,
          h: 2.0 * scale,
          topColor: const Color(0xFFFBBF24),
          leftColor: const Color(0xFFF59E0B),
          rightColor: const Color(0xFFD97706),
        );
        break;

      case 3:
      default:
        // Variant 3: Tekil Sarp Boynuz Zirve (Matterhorn Needle Crag)
        drawIsoCube(
          canvas,
          baseCenter,
          w: 34.0 * scale,
          d: 34.0 * scale,
          h: 10.0 * scale,
          topColor: const Color(0xFF64748B),
          leftColor: const Color(0xFF475569),
          rightColor: const Color(0xFF334155),
          drawShadow: true,
        );
        final Offset midSpire = Offset(baseCenter.dx + 2.0 * scale, baseCenter.dy - 10.0 * scale);
        drawIsoCube(
          canvas,
          midSpire,
          w: 20.0 * scale,
          d: 20.0 * scale,
          h: 16.0 * scale,
          topColor: const Color(0xFF94A3B8),
          leftColor: const Color(0xFF64748B),
          rightColor: const Color(0xFF475569),
        );
        final Offset topSpire = Offset(midSpire.dx, midSpire.dy - 16.0 * scale);
        drawIsoCube(
          canvas,
          topSpire,
          w: 10.0 * scale,
          d: 10.0 * scale,
          h: 18.0 * scale,
          topColor: snowTop,
          leftColor: snowLeft,
          rightColor: snowRight,
        );
        break;
    }
  }

  /// 3D Voxel Oduncu Kulübesi (Çoklu Görsel Varyantlar)
  static void drawVoxelLumberjack(Canvas canvas, Offset baseCenter, {int variant = 0}) {
    final int v = variant % 3;

    if (v == 1) {
      // Varyant 1: Oduncu Çadırı & Dev Ulu Tomruk
      final Offset tentPos = Offset(baseCenter.dx - 4 * cosIso, baseCenter.dy - 4 * sinIso);
      drawIsoCube(
        canvas,
        tentPos,
        w: 20.0,
        d: 20.0,
        h: 12.0,
        topColor: const Color(0xFFD97706),
        leftColor: const Color(0xFFB45309),
        rightColor: const Color(0xFF92400E),
        drawShadow: true,
      );
      // Dev Devrilmiş Tomruk
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 10 * cosIso, baseCenter.dy + 8 * sinIso),
        w: 16.0,
        d: 6.0,
        h: 6.0,
        topColor: const Color(0xFF92400E),
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF451A03),
      );
    } else if (v == 2) {
      // Varyant 2: Piramit Kütük İstifleri & Testere Sehpası
      drawIsoCube(
        canvas,
        baseCenter,
        w: 22.0,
        d: 22.0,
        h: 10.0,
        topColor: const Color(0xFF92400E),
        leftColor: const Color(0xFF78350F),
        rightColor: const Color(0xFF451A03),
        drawShadow: true,
      );
      // Piramit Tomruk Yığını
      final Offset stackPos = Offset(baseCenter.dx + 10 * cosIso, baseCenter.dy + 10 * sinIso);
      drawIsoCube(
        canvas,
        stackPos,
        w: 12.0,
        d: 8.0,
        h: 6.0,
        topColor: const Color(0xFFFDE68A),
        leftColor: const Color(0xFFD97706),
        rightColor: const Color(0xFF92400E),
      );
      drawIsoCube(
        canvas,
        Offset(stackPos.dx, stackPos.dy - 6.0),
        w: 8.0,
        d: 6.0,
        h: 5.0,
        topColor: const Color(0xFFFEF3C7),
        leftColor: const Color(0xFFFDE68A),
        rightColor: const Color(0xFFD97706),
      );
    } else {
      // Varyant 0: Klasik Kütük Kulübe & Kütük Üzerinde Balta
      drawIsoCube(
        canvas,
        baseCenter,
        w: 26.0,
        d: 26.0,
        h: 14.0,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
        drawShadow: true,
      );

      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 12 * cosIso, baseCenter.dy + 12 * sinIso),
        w: 12.0,
        d: 6.0,
        h: 6.0,
        topColor: const Color(0xFFFDE68A),
        leftColor: const Color(0xFFD97706),
        rightColor: const Color(0xFF92400E),
      );
    }
  }

  /// 3D Voxel Hızarhane (Çoklu Görsel Varyantlar)
  static void drawVoxelSawmill(Canvas canvas, Offset baseCenter, {int variant = 0}) {
    final int v = variant % 3;

    drawIsoCube(
      canvas,
      baseCenter,
      w: 28.0,
      d: 28.0,
      h: 14.0,
      topColor: const Color(0xFF92400E),
      leftColor: const Color(0xFF78350F),
      rightColor: const Color(0xFF451A03),
      drawShadow: true,
    );

    if (v == 1) {
      // Varyant 1: Çift Bıçaklı Açık Kesim Tezgahı & Kalas İstifleri
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx - 4, baseCenter.dy - 14.0),
        w: 4.0,
        d: 12.0,
        h: 9.0,
        topColor: const Color(0xFFF1F5F9),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 8, baseCenter.dy - 14.0),
        w: 4.0,
        d: 12.0,
        h: 9.0,
        topColor: const Color(0xFFF1F5F9),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );
      // Kalas İstifi
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 12 * cosIso, baseCenter.dy + 8 * sinIso),
        w: 12.0,
        d: 6.0,
        h: 6.0,
        topColor: const Color(0xFFFDE68A),
        leftColor: const Color(0xFFD97706),
        rightColor: const Color(0xFFB45309),
      );
    } else if (v == 2) {
      // Varyant 2: Hızar Kulesi Sundurması
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx - 6 * cosIso, baseCenter.dy - 14.0 - 6 * sinIso),
        w: 12.0,
        d: 12.0,
        h: 12.0,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
      );
    } else {
      // Varyant 0: Tek Bıçaklı Hızar
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 6, baseCenter.dy - 14.0),
        w: 4.0,
        d: 12.0,
        h: 8.0,
        topColor: const Color(0xFFF1F5F9),
        leftColor: const Color(0xFFCBD5E1),
        rightColor: const Color(0xFF94A3B8),
      );
    }
  }

  /// 3D Voxel Mobilya Atölyesi (Çoklu Görsel Varyantlar)
  static void drawVoxelFurniture(Canvas canvas, Offset baseCenter, {int variant = 0}) {
    final int v = variant % 3;

    drawIsoCube(
      canvas,
      baseCenter,
      w: 28.0,
      d: 28.0,
      h: 14.0,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF78350F),
      drawShadow: true,
    );

    if (v == 1) {
      // Varyant 1: Ahşap Oyma Tezgahı & Vernik Fıçısı
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 4, baseCenter.dy - 14.0),
        w: 12.0,
        d: 6.0,
        h: 6.0,
        topColor: const Color(0xFFFEF3C7),
        leftColor: const Color(0xFFFDE68A),
        rightColor: const Color(0xFFD97706),
      );
      // Vernik Fıçısı
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 12 * cosIso, baseCenter.dy + 8 * sinIso),
        w: 5.0,
        d: 5.0,
        h: 6.0,
        topColor: const Color(0xFF78350F),
        leftColor: const Color(0xFF5A2508),
        rightColor: const Color(0xFF451A03),
      );
    } else if (v == 2) {
      // Varyant 2: Otağ Sandığı & Oyma Taht
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx - 2, baseCenter.dy - 14.0),
        w: 10.0,
        d: 10.0,
        h: 12.0,
        topColor: const Color(0xFFFBBF24),
        leftColor: const Color(0xFFF59E0B),
        rightColor: const Color(0xFFD97706),
      );
    } else {
      // Varyant 0: Bitmiş Dolap & Tezgah
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx, baseCenter.dy - 14.0),
        w: 8.0,
        d: 8.0,
        h: 10.0,
        topColor: const Color(0xFFFEF3C7),
        leftColor: const Color(0xFFFDE68A),
        rightColor: const Color(0xFFD97706),
      );
    }
  }

  /// 3D Voxel Maden ve Demir Döküm Ocağı (Çoklu Görsel Varyantlar)
  static void drawVoxelMine(Canvas canvas, Offset baseCenter, {double animTime = 0.0, bool isNight = false, int variant = 0}) {
    final int v = variant % 3;

    drawIsoCube(
      canvas,
      baseCenter,
      w: 28.0,
      d: 28.0,
      h: 16.0,
      topColor: const Color(0xFF475569),
      leftColor: const Color(0xFF334155),
      rightColor: const Color(0xFF1E293B),
      drawShadow: true,
    );

    if (v == 1) {
      // Varyant 1: Ahşap Tahkimatlı Asansör Kulesi & Ray
      final Offset towerPos = Offset(baseCenter.dx - 4 * cosIso, baseCenter.dy - 16.0 - 4 * sinIso);
      drawIsoCube(
        canvas,
        towerPos,
        w: 10.0,
        d: 10.0,
        h: 16.0,
        topColor: const Color(0xFFB45309),
        leftColor: const Color(0xFF92400E),
        rightColor: const Color(0xFF78350F),
      );
    } else if (v == 2) {
      // Varyant 2: İkiz Maden Tüneli Girişi
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx - 4 * cosIso, baseCenter.dy + 4),
        w: 8.0,
        d: 5.0,
        h: 8.0,
        topColor: const Color(0xFF0F172A),
        leftColor: Colors.black,
        rightColor: Colors.black,
      );
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx + 6 * cosIso, baseCenter.dy + 4),
        w: 8.0,
        d: 5.0,
        h: 8.0,
        topColor: const Color(0xFF0F172A),
        leftColor: Colors.black,
        rightColor: Colors.black,
      );
    } else {
      // Varyant 0: Maden Giriş Tüneli
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx, baseCenter.dy + 4),
        w: 12.0,
        d: 6.0,
        h: 10.0,
        topColor: const Color(0xFF0F172A),
        leftColor: Colors.black,
        rightColor: Colors.black,
      );
    }

    // Altın / Demir Cevheri Yığını
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx + 10 * cosIso, baseCenter.dy + 8 * sinIso),
      w: 8.0,
      d: 8.0,
      h: 6.0,
      topColor: const Color(0xFFFFD700),
      leftColor: const Color(0xFFEAB308),
      rightColor: const Color(0xFFCA8A04),
    );

    // Maden Havalandırma Bacası
    final Offset ventBase = Offset(baseCenter.dx - 6 * cosIso, baseCenter.dy - 16.0 - 4 * sinIso);
    drawIsoCube(
      canvas,
      ventBase,
      w: 6.0,
      d: 6.0,
      h: 8.0,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
    );

    // Yükselen Voksel Kömür Dumanı
    if (animTime > 0) {
      final double puffY = (animTime * 16.0) % 20.0;
      final double alpha = (1.0 - (puffY / 20.0)).clamp(0.0, 1.0);
      drawIsoCube(
        canvas,
        Offset(ventBase.dx + math.sin(animTime * 2.5) * 2.0, ventBase.dy - 8.0 - puffY),
        w: 5.0 + (puffY / 20.0) * 3.0,
        d: 5.0 + (puffY / 20.0) * 3.0,
        h: 4.0,
        topColor: const Color(0xFF94A3B8).withValues(alpha: alpha * 0.7),
        leftColor: const Color(0xFF64748B).withValues(alpha: alpha * 0.6),
        rightColor: const Color(0xFF475569).withValues(alpha: alpha * 0.5),
      );
    }
  }

  /// Sis İçinde Seyrek Kadim Rünler, Sunak ve Efsanevi Biyom Fısıltıları (Clean & Sparse)
  static void drawVoxelMysteryFog(
    Canvas canvas,
    Offset center, {
    required int seed,
    required TileBiome hiddenBiome,
    required bool hasShrine,
    required bool isBorderFog,
    double animTime = 0.0,
    double alpha = 1.0,
    double disperseRise = 0.0,
  }) {
    if (alpha <= 0.01) return;

    final Offset mistCenter = Offset(center.dx, center.dy - disperseRise);

    // 1. Kadim Sunak (Shrine) Keşif Parıltısı
    if (hasShrine) {
      final double shrinePulse = 0.4 + 0.4 * math.sin(animTime * 2.6 + seed);
      _sharedFillPaint
        ..color = const Color(0xFF38BDF8).withValues(alpha: (0.28 * shrinePulse * alpha).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(mistCenter.dx, mistCenter.dy - 6), 12.0, _sharedFillPaint);

      // Yüzen Kadim Göksel Rün Kristali
      final double floatY = math.sin(animTime * 2.2 + seed) * 3.0;
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 8.0 - floatY),
        w: 5.0,
        d: 5.0,
        h: 8.0,
        topColor: const Color(0xFFE0F2FE).withValues(alpha: alpha),
        leftColor: const Color(0xFF7DD3FC).withValues(alpha: alpha),
        rightColor: const Color(0xFF0284C7).withValues(alpha: alpha),
      );
      return;
    }

    // 2. Efsanevi Biyomlar (Göksel Krater, Kurgan, Kristal)
    if (hiddenBiome == TileBiome.celestialCrater) {
      // Göksel Yıldız Tozu Parıltısı
      final double starPulse = 0.35 + 0.35 * math.sin(animTime * 3.0 + seed);
      _sharedFillPaint
        ..color = const Color(0xFFA855F7).withValues(alpha: (0.3 * starPulse * alpha).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(mistCenter.dx, mistCenter.dy - 4), 10.0, _sharedFillPaint);
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 6.0),
        w: 4.0,
        d: 4.0,
        h: 4.0,
        topColor: const Color(0xFFE9D5FF).withValues(alpha: alpha),
        leftColor: const Color(0xFFC084FC).withValues(alpha: alpha),
        rightColor: const Color(0xFF9333EA).withValues(alpha: alpha),
      );
      return;
    } else if (hiddenBiome == TileBiome.kurganValley) {
      // Atalar Kurganı Altın Ruhu
      final double kurganPulse = 0.35 + 0.35 * math.sin(animTime * 2.0 + seed);
      _sharedFillPaint
        ..color = const Color(0xFFF59E0B).withValues(alpha: (0.28 * kurganPulse * alpha).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(mistCenter.dx, mistCenter.dy - 4), 10.0, _sharedFillPaint);
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 6.0),
        w: 5.0,
        d: 5.0,
        h: 5.0,
        topColor: const Color(0xFFFEF3C7).withValues(alpha: alpha),
        leftColor: const Color(0xFFFBBF24).withValues(alpha: alpha),
        rightColor: const Color(0xFFD97706).withValues(alpha: alpha),
      );
      return;
    } else if (hiddenBiome == TileBiome.crystalChasm) {
      // Kristal Yarığı Mor Işıltısı
      final double crystalPulse = 0.35 + 0.35 * math.sin(animTime * 2.8 + seed);
      _sharedFillPaint
        ..color = const Color(0xFFEC4899).withValues(alpha: (0.28 * crystalPulse * alpha).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(mistCenter.dx, mistCenter.dy - 4), 10.0, _sharedFillPaint);
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 6.0),
        w: 4.0,
        d: 4.0,
        h: 6.0,
        topColor: const Color(0xFFFCE7F3).withValues(alpha: alpha),
        leftColor: const Color(0xFFF472B6).withValues(alpha: alpha),
        rightColor: const Color(0xFFDB2777).withValues(alpha: alpha),
      );
      return;
    }

    // 3. %5 Seyrek Rastgele Bozkır Tamgası / Rünik Keşif Fısıltısı
    final bool isRareMystery = (seed % 20 == 0);
    if (isRareMystery) {
      drawVoxelPetroglyph(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 4),
        seed: seed,
        animTime: animTime,
        isBorderFog: isBorderFog,
      );
    }
  }

  /// Antik Bozkır Petroglif & Tamga Kazıma Çizgileri (Sis Karoları İçin)
  static void drawVoxelPetroglyph(
    Canvas canvas,
    Offset center, {
    required int seed,
    double animTime = 0.0,
    bool isBorderFog = false,
  }) {
    final int variant = seed % 4;
    final double runeBrightness = isBorderFog ? 0.75 : 0.25;
    final double runePulse = runeBrightness + 0.2 * math.sin(animTime * 2.5 + (seed % 5));

    _sharedStrokePaint
      ..color = isBorderFog
          ? const Color(0xFFFBBF24).withValues(alpha: runePulse.clamp(0.0, 1.0))
          : const Color(0xFFD97706).withValues(alpha: runePulse.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isBorderFog ? 2.2 : 1.5
      ..strokeCap = StrokeCap.round;

    _cubeShadowPaint
      ..color = const Color(0xFFFBBF24).withValues(alpha: (runePulse * 0.4).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    _sharedPath.reset();

    switch (variant) {
      case 0:
        // Variant 0: Bozkır Boynuz / Geyik Tamgası
        _sharedPath.moveTo(center.dx - 8, center.dy - 4);
        _sharedPath.lineTo(center.dx, center.dy + 4);
        _sharedPath.lineTo(center.dx + 8, center.dy - 4);
        _sharedPath.moveTo(center.dx, center.dy + 4);
        _sharedPath.lineTo(center.dx, center.dy + 10);
        _sharedPath.moveTo(center.dx - 5, center.dy - 1);
        _sharedPath.lineTo(center.dx + 5, center.dy - 1);
        break;
      case 1:
        // Variant 1: Dört Yön Kağan Tamgası (Güneş Rünü)
        _sharedPath.moveTo(center.dx, center.dy - 8);
        _sharedPath.lineTo(center.dx, center.dy + 8);
        _sharedPath.moveTo(center.dx - 8, center.dy);
        _sharedPath.lineTo(center.dx + 8, center.dy);
        _sharedPath.addOval(Rect.fromCircle(center: center, radius: 4.0));
        break;
      case 2:
        // Variant 2: Bozkır Dağ Keçisi Rünü
        _sharedPath.moveTo(center.dx - 6, center.dy - 6);
        _sharedPath.quadraticBezierTo(center.dx - 2, center.dy - 10, center.dx, center.dy - 4);
        _sharedPath.lineTo(center.dx, center.dy + 6);
        _sharedPath.lineTo(center.dx - 4, center.dy + 10);
        _sharedPath.moveTo(center.dx, center.dy + 6);
        _sharedPath.lineTo(center.dx + 4, center.dy + 10);
        break;
      case 3:
      default:
        // Variant 3: Ok ve Yay / And İmzası
        _sharedPath.moveTo(center.dx - 7, center.dy + 6);
        _sharedPath.lineTo(center.dx + 7, center.dy - 6);
        _sharedPath.moveTo(center.dx + 7, center.dy - 6);
        _sharedPath.lineTo(center.dx + 2, center.dy - 6);
        _sharedPath.moveTo(center.dx + 7, center.dy - 6);
        _sharedPath.lineTo(center.dx + 7, center.dy - 1);
        _sharedPath.moveTo(center.dx - 2, center.dy + 1);
        _sharedPath.lineTo(center.dx + 2, center.dy - 3);
        break;
    }

    canvas.drawPath(_sharedPath, _cubeShadowPaint);
    canvas.drawPath(_sharedPath, _sharedStrokePaint);
  }

  /// 3D Voxel Kule (Gece Dönen Fener Işığı - Lighthouse Sweep)
  static void drawVoxelWatchtower(
    Canvas canvas,
    Offset baseCenter, {
    bool isNight = false,
    double animTime = 0.0,
  }) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 14.0,
      d: 14.0,
      h: 30.0,
      topColor: const Color(0xFFB45309),
      leftColor: const Color(0xFF92400E),
      rightColor: const Color(0xFF78350F),
      drawShadow: true,
    );

    drawIsoCube(
      canvas,
      Offset(baseCenter.dx, baseCenter.dy - 30.0),
      w: 18.0,
      d: 18.0,
      h: 8.0,
      topColor: isNight ? const Color(0xFFFDE047) : const Color(0xFFFEF08A),
      leftColor: isNight ? const Color(0xFFEAB308) : const Color(0xFFFDE047),
      rightColor: isNight ? const Color(0xFFCA8A04) : const Color(0xFFCA8A04),
    );

    // Gece 360 Derece Dönen Fener Huzmesi (Lighthouse Sweep)
    if (isNight) {
      final double angle = animTime * 2.2;
      final Offset beaconOrigin = Offset(baseCenter.dx, baseCenter.dy - 34.0);
      final Offset sweepTarget = Offset(
        beaconOrigin.dx + math.cos(angle) * 55.0,
        beaconOrigin.dy + math.sin(angle) * 28.0,
      );
      _sharedFillPaint
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.32)
        ..style = PaintingStyle.fill;

      _sharedPath
        ..reset()
        ..moveTo(beaconOrigin.dx, beaconOrigin.dy)
        ..lineTo(sweepTarget.dx - 14 * math.sin(angle), sweepTarget.dy + 14 * math.cos(angle))
        ..lineTo(sweepTarget.dx + 14 * math.sin(angle), sweepTarget.dy - 14 * math.cos(angle))
        ..close();
      canvas.drawPath(_sharedPath, _sharedFillPaint);

      _sharedFillPaint
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(beaconOrigin, 6.0, _sharedFillPaint);
    }
  }

  /// İnşaat ve Geliştirme Anında Patlayan Voksel Harç & Çakıl Parçacıkları (Construction Poof)
  static void drawVoxelConstructionPoof(Canvas canvas, Offset center, double progress) {
    if (progress <= 0.0 || progress >= 1.0) return;
    const int count = 8;
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      final double angle = (i / count) * 2 * math.pi;
      final double dist = progress * 28.0;
      final double arcY = -math.sin(progress * math.pi) * 18.0;

      final Offset pPos = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist * sinIso + arcY,
      );

      final Color pColor = i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFFE2E8F0);

      drawIsoCube(
        canvas,
        pPos,
        w: 5.0 * (1.0 - progress * 0.5),
        d: 5.0 * (1.0 - progress * 0.5),
        h: 4.0 * (1.0 - progress * 0.5),
        topColor: pColor.withValues(alpha: alpha),
        leftColor: pColor.withValues(alpha: alpha * 0.8),
        rightColor: pColor.withValues(alpha: alpha * 0.6),
      );
    }
  }

  /// 3D Voxel Ahşap Kazıklı Köprü (Yan trabzanlar ve su üstü kazıkları)
  static void drawVoxelBridge(Canvas canvas, Offset baseCenter) {
    // 1. Su üstü destek kazıkları
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx - 10 * cosIso, baseCenter.dy + 8 * sinIso + 4),
      w: 4.0,
      d: 4.0,
      h: 10.0,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A270B),
      rightColor: const Color(0xFF3F1905),
    );
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx + 10 * cosIso, baseCenter.dy + 8 * sinIso + 4),
      w: 4.0,
      d: 4.0,
      h: 10.0,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A270B),
      rightColor: const Color(0xFF3F1905),
    );

    // 2. Ana Ahşap Platform Tabliyesi
    drawIsoCube(
      canvas,
      baseCenter,
      w: 34.0,
      d: 14.0,
      h: 5.0,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF78350F),
      drawShadow: true,
      shadowOpacity: 0.35,
    );

    // 3. Yan Ahşap Korkuluklar / Trabzanlar
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx - 4 * sinIso, baseCenter.dy - 5 - 4 * cosIso),
      w: 34.0,
      d: 2.0,
      h: 4.0,
      topColor: const Color(0xFFFDE68A),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx + 4 * sinIso, baseCenter.dy - 5 + 4 * cosIso),
      w: 34.0,
      d: 2.0,
      h: 4.0,
      topColor: const Color(0xFFFDE68A),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );
  }

  /// 3D Voxel Balıkçı Teknesi (Su üstü salınımı, pruva feneri, ağ ve fıçı)
  static void drawVoxelFishermanBoat(
    Canvas canvas,
    Offset baseCenter, {
    required double animTime,
    bool isNight = false,
  }) {
    final double bobWater = math.sin(animTime * 2.2) * 1.5;
    final Offset pos = Offset(baseCenter.dx, baseCenter.dy + bobWater);

    // İskele Destek Kazığı
    drawIsoCube(
      canvas,
      Offset(pos.dx + 8 * cosIso, pos.dy + 8 * sinIso + 4),
      w: 4.0,
      d: 4.0,
      h: 8.0,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A270B),
      rightColor: const Color(0xFF3F1905),
    );

    // Tekne Gövdesi (Meşe Ahşap)
    drawIsoCube(
      canvas,
      pos,
      w: 22.0,
      d: 12.0,
      h: 5.0,
      topColor: const Color(0xFF92400E),
      leftColor: const Color(0xFF78350F),
      rightColor: const Color(0xFF5A270B),
      drawShadow: true,
      shadowOpacity: 0.25,
    );

    // Pruva / Ön Sivri Burun
    drawIsoCube(
      canvas,
      Offset(pos.dx - 8 * cosIso, pos.dy - 3),
      w: 8.0,
      d: 8.0,
      h: 4.0,
      topColor: const Color(0xFFB45309),
      leftColor: const Color(0xFF92400E),
      rightColor: const Color(0xFF78350F),
    );

    // Balıkçı Direği
    drawIsoCube(
      canvas,
      Offset(pos.dx + 2, pos.dy - 5),
      w: 2.5,
      d: 2.5,
      h: 14.0,
      topColor: const Color(0xFFFDE68A),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );

    // Direk Ucu Fener (Gece parıldayan sarı ışık)
    drawIsoCube(
      canvas,
      Offset(pos.dx + 2, pos.dy - 19),
      w: 4.0,
      d: 4.0,
      h: 4.0,
      topColor: isNight ? const Color(0xFFFEF08A) : const Color(0xFFFDE047),
      leftColor: isNight ? const Color(0xFFFACC15) : const Color(0xFFEAB308),
      rightColor: isNight ? const Color(0xFFEAB308) : const Color(0xFFCA8A04),
    );

    // Balık Ağı / Varil
    drawIsoCube(
      canvas,
      Offset(pos.dx + 6 * cosIso, pos.dy - 4 + 3 * sinIso),
      w: 5.0,
      d: 5.0,
      h: 4.0,
      topColor: const Color(0xFF0284C7),
      leftColor: const Color(0xFF0369A1),
      rightColor: const Color(0xFF075985),
    );
  }

  /// 3D Voxel Balıkçı Kulübesi & İskele (Sazdan çatı, iskele platformu ve fıçı)
  static void drawVoxelFishermanHut(
    Canvas canvas,
    Offset baseCenter, {
    required double animTime,
    bool isNight = false,
  }) {
    // 1. İskele Platformu
    drawIsoCube(
      canvas,
      baseCenter,
      w: 24.0,
      d: 20.0,
      h: 4.0,
      topColor: const Color(0xFFB45309),
      leftColor: const Color(0xFF92400E),
      rightColor: const Color(0xFF78350F),
      drawShadow: true,
      shadowOpacity: 0.3,
    );

    // İskele Destek Kazıkları
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx - 8 * cosIso, baseCenter.dy + 8 * sinIso + 4),
      w: 3.5,
      d: 3.5,
      h: 8.0,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A270B),
      rightColor: const Color(0xFF3F1905),
    );
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx + 8 * cosIso, baseCenter.dy + 8 * sinIso + 4),
      w: 3.5,
      d: 3.5,
      h: 8.0,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A270B),
      rightColor: const Color(0xFF3F1905),
    );

    // 2. Ahşap Kulübe Gövdesi
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx - 2, baseCenter.dy - 4),
      w: 14.0,
      d: 14.0,
      h: 12.0,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF92400E),
    );

    // 3. Saz / Saman Çatı
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx - 2, baseCenter.dy - 16),
      w: 16.0,
      d: 16.0,
      h: 6.0,
      topColor: const Color(0xFFFEF08A),
      leftColor: const Color(0xFFFDE047),
      rightColor: const Color(0xFFEAB308),
    );

    // 4. Balık Varili
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx + 7 * cosIso, baseCenter.dy - 4 + 6 * sinIso),
      w: 4.5,
      d: 4.5,
      h: 6.0,
      topColor: const Color(0xFF0284C7),
      leftColor: const Color(0xFF0369A1),
      rightColor: const Color(0xFF075985),
    );

    // Gece Feneri
    if (isNight) {
      drawIsoCube(
        canvas,
        Offset(baseCenter.dx - 6, baseCenter.dy - 12),
        w: 3.0,
        d: 3.0,
        h: 3.0,
        topColor: const Color(0xFFFFE066),
        leftColor: const Color(0xFFFACC15),
        rightColor: const Color(0xFFEAB308),
      );
    }
  }

  /// 3D Voxel Kadim Göktürk Rünik Dikilitaş / Sunak
  /// Türüne göre parıldayan rünik çekirdek ve havada asılı mistik faset bloklar
  static void drawVoxelAncientShrine(
    Canvas canvas,
    Offset baseCenter, {
    required ShrineType shrineType,
    required double animTime,
    bool isNight = false,
  }) {
    // 1. Granit Taş Kaide
    drawIsoCube(
      canvas,
      baseCenter,
      w: 22.0,
      d: 22.0,
      h: 5.0,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
      drawShadow: true,
      shadowOpacity: 0.4,
    );

    // 2. Monolitik Dikilitaş Gövdesi (Orhun Taşları Formu)
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx, baseCenter.dy - 5),
      w: 12.0,
      d: 12.0,
      h: 24.0,
      topColor: const Color(0xFF1E293B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF020617),
    );

    // 3. Rünik Çekirdek Rengi Belirleme
    Color runeTop;
    Color runeLeft;
    Color runeRight;
    switch (shrineType) {
      case ShrineType.foodBoost:
        runeTop = const Color(0xFF34D399);
        runeLeft = const Color(0xFF10B981);
        runeRight = const Color(0xFF059669);
        break;
      case ShrineType.woodBoost:
        runeTop = const Color(0xFFFBBF24);
        runeLeft = const Color(0xFFF59E0B);
        runeRight = const Color(0xFFD97706);
        break;
      case ShrineType.speedBoost:
      case ShrineType.none:
        runeTop = const Color(0xFF38BDF8);
        runeLeft = const Color(0xFF0EA5E9);
        runeRight = const Color(0xFF0284C7);
        break;
    }

    // Gövde Üzerindeki Parlayan Rün Yuvası
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx, baseCenter.dy - 17),
      w: 6.0,
      d: 6.0,
      h: 6.0,
      topColor: runeTop,
      leftColor: runeLeft,
      rightColor: runeRight,
    );

    // 4. Havada Asılı Mistik Süzülen Rünik Parçacıklar (Levitating Voxel Runes)
    final double float1 = math.sin(animTime * 2.5) * 3.5;
    final double float2 = math.cos(animTime * 2.0 + 1.0) * 3.0;

    drawIsoCube(
      canvas,
      Offset(baseCenter.dx - 10 * cosIso, baseCenter.dy - 28 + float1),
      w: 4.0,
      d: 4.0,
      h: 4.0,
      topColor: runeTop,
      leftColor: runeLeft,
      rightColor: runeRight,
    );

    drawIsoCube(
      canvas,
      Offset(baseCenter.dx + 10 * cosIso, baseCenter.dy - 30 + float2),
      w: 4.0,
      d: 4.0,
      h: 4.0,
      topColor: runeTop,
      leftColor: runeLeft,
      rightColor: runeRight,
    );
  }

  /// 3D Voxel Bulut
  static void drawVoxelCloud(Canvas canvas, Offset pos, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      pos,
      w: 24.0 * scale,
      d: 18.0 * scale,
      h: 10.0 * scale,
      topColor: Colors.white,
      leftColor: const Color(0xFFF1F5F9),
      rightColor: const Color(0xFFE2E8F0),
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx + 12 * cosIso * scale, pos.dy + 6 * sinIso * scale),
      w: 16.0 * scale,
      d: 14.0 * scale,
      h: 8.0 * scale,
      topColor: Colors.white,
      leftColor: const Color(0xFFF8FAFC),
      rightColor: const Color(0xFFE2E8F0),
    );
  }

  /// 3D Voxel İnsan / İşçi (Yön Tayini, Kıyafet & Başlık Varyantları, Çalışma/Taşıma/Dinlenme Animasyonları)
  static void drawVoxelWorker(
    Canvas canvas,
    Offset pos, {
    required Color cargoColor,
    required double walkAnim,
    bool hasCargo = true,
    bool facingLeft = false,
    int seed = 0,
    int actionState = 0, // 0: walking, 1: working/loading, 2: unloading/resting
  }) {
    final double flipX = facingLeft ? -1.0 : 1.0;
    final int archetype = seed % 4;

    // Giysi ve Başlık Renk Paletleri
    Color clothesTop;
    Color clothesLeft;
    Color clothesRight;
    Color hatTop;
    Color hatLeft;
    Color hatRight;

    switch (archetype) {
      case 0: // Bozkır Göçeri (Turkuaz Kaftan + Sivri Keçe Börk)
        clothesTop = const Color(0xFF0284C7);
        clothesLeft = const Color(0xFF0369A1);
        clothesRight = const Color(0xFF075985);
        hatTop = const Color(0xFF92400E);
        hatLeft = const Color(0xFF78350F);
        hatRight = const Color(0xFF451A03);
        break;
      case 1: // Usta / Demirci (Koyu Deri Önlük + Kırmızı Bandana)
        clothesTop = const Color(0xFF475569);
        clothesLeft = const Color(0xFF334155);
        clothesRight = const Color(0xFF1E293B);
        hatTop = const Color(0xFFDC2626);
        hatLeft = const Color(0xFFB91C1C);
        hatRight = const Color(0xFF991B1B);
        break;
      case 2: // Hasatçı / Çiftçi (Doğal Keten Gömlek + Hasır Şapka)
        clothesTop = const Color(0xFFF1F5F9);
        clothesLeft = const Color(0xFFE2E8F0);
        clothesRight = const Color(0xFFCBD5E1);
        hatTop = const Color(0xFFFBBF24);
        hatLeft = const Color(0xFFD97706);
        hatRight = const Color(0xFFB45309);
        break;
      case 3: // Ormancı / Avcı (Orman Yeşili Giysi + Kahve Başlık)
      default:
        clothesTop = const Color(0xFF15803D);
        clothesLeft = const Color(0xFF166534);
        clothesRight = const Color(0xFF14532D);
        hatTop = const Color(0xFF78350F);
        hatLeft = const Color(0xFF5A270B);
        hatRight = const Color(0xFF3F1905);
        break;
    }

    double bobY = 0.0;
    double bodyTilt = 0.0;
    double armSwing = 0.0;
    double toolMotion = 0.0;

    if (actionState == 0) {
      // YÜRÜME: İki zamanlı gerçek adım yaylanması
      bobY = math.sin(walkAnim * 2.0).abs() * 2.8;
      armSwing = math.sin(walkAnim) * 3.0;
      bodyTilt = math.sin(walkAnim) * 0.6 * flipX;
    } else if (actionState == 1) {
      // ÇALIŞMA / YÜKLEME: Eğilme ve alet sallama ritmi
      toolMotion = math.sin(walkAnim * 2.5).abs() * 5.0;
      bobY = math.sin(walkAnim * 2.5).abs() * 1.5;
      bodyTilt = 1.5 * flipX;
    } else {
      // BOŞALTMA / ALIN TERİNİ SİLME / ESNEME:
      final double breath = math.sin(walkAnim * 1.5) * 0.8;
      bobY = breath;
      armSwing = math.sin(walkAnim * 1.2) * 2.0;
    }

    // 1. Ayaklar / Adımlar (Feet Stride Voxels)
    if (actionState == 0) {
      final double leftStep = math.sin(walkAnim) * 2.5;
      final double rightStep = -leftStep;

      // Sol Ayak
      drawIsoCube(
        canvas,
        Offset(pos.dx + (leftStep - 1.5) * flipX, pos.dy + 1.0 - (leftStep > 0 ? leftStep * 0.5 : 0)),
        w: 2.5,
        d: 2.5,
        h: 3.0,
        topColor: const Color(0xFF1E293B),
        leftColor: const Color(0xFF0F172A),
        rightColor: const Color(0xFF020617),
      );
      // Sağ Ayak
      drawIsoCube(
        canvas,
        Offset(pos.dx + (rightStep + 1.5) * flipX, pos.dy + 1.0 - (rightStep > 0 ? rightStep * 0.5 : 0)),
        w: 2.5,
        d: 2.5,
        h: 3.0,
        topColor: const Color(0xFF1E293B),
        leftColor: const Color(0xFF0F172A),
        rightColor: const Color(0xFF020617),
      );
    }

    // 2. Gövde (Body / Kaftan)
    drawIsoCube(
      canvas,
      Offset(pos.dx + bodyTilt, pos.dy - bobY),
      w: 6.0,
      d: 6.0,
      h: 8.0,
      topColor: clothesTop,
      leftColor: clothesLeft,
      rightColor: clothesRight,
      drawShadow: true,
      shadowOpacity: 0.35,
    );

    // Kollar (Arms)
    if (hasCargo) {
      // Yük taşırken kollar kargo kutusunu tutar
      drawIsoCube(
        canvas,
        Offset(pos.dx + (3.5 * flipX) + bodyTilt, pos.dy - 3.0 - bobY),
        w: 2.0,
        d: 2.0,
        h: 4.0,
        topColor: clothesTop,
        leftColor: clothesLeft,
        rightColor: clothesRight,
      );
    } else if (actionState == 1) {
      // Çalışırken alet tutan el yukarı aşağı hareket eder
      drawIsoCube(
        canvas,
        Offset(pos.dx + (4.0 * flipX) + bodyTilt, pos.dy - 6.0 - bobY - toolMotion),
        w: 2.0,
        d: 2.0,
        h: 4.0,
        topColor: const Color(0xFFFED7AA),
        leftColor: const Color(0xFFFDBA74),
        rightColor: const Color(0xFFFB923C),
      );
      // Minik Kazma / Balta Aleti (Voxel Tool)
      drawIsoCube(
        canvas,
        Offset(pos.dx + (6.0 * flipX) + bodyTilt, pos.dy - 9.0 - bobY - toolMotion),
        w: 2.0,
        d: 4.5,
        h: 2.0,
        topColor: const Color(0xFF94A3B8),
        leftColor: const Color(0xFF64748B),
        rightColor: const Color(0xFF475569),
      );
    } else {
      // Boş yürürken kollar ters salınır
      drawIsoCube(
        canvas,
        Offset(pos.dx - (3.5 * flipX) - armSwing, pos.dy - 2.0 - bobY),
        w: 2.0,
        d: 2.0,
        h: 4.0,
        topColor: clothesTop,
        leftColor: clothesLeft,
        rightColor: clothesRight,
      );
    }

    // 3. Kafa (Head)
    final Offset headPos = Offset(pos.dx + (bodyTilt * 1.5), pos.dy - 8.0 - bobY);
    drawIsoCube(
      canvas,
      headPos,
      w: 5.5,
      d: 5.5,
      h: 5.5,
      topColor: const Color(0xFFFED7AA),
      leftColor: const Color(0xFFFDBA74),
      rightColor: const Color(0xFFFB923C),
    );

    // 4. Başlık / Şapka / Börk (Hat / Cap)
    drawIsoCube(
      canvas,
      Offset(headPos.dx, headPos.dy - 4.5),
      w: 6.0,
      d: 6.0,
      h: 3.5,
      topColor: hatTop,
      leftColor: hatLeft,
      rightColor: hatRight,
    );
    // Börk Sivri Tepesi
    if (archetype == 0 || archetype == 3) {
      drawIsoCube(
        canvas,
        Offset(headPos.dx, headPos.dy - 7.0),
        w: 3.0,
        d: 3.0,
        h: 2.5,
        topColor: hatTop,
        leftColor: hatLeft,
        rightColor: hatRight,
      );
    }

    // 5. Kargo / Sırt Yükü (Cargo Cube)
    if (hasCargo) {
      drawIsoCube(
        canvas,
        Offset(pos.dx + (4.5 * flipX) * cosIso, pos.dy - 4.0 - bobY + 4.0 * sinIso),
        w: 5.5,
        d: 5.5,
        h: 5.5,
        topColor: cargoColor,
        leftColor: cargoColor.withValues(alpha: 0.85),
        rightColor: cargoColor.withValues(alpha: 0.65),
      );
    }
  }

  // ==========================================
  // YENİ BİYOM VOKSEL ÇİZİCİLERİ & DETAYLARI
  // ==========================================

  /// Çöl (Karakum): Katmanlı Kum Tepesi
  static void drawVoxelSandDunes(Canvas canvas, Offset center, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 26.0 * scale,
      d: 18.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFFFDE68A),
      leftColor: const Color(0xFFF59E0B),
      rightColor: const Color(0xFFD97706),
      drawShadow: true,
      shadowOpacity: 0.25,
    );
    drawIsoCube(
      canvas,
      Offset(center.dx + 4 * scale, center.dy - 5.0 * scale),
      w: 16.0 * scale,
      d: 12.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFFFEF08A),
      leftColor: const Color(0xFFFBBF24),
      rightColor: const Color(0xFFF59E0B),
    );
  }

  /// Çöl: Voksel Bozkır Kaktüsü / Kurak Diken
  static void drawVoxelCactus(Canvas canvas, Offset center, {double scale = 1.0}) {
    // Gövde
    drawIsoCube(
      canvas,
      center,
      w: 6.0 * scale,
      d: 6.0 * scale,
      h: 16.0 * scale,
      topColor: const Color(0xFF15803D),
      leftColor: const Color(0xFF166534),
      rightColor: const Color(0xFF14532D),
      drawShadow: true,
      shadowOpacity: 0.3,
    );
    // Sol Dal
    drawIsoCube(
      canvas,
      Offset(center.dx - 5.0 * scale, center.dy - 6.0 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFF16A34A),
      leftColor: const Color(0xFF15803D),
      rightColor: const Color(0xFF166534),
    );
    // Sağ Dal
    drawIsoCube(
      canvas,
      Offset(center.dx + 5.0 * scale, center.dy - 9.0 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 7.0 * scale,
      topColor: const Color(0xFF16A34A),
      leftColor: const Color(0xFF15803D),
      rightColor: const Color(0xFF166534),
    );
  }

  /// Çöl: Kurak Bozkır Çalısı
  static void drawVoxelDesertShrub(Canvas canvas, Offset center, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 6.0 * scale,
      topColor: const Color(0xFFCA8A04),
      leftColor: const Color(0xFFA16207),
      rightColor: const Color(0xFF854D0E),
    );
  }

  /// Tundra: Donmuş Kaya Sütunu / Dikilitaş (Permafrost Spire)
  static void drawVoxelPermafrostSpire(Canvas canvas, Offset center, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 14.0 * scale,
      d: 14.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFF64748B),
      leftColor: const Color(0xFF475569),
      rightColor: const Color(0xFF334155),
      drawShadow: true,
    );
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 8.0 * scale),
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 12.0 * scale,
      topColor: const Color(0xFF93C5FD),
      leftColor: const Color(0xFF60A5FA),
      rightColor: const Color(0xFF3B82F6),
    );
  }

  /// Tundra: Yosunlu Arktik Taşlar
  static void drawVoxelLichenRocks(Canvas canvas, Offset center, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 10.0 * scale,
      d: 10.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF65A30D),
      leftColor: const Color(0xFF475569),
      rightColor: const Color(0xFF334155),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx + 8 * scale, center.dy + 3 * scale),
      w: 7.0 * scale,
      d: 7.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF84CC16),
      leftColor: const Color(0xFF64748B),
      rightColor: const Color(0xFF475569),
    );
  }

  /// Volkan: Obsidiyen Masif Sütunları
  static void drawVoxelObsidianPillars(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 12.0 * scale,
      topColor: const Color(0xFF1E293B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF020617),
      drawShadow: true,
    );
    // Siyah Sivri Prizma
    drawIsoCube(
      canvas,
      Offset(center.dx + 4 * scale, center.dy - 12.0 * scale),
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 14.0 * scale,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
    );
  }

  /// Volkan: Lav Çatlağı / Magma Menfezi
  static void drawVoxelMagmaVent(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    final double pulse = (math.sin(animTime * 3.0) + 1.0) * 0.5;
    final Color magmaColor = Color.lerp(const Color(0xFFEA580C), const Color(0xFFFBBF24), pulse)!;

    drawIsoCube(
      canvas,
      center,
      w: 12.0 * scale,
      d: 12.0 * scale,
      h: 3.0 * scale,
      topColor: magmaColor,
      leftColor: const Color(0xFFDC2626),
      rightColor: const Color(0xFF991B1B),
    );
  }

  /// Sazlık: Bozkır Kamışları & Sazlar
  static void drawVoxelReeds(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    final double windSway = math.sin(animTime * 2.5) * 1.5 * scale;

    drawIsoCube(
      canvas,
      Offset(center.dx - 4 * scale + windSway, center.dy),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 14.0 * scale,
      topColor: const Color(0xFF65A30D),
      leftColor: const Color(0xFF4D7C0F),
      rightColor: const Color(0xFF3F6212),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx + 3 * scale + windSway * 0.8, center.dy + 2 * scale),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 16.0 * scale,
      topColor: const Color(0xFF84CC16),
      leftColor: const Color(0xFF65A30D),
      rightColor: const Color(0xFF4D7C0F),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx - 1 * scale, center.dy + 4 * scale),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 11.0 * scale,
      topColor: const Color(0xFF4D7C0F),
      leftColor: const Color(0xFF3F6212),
      rightColor: const Color(0xFF365314),
    );
  }

  /// Sazlık: Nilüfer Yaprağı ve Çiçeği
  static void drawVoxelWaterLilies(Canvas canvas, Offset center, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 1.5 * scale,
      topColor: const Color(0xFF10B981),
      leftColor: const Color(0xFF059669),
      rightColor: const Color(0xFF047857),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 1.5 * scale),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 2.5 * scale,
      topColor: const Color(0xFFF472B6),
      leftColor: const Color(0xFFEC4899),
      rightColor: const Color(0xFFDB2777),
    );
  }

  /// Mevsimsel: Bahar Gelincikleri / Kır Laleleri
  static void drawVoxelSpringPoppies(Canvas canvas, Offset center, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFFEF4444),
      leftColor: const Color(0xFFDC2626),
      rightColor: const Color(0xFFB91C1C),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx + 6 * scale, center.dy + 4 * scale),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 3.0 * scale,
      topColor: const Color(0xFFF59E0B),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );
  }

  /// Mevsimsel: Sonbahar Kızıl Yaprak Kümesi
  static void drawVoxelAutumnFoliage(Canvas canvas, Offset center, {double scale = 1.0}) {
    drawIsoCube(
      canvas,
      center,
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 3.0 * scale,
      topColor: const Color(0xFFEA580C),
      leftColor: const Color(0xFFC2410C),
      rightColor: const Color(0xFF9A3412),
    );
  }

  /// Mevsimsel: Kış Kıyı Buz Kütleleri (Ice Floes)
  static void drawVoxelIceFloes(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    final double bob = math.sin(animTime * 1.5) * 1.0;
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + bob),
      w: 12.0 * scale,
      d: 8.0 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFFE0F2FE),
      leftColor: const Color(0xFFBAE6FD),
      rightColor: const Color(0xFF7DD3FC),
    );
  }

  // ==========================================
  // ÖZEL ÇÖL BİNALARI (DESERT EXCLUSIVES)
  // ==========================================

  /// Vaha Sarnıcı (Oasis Cistern)
  static void drawVoxelOasisCistern(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Taş taban havuzu
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 4 * scale),
      w: 18.0 * scale,
      d: 18.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF92400E),
    );
    // Berrak turkuaz su
    final double ripple = math.sin(animTime * 2.0) * 0.5;
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + (2 + ripple) * scale),
      w: 12.0 * scale,
      d: 12.0 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFF38BDF8),
      leftColor: const Color(0xFF0284C7),
      rightColor: const Color(0xFF0369A1),
    );
    // Hurma ağacı gölgesi
    drawIsoCube(
      canvas,
      Offset(center.dx - 8 * scale, center.dy - 6 * scale),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 12.0 * scale,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A2408),
      rightColor: const Color(0xFF451A03),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx - 8 * scale, center.dy - 18 * scale),
      w: 10.0 * scale,
      d: 10.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF65A30D),
      leftColor: const Color(0xFF4D7C0F),
      rightColor: const Color(0xFF3F6212),
    );
  }

  /// İpek Yolu Kervansarayı (Silk Road Caravanserai)
  static void drawVoxelCaravanserai(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Kumtaşı kale avlusu
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 2 * scale),
      w: 22.0 * scale,
      d: 22.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFFDE68A),
      leftColor: const Color(0xFFF59E0B),
      rightColor: const Color(0xFFD97706),
    );
    // İç avlu kumaş gölgeliği (Kırmızı-Sarı Tente)
    final double sway = math.sin(animTime * 1.8) * 0.6;
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - (6 + sway) * scale),
      w: 12.0 * scale,
      d: 12.0 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFFDC2626),
      leftColor: const Color(0xFFB91C1C),
      rightColor: const Color(0xFF991B1B),
    );
    // Ahşap kervan kapısı kulesi
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 10 * scale),
      w: 6.0 * scale,
      d: 6.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFFBBF24),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );
  }

  /// Gök Gözlemevi (Desert Astrolabe)
  static void drawVoxelAstrolabe(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Silindirik pirinç taban
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 4 * scale),
      w: 14.0 * scale,
      d: 14.0 * scale,
      h: 10.0 * scale,
      topColor: const Color(0xFFE2E8F0),
      leftColor: const Color(0xFFCBD5E1),
      rightColor: const Color(0xFF94A3B8),
    );
    // Dönen göksel pirinç halkalar
    final double spin = math.sin(animTime * 2.2) * 2.0;
    drawIsoCube(
      canvas,
      Offset(center.dx + spin * scale, center.dy - 8 * scale),
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFFBBF24),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );
    // Mistik parıltı küresi
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 16 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF67E8F9),
      leftColor: const Color(0xFF06B6D4),
      rightColor: const Color(0xFF0891B2),
    );
  }

  // ==========================================
  // ÖZEL TUNDRA BİNALARI (TUNDRA EXCLUSIVES)
  // ==========================================

  /// Geyik Otağı & Kürk Loncası (Reindeer Sanctuary)
  static void drawVoxelReindeerSanctuary(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Ahşap çit ve barınak
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 2 * scale),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 6.0 * scale,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A2408),
      rightColor: const Color(0xFF451A03),
    );
    // Kürk kaplı sivri çadır (Chum / Yurt)
    drawIsoCube(
      canvas,
      Offset(center.dx - 4 * scale, center.dy - 8 * scale),
      w: 10.0 * scale,
      d: 10.0 * scale,
      h: 12.0 * scale,
      topColor: const Color(0xFFD6D3D1),
      leftColor: const Color(0xFFA8A29E),
      rightColor: const Color(0xFF78716C),
    );
    // Otlayan boynuzlu geyik
    final double headBob = math.sin(animTime * 2.0) * 0.8;
    drawIsoCube(
      canvas,
      Offset(center.dx + 6 * scale, center.dy + headBob * scale),
      w: 5.0 * scale,
      d: 7.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF9A3412),
      leftColor: const Color(0xFF7C2D12),
      rightColor: const Color(0xFF5B21B6),
    );
  }

  /// Jeotermal Kaplıca (Geothermal Bath)
  static void drawVoxelGeothermalBath(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Ahşap setli sıcak su havuzu
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 3 * scale),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF78716C),
      leftColor: const Color(0xFF57534E),
      rightColor: const Color(0xFF44403C),
    );
    // Sıcak turkuaz-yeşil mineral suyu
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 1 * scale),
      w: 12.0 * scale,
      d: 12.0 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFF2DD4BF),
      leftColor: const Color(0xFF0D9488),
      rightColor: const Color(0xFF0F766E),
    );
    // Yükselen buhar küpü
    final double steamY = (animTime * 10.0) % 16.0;
    _sharedFillPaint.color = const Color(0xFFE0F2FE).withValues(alpha: (1.0 - steamY / 16.0).clamp(0.0, 0.7));
    canvas.drawCircle(Offset(center.dx, center.dy - 6 * scale - steamY), 3.0 * scale, _sharedFillPaint);
  }

  /// Mamut & Kehribar Sondajı (Permafrost Dig)
  static void drawVoxelPermafrostDig(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Ahşap vinç kulesi
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy),
      w: 14.0 * scale,
      d: 14.0 * scale,
      h: 6.0 * scale,
      topColor: const Color(0xFF475569),
      leftColor: const Color(0xFF334155),
      rightColor: const Color(0xFF1E293B),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx - 3 * scale, center.dy - 10 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 14.0 * scale,
      topColor: const Color(0xFFB45309),
      leftColor: const Color(0xFF92400E),
      rightColor: const Color(0xFF78350F),
    );
    // Kehribar ve mamut dişi sandığı
    drawIsoCube(
      canvas,
      Offset(center.dx + 5 * scale, center.dy - 4 * scale),
      w: 6.0 * scale,
      d: 6.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFFFBBF24),
      leftColor: const Color(0xFFF59E0B),
      rightColor: const Color(0xFFD97706),
    );
  }

  // ==========================================
  // ÖZEL VOLKAN BİNALARI (VOLCANO EXCLUSIVES)
  // ==========================================

  /// Jeotermal Buhar Bacası (Steam Vent Dynamo)
  static void drawVoxelSteamVent(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Obsidyen taban
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 3 * scale),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF1E293B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF020617),
    );
    // Pirinç buhar borusu
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 8 * scale),
      w: 6.0 * scale,
      d: 6.0 * scale,
      h: 12.0 * scale,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF92400E),
    );
    // Basınç vanası
    final double vRotate = math.sin(animTime * 3.0) * 1.5;
    drawIsoCube(
      canvas,
      Offset(center.dx + vRotate * scale, center.dy - 16 * scale),
      w: 8.0 * scale,
      d: 4.0 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFFEF4444),
      leftColor: const Color(0xFFDC2626),
      rightColor: const Color(0xFFB91C1C),
    );
  }

  /// Kadim Obsidyen Dökümhanesi (Obsidian Master Forge)
  static void drawVoxelObsidianForge(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Lav oluklu döküm tabanı
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 2 * scale),
      w: 20.0 * scale,
      d: 20.0 * scale,
      h: 7.0 * scale,
      topColor: const Color(0xFF0F172A),
      leftColor: const Color(0xFF020617),
      rightColor: const Color(0xFF000000),
    );
    // Kor lav kanalı
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 1 * scale),
      w: 12.0 * scale,
      d: 4.0 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFFEF4444),
      leftColor: const Color(0xFFDC2626),
      rightColor: const Color(0xFFB91C1C),
    );
    // Büyük obsidyen örs
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 8 * scale),
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 9.0 * scale,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
    );
    // Ateş kıvılcımı puf
    final double flamePulse = 0.5 + 0.5 * math.sin(animTime * 4.0);
    _sharedFillPaint.color = const Color(0xFFF59E0B).withValues(alpha: flamePulse);
    canvas.drawCircle(Offset(center.dx, center.dy - 18 * scale), 3.0 * scale, _sharedFillPaint);
  }

  // ==========================================
  // ÖZEL SAZLIK BİNALARI (WETLAND EXCLUSIVES)
  // ==========================================

  /// Bozkır Şifacı Otağı (Herbalist Yurt)
  static void drawVoxelHerbalistYurt(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Sazlık kazıkları üstünde ahşap platform
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 4 * scale),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF5A2408),
      rightColor: const Color(0xFF451A03),
    );
    // Yeşil otlarla kaplı şifa çadırı
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 6 * scale),
      w: 12.0 * scale,
      d: 12.0 * scale,
      h: 10.0 * scale,
      topColor: const Color(0xFF84CC16),
      leftColor: const Color(0xFF65A30D),
      rightColor: const Color(0xFF4D7C0F),
    );
    // Kaynayan şifa kazanı
    drawIsoCube(
      canvas,
      Offset(center.dx + 6 * scale, center.dy),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF10B981),
      leftColor: const Color(0xFF059669),
      rightColor: const Color(0xFF047857),
    );
  }

  /// Kamış & Yazıt Atölyesi (Reed Scribe Workshop)
  static void drawVoxelScribeWorkshop(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Ahşap tezgah ve kurutma iskeleti
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 2 * scale),
      w: 18.0 * scale,
      d: 14.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFFB45309),
      leftColor: const Color(0xFF92400E),
      rightColor: const Color(0xFF78350F),
    );
    // Parşömen kurutma askıları
    final double paperSway = math.sin(animTime * 1.6) * 0.5;
    drawIsoCube(
      canvas,
      Offset(center.dx - 4 * scale, center.dy - (6 + paperSway) * scale),
      w: 3.0 * scale,
      d: 10.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFFEF3C7),
      leftColor: const Color(0xFFFDE68A),
      rightColor: const Color(0xFFFCD34D),
    );
    // Rün ve mühür masası
    drawIsoCube(
      canvas,
      Offset(center.dx + 4 * scale, center.dy - 4 * scale),
      w: 6.0 * scale,
      d: 6.0 * scale,
      h: 6.0 * scale,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF92400E),
    );
  }

  // ==========================================
  // EFSANEVİ BİYOMLAR & ANITSAL BİNALAR
  // ==========================================

  /// Gök Demircisi (Celestial Anvil)
  static void drawVoxelCelestialAnvil(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Göksel krater monolit tabanı
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 3 * scale),
      w: 20.0 * scale,
      d: 20.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFF1E1B4B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF020617),
    );
    // Mavi parıltılı Mithril gök örsü
    final double pulse = 0.7 + 0.3 * math.sin(animTime * 3.0);
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 8 * scale),
      w: 10.0 * scale,
      d: 10.0 * scale,
      h: 10.0 * scale,
      topColor: Color.lerp(const Color(0xFF38BDF8), const Color(0xFF818CF8), pulse)!,
      leftColor: const Color(0xFF0284C7),
      rightColor: const Color(0xFF1E40AF),
    );
    // Yıldız tozu ışıltısı
    _sharedFillPaint.color = const Color(0xFFBAE6FD).withValues(alpha: pulse);
    canvas.drawCircle(Offset(center.dx, center.dy - 20 * scale), 4.0 * scale, _sharedFillPaint);
  }

  /// Kurgan Koruyucusu (Ancestral Totem)
  static void drawVoxelAncestralTotem(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Höyük taş kaidesi
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 4 * scale),
      w: 22.0 * scale,
      d: 22.0 * scale,
      h: 7.0 * scale,
      topColor: const Color(0xFF475569),
      leftColor: const Color(0xFF334155),
      rightColor: const Color(0xFF1E293B),
    );
    // Üçlü Taş Balbal Heykelleri
    drawIsoCube(
      canvas,
      Offset(center.dx - 6 * scale, center.dy - 6 * scale),
      w: 5.0 * scale,
      d: 5.0 * scale,
      h: 14.0 * scale,
      topColor: const Color(0xFF94A3B8),
      leftColor: const Color(0xFF64748B),
      rightColor: const Color(0xFF475569),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx + 6 * scale, center.dy - 6 * scale),
      w: 5.0 * scale,
      d: 5.0 * scale,
      h: 14.0 * scale,
      topColor: const Color(0xFF94A3B8),
      leftColor: const Color(0xFF64748B),
      rightColor: const Color(0xFF475569),
    );
    // Ortadaki kutsal ata sütunu ve tamga ateşi
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 12 * scale),
      w: 6.0 * scale,
      d: 6.0 * scale,
      h: 20.0 * scale,
      topColor: const Color(0xFFFBBF24),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );
  }

  /// Rezonans Kulesi (Prismatic Resonator)
  static void drawVoxelPrismaticResonator(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Kristal yarık kaidesi
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 3 * scale),
      w: 18.0 * scale,
      d: 18.0 * scale,
      h: 6.0 * scale,
      topColor: const Color(0xFF581C87),
      leftColor: const Color(0xFF3B0764),
      rightColor: const Color(0xFF2E1065),
    );
    // Yükselen prizmatik kristal monolit
    final double glow = 0.6 + 0.4 * math.sin(animTime * 2.5);
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 10 * scale),
      w: 8.0 * scale,
      d: 8.0 * scale,
      h: 18.0 * scale,
      topColor: Color.lerp(const Color(0xFFC084FC), const Color(0xFFE879F9), glow)!,
      leftColor: const Color(0xFF9333EA),
      rightColor: const Color(0xFF7E22CE),
    );
    // Tepe rezonans halkası
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy - 22 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFFF0ABFC),
      leftColor: const Color(0xFFD946EF),
      rightColor: const Color(0xFFA21CAF),
    );
  }

  // ==========================================
  // EFSANEVİ BİYOM DOĞAL ZEMİN & BALBALLAR
  // ==========================================

  /// Göksel Krater Doğal Zemin Vokselleri
  static void drawVoxelCelestialCraterGround(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Krater çukuru kayaları
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 3.0 * scale,
      topColor: const Color(0xFF1E1B4B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF020617),
    );
    // Mavi göktaşı kristal parçaları
    final double pulse = 0.5 + 0.5 * math.sin(animTime * 2.0);
    drawIsoCube(
      canvas,
      Offset(center.dx - 4 * scale, center.dy - 2 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 5.0 * scale,
      topColor: Color.lerp(const Color(0xFF38BDF8), const Color(0xFF818CF8), pulse)!,
      leftColor: const Color(0xFF0284C7),
      rightColor: const Color(0xFF1E40AF),
    );
  }

  /// Atalar Kurganı Doğal Balbal Taşları
  static void drawVoxelKurganBalbals(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Höyük tepeciği
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy + 2 * scale),
      w: 18.0 * scale,
      d: 18.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
    );
    // İkili Kadim Taş Balbal
    drawIsoCube(
      canvas,
      Offset(center.dx - 5 * scale, center.dy - 4 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 10.0 * scale,
      topColor: const Color(0xFF94A3B8),
      leftColor: const Color(0xFF64748B),
      rightColor: const Color(0xFF475569),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx + 5 * scale, center.dy - 2 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFF94A3B8),
      leftColor: const Color(0xFF64748B),
      rightColor: const Color(0xFF475569),
    );
  }

  /// Kristal Yarığı Doğal Zemin Vokselleri
  static void drawVoxelCrystalChasmGround(Canvas canvas, Offset center, {double scale = 1.0, double animTime = 0.0}) {
    // Mor-koyu taban yarığı
    drawIsoCube(
      canvas,
      Offset(center.dx, center.dy),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 4.0 * scale,
      topColor: const Color(0xFF3B0764),
      leftColor: const Color(0xFF2E1065),
      rightColor: const Color(0xFF1E1B4B),
    );
    // Yükselen 3 kristal dikiti
    final double g = 0.7 + 0.3 * math.sin(animTime * 3.0);
    drawIsoCube(
      canvas,
      Offset(center.dx - 4 * scale, center.dy - 3 * scale),
      w: 3.0 * scale,
      d: 3.0 * scale,
      h: 7.0 * scale,
      topColor: Color.lerp(const Color(0xFFC084FC), const Color(0xFFF472B6), g)!,
      leftColor: const Color(0xFF9333EA),
      rightColor: const Color(0xFF7E22CE),
    );
    drawIsoCube(
      canvas,
      Offset(center.dx + 3 * scale, center.dy - 5 * scale),
      w: 4.0 * scale,
      d: 4.0 * scale,
      h: 11.0 * scale,
      topColor: Color.lerp(const Color(0xFFE879F9), const Color(0xFFA855F7), g)!,
      leftColor: const Color(0xFFA21CAF),
      rightColor: const Color(0xFF701A75),
    );
  }

  // ==========================================
  // CANLI MİKRO-PARTİKÜL & ATMOSFER EFEKTLERİ
  // ==========================================

  /// Çöl: Rüzgarda Savrulan Kum Tozları
  static void drawVoxelDesertDust(Canvas canvas, Offset center, {double animTime = 0.0, int seed = 0}) {
    _sharedFillPaint.color = const Color(0xFFFDE68A).withValues(alpha: 0.45);
    for (int i = 0; i < 3; i++) {
      final double progress = ((animTime * 0.8 + i * 0.33 + (seed % 7) * 0.1) % 1.0);
      final double x = center.dx - 15.0 + progress * 30.0;
      final double y = center.dy - 8.0 + math.sin(progress * math.pi * 2.0) * 4.0;
      canvas.drawCircle(Offset(x, y), 1.2, _sharedFillPaint);
    }
  }

  /// Tundra: Don & Buz Kristalleri Parıltısı
  static void drawVoxelIceSparkles(Canvas canvas, Offset center, {double animTime = 0.0, int seed = 0}) {
    for (int i = 0; i < 2; i++) {
      final double sparkle = (0.5 + 0.5 * math.sin(animTime * 3.5 + i * 2.0 + seed)).clamp(0.0, 1.0);
      _sharedFillPaint.color = const Color(0xFFBAE6FD).withValues(alpha: sparkle * 0.7);
      final double ox = (i == 0 ? -7.0 : 8.0) + (seed % 5);
      final double oy = (i == 0 ? -4.0 : 5.0) - (seed % 3);
      canvas.drawCircle(Offset(center.dx + ox, center.dy + oy), 1.5, _sharedFillPaint);
    }
  }

  /// Volkan: Lav Korları & Kıvılcımlar
  static void drawVoxelVolcanoEmbers(Canvas canvas, Offset center, {double animTime = 0.0, int seed = 0}) {
    for (int i = 0; i < 3; i++) {
      final double progress = ((animTime * 1.2 + i * 0.33 + (seed % 5) * 0.2) % 1.0);
      final double y = center.dy + 4.0 - progress * 20.0;
      final double x = center.dx + math.sin(progress * 6.0 + i) * 5.0;
      final double alpha = (1.0 - progress).clamp(0.0, 0.8);
      _sharedFillPaint.color = (i % 2 == 0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 1.4, _sharedFillPaint);
    }
  }

  /// Sazlık: Uçuşan Yusufçuklar
  static void drawVoxelDragonflies(Canvas canvas, Offset center, {double animTime = 0.0, int seed = 0}) {
    final double flightAngle = animTime * 2.5 + seed;
    final double x = center.dx + math.cos(flightAngle) * 12.0;
    final double y = center.dy + math.sin(flightAngle * 1.5) * 6.0 - 4.0;
    _sharedFillPaint.color = const Color(0xFF38BDF8).withValues(alpha: 0.85);
    canvas.drawCircle(Offset(x, y), 1.8, _sharedFillPaint);
    _sharedFillPaint.color = const Color(0xFFE0F2FE).withValues(alpha: 0.6);
    canvas.drawCircle(Offset(x - 2, y - 1), 1.0, _sharedFillPaint);
    canvas.drawCircle(Offset(x + 2, y - 1), 1.0, _sharedFillPaint);
  }

  /// Göksel Krater & Kristal: Kozmik Yıldız Tozu
  static void drawVoxelCelestialStardust(Canvas canvas, Offset center, {double animTime = 0.0, int seed = 0}) {
    for (int i = 0; i < 4; i++) {
      final double progress = ((animTime * 0.7 + i * 0.25 + seed * 0.1) % 1.0);
      final double radius = 4.0 + progress * 12.0;
      final double angle = progress * math.pi * 2.0 + i * 1.57;
      final double x = center.dx + math.cos(angle) * radius;
      final double y = center.dy + math.sin(angle) * radius * 0.5 - 6.0;
      final double alpha = (math.sin(progress * math.pi)).clamp(0.0, 0.8);
      _sharedFillPaint.color = (i % 2 == 0 ? const Color(0xFFC084FC) : const Color(0xFF38BDF8)).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 1.3, _sharedFillPaint);
    }
  }
}
