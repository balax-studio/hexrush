import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/building_model.dart';
import '../../../domain/models/hex_tile_model.dart';

class LowPolyBuildingRenderer {
  static final Paint _stroke = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3;

  static final Paint _fill = Paint()..style = PaintingStyle.fill;
  static final Path _path = Path();

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
      case BuildingType.fisherman:
        _drawFishermanPier(canvas, center, animTime);
        break;
      case BuildingType.fishermanHut:
        _drawFishermanHut(canvas, center);
        break;
      case BuildingType.shrine:
        _drawShrineMonolith(canvas, center, animTime);
        break;
    }
  }

  // --- BİYOM LOW-POLY ÇİZİMLERİ ---

  static void _drawLowPolyMeadowTuft(Canvas canvas, Offset c, double t) {
    _fill.color = const Color(0xFF86EFAC);
    final double sway = math.sin(t * 3.0) * 1.5;

    // 3 adet sivri geometrik ot
    _path
      ..reset()
      ..moveTo(c.dx - 6, c.dy + 4)
      ..lineTo(c.dx - 8 + sway, c.dy - 6)
      ..lineTo(c.dx - 4, c.dy + 4)
      ..lineTo(c.dx + sway, c.dy - 10)
      ..lineTo(c.dx + 4, c.dy + 4)
      ..lineTo(c.dx + 8 + sway, c.dy - 5)
      ..lineTo(c.dx + 6, c.dy + 4)
      ..close();

    canvas.drawPath(_path, _fill);
    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;
    canvas.drawPath(_path, _stroke);
  }

  static void _drawLowPolyPineTrees(Canvas canvas, Offset c) {
    // 3 katmanlı fasetli çam ağacı
    const darkGreen = Color(0xFF166534);
    const midGreen = Color(0xFF22C55E);
    const trunk = Color(0xFF78350F);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Gövde
    _fill.color = trunk;
    canvas.drawRect(Rect.fromLTWH(c.dx - 2, c.dy + 4, 4, 8), _fill);
    canvas.drawRect(Rect.fromLTWH(c.dx - 2, c.dy + 4, 4, 8), _stroke);

    // 3 Katmanlı piramit taç
    for (int i = 0; i < 3; i++) {
      final double yBase = c.dy + 4 - (i * 6);
      final double halfW = 12.0 - (i * 2.5);

      // Sol açık faset
      _path
        ..reset()
        ..moveTo(c.dx, yBase - 8)
        ..lineTo(c.dx - halfW, yBase)
        ..lineTo(c.dx, yBase)
        ..close();
      _fill.color = midGreen;
      canvas.drawPath(_path, _fill);
      canvas.drawPath(_path, _stroke);

      // Sağ koyu faset
      _path
        ..reset()
        ..moveTo(c.dx, yBase - 8)
        ..lineTo(c.dx + halfW, yBase)
        ..lineTo(c.dx, yBase)
        ..close();
      _fill.color = darkGreen;
      canvas.drawPath(_path, _fill);
      canvas.drawPath(_path, _stroke);
    }
  }

  static void _drawLowPolyMountainPeaks(Canvas canvas, Offset c) {
    // İkiz kristalize piramit zirve
    const darkRock = Color(0xFF475569);
    const lightRock = Color(0xFF94A3B8);
    const snow = Color(0xFFF8FAFC);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Ana Zirve
    _path
      ..reset()
      ..moveTo(c.dx - 2, c.dy - 14)
      ..lineTo(c.dx - 16, c.dy + 8)
      ..lineTo(c.dx - 2, c.dy + 8)
      ..close();
    _fill.color = lightRock;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    _path
      ..reset()
      ..moveTo(c.dx - 2, c.dy - 14)
      ..lineTo(c.dx + 12, c.dy + 8)
      ..lineTo(c.dx - 2, c.dy + 8)
      ..close();
    _fill.color = darkRock;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // Kar Başlığı
    _path
      ..reset()
      ..moveTo(c.dx - 2, c.dy - 14)
      ..lineTo(c.dx - 7, c.dy - 6)
      ..lineTo(c.dx + 4, c.dy - 6)
      ..close();
    _fill.color = snow;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);
  }

  static void _drawLowPolyWaves(Canvas canvas, Offset c, double t) {
    _stroke.color = const Color(0xFFE0F2FE);
    _stroke.strokeWidth = 2.0;

    final double phase = (t * 2.5) % (math.pi * 2);
    for (int row = -1; row <= 1; row++) {
      final double y = c.dy + row * 6.0;
      final double shift = math.sin(phase + row) * 3.0;

      _path
        ..reset()
        ..moveTo(c.dx - 12 + shift, y)
        ..lineTo(c.dx - 4 + shift, y - 2)
        ..lineTo(c.dx + 4 + shift, y + 1)
        ..lineTo(c.dx + 12 + shift, y - 1);
      canvas.drawPath(_path, _stroke);
    }
  }

  // --- BİNA LOW-POLY ÇİZİMLERİ ---

  static void _drawCastle(Canvas canvas, Offset c, int level) {
    const wall = Color(0xFF94A3B8);
    const wallDark = Color(0xFF64748B);
    const roof = Color(0xFFDC2626);
    const gold = Color(0xFFFFD700);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Ana Gövde
    _fill.color = wall;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 26, height: 16), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 26, height: 16), _stroke);

    // Kapı
    final RRect gate = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 7), width: 8, height: 8),
      const Radius.circular(3),
    );
    _fill.color = const Color(0xFF1E293B);
    canvas.drawRRect(gate, _fill);
    canvas.drawRRect(gate, _stroke);

    // İki Kule
    for (final xOff in [-11.0, 11.0]) {
      final Rect tRect = Rect.fromCenter(center: Offset(c.dx + xOff, c.dy - 2), width: 8, height: 20);
      _fill.color = wallDark;
      canvas.drawRect(tRect, _fill);
      canvas.drawRect(tRect, _stroke);

      // Kule Çatısı (Kırmızı Piramit)
      _path
        ..reset()
        ..moveTo(c.dx + xOff, c.dy - 18)
        ..lineTo(c.dx + xOff - 6, c.dy - 12)
        ..lineTo(c.dx + xOff + 6, c.dy - 12)
        ..close();
      _fill.color = roof;
      canvas.drawPath(_path, _fill);
      canvas.drawPath(_path, _stroke);
    }

    // Kraliyet Bayrağı
    _path
      ..reset()
      ..moveTo(c.dx, c.dy - 5)
      ..lineTo(c.dx, c.dy - 15)
      ..lineTo(c.dx + 8, c.dy - 11)
      ..lineTo(c.dx, c.dy - 8);
    _fill.color = gold;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);
  }

  static void _drawCornFarm(Canvas canvas, Offset c) {
    const soil = Color(0xFF78350F);
    const corn = Color(0xFFFBBF24);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Çiftlik çit/tarla platformu
    _fill.color = soil;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), _stroke);

    // Mısır koçanı dizisi
    for (int i = -1; i <= 1; i++) {
      final double x = c.dx + i * 7.0;
      _fill.color = corn;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, c.dy - 2), width: 4, height: 10), _fill);
      _stroke.color = Colors.black;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, c.dy - 2), width: 4, height: 10), _stroke);

      _stroke.color = const Color(0xFF166534);
      canvas.drawLine(Offset(x - 3, c.dy), Offset(x, c.dy - 2), _stroke);
      canvas.drawLine(Offset(x + 3, c.dy), Offset(x, c.dy - 2), _stroke);
    }
  }

  static void _drawLumberjackLodge(Canvas canvas, Offset c) {
    const wood = Color(0xFF92400E);
    const roof = Color(0xFFB45309);
    const axe = Color(0xFFE2E8F0);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Kütük kulübe
    _fill.color = wood;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 20, height: 14), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 20, height: 14), _stroke);

    // Üçgen çatı
    _path
      ..reset()
      ..moveTo(c.dx, c.dy - 10)
      ..lineTo(c.dx - 13, c.dy - 3)
      ..lineTo(c.dx + 13, c.dy - 3)
      ..close();
    _fill.color = roof;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // Balta & Kütük
    _fill.color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(c.dx + 10, c.dy + 7), 3, _fill);
    _stroke.color = axe;
    _stroke.strokeWidth = 2.0;
    canvas.drawLine(Offset(c.dx + 10, c.dy + 4), Offset(c.dx + 13, c.dy + 1), _stroke);
  }

  static void _drawWindmill(Canvas canvas, Offset c, double t) {
    const tower = Color(0xFFF1F5F9);
    const roof = Color(0xFFDC2626);
    const blade = Color(0xFFFDE047);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Konik Kule Gövdesi
    _path
      ..reset()
      ..moveTo(c.dx - 6, c.dy - 5)
      ..lineTo(c.dx + 6, c.dy - 5)
      ..lineTo(c.dx + 9, c.dy + 10)
      ..lineTo(c.dx - 9, c.dy + 10)
      ..close();
    _fill.color = tower;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // Çatı
    _path
      ..reset()
      ..moveTo(c.dx, c.dy - 12)
      ..lineTo(c.dx - 7, c.dy - 5)
      ..lineTo(c.dx + 7, c.dy - 5)
      ..close();
    _fill.color = roof;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // ⚡ CANLI DÖNEN DEĞİRMEN KANATLARI (4 Bıçak)
    final double angle = t * 2.8; // 30-40 RPM
    final Offset hub = Offset(c.dx, c.dy - 5);

    for (int i = 0; i < 4; i++) {
      final double a = angle + i * (math.pi / 2);
      const double bLen = 13.0;
      final double bx = hub.dx + bLen * math.cos(a);
      final double by = hub.dy + bLen * math.sin(a);

      _stroke.strokeWidth = 2.0;
      _stroke.color = Colors.black;
      canvas.drawLine(hub, Offset(bx, by), _stroke);

      _path
        ..reset()
        ..moveTo(hub.dx + (bLen * 0.4) * math.cos(a), hub.dy + (bLen * 0.4) * math.sin(a))
        ..lineTo(bx, by)
        ..lineTo(bx + 4 * math.sin(a), by - 4 * math.cos(a))
        ..close();
      _fill.color = blade;
      canvas.drawPath(_path, _fill);
      _stroke.strokeWidth = 1.0;
      canvas.drawPath(_path, _stroke);
    }
    // Göbek
    _fill.color = Colors.black;
    canvas.drawCircle(hub, 2.5, _fill);
  }

  static void _drawSawmill(Canvas canvas, Offset c) {
    const mill = Color(0xFF78350F);
    const blade = Color(0xFFE2E8F0);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    _fill.color = mill;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 4, c.dy + 2), width: 16, height: 16), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 4, c.dy + 2), width: 16, height: 16), _stroke);

    // Dairesel Hızar Bıçağı
    _fill.color = blade;
    canvas.drawCircle(Offset(c.dx + 8, c.dy + 3), 7, _fill);
    canvas.drawCircle(Offset(c.dx + 8, c.dy + 3), 7, _stroke);
  }

  static void _drawBakery(Canvas canvas, Offset c, double t) {
    const stone = Color(0xFF64748B);
    const fire = Color(0xFFF97316);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Taş fırın kubbesi
    _path
      ..reset()
      ..moveTo(c.dx - 10, c.dy + 8)
      ..lineTo(c.dx + 10, c.dy + 8)
      ..lineTo(c.dx + 8, c.dy - 2)
      ..quadraticBezierTo(c.dx, c.dy - 10, c.dx - 8, c.dy - 2)
      ..close();
    _fill.color = stone;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // Fırın Ateşi Ağzı
    _fill.color = fire;
    canvas.drawCircle(Offset(c.dx, c.dy + 4), 4, _fill);
    canvas.drawCircle(Offset(c.dx, c.dy + 4), 4, _stroke);

    // ⚡ CANLI BACA DUMANI HALKALARI
    final double puffY = (t * 15) % 18;
    final double puffSize = 2.5 + (puffY * 0.25);
    final double alpha = (1.0 - (puffY / 18)).clamp(0.0, 1.0);

    _fill.color = Colors.white.withValues(alpha: alpha * 0.7);
    canvas.drawCircle(Offset(c.dx - 4, c.dy - 10 - puffY), puffSize, _fill);
    canvas.drawCircle(Offset(c.dx - 6, c.dy - 14 - puffY * 0.8), puffSize * 1.2, _fill);
  }

  static void _drawFurnitureWorkshop(Canvas canvas, Offset c) {
    const wood = Color(0xFFD97706);
    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    _fill.color = wood;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 22, height: 12), _stroke);

    // Tezgah üstü sandalye formu
    _fill.color = const Color(0xFFB45309);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 4), width: 10, height: 8), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 4), width: 10, height: 8), _stroke);
  }

  static void _drawWorkerCottage(Canvas canvas, Offset c) {
    const tent = Color(0xFFE2E8F0);
    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    _path
      ..reset()
      ..moveTo(c.dx, c.dy - 8)
      ..lineTo(c.dx - 9, c.dy + 8)
      ..lineTo(c.dx + 9, c.dy + 8)
      ..close();
    _fill.color = tent;
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);
  }

  static void _drawWatchtower(Canvas canvas, Offset c) {
    const wood = Color(0xFF78350F);
    const light = Color(0xFFFEF08A);

    _stroke.color = Colors.black;
    _stroke.strokeWidth = 2.0;

    // Kule Ayakları
    canvas.drawLine(Offset(c.dx - 8, c.dy + 10), Offset(c.dx - 4, c.dy - 8), _stroke);
    canvas.drawLine(Offset(c.dx + 8, c.dy + 10), Offset(c.dx + 4, c.dy - 8), _stroke);
    _stroke.strokeWidth = 1.5;
    canvas.drawLine(Offset(c.dx - 7, c.dy + 2), Offset(c.dx + 7, c.dy + 2), _stroke);

    // Gözlem Kabini
    _fill.color = wood;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 10), width: 14, height: 8), _fill);
    _stroke.strokeWidth = 1.3;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 10), width: 14, height: 8), _stroke);

    // Işık / Meşale
    _fill.color = light;
    canvas.drawCircle(Offset(c.dx, c.dy - 15), 3, _fill);
  }

  static void _drawMineShaft(Canvas canvas, Offset c) {
    const frame = Color(0xFF78350F);
    const ore = Color(0xFFFFD700);

    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Maden Giriş Kirişi
    _fill.color = frame;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 18, height: 14), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 18, height: 14), _stroke);

    // Karanlık Tünel
    _fill.color = Colors.black;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 4), width: 12, height: 10), _fill);

    // Vagon / Altın Külçesi
    _fill.color = ore;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx + 8, c.dy + 8), width: 6, height: 4), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx + 8, c.dy + 8), width: 6, height: 4), _stroke);
  }

  static void _drawBridge(Canvas canvas, Offset c) {
    const wood = Color(0xFFD97706);
    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // İki kemerli ahşap köprü
    _fill.color = wood;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy), width: 28, height: 8), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy), width: 28, height: 8), _stroke);

    // Parmaklıklar
    for (int i = -2; i <= 2; i++) {
      final double x = c.dx + i * 6.0;
      canvas.drawLine(Offset(x, c.dy - 4), Offset(x, c.dy - 8), _stroke);
    }
  }

  static void _drawFishermanPier(Canvas canvas, Offset c, double t) {
    const wood = Color(0xFFB45309);
    const boat = Color(0xFFD97706);
    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Ahşap İskele Platformu
    _fill.color = wood;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 4, c.dy), width: 16, height: 6), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 4, c.dy), width: 16, height: 6), _stroke);

    // İskele Kazıkları
    canvas.drawLine(Offset(c.dx - 10, c.dy + 3), Offset(c.dx - 10, c.dy + 9), _stroke);
    canvas.drawLine(Offset(c.dx + 2, c.dy + 3), Offset(c.dx + 2, c.dy + 9), _stroke);

    // Küçük Balıkçı Kayığı (Hafif Salınım)
    final double bob = math.sin(t * 2.5) * 1.5;
    _fill.color = boat;
    _path
      ..reset()
      ..moveTo(c.dx + 6, c.dy + 2 + bob)
      ..lineTo(c.dx + 16, c.dy + 2 + bob)
      ..lineTo(c.dx + 14, c.dy + 7 + bob)
      ..lineTo(c.dx + 8, c.dy + 7 + bob)
      ..close();
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // Olta Direği
    canvas.drawLine(Offset(c.dx + 12, c.dy + 2 + bob), Offset(c.dx + 17, c.dy - 5 + bob), _stroke);
  }

  static void _drawFishermanHut(Canvas canvas, Offset c) {
    const woodWall = Color(0xFF78350F);
    const roof = Color(0xFF0D9488);
    _stroke.strokeWidth = 1.3;
    _stroke.color = Colors.black;

    // Kıyı Kulübesi Gövdesi
    _fill.color = woodWall;
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 16, height: 12), _fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 16, height: 12), _stroke);

    // Üçgen Çatı
    _fill.color = roof;
    _path
      ..reset()
      ..moveTo(c.dx - 10, c.dy - 3)
      ..lineTo(c.dx, c.dy - 12)
      ..lineTo(c.dx + 10, c.dy - 3)
      ..close();
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // Kurutma Tezgahı
    canvas.drawLine(Offset(c.dx + 11, c.dy + 1), Offset(c.dx + 11, c.dy + 8), _stroke);
    canvas.drawLine(Offset(c.dx + 16, c.dy + 1), Offset(c.dx + 16, c.dy + 8), _stroke);
    canvas.drawLine(Offset(c.dx + 10, c.dy + 2), Offset(c.dx + 17, c.dy + 2), _stroke);
  }

  static void _drawShrineMonolith(Canvas canvas, Offset c, double t) {
    const stone = Color(0xFF475569);
    const runeGlow = Color(0xFF38BDF8);
    _stroke.strokeWidth = 1.4;
    _stroke.color = Colors.black;

    // Antik Taş Dikilitaş (Monolith)
    _fill.color = stone;
    _path
      ..reset()
      ..moveTo(c.dx - 5, c.dy + 9)
      ..lineTo(c.dx - 3, c.dy - 10)
      ..lineTo(c.dx, c.dy - 14)
      ..lineTo(c.dx + 3, c.dy - 10)
      ..lineTo(c.dx + 5, c.dy + 9)
      ..close();
    canvas.drawPath(_path, _fill);
    canvas.drawPath(_path, _stroke);

    // Parıldayan Rünik Çizgi
    final double pulse = 0.5 + 0.5 * math.sin(t * 3.0);
    final runePaint = Paint()
      ..color = runeGlow.withValues(alpha: 0.4 + 0.6 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(c.dx, c.dy - 7), Offset(c.dx, c.dy + 3), runePaint);
    canvas.drawLine(Offset(c.dx - 2, c.dy - 2), Offset(c.dx + 2, c.dy - 2), runePaint);
  }
}
