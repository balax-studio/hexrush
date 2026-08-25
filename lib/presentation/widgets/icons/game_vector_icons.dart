import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GameIconType {
  food,
  wood,
  stone,
  iron,
  flour,
  plank,
  bread,
  furniture,
  crown,
  land,
  market,
  tore,
  settings,
  frenzy,
  winter,
  zud,
  spring,
  summer,
  autumn,
  desert,
  tundra,
  volcano,
  wetland,
  shrine,
}

class GameVectorIcon extends StatelessWidget {
  final GameIconType type;
  final double size;
  final Color? color;

  const GameVectorIcon({
    super.key,
    required this.type,
    this.size = 18.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GameIconPainter(type: type, customColor: color),
    );
  }
}

class _GameIconPainter extends CustomPainter {
  final GameIconType type;
  final Color? customColor;

  _GameIconPainter({required this.type, this.customColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double h = size.height;

    switch (type) {
      case GameIconType.food:
        _drawFood(canvas, s, h);
        break;
      case GameIconType.wood:
        _drawWood(canvas, s, h);
        break;
      case GameIconType.stone:
        _drawStone(canvas, s, h);
        break;
      case GameIconType.iron:
        _drawIron(canvas, s, h);
        break;
      case GameIconType.flour:
        _drawFlour(canvas, s, h);
        break;
      case GameIconType.plank:
        _drawPlank(canvas, s, h);
        break;
      case GameIconType.bread:
        _drawBread(canvas, s, h);
        break;
      case GameIconType.furniture:
        _drawFurniture(canvas, s, h);
        break;
      case GameIconType.crown:
        _drawCrown(canvas, s, h);
        break;
      case GameIconType.land:
        _drawLand(canvas, s, h);
        break;
      case GameIconType.market:
        _drawMarket(canvas, s, h);
        break;
      case GameIconType.tore:
        _drawTore(canvas, s, h);
        break;
      case GameIconType.settings:
        _drawSettings(canvas, s, h);
        break;
      case GameIconType.frenzy:
        _drawFrenzy(canvas, s, h);
        break;
      case GameIconType.winter:
        _drawWinter(canvas, s, h, isZud: false);
        break;
      case GameIconType.zud:
        _drawWinter(canvas, s, h, isZud: true);
        break;
      case GameIconType.spring:
        _drawSpring(canvas, s, h);
        break;
      case GameIconType.summer:
        _drawSummer(canvas, s, h);
        break;
      case GameIconType.autumn:
        _drawAutumn(canvas, s, h);
        break;
      case GameIconType.desert:
        _drawDesert(canvas, s, h);
        break;
      case GameIconType.tundra:
        _drawTundra(canvas, s, h);
        break;
      case GameIconType.volcano:
        _drawVolcano(canvas, s, h);
        break;
      case GameIconType.wetland:
        _drawWetland(canvas, s, h);
        break;
      case GameIconType.shrine:
        _drawShrine(canvas, s, h);
        break;
    }
  }

  void _drawShrine(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFA855F7);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Monolitik Dikilitaş Formu
    final Path monolith = Path()
      ..moveTo(w * 0.35, h * 0.85)
      ..lineTo(w * 0.65, h * 0.85)
      ..lineTo(w * 0.65, h * 0.25)
      ..lineTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.35, h * 0.25)
      ..close();

    canvas.drawPath(monolith, fill);
    canvas.drawPath(monolith, stroke);

    // Orta rünik göz
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.1, stroke);
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.05, Paint()..color = Colors.white);
  }

  void _drawFood(Canvas canvas, double w, double h) {
    // 3'lü altın sarısı geometrik başak
    final Paint fill = Paint()
      ..color = customColor ?? const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Sap
    final Path stem = Path()
      ..moveTo(w * 0.5, h * 0.9)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, h * 0.2);
    canvas.drawPath(stem, stroke..strokeWidth = 1.5);

    // Başak taneleri (rhombus fasetleri)
    for (int i = 0; i < 4; i++) {
      final double y = h * (0.3 + i * 0.15);
      final double offset = (i % 2 == 0 ? -1 : 1) * w * 0.2;

      final Path grain = Path()
        ..moveTo(w * 0.5, y)
        ..lineTo(w * 0.5 + offset, y - h * 0.08)
        ..lineTo(w * 0.5 + offset * 1.3, y)
        ..lineTo(w * 0.5 + offset * 0.4, y + h * 0.06)
        ..close();

      canvas.drawPath(grain, fill);
      canvas.drawPath(grain, stroke..strokeWidth = 1.0);
    }
  }

  void _drawWood(Canvas canvas, double w, double h) {
    // Kesilmiş fasetli ikili odun tomruğu
    final Paint fill = Paint()
      ..color = customColor ?? const Color(0xFFB45309)
      ..style = PaintingStyle.fill;
    final Paint inner = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Alt tomruk gövde
    final RRect log = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.45, w * 0.8, h * 0.35),
      const Radius.circular(3),
    );
    canvas.drawRRect(log, fill);
    canvas.drawRRect(log, stroke);

    // Yan halka
    canvas.drawCircle(Offset(w * 0.22, h * 0.625), w * 0.12, inner);
    canvas.drawCircle(Offset(w * 0.22, h * 0.625), w * 0.12, stroke);
    canvas.drawCircle(Offset(w * 0.22, h * 0.625), w * 0.05, stroke);
  }

  void _drawStone(Canvas canvas, double w, double h) {
    // 3D Faceted kristal kaya
    final Paint top = Paint()..color = customColor ?? const Color(0xFF94A3B8);
    final Paint left = Paint()..color = const Color(0xFF64748B);
    final Paint right = Paint()..color = const Color(0xFF475569);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path pTop = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.8, h * 0.4)
      ..lineTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.2, h * 0.4)
      ..close();
    canvas.drawPath(pTop, top);
    canvas.drawPath(pTop, stroke);

    final Path pLeft = Path()
      ..moveTo(w * 0.2, h * 0.4)
      ..lineTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.15, h * 0.65)
      ..close();
    canvas.drawPath(pLeft, left);
    canvas.drawPath(pLeft, stroke);

    final Path pRight = Path()
      ..moveTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.8, h * 0.4)
      ..lineTo(w * 0.85, h * 0.65)
      ..lineTo(w * 0.5, h * 0.85)
      ..close();
    canvas.drawPath(pRight, right);
    canvas.drawPath(pRight, stroke);
  }

  void _drawIron(Canvas canvas, double w, double h) {
    // 3D Külçe
    final Paint top = Paint()..color = customColor ?? const Color(0xFFCBD5E1);
    final Paint front = Paint()..color = const Color(0xFF94A3B8);
    final Paint side = Paint()..color = const Color(0xFF475569);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path pTop = Path()
      ..moveTo(w * 0.3, h * 0.25)
      ..lineTo(w * 0.85, h * 0.25)
      ..lineTo(w * 0.7, h * 0.5)
      ..lineTo(w * 0.15, h * 0.5)
      ..close();
    canvas.drawPath(pTop, top);
    canvas.drawPath(pTop, stroke);

    final Path pFront = Path()
      ..moveTo(w * 0.15, h * 0.5)
      ..lineTo(w * 0.7, h * 0.5)
      ..lineTo(w * 0.65, h * 0.75)
      ..lineTo(w * 0.1, h * 0.75)
      ..close();
    canvas.drawPath(pFront, front);
    canvas.drawPath(pFront, stroke);

    final Path pSide = Path()
      ..moveTo(w * 0.7, h * 0.5)
      ..lineTo(w * 0.85, h * 0.25)
      ..lineTo(w * 0.8, h * 0.55)
      ..lineTo(w * 0.65, h * 0.75)
      ..close();
    canvas.drawPath(pSide, side);
    canvas.drawPath(pSide, stroke);
  }

  void _drawFlour(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFFEF08A);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path sack = Path()
      ..moveTo(w * 0.2, h * 0.85)
      ..lineTo(w * 0.8, h * 0.85)
      ..lineTo(w * 0.75, h * 0.35)
      ..lineTo(w * 0.25, h * 0.35)
      ..close();
    canvas.drawPath(sack, fill);
    canvas.drawPath(sack, stroke);

    // Çuval boğumu
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.25, w * 0.3, h * 0.1), fill);
    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.25, w * 0.3, h * 0.1), stroke);
  }

  void _drawPlank(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFD97706);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 2; i++) {
      final double y = h * (0.25 + i * 0.3);
      final Rect r = Rect.fromLTWH(w * 0.1, y, w * 0.8, h * 0.22);
      canvas.drawRect(r, fill);
      canvas.drawRect(r, stroke);
    }
  }

  void _drawBread(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFF59E0B);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final RRect loaf = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.3, w * 0.7, h * 0.45),
      const Radius.circular(10),
    );
    canvas.drawRRect(loaf, fill);
    canvas.drawRRect(loaf, stroke);

    // Ekmek çizikleri
    canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.45, h * 0.65), stroke);
    canvas.drawLine(Offset(w * 0.55, h * 0.35), Offset(w * 0.65, h * 0.65), stroke);
  }

  void _drawFurniture(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFB45309);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Sandalye sırtı
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.15, h * 0.65), fill);
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.15, h * 0.65), stroke);

    // Oturak
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.55, h * 0.1), fill);
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.55, h * 0.1), stroke);

    // Ön bacak
    canvas.drawRect(Rect.fromLTWH(w * 0.6, h * 0.65, w * 0.12, h * 0.2), fill);
    canvas.drawRect(Rect.fromLTWH(w * 0.6, h * 0.65, w * 0.12, h * 0.2), stroke);
  }

  void _drawCrown(Canvas canvas, double w, double h) {
    // 3 uçlu sert köşeli altın taç
    final Paint fill = Paint()
      ..color = customColor ?? const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final Path crown = Path()
      ..moveTo(w * 0.15, h * 0.75)
      ..lineTo(w * 0.85, h * 0.75)
      ..lineTo(w * 0.9, h * 0.3)
      ..lineTo(w * 0.65, h * 0.5)
      ..lineTo(w * 0.5, h * 0.2)
      ..lineTo(w * 0.35, h * 0.5)
      ..lineTo(w * 0.1, h * 0.3)
      ..close();

    canvas.drawPath(crown, fill);
    canvas.drawPath(crown, stroke);

    // Kırmızı taş faseti
    final Paint ruby = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(w * 0.5, h * 0.62), w * 0.08, ruby);
    canvas.drawCircle(Offset(w * 0.5, h * 0.62), w * 0.08, stroke..strokeWidth = 0.8);
  }

  void _drawLand(Canvas canvas, double w, double h) {
    final Paint stroke = Paint()
      ..color = customColor ?? const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final Paint fill = Paint()
      ..color = (customColor ?? const Color(0xFF10B981)).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // İzometrik mini altıgen
    final Path hex = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.85, h * 0.35)
      ..lineTo(w * 0.85, h * 0.65)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.15, h * 0.65)
      ..lineTo(w * 0.15, h * 0.35)
      ..close();

    canvas.drawPath(hex, fill);
    canvas.drawPath(hex, stroke);
  }

  void _drawMarket(Canvas canvas, double w, double h) {
    final Paint stroke = Paint()
      ..color = customColor ?? const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Terazi direği & tabanı
    canvas.drawLine(Offset(w * 0.5, h * 0.2), Offset(w * 0.5, h * 0.85), stroke);
    canvas.drawLine(Offset(w * 0.3, h * 0.85), Offset(w * 0.7, h * 0.85), stroke);

    // Terazi kolu
    canvas.drawLine(Offset(w * 0.15, h * 0.35), Offset(w * 0.85, h * 0.35), stroke);

    // Kefeler
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.22, h * 0.55), width: w * 0.25, height: h * 0.15),
      0,
      math.pi,
      true,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.78, h * 0.55), width: w * 0.25, height: h * 0.15),
      0,
      math.pi,
      true,
      stroke,
    );
  }

  void _drawTore(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFF59E0B);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Ferman parşömeni
    final Path scroll = Path()
      ..moveTo(w * 0.25, h * 0.2)
      ..lineTo(w * 0.75, h * 0.2)
      ..lineTo(w * 0.7, h * 0.8)
      ..lineTo(w * 0.2, h * 0.8)
      ..close();

    canvas.drawPath(scroll, fill);
    canvas.drawPath(scroll, stroke);

    // Kırmızı mühür
    final Paint seal = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(Offset(w * 0.45, h * 0.5), w * 0.1, seal);
    canvas.drawCircle(Offset(w * 0.45, h * 0.5), w * 0.1, stroke..strokeWidth = 0.8);
  }

  void _drawSettings(Canvas canvas, double w, double h) {
    final Paint stroke = Paint()
      ..color = customColor ?? const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // 6 dişli neo-brutalist çark
    final double r = w * 0.35;
    final Offset c = Offset(w * 0.5, h * 0.5);

    canvas.drawCircle(c, r, stroke);
    canvas.drawCircle(c, r * 0.45, stroke);

    for (int i = 0; i < 6; i++) {
      final double ang = i * math.pi / 3;
      final double x1 = c.dx + (r - 1) * math.cos(ang);
      final double y1 = c.dy + (r - 1) * math.sin(ang);
      final double x2 = c.dx + (r + 4) * math.cos(ang);
      final double y2 = c.dy + (r + 4) * math.sin(ang);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke..strokeWidth = 2.2);
    }
  }

  void _drawFrenzy(Canvas canvas, double w, double h) {
    final Paint fill = Paint()
      ..color = customColor ?? const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Alev / Şimşek poligonu
    final Path bolt = Path()
      ..moveTo(w * 0.55, h * 0.1)
      ..lineTo(w * 0.2, h * 0.55)
      ..lineTo(w * 0.48, h * 0.55)
      ..lineTo(w * 0.4, h * 0.9)
      ..lineTo(w * 0.8, h * 0.45)
      ..lineTo(w * 0.52, h * 0.45)
      ..close();

    canvas.drawPath(bolt, fill);
    canvas.drawPath(bolt, stroke);
  }

  void _drawWinter(Canvas canvas, double w, double h, {required bool isZud}) {
    final Paint stroke = Paint()
      ..color = isZud ? const Color(0xFFEF4444) : (customColor ?? const Color(0xFF38BDF8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Offset c = Offset(w * 0.5, h * 0.5);
    for (int i = 0; i < 4; i++) {
      final double ang = i * math.pi / 4;
      final double dx = (w * 0.38) * math.cos(ang);
      final double dy = (h * 0.38) * math.sin(ang);
      canvas.drawLine(Offset(c.dx - dx, c.dy - dy), Offset(c.dx + dx, c.dy + dy), stroke);
    }
  }

  void _drawSpring(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFF4ADE80);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path leaf = Path()
      ..moveTo(w * 0.2, h * 0.8)
      ..quadraticBezierTo(w * 0.2, h * 0.2, w * 0.8, h * 0.2)
      ..quadraticBezierTo(w * 0.8, h * 0.8, w * 0.2, h * 0.8);

    canvas.drawPath(leaf, fill);
    canvas.drawPath(leaf, stroke);
  }

  void _drawSummer(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFFBBF24);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.25, fill);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.25, stroke);
  }

  void _drawAutumn(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFEA580C);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path leaf = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.75, h * 0.4)
      ..lineTo(w * 0.65, h * 0.6)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.35, h * 0.6)
      ..lineTo(w * 0.25, h * 0.4)
      ..close();

    canvas.drawPath(leaf, fill);
    canvas.drawPath(leaf, stroke);
  }

  void _drawDesert(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFF59E0B);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path dune = Path()
      ..moveTo(w * 0.1, h * 0.8)
      ..quadraticBezierTo(w * 0.4, h * 0.3, w * 0.7, h * 0.6)
      ..quadraticBezierTo(w * 0.85, h * 0.5, w * 0.95, h * 0.8)
      ..close();

    canvas.drawPath(dune, fill);
    canvas.drawPath(dune, stroke);
  }

  void _drawTundra(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFF93C5FD);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path spire = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.75, h * 0.8)
      ..lineTo(w * 0.25, h * 0.8)
      ..close();

    canvas.drawPath(spire, fill);
    canvas.drawPath(spire, stroke);
  }

  void _drawVolcano(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFFDC2626);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path volc = Path()
      ..moveTo(w * 0.35, h * 0.3)
      ..lineTo(w * 0.65, h * 0.3)
      ..lineTo(w * 0.85, h * 0.85)
      ..lineTo(w * 0.15, h * 0.85)
      ..close();

    canvas.drawPath(volc, fill);
    canvas.drawPath(volc, stroke);
  }

  void _drawWetland(Canvas canvas, double w, double h) {
    final Paint fill = Paint()..color = customColor ?? const Color(0xFF059669);
    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path reed = Path()
      ..moveTo(w * 0.3, h * 0.85)
      ..lineTo(w * 0.3, h * 0.2)
      ..moveTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.5, h * 0.15)
      ..moveTo(w * 0.7, h * 0.85)
      ..lineTo(w * 0.7, h * 0.3);

    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.75, w * 0.7, h * 0.12), fill);
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.75, w * 0.7, h * 0.12), stroke);
    canvas.drawPath(reed, stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _GameIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.customColor != customColor;
}
