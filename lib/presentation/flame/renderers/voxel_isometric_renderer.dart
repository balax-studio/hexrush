import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Voxel / Isometric Low-Poly Çizim Motoru
/// Kullanıcının referans görselindeki (3D Voxel Diorama / Island) stili
/// saf matematiksel izometrik projeksiyon ve 3-fasetli küp çizimi ile üretir.
class VoxelIsometricRenderer {
  // İzometrik Projeksiyon Sabitleri
  static const double isoAngle = 30.0 * (math.pi / 180.0);
  static final double cosIso = math.cos(isoAngle);
  static final double sinIso = math.sin(isoAngle);

  /// 3D İzometrik Küp / Prizma çizer
  /// [baseCenter]: Küpün alt merkez noktası
  /// [w]: Genişlik (X ekseni)
  /// [d]: Derinlik (Y ekseni)
  /// [h]: Yükseklik (Z ekseni yukarı)
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
    // İzometrik taban köşe vektörleri
    final double dxR = (w / 2) * cosIso;
    final double dyR = (w / 2) * sinIso;
    final double dxL = -(d / 2) * cosIso;
    final double dyL = (d / 2) * sinIso;

    final Offset bottomCenter = baseCenter;
    final Offset bFront = Offset(bottomCenter.dx, bottomCenter.dy + dyR + dyL);
    final Offset bRight = Offset(bottomCenter.dx + dxR, bottomCenter.dy + dyR - dyL);
    final Offset bLeft = Offset(bottomCenter.dx + dxL, bottomCenter.dy - dyR + dyL);
    final Offset bBack = Offset(bottomCenter.dx + dxR + dxL, bottomCenter.dy - dyR - dyL);

    // Zemin yumuşak temas gölgesi
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

    // Üst Köşeler (Z ekseninde -h kadar yukarı ötelenmiş)
    final Offset tFront = Offset(bFront.dx, bFront.dy - h);
    final Offset tRight = Offset(bRight.dx, bRight.dy - h);
    final Offset tLeft = Offset(bLeft.dx, bLeft.dy - h);
    final Offset tBack = Offset(bBack.dx, bBack.dy - h);

    // 1. Sol Yüzey (Orta Ton)
    final Path leftFace = Path()
      ..moveTo(bLeft.dx, bLeft.dy)
      ..lineTo(bFront.dx, bFront.dy)
      ..lineTo(tFront.dx, tFront.dy)
      ..lineTo(tLeft.dx, tLeft.dy)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = leftColor);

    // 2. Sağ Yüzey (Gölge Tonu)
    final Path rightFace = Path()
      ..moveTo(bFront.dx, bFront.dy)
      ..lineTo(bRight.dx, bRight.dy)
      ..lineTo(tRight.dx, tRight.dy)
      ..lineTo(tFront.dx, tFront.dy)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = rightColor);

    // 3. Üst Yüzey (Işık Alan Parlak Ton)
    final Path topFace = Path()
      ..moveTo(tFront.dx, tFront.dy)
      ..lineTo(tRight.dx, tRight.dy)
      ..lineTo(tBack.dx, tBack.dy)
      ..lineTo(tLeft.dx, tLeft.dy)
      ..close();
    canvas.drawPath(topFace, Paint()..color = topColor);
  }

  /// 3D Voxel Ağaç (Referans görseldeki bloklu sevimli ağaçlar)
  static void drawVoxelTree(Canvas canvas, Offset baseCenter, {double scale = 1.0}) {
    // 1. Gövde (Kahverengi Ahşap Voxel)
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

    // 2. Yaprak Voxel Blokları (3 Katmanlı 3D Yeşil Küpler)
    final Offset foliageCenter = Offset(baseCenter.dx, baseCenter.dy - trunkH + 4 * scale);

    // Ana Alt Yaprak Bloğu
    drawIsoCube(
      canvas,
      foliageCenter,
      w: 22.0 * scale,
      d: 22.0 * scale,
      h: 12.0 * scale,
      topColor: const Color(0xFF86EFAC),
      leftColor: const Color(0xFF22C55E),
      rightColor: const Color(0xFF15803D),
    );

    // Orta Yaprak Bloğu
    drawIsoCube(
      canvas,
      Offset(foliageCenter.dx, foliageCenter.dy - 10 * scale),
      w: 16.0 * scale,
      d: 16.0 * scale,
      h: 10.0 * scale,
      topColor: const Color(0xFF4ADE80),
      leftColor: const Color(0xFF16A34A),
      rightColor: const Color(0xFF166534),
    );

    // Tepe Küçük Yaprak Bloğu
    drawIsoCube(
      canvas,
      Offset(foliageCenter.dx, foliageCenter.dy - 18 * scale),
      w: 10.0 * scale,
      d: 10.0 * scale,
      h: 8.0 * scale,
      topColor: const Color(0xFFBBF7D0),
      leftColor: const Color(0xFF4ADE80),
      rightColor: const Color(0xFF15803D),
    );
  }

  /// 3D Voxel Çam Ağacı (Koni / Piramit Voxel Katmanları)
  static void drawVoxelPine(Canvas canvas, Offset baseCenter, {double scale = 1.0}) {
    // Gövde
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
    // 3 Kademeli Küçülen Çam Blokları
    for (int i = 0; i < 3; i++) {
      final double size = (20.0 - i * 6.0) * scale;
      final double h = (8.0) * scale;
      final Offset c = Offset(baseCenter.dx, startY - (i * 7.0 * scale));

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

  /// 3D Voxel Ekin / Buğday Tarlası (Referans görseldeki altın sarısı tarla)
  static void drawVoxelCropField(Canvas canvas, Offset baseCenter) {
    // 1. Toprak Parsel Tabanı (Kahverengi Voxel Plaka)
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

    // 2. Altın Sarısı 3D Voxel Ekin Başakları (3x3 Grid)
    final Offset fieldTop = Offset(baseCenter.dx, baseCenter.dy - 4.0);
    const int rows = 3;
    const int cols = 3;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double offX = (c - 1) * 8.0 * cosIso - (r - 1) * 8.0 * cosIso;
        final double offY = (c - 1) * 8.0 * sinIso + (r - 1) * 8.0 * sinIso;
        final Offset cropPos = Offset(fieldTop.dx + offX, fieldTop.dy + offY);

        // Minik buğday sapı
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

  /// 3D Voxel Şato / Kale (Diorama Krallık Kalesi)
  static void drawVoxelCastle(Canvas canvas, Offset baseCenter, int level) {
    // 1. Ana Taş Gövde
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

    // 2. Kale Kapısı Voxel Girişi
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

    // 3. İki Köşe Kulesi
    for (final xSign in [-1.0, 1.0]) {
      final double tx = baseCenter.dx + xSign * 16.0 * cosIso;
      final double ty = baseCenter.dy - 18.0 + xSign * 16.0 * sinIso;

      // Kule gövdesi
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

      // Kule Kırmızı Çatısı (Piramit Voxel)
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

    // 4. Merkez Flama / Bayrak Direği
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
  static void drawVoxelWindmill(Canvas canvas, Offset baseCenter, double animTime) {
    // 1. Konik Sekizgen/Kübik Taş Kule
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

    // 2. Kırmızı Ahşap Çatı
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

    // 3. Dönen 3D Voxel Pervane Kanatları
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

  /// 3D Voxel Fırın (Bacasından Duman Yükselen Taş Fırın)
  static void drawVoxelBakery(Canvas canvas, Offset baseCenter, double animTime) {
    // Ana Taş Fırın Gövdesi
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

    // Tuğla Baca
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

    // Yükselen 3D Voxel Duman Pofudukları
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

  /// 3D Voxel Dağ Zirvesi (Kristalize Kademeli Kaya ve Kar Başlığı)
  static void drawVoxelMountain(Canvas canvas, Offset baseCenter) {
    // 1. Taban Kaya Bloğu
    drawIsoCube(
      canvas,
      baseCenter,
      w: 36.0,
      d: 36.0,
      h: 12.0,
      topColor: const Color(0xFF64748B),
      leftColor: const Color(0xFF475569),
      rightColor: const Color(0xFF334155),
      drawShadow: true,
    );

    // 2. Orta Zirve Bloğu
    final Offset midBase = Offset(baseCenter.dx, baseCenter.dy - 12.0);
    drawIsoCube(
      canvas,
      midBase,
      w: 24.0,
      d: 24.0,
      h: 14.0,
      topColor: const Color(0xFF94A3B8),
      leftColor: const Color(0xFF64748B),
      rightColor: const Color(0xFF475569),
    );

    // 3. Kar Başlıklı Tepe Bloğu
    final Offset topBase = Offset(baseCenter.dx, midBase.dy - 14.0);
    drawIsoCube(
      canvas,
      topBase,
      w: 14.0,
      d: 14.0,
      h: 12.0,
      topColor: const Color(0xFFFFFFFF),
      leftColor: const Color(0xFFE2E8F0),
      rightColor: const Color(0xFFCBD5E1),
    );
  }

  /// 3D Voxel Oduncu / Kereste Kulübesi
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

    // Kütük Yığını
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

  /// 3D Voxel Hızarhane (Sawmill)
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

    // Metal Bıçak Bloğu
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

    // Tezgah Üzeri Sandalye Voxel
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

  /// 3D Voxel Maden Girişi
  static void drawVoxelMine(Canvas canvas, Offset baseCenter) {
    // Maden kaya kemeri
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

    // Tünel karanlık girişi
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

    // Altın Maden Vagonu
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
  }

  /// 3D Voxel Gözlem Kulesi
  static void drawVoxelWatchtower(Canvas canvas, Offset baseCenter) {
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

    // Gözlem Kabini & Meşale
    drawIsoCube(
      canvas,
      Offset(baseCenter.dx, baseCenter.dy - 30.0),
      w: 18.0,
      d: 18.0,
      h: 8.0,
      topColor: const Color(0xFFFEF08A),
      leftColor: const Color(0xFFFDE047),
      rightColor: const Color(0xFFCA8A04),
    );
  }

  /// 3D Voxel Köprü
  static void drawVoxelBridge(Canvas canvas, Offset baseCenter) {
    drawIsoCube(
      canvas,
      baseCenter,
      w: 32.0,
      d: 14.0,
      h: 8.0,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF78350F),
    );
  }

  /// 3D Voxel Gökyüzü Bulutu (Referans görselin tepesinde yüzen beyaz 3D blok bulutlar)
  static void drawVoxelCloud(Canvas canvas, Offset pos, {double scale = 1.0}) {
    // 3'lü küme voxel bulut
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

  /// 3D Voxel Sevimli Mini İşçi / Karakter (Referans görseldeki küçük diorama sakinleri)
  static void drawVoxelWorker(Canvas canvas, Offset pos, {required Color cargoColor, required double walkAnim}) {
    final double bobY = math.sin(walkAnim).abs() * 2.5;

    // Ayaklar / Gövde
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

    // Kafa Voxel
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

    // Sırt Kargo Kutusu Voxel
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
