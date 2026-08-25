import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/building_model.dart';
import '../../../domain/models/hex_tile_model.dart';

class LowPolyBuildingRenderer {
  static final Paint _stroke = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3;

  /// Biyom dekorasyonlarını (Ağaç, çim, dalga, dağ zirvesi) saf low-poly çizer
  static void renderBiomeDecoration(
    Canvas canvas,
    Offset center,
    TileBiome biome,
    double animTime,
  ) {
    switch (biome) {
      case TileBiome.meadow:
      case TileBiome.desert:
        _drawLowPolyMeadowTuft(canvas, center, animTime);
        break;
      case TileBiome.forest:
      case TileBiome.tundra:
        _drawLowPolyPineTrees(canvas, center);
        break;
      case TileBiome.mountain:
      case TileBiome.volcano:
        _drawLowPolyMountainPeaks(canvas, center);
        break;
      case TileBiome.sea:
      case TileBiome.wetland:
        _drawLowPolyWaves(canvas, center, animTime);
        break;
    }
  }

  /// Binaları saf low-poly geometrik formlarla çizer
  static void renderBuilding(
    Canvas canvas,
    Offset center,
    BuildingType type,
    int level,
    double animTime,
  ) {
    switch (type) {
      case BuildingType.castle:
        _drawCastle(canvas, center, level);
        break;
      case BuildingType.corn:
        _drawCornFarm(canvas, center);
        break;
      case BuildingType.lumberjack:
        _drawLumberjackLodge(canvas, center);
        break;
      case BuildingType.windmill:
        _drawWindmill(canvas, center, animTime);
        break;
      case BuildingType.sawmill:
        _drawSawmill(canvas, center);
        break;
      case BuildingType.bakery:
        _drawBakery(canvas, center, animTime);
        break;
      case BuildingType.furniture:
        _drawFurnitureWorkshop(canvas, center);
        break;
      case BuildingType.worker:
        _drawWorkerCottage(canvas, center);
        break;
      case BuildingType.watchtower:
        _drawWatchtower(canvas, center);
        break;
      case BuildingType.mine:
        _drawMineShaft(canvas, center);
        break;
      case BuildingType.bridge:
        _drawBridge(canvas, center);
        break;
    }
  }

  // --- BİYOM LOW-POLY ÇİZİMLERİ ---

  static void _drawLowPolyMeadowTuft(Canvas canvas, Offset c, double t) {
    final Paint p1 = Paint()..color = const Color(0xFF86EFAC);
    final double sway = math.sin(t * 3.0) * 1.5;

    // 3 adet sivri geometrik ot
    final Path tuft = Path()
      ..moveTo(c.dx - 6, c.dy + 4)
      ..lineTo(c.dx - 8 + sway, c.dy - 6)
      ..lineTo(c.dx - 4, c.dy + 4)
      ..lineTo(c.dx + sway, c.dy - 10)
      ..lineTo(c.dx + 4, c.dy + 4)
      ..lineTo(c.dx + 8 + sway, c.dy - 5)
      ..lineTo(c.dx + 6, c.dy + 4)
      ..close();

    canvas.drawPath(tuft, p1);
    canvas.drawPath(tuft, _stroke);
  }

  static void _drawLowPolyPineTrees(Canvas canvas, Offset c) {
    // 3 katmanlı fasetli çam ağacı
    final Paint darkGreen = Paint()..color = const Color(0xFF166534);
    final Paint midGreen = Paint()..color = const Color(0xFF22C55E);
    final Paint trunk = Paint()..color = const Color(0xFF78350F);

    // Gövde
    canvas.drawRect(Rect.fromLTWH(c.dx - 2, c.dy + 4, 4, 8), trunk);
    canvas.drawRect(Rect.fromLTWH(c.dx - 2, c.dy + 4, 4, 8), _stroke);

    // 3 Katmanlı piramit taç
    for (int i = 0; i < 3; i++) {
      final double yBase = c.dy + 4 - (i * 6);
      final double halfW = 12.0 - (i * 2.5);

      // Sol açık faset
      final Path leftP = Path()
        ..moveTo(c.dx, yBase - 8)
        ..lineTo(c.dx - halfW, yBase)
        ..lineTo(c.dx, yBase)
        ..close();
      canvas.drawPath(leftP, midGreen);
      canvas.drawPath(leftP, _stroke);

      // Sağ koyu faset
      final Path rightP = Path()
        ..moveTo(c.dx, yBase - 8)
        ..lineTo(c.dx + halfW, yBase)
        ..lineTo(c.dx, yBase)
        ..close();
      canvas.drawPath(rightP, darkGreen);
      canvas.drawPath(rightP, _stroke);
    }
  }

  static void _drawLowPolyMountainPeaks(Canvas canvas, Offset c) {
    // İkiz kristalize piramit zirve
    final Paint darkRock = Paint()..color = const Color(0xFF475569);
    final Paint lightRock = Paint()..color = const Color(0xFF94A3B8);
    final Paint snow = Paint()..color = const Color(0xFFF8FAFC);

    // Ana Zirve
    final Path leftM = Path()
      ..moveTo(c.dx - 2, c.dy - 14)
      ..lineTo(c.dx - 16, c.dy + 8)
      ..lineTo(c.dx - 2, c.dy + 8)
      ..close();
    canvas.drawPath(leftM, lightRock);
    canvas.drawPath(leftM, _stroke);

    final Path rightM = Path()
      ..moveTo(c.dx - 2, c.dy - 14)
      ..lineTo(c.dx + 12, c.dy + 8)
      ..lineTo(c.dx - 2, c.dy + 8)
      ..close();
    canvas.drawPath(rightM, darkRock);
    canvas.drawPath(rightM, _stroke);

    // Kar Başlığı
    final Path snowCap = Path()
      ..moveTo(c.dx - 2, c.dy - 14)
      ..lineTo(c.dx - 7, c.dy - 6)
      ..lineTo(c.dx + 4, c.dy - 6)
      ..close();
    canvas.drawPath(snowCap, snow);
    canvas.drawPath(snowCap, _stroke);
  }

  static void _drawLowPolyWaves(Canvas canvas, Offset c, double t) {
    final Paint wave = Paint()
      ..color = const Color(0xFFE0F2FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double phase = (t * 2.5) % (math.pi * 2);
    for (int row = -1; row <= 1; row++) {
      final double y = c.dy + row * 6.0;
      final double shift = math.sin(phase + row) * 3.0;

      final Path p = Path()
        ..moveTo(c.dx - 12 + shift, y)
        ..lineTo(c.dx - 4 + shift, y - 2)
        ..lineTo(c.dx + 4 + shift, y + 1)
        ..lineTo(c.dx + 12 + shift, y - 1);
      canvas.drawPath(p, wave);
    }
  }

  // --- BİNA LOW-POLY ÇİZİMLERİ ---

  static void _drawCastle(Canvas canvas, Offset c, int level) {
    final Paint wall = Paint()..color = const Color(0xFF94A3B8);
    final Paint wallDark = Paint()..color = const Color(0xFF64748B);
    final Paint roof = Paint()..color = const Color(0xFFDC2626);
    final Paint gold = Paint()..color = const Color(0xFFFFD700);

    // Ana Gövde
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 26, height: 16), wall);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 26, height: 16), _stroke);

    // Kapı
    final RRect gate = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 7), width: 8, height: 8),
      const Radius.circular(3),
    );
    canvas.drawRRect(gate, Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(gate, _stroke);

    // İki Kule
    for (final xOff in [-11.0, 11.0]) {
      final Rect tRect = Rect.fromCenter(center: Offset(c.dx + xOff, c.dy - 2), width: 8, height: 20);
      canvas.drawRect(tRect, wallDark);
      canvas.drawRect(tRect, _stroke);

      // Kule Çatısı (Kırmızı Piramit)
      final Path rPath = Path()
        ..moveTo(c.dx + xOff, c.dy - 18)
        ..lineTo(c.dx + xOff - 6, c.dy - 12)
        ..lineTo(c.dx + xOff + 6, c.dy - 12)
        ..close();
      canvas.drawPath(rPath, roof);
      canvas.drawPath(rPath, _stroke);
    }

    // Kraliyet Bayrağı
    final Path flag = Path()
      ..moveTo(c.dx, c.dy - 5)
      ..lineTo(c.dx, c.dy - 15)
      ..lineTo(c.dx + 8, c.dy - 11)
      ..lineTo(c.dx, c.dy - 8);
    canvas.drawPath(flag, gold);
    canvas.drawPath(flag, _stroke);
  }

  static void _drawCornFarm(Canvas canvas, Offset c) {
    final Paint soil = Paint()..color = const Color(0xFF78350F);
    final Paint corn = Paint()..color = const Color(0xFFFBBF24);

    // Çiftlik çit/tarla platformu
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), soil);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), _stroke);

    // Mısır koçanı dizisi
    for (int i = -1; i <= 1; i++) {
      final double x = c.dx + i * 7.0;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, c.dy - 2), width: 4, height: 10), corn);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, c.dy - 2), width: 4, height: 10), _stroke);

      canvas.drawLine(Offset(x - 3, c.dy), Offset(x, c.dy - 2), _stroke..color = Colors.green.shade800);
      canvas.drawLine(Offset(x + 3, c.dy), Offset(x, c.dy - 2), _stroke..color = Colors.green.shade800);
    }
  }

  static void _drawLumberjackLodge(Canvas canvas, Offset c) {
    final Paint wood = Paint()..color = const Color(0xFF92400E);
    final Paint roof = Paint()..color = const Color(0xFFB45309);
    final Paint axe = Paint()..color = const Color(0xFFE2E8F0);

    // Kütük kulübe
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 20, height: 14), wood);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 20, height: 14), _stroke);

    // Üçgen çatı
    final Path r = Path()
      ..moveTo(c.dx, c.dy - 10)
      ..lineTo(c.dx - 13, c.dy - 3)
      ..lineTo(c.dx + 13, c.dy - 3)
      ..close();
    canvas.drawPath(r, roof);
    canvas.drawPath(r, _stroke);

    // Balta & Kütük
    canvas.drawCircle(Offset(c.dx + 10, c.dy + 7), 3, Paint()..color = const Color(0xFFFDE68A));
    canvas.drawLine(Offset(c.dx + 10, c.dy + 4), Offset(c.dx + 13, c.dy + 1), axe..strokeWidth = 2);
  }

  static void _drawWindmill(Canvas canvas, Offset c, double t) {
    final Paint tower = Paint()..color = const Color(0xFFF1F5F9);
    final Paint roof = Paint()..color = const Color(0xFFDC2626);
    final Paint blade = Paint()..color = const Color(0xFFFDE047);

    // Konik Kule Gövdesi
    final Path body = Path()
      ..moveTo(c.dx - 6, c.dy - 5)
      ..lineTo(c.dx + 6, c.dy - 5)
      ..lineTo(c.dx + 9, c.dy + 10)
      ..lineTo(c.dx - 9, c.dy + 10)
      ..close();
    canvas.drawPath(body, tower);
    canvas.drawPath(body, _stroke);

    // Çatı
    final Path r = Path()
      ..moveTo(c.dx, c.dy - 12)
      ..lineTo(c.dx - 7, c.dy - 5)
      ..lineTo(c.dx + 7, c.dy - 5)
      ..close();
    canvas.drawPath(r, roof);
    canvas.drawPath(r, _stroke);

    // ⚡ CANLI DÖNEN DEĞİRMEN KANATLARI (4 Bıçak)
    final double angle = t * 2.8; // 30-40 RPM
    final Offset hub = Offset(c.dx, c.dy - 5);

    for (int i = 0; i < 4; i++) {
      final double a = angle + i * (math.pi / 2);
      final double bLen = 13.0;
      final double bx = hub.dx + bLen * math.cos(a);
      final double by = hub.dy + bLen * math.sin(a);

      canvas.drawLine(hub, Offset(bx, by), _stroke..strokeWidth = 2.0);

      final Path sail = Path()
        ..moveTo(hub.dx + (bLen * 0.4) * math.cos(a), hub.dy + (bLen * 0.4) * math.sin(a))
        ..lineTo(bx, by)
        ..lineTo(bx + 4 * math.sin(a), by - 4 * math.cos(a))
        ..close();
      canvas.drawPath(sail, blade);
      canvas.drawPath(sail, _stroke..strokeWidth = 1.0);
    }
    // Göbek
    canvas.drawCircle(hub, 2.5, Paint()..color = Colors.black);
  }

  static void _drawSawmill(Canvas canvas, Offset c) {
    final Paint mill = Paint()..color = const Color(0xFF78350F);
    final Paint blade = Paint()..color = const Color(0xFFE2E8F0);

    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 4, c.dy + 2), width: 16, height: 16), mill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 4, c.dy + 2), width: 16, height: 16), _stroke);

    // Dairesel Hızar Bıçağı
    canvas.drawCircle(Offset(c.dx + 8, c.dy + 3), 7, blade);
    canvas.drawCircle(Offset(c.dx + 8, c.dy + 3), 7, _stroke);
  }

  static void _drawBakery(Canvas canvas, Offset c, double t) {
    final Paint stone = Paint()..color = const Color(0xFF64748B);
    final Paint fire = Paint()..color = const Color(0xFFF97316);

    // Taş fırın kubbesi
    final Path dome = Path()
      ..moveTo(c.dx - 10, c.dy + 8)
      ..lineTo(c.dx + 10, c.dy + 8)
      ..lineTo(c.dx + 8, c.dy - 2)
      ..quadraticBezierTo(c.dx, c.dy - 10, c.dx - 8, c.dy - 2)
      ..close();
    canvas.drawPath(dome, stone);
    canvas.drawPath(dome, _stroke);

    // Fırın Ateşi Ağzı
    canvas.drawCircle(Offset(c.dx, c.dy + 4), 4, fire);
    canvas.drawCircle(Offset(c.dx, c.dy + 4), 4, _stroke);

    // ⚡ CANLI BACA DUMANI HALKALARI
    final double puffY = (t * 15) % 18;
    final double puffSize = 2.5 + (puffY * 0.25);
    final double alpha = (1.0 - (puffY / 18)).clamp(0.0, 1.0);

    final Paint smoke = Paint()..color = Colors.white.withValues(alpha: alpha * 0.7);
    canvas.drawCircle(Offset(c.dx - 4, c.dy - 10 - puffY), puffSize, smoke);
    canvas.drawCircle(Offset(c.dx - 6, c.dy - 14 - puffY * 0.8), puffSize * 1.2, smoke);
  }

  static void _drawFurnitureWorkshop(Canvas canvas, Offset c) {
    final Paint wood = Paint()..color = const Color(0xFFD97706);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), wood);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), _stroke);

    // Tezgah üstü sandalye formu
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 4), width: 10, height: 8), Paint()..color = const Color(0xFFB45309));
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 4), width: 10, height: 8), _stroke);
  }

  static void _drawWorkerCottage(Canvas canvas, Offset c) {
    final Paint tent = Paint()..color = const Color(0xFFE2E8F0);
    final Path t = Path()
      ..moveTo(c.dx, c.dy - 8)
      ..lineTo(c.dx - 9, c.dy + 8)
      ..lineTo(c.dx + 9, c.dy + 8)
      ..close();
    canvas.drawPath(t, tent);
    canvas.drawPath(t, _stroke);
  }

  static void _drawWatchtower(Canvas canvas, Offset c) {
    final Paint wood = Paint()..color = const Color(0xFF78350F);
    final Paint light = Paint()..color = const Color(0xFFFEF08A);

    // Kule Ayakları
    canvas.drawLine(Offset(c.dx - 8, c.dy + 10), Offset(c.dx - 4, c.dy - 8), _stroke..strokeWidth = 2);
    canvas.drawLine(Offset(c.dx + 8, c.dy + 10), Offset(c.dx + 4, c.dy - 8), _stroke..strokeWidth = 2);
    canvas.drawLine(Offset(c.dx - 7, c.dy + 2), Offset(c.dx + 7, c.dy + 2), _stroke..strokeWidth = 1.5);

    // Gözlem Kabini
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 10), width: 14, height: 8), wood);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 10), width: 14, height: 8), _stroke);

    // Işık / Meşale
    canvas.drawCircle(Offset(c.dx, c.dy - 15), 3, light);
  }

  static void _drawMineShaft(Canvas canvas, Offset c) {
    final Paint frame = Paint()..color = const Color(0xFF78350F);
    final Paint ore = Paint()..color = const Color(0xFFFFD700);

    // Maden Giriş Kirişi
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 18, height: 14), frame);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 18, height: 14), _stroke);

    // Karanlık Tünel
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 12, height: 10), Paint()..color = Colors.black);

    // Vagon / Altın Külçesi
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx + 8, c.dy + 8), width: 6, height: 4), ore);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx + 8, c.dy + 8), width: 6, height: 4), _stroke);
  }

  static void _drawBridge(Canvas canvas, Offset c) {
    final Paint wood = Paint()..color = const Color(0xFFD97706);
    // İki kemerli ahşap köprü
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy), width: 28, height: 8), wood);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy), width: 28, height: 8), _stroke);

    // Parmaklıklar
    for (int i = -2; i <= 2; i++) {
      final double x = c.dx + i * 6.0;
      canvas.drawLine(Offset(x, c.dy - 4), Offset(x, c.dy - 8), _stroke);
    }
  }
}
