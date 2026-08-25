import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/hex_tile_model.dart';

/// 3D Voxel / Isometric Canlı Diorama Çizim Motoru
/// Rüzgar salınımı, gece pencereleri, ateşböcekleri, sıçrayan balıklar, taş patikalar ve partiküller.
class VoxelIsometricRenderer {
  static const double isoAngle = 30.0 * (math.pi / 180.0);
  static final double cosIso = math.cos(isoAngle);
  static final double sinIso = math.sin(isoAngle);

  /// 3D İzometrik Küp / Prizma çizer
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
    final double dxR = (w / 2) * cosIso;
    final double dyR = (w / 2) * sinIso;
    final double dxL = -(d / 2) * cosIso;
    final double dyL = (d / 2) * sinIso;

    final Offset bottomCenter = baseCenter;
    final Offset bFront = Offset(bottomCenter.dx, bottomCenter.dy + dyR + dyL);
    final Offset bRight = Offset(bottomCenter.dx + dxR, bottomCenter.dy + dyR - dyL);
    final Offset bLeft = Offset(bottomCenter.dx + dxL, bottomCenter.dy - dyR + dyL);
    final Offset bBack = Offset(bottomCenter.dx + dxR + dxL, bottomCenter.dy - dyR - dyL);

    // Zemin temas gölgesi
    if (drawShadow) {
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: shadowOpacity)
        ..style = PaintingStyle.fill;
      final Path shadowPath = Path()
        ..moveTo(bFront.dx, bFront.dy + 2)
        ..lineTo(bRight.dx + 4, bRight.dy + 2)
        ..lineTo(bBack.dx + 4, bBack.dy + 2)
        ..lineTo(bLeft.dx - 4, bLeft.dy + 2)
        ..close();
      canvas.drawPath(shadowPath, shadowPaint);
    }

    final Offset tFront = Offset(bFront.dx, bFront.dy - h);
    final Offset tRight = Offset(bRight.dx, bRight.dy - h);
    final Offset tLeft = Offset(bLeft.dx, bLeft.dy - h);
    final Offset tBack = Offset(bBack.dx, bBack.dy - h);

    // 1. Sol Yüzey
    final Path leftFace = Path()
      ..moveTo(bLeft.dx, bLeft.dy)
      ..lineTo(bFront.dx, bFront.dy)
      ..lineTo(tFront.dx, tFront.dy)
      ..lineTo(tLeft.dx, tLeft.dy)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = leftColor);

    // 2. Sağ Yüzey
    final Path rightFace = Path()
      ..moveTo(bFront.dx, bFront.dy)
      ..lineTo(bRight.dx, bRight.dy)
      ..lineTo(tRight.dx, tRight.dy)
      ..lineTo(tFront.dx, tFront.dy)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = rightColor);

    // 3. Üst Yüzey
    final Path topFace = Path()
      ..moveTo(tFront.dx, tFront.dy)
      ..lineTo(tRight.dx, tRight.dy)
      ..lineTo(tBack.dx, tBack.dy)
      ..lineTo(tLeft.dx, tLeft.dy)
      ..close();
    canvas.drawPath(topFace, Paint()..color = topColor);
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
      final Paint splashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(seaCenter.dx + jumpX, seaCenter.dy), width: 14.0, height: 7.0),
        splashPaint,
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
      final Paint glowPaint = Paint()
        ..color = fireflyColor.withValues(alpha: 0.4 * glow)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(fx, fy), 4.0, glowPaint);

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
  static void drawVoxelSheep(Canvas canvas, Offset pos, {double animTime = 0.0, double scale = 1.0, int seed = 0}) {
    // 8 saniyelik asenkron organik davranış döngüsü
    final double cycle = (animTime + (seed * 1.73)) % 8.0;

    double bobY = 0.0;
    double headTilt = 0.0;
    double chewWobble = 0.0;

    if (cycle < 3.5) {
      // 1. Aşama: Otlama (Grazing) - Baş aşağıda, mikro çiğneme
      headTilt = 3.0 * scale;
      chewWobble = math.sin(animTime * 6.0) * 0.5 * scale;
    } else if (cycle < 5.5) {
      // 2. Aşama: Çevreye bakınma (Looking around) - Dik duruş, hafif nefes
      bobY = math.sin(animTime * 1.5) * 0.4 * scale;
      headTilt = -1.5 * scale;
    } else {
      // 3. Aşama: Neşeli Zıplama / Adım (Happy hop)
      final double hopProgress = (cycle - 5.5) / 2.5;
      bobY = math.sin(hopProgress * math.pi * 3).abs() * 2.5 * scale;
    }

    drawIsoCube(
      canvas,
      Offset(pos.dx, pos.dy - 3 * scale - bobY),
      w: 12.0 * scale,
      d: 10.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFFFFFFF),
      leftColor: const Color(0xFFF1F5F9),
      rightColor: const Color(0xFFE2E8F0),
      drawShadow: true,
      shadowOpacity: 0.2,
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx - 6 * cosIso * scale + chewWobble, pos.dy - 5 * scale - bobY + 3 * sinIso * scale + headTilt),
      w: 5.0 * scale,
      d: 5.0 * scale,
      h: 5.0 * scale,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx - 9 * cosIso * scale + chewWobble, pos.dy - 5 * scale - bobY + 4 * sinIso * scale + headTilt),
      w: 2.5 * scale,
      d: 2.5 * scale,
      h: 2.0 * scale,
      topColor: const Color(0xFFFDA4AF),
      leftColor: const Color(0xFFFB7185),
      rightColor: const Color(0xFFE11D48),
    );
  }

  /// Sevimli 3D Voxel Karaca / Geyik (Organik Asil Duruş, Eğilme ve Yaylanma)
  static void drawVoxelDeer(Canvas canvas, Offset pos, {double animTime = 0.0, double scale = 1.0, int seed = 0}) {
    // 9 saniyelik asenkron organik davranış döngüsü
    final double cycle = (animTime * 0.9 + (seed * 2.41)) % 9.0;

    double bobY = 0.0;
    double headTilt = 0.0;

    if (cycle < 4.5) {
      // 1. Asil Nöbet / Dikilme (Noble vigil) - Yavaş soluk alma
      bobY = math.sin(animTime * 1.4) * 0.5 * scale;
    } else if (cycle < 6.5) {
      // 2. Eğilip Ot Yeme (Bowing down)
      headTilt = 4.0 * scale;
      bobY = 0.0;
    } else {
      // 3. Zarif Yaylanma / Adım (Graceful stride)
      final double strideProgress = (cycle - 6.5) / 2.5;
      bobY = math.sin(strideProgress * math.pi * 2).abs() * 2.0 * scale;
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
      Offset(pos.dx - 6 * cosIso * scale, pos.dy - 10 * scale - bobY + 2 * sinIso * scale + headTilt),
      w: 5.0 * scale,
      d: 5.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFFDE68A),
      leftColor: const Color(0xFFF59E0B),
      rightColor: const Color(0xFFD97706),
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx - 6 * cosIso * scale, pos.dy - 18 * scale - bobY + 2 * sinIso * scale + headTilt),
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
    final Paint sandPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final Path shorelinePath = Path()..moveTo(corners[0].dx, corners[0].dy);
    for (int i = 1; i < 6; i++) {
      shorelinePath.lineTo(corners[i].dx, corners[i].dy);
    }
    shorelinePath.close();
    canvas.drawPath(shorelinePath, sandPaint);

    // 2. Dinamik Sinüs Salınımlı Beyaz Dalga Köpüğü
    final double wavePulse1 = 0.5 + 0.5 * math.sin(animTime * 2.8 + seed);
    final double wavePulse2 = 0.5 + 0.5 * math.cos(animTime * 2.2 + seed * 2);

    final Paint foamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75 * wavePulse1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Path foamPath = Path();
    for (int i = 0; i < 6; i++) {
      final pA = corners[i];
      final pB = corners[(i + 1) % 6];
      final mid = Offset((pA.dx + pB.dx) / 2, (pA.dy + pB.dy) / 2);
      final offsetMid = Offset(
        mid.dx + (center.dx - mid.dx) * (0.15 + 0.1 * wavePulse1),
        mid.dy + (center.dy - mid.dy) * (0.15 + 0.1 * wavePulse1),
      );
      foamPath.moveTo(pA.dx + (center.dx - pA.dx) * 0.1, pA.dy + (center.dy - pA.dy) * 0.1);
      foamPath.quadraticBezierTo(offsetMid.dx, offsetMid.dy, pB.dx + (center.dx - pB.dx) * 0.1, pB.dy + (center.dy - pB.dy) * 0.1);
    }
    canvas.drawPath(foamPath, foamPaint);

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

  /// 3D Voxel Ekin / Buğday Tarlası (Rüzgar Salınımlı)
  static void drawVoxelCropField(Canvas canvas, Offset baseCenter, {double animTime = 0.0}) {
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
    const int rows = 3;
    const int cols = 3;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
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

  /// 3D Voxel Dönen Değirmen
  static void drawVoxelWindmill(Canvas canvas, Offset baseCenter, double animTime, {bool isNight = false}) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 24.0,
      d: 24.0,
      h: 26.0,
      topColor: const Color(0xFFF8FAFC),
      leftColor: const Color(0xFFE2E8F0),
      rightColor: const Color(0xFF94A3B8),
      drawShadow: true,
    );

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
    drawIsoCube(
      canvas,
      roofBase,
      w: 20.0,
      d: 20.0,
      h: 10.0,
      topColor: const Color(0xFFF87171),
      leftColor: const Color(0xFFEF4444),
      rightColor: const Color(0xFFB91C1C),
    );

    final Offset rotorHub = Offset(baseCenter.dx - 8 * cosIso, baseCenter.dy - 20.0 + 8 * sinIso);
    final double angle = animTime * 2.8;

    for (int i = 0; i < 4; i++) {
      final double a = angle + i * (math.pi / 2);
      final double bLen = 16.0;
      final double bx = rotorHub.dx + bLen * math.cos(a);
      final double by = rotorHub.dy + bLen * math.sin(a) * 0.8;

      final Paint bladePaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.fill;
      final Paint framePaint = Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawLine(rotorHub, Offset(bx, by), framePaint);
      canvas.drawCircle(Offset(bx, by), 3.0, bladePaint);
    }
    canvas.drawCircle(rotorHub, 3.5, Paint()..color = const Color(0xFF451A03));
  }

  /// 3D Voxel Fırın (Duman Pufu & Gece Işığı)
  static void drawVoxelBakery(Canvas canvas, Offset baseCenter, double animTime, {bool isNight = false}) {
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
  static void drawVoxelMountain(Canvas canvas, Offset baseCenter, {int variant = 0, String season = 'SPRING', bool isZud = false}) {
    drawVoxelMountainVariant(canvas, baseCenter, variant, season: season, isZud: isZud);
  }

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

  /// 3D Voxel Oduncu Kulübesi
  static void drawVoxelLumberjack(Canvas canvas, Offset baseCenter) {
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

  /// 3D Voxel Hızarhane
  static void drawVoxelSawmill(Canvas canvas, Offset baseCenter) {
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

  /// 3D Voxel Mobilya Atölyesi
  static void drawVoxelFurniture(Canvas canvas, Offset baseCenter) {
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

  /// 3D Voxel Maden ve Demir Döküm Ocağı (Duman ve Kıvılcımlar)
  static void drawVoxelMine(Canvas canvas, Offset baseCenter, {double animTime = 0.0, bool isNight = false}) {
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

    // Maden Giriş Tüneli
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

  /// 3D Voksel Canlı Sis Kubbesi, Gizem Işıltıları ve Rünik Keşif Fısıltıları
  static void drawVoxelMysteryFog(
    Canvas canvas,
    Offset center, {
    required int seed,
    required TileBiome hiddenBiome,
    required bool hasShrine,
    required bool isBorderFog,
    double animTime = 0.0,
  }) {
    // 1. Zemin Nefes Alan Voksel Sis Tepeleri (Layered Voxel Mist Canopy)
    final double floatOffset = math.sin(animTime * 1.8 + (seed % 7)) * 2.5;
    final Offset mistCenter = Offset(center.dx, center.dy - 4.0 + floatOffset);

    // Ana Sis Gövdesi (3D Yarı Saydam İzometrik Blok)
    drawIsoCube(
      canvas,
      mistCenter,
      w: 32.0,
      d: 32.0,
      h: 10.0,
      topColor: const Color(0xFF1E293B).withValues(alpha: 0.88),
      leftColor: const Color(0xFF0F172A).withValues(alpha: 0.85),
      rightColor: const Color(0xFF060913).withValues(alpha: 0.80),
      drawShadow: true,
      shadowOpacity: 0.35,
    );

    // İkincil Küçük Sis Bulut Parçaları (Organik Saçaklar)
    final Offset mistPuff1 = Offset(mistCenter.dx - 10 * cosIso, mistCenter.dy - 5 + 6 * sinIso);
    drawIsoCube(
      canvas,
      mistPuff1,
      w: 14.0,
      d: 14.0,
      h: 7.0,
      topColor: const Color(0xFF334155).withValues(alpha: 0.75),
      leftColor: const Color(0xFF1E293B).withValues(alpha: 0.70),
      rightColor: const Color(0xFF0F172A).withValues(alpha: 0.65),
    );

    final Offset mistPuff2 = Offset(mistCenter.dx + 12 * cosIso, mistCenter.dy - 7 - 4 * sinIso);
    drawIsoCube(
      canvas,
      mistPuff2,
      w: 12.0,
      d: 12.0,
      h: 8.0,
      topColor: const Color(0xFF334155).withValues(alpha: 0.75),
      leftColor: const Color(0xFF1E293B).withValues(alpha: 0.70),
      rightColor: const Color(0xFF0F172A).withValues(alpha: 0.65),
    );

    // 2. Gizem Işıkları ve Fısıltı Teaser Efektleri (Mystery Glimmers)
    if (hasShrine) {
      // Tapınak Varsa: Göğe yükselen mistik mavi ışık huzmesi ve kristal parıltı
      final double shrinePulse = 0.5 + 0.5 * math.sin(animTime * 3.0);
      final Paint beaconPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.35 * shrinePulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(mistCenter.dx, mistCenter.dy - 16), 14.0, beaconPaint);

      // Yüzen Kadim Kristal Parçacığı
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 18 - math.sin(animTime * 2.5) * 4.0),
        w: 6.0,
        d: 6.0,
        h: 10.0,
        topColor: const Color(0xFFE0F2FE),
        leftColor: const Color(0xFF7DD3FC),
        rightColor: const Color(0xFF0284C7),
      );
    } else if (hiddenBiome == TileBiome.volcano) {
      // Volkan Varsa: Sisin altından sızan lav/kor parıltısı
      final double lavaPulse = 0.4 + 0.4 * math.sin(animTime * 2.2);
      final Paint lavaPaint = Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: 0.3 * lavaPulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(mistCenter.dx, mistCenter.dy - 4), 12.0, lavaPaint);

      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 7),
        w: 8.0,
        d: 8.0,
        h: 4.0,
        topColor: const Color(0xFFF97316),
        leftColor: const Color(0xFFEA580C),
        rightColor: const Color(0xFFC2410C),
      );
    } else if (hiddenBiome == TileBiome.mountain) {
      // Dağ Varsa: Sisin tepesinden yükselen karanlık masif zirve silüeti
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 11),
        w: 10.0,
        d: 10.0,
        h: 11.0,
        topColor: const Color(0xFF64748B).withValues(alpha: 0.9),
        leftColor: const Color(0xFF475569).withValues(alpha: 0.85),
        rightColor: const Color(0xFF334155).withValues(alpha: 0.8),
      );
    } else if (hiddenBiome == TileBiome.sea || hiddenBiome == TileBiome.wetland) {
      // Deniz/Su Varsa: Sisin üzerinde turkuaz dalga pırıltısı
      final double wavePulse = 0.3 + 0.3 * math.sin(animTime * 2.0 + seed);
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx, mistCenter.dy - 4),
        w: 10.0,
        d: 4.0,
        h: 2.0,
        topColor: const Color(0xFF38BDF8).withValues(alpha: wavePulse),
        leftColor: const Color(0xFF0284C7).withValues(alpha: wavePulse * 0.8),
        rightColor: const Color(0xFF0369A1).withValues(alpha: wavePulse * 0.6),
      );
    } else if (hiddenBiome == TileBiome.forest) {
      // Orman Varsa: Zümrüt rengi uçuşan yaprak/polen zerresi
      final double leafY = (animTime * 10.0 + seed * 3.0) % 18.0;
      drawIsoCube(
        canvas,
        Offset(mistCenter.dx + math.sin(animTime + seed) * 4.0, mistCenter.dy - 8.0 - leafY),
        w: 3.0,
        d: 3.0,
        h: 3.0,
        topColor: const Color(0xFF34D399).withValues(alpha: 0.8),
        leftColor: const Color(0xFF10B981).withValues(alpha: 0.7),
        rightColor: const Color(0xFF059669).withValues(alpha: 0.6),
      );
    }

    // 3. Rünik Petroglifler (Sınır Karolarında Parlak Nabız)
    final double runeBrightness = isBorderFog ? 0.75 : 0.25;
    final double runePulse = runeBrightness + 0.2 * math.sin(animTime * 2.5 + (seed % 5));
    
    final Paint runePaint = Paint()
      ..color = isBorderFog 
          ? const Color(0xFFFBBF24).withValues(alpha: runePulse.clamp(0.0, 1.0))
          : const Color(0xFFD97706).withValues(alpha: runePulse.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isBorderFog ? 2.2 : 1.5
      ..strokeCap = StrokeCap.round;

    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: (runePulse * 0.5).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isBorderFog ? 4.5 : 2.5
      ..strokeCap = StrokeCap.round;

    final int variant = seed % 4;
    final Path rune = Path();
    final Offset rCenter = Offset(mistCenter.dx, mistCenter.dy - 8);

    switch (variant) {
      case 0:
        rune.moveTo(rCenter.dx - 7, rCenter.dy - 3);
        rune.lineTo(rCenter.dx, rCenter.dy + 4);
        rune.lineTo(rCenter.dx + 7, rCenter.dy - 3);
        rune.moveTo(rCenter.dx, rCenter.dy + 4);
        rune.lineTo(rCenter.dx, rCenter.dy + 9);
        rune.moveTo(rCenter.dx - 4, rCenter.dy - 1);
        rune.lineTo(rCenter.dx + 4, rCenter.dy - 1);
        break;
      case 1:
        rune.moveTo(rCenter.dx, rCenter.dy - 7);
        rune.lineTo(rCenter.dx, rCenter.dy + 7);
        rune.moveTo(rCenter.dx - 7, rCenter.dy);
        rune.lineTo(rCenter.dx + 7, rCenter.dy);
        rune.addOval(Rect.fromCircle(center: rCenter, radius: 3.5));
        break;
      case 2:
        rune.moveTo(rCenter.dx - 5, rCenter.dy - 5);
        rune.quadraticBezierTo(rCenter.dx - 2, rCenter.dy - 9, rCenter.dx, rCenter.dy - 3);
        rune.lineTo(rCenter.dx, rCenter.dy + 5);
        rune.lineTo(rCenter.dx - 3, rCenter.dy + 8);
        rune.moveTo(rCenter.dx, rCenter.dy + 5);
        rune.lineTo(rCenter.dx + 3, rCenter.dy + 8);
        break;
      case 3:
      default:
        rune.moveTo(rCenter.dx - 6, rCenter.dy + 5);
        rune.lineTo(rCenter.dx + 6, rCenter.dy - 5);
        rune.moveTo(rCenter.dx + 6, rCenter.dy - 5);
        rune.lineTo(rCenter.dx + 2, rCenter.dy - 5);
        rune.moveTo(rCenter.dx + 6, rCenter.dy - 5);
        rune.lineTo(rCenter.dx + 6, rCenter.dy - 1);
        break;
    }

    if (isBorderFog) {
      canvas.drawPath(rune, glowPaint);
    }
    canvas.drawPath(rune, runePaint);
  }

  /// Antik Bozkır Petroglif & Tamga Kazıma Çizgileri (Sis Karoları İçin)
  static void drawVoxelPetroglyph(Canvas canvas, Offset center, {required int seed, double animTime = 0.0}) {
    final int variant = seed % 4;
    final double pulse = 0.35 + 0.15 * math.sin(animTime * 1.5 + (seed % 10));
    final Paint runePaint = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: pulse * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final Path rune = Path();

    switch (variant) {
      case 0:
        // Variant 0: Bozkır Boynuz / Geyik Tamgası
        rune.moveTo(center.dx - 8, center.dy - 4);
        rune.lineTo(center.dx, center.dy + 4);
        rune.lineTo(center.dx + 8, center.dy - 4);
        rune.moveTo(center.dx, center.dy + 4);
        rune.lineTo(center.dx, center.dy + 10);
        rune.moveTo(center.dx - 5, center.dy - 1);
        rune.lineTo(center.dx + 5, center.dy - 1);
        break;
      case 1:
        // Variant 1: Dört Yön Kağan Tamgası (Güneş Rünü)
        rune.moveTo(center.dx, center.dy - 8);
        rune.lineTo(center.dx, center.dy + 8);
        rune.moveTo(center.dx - 8, center.dy);
        rune.lineTo(center.dx + 8, center.dy);
        rune.addOval(Rect.fromCircle(center: center, radius: 4.0));
        break;
      case 2:
        // Variant 2: Bozkır Dağ Keçisi Rünü
        rune.moveTo(center.dx - 6, center.dy - 6);
        rune.quadraticBezierTo(center.dx - 2, center.dy - 10, center.dx, center.dy - 4);
        rune.lineTo(center.dx, center.dy + 6);
        rune.lineTo(center.dx - 4, center.dy + 10);
        rune.moveTo(center.dx, center.dy + 6);
        rune.lineTo(center.dx + 4, center.dy + 10);
        break;
      case 3:
      default:
        // Variant 3: Ok ve Yay / And İmzası
        rune.moveTo(center.dx - 7, center.dy + 6);
        rune.lineTo(center.dx + 7, center.dy - 6);
        rune.moveTo(center.dx + 7, center.dy - 6);
        rune.lineTo(center.dx + 2, center.dy - 6);
        rune.moveTo(center.dx + 7, center.dy - 6);
        rune.lineTo(center.dx + 7, center.dy - 1);
        rune.moveTo(center.dx - 2, center.dy + 1);
        rune.lineTo(center.dx + 2, center.dy - 3);
        break;
    }

    canvas.drawPath(rune, glowPaint);
    canvas.drawPath(rune, runePaint);
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
      final Paint beamPaint = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.32)
        ..style = PaintingStyle.fill;

      final Path beam = Path()
        ..moveTo(beaconOrigin.dx, beaconOrigin.dy)
        ..lineTo(sweepTarget.dx - 14 * math.sin(angle), sweepTarget.dy + 14 * math.cos(angle))
        ..lineTo(sweepTarget.dx + 14 * math.sin(angle), sweepTarget.dy - 14 * math.cos(angle))
        ..close();
      canvas.drawPath(beam, beamPaint);

      final Paint glowPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(beaconOrigin, 6.0, glowPaint);
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

  /// 3D Voxel İşçi (Sırtında Kargo & Yürüme Yaylanması)
  static void drawVoxelWorker(
    Canvas canvas,
    Offset pos, {
    required Color cargoColor,
    required double walkAnim,
    bool hasCargo = true,
  }) {
    final double bobY = math.sin(walkAnim).abs() * 2.5;

    drawIsoCube(
      canvas,
      Offset(pos.dx, pos.dy - bobY),
      w: 6.0,
      d: 6.0,
      h: 8.0,
      topColor: const Color(0xFF3B82F6),
      leftColor: const Color(0xFF2563EB),
      rightColor: const Color(0xFF1D4ED8),
      drawShadow: true,
      shadowOpacity: 0.35,
    );

    drawIsoCube(
      canvas,
      Offset(pos.dx, pos.dy - 8.0 - bobY),
      w: 6.0,
      d: 6.0,
      h: 6.0,
      topColor: const Color(0xFFFED7AA),
      leftColor: const Color(0xFFFDBA74),
      rightColor: const Color(0xFFFB923C),
    );

    if (hasCargo) {
      drawIsoCube(
        canvas,
        Offset(pos.dx + 4 * cosIso, pos.dy - 4.0 - bobY + 4 * sinIso),
        w: 5.0,
        d: 5.0,
        h: 5.0,
        topColor: cargoColor,
        leftColor: cargoColor.withValues(alpha: 0.8),
        rightColor: cargoColor.withValues(alpha: 0.6),
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
}
