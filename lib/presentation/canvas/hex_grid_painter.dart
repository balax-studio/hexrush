import 'package:flutter/material.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../core/hex/hex_math.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/hex_tile_model.dart';

class HexGridPainter extends CustomPainter {
  final Map<HexAxial, HexTileModel> tiles;
  final HexAxial? selectedCoord;
  final String currentSeason;
  final double hexSize;
  final double yScale;

  const HexGridPainter({
    required this.tiles,
    required this.selectedCoord,
    required this.currentSeason,
    this.hexSize = HexMath.defaultHexSize,
    this.yScale = HexMath.defaultYScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Canvas merkezini (0, 0) ortasına kaydır
    final centerOffset = Offset(size.width / 2, size.height / 2);

    // Y-sort sıralaması: r (dikey sıra) bazlı sırala
    final sortedTiles = tiles.values.toList()
      ..sort((a, b) {
        if (a.coord.r != b.coord.r) {
          return a.coord.r.compareTo(b.coord.r);
        }
        return a.coord.q.compareTo(b.coord.q);
      });

    for (final tile in sortedTiles) {
      final tileCenter =
          centerOffset + HexMath.hexToPixel(tile.coord, hexSize: hexSize, yScale: yScale);
      _drawTile(canvas, tile, tileCenter);
    }

    // Seçili altıgeni en üstte parlak çiz
    if (selectedCoord != null && tiles.containsKey(selectedCoord)) {
      final selectedTile = tiles[selectedCoord]!;
      final tileCenter = centerOffset +
          HexMath.hexToPixel(selectedTile.coord, hexSize: hexSize, yScale: yScale);
      _drawSelectionHighlight(canvas, tileCenter);
    }
  }

  void _drawTile(Canvas canvas, HexTileModel tile, Offset center) {
    final corners = HexMath.getHexCorners(center, hexSize: hexSize, yScale: yScale);
    final path = Path()..addPolygon(corners, true);

    if (tile.isFog) {
      // Sisli / Keşfedilmemiş karo
      final fogPaint = Paint()
        ..color = const Color(0xFF1E2530)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fogPaint);

      final borderPaint = Paint()
        ..color = const Color(0xFF151922)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(path, borderPaint);

      // Sis soru işareti
      _drawText(canvas, '?', center, fontSize: 14, color: const Color(0x33FFFFFF));
      return;
    }

    // Biyom zemin rengi
    Color baseColor = _getBiomeColor(tile.biome);
    if (currentSeason == 'WINTER') {
      baseColor = Color.lerp(baseColor, const Color(0xFFE2E8F0), 0.35)!;
    } else if (currentSeason == 'AUTUMN') {
      baseColor = Color.lerp(baseColor, const Color(0xFFD97706), 0.20)!;
    }

    final fillPaint = Paint()
      ..color = tile.isOwned ? baseColor : baseColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Kenarlık rengi
    final borderPaint = Paint()
      ..color = tile.isOwned
          ? const Color(0xFFFFD54F)
          : const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = tile.isOwned ? 2.0 : 1.0;
    canvas.drawPath(path, borderPaint);

    // Karo içi görsel içerik (Bina veya Biyom İkonu)
    if (tile.hasBuilding) {
      _drawBuilding(canvas, tile.building!, center);
    } else {
      _drawBiomeIcon(canvas, tile.biome, center, tile.isOwned);
    }
  }

  Color _getBiomeColor(TileBiome biome) {
    switch (biome) {
      case TileBiome.meadow:
        return const Color(0xFF388E3C); // Zengin Çayır Yeşili
      case TileBiome.forest:
        return const Color(0xFF1B5E20); // Koyu Orman Yeşili
      case TileBiome.mountain:
        return const Color(0xFF5D4037); // Dağ / Taş Kahve-Gri
      case TileBiome.sea:
        return const Color(0xFF0288D1); // Okyanus Mavisi
    }
  }

  void _drawBiomeIcon(Canvas canvas, TileBiome biome, Offset center, bool isOwned) {
    String emoji = '';
    switch (biome) {
      case TileBiome.meadow:
        emoji = isOwned ? '🌾' : '🌱';
        break;
      case TileBiome.forest:
        emoji = '🌲';
        break;
      case TileBiome.mountain:
        emoji = '🏔️';
        break;
      case TileBiome.sea:
        emoji = '🌊';
        break;
    }
    _drawText(canvas, emoji, center.translate(0, -2), fontSize: 18);
  }

  void _drawBuilding(Canvas canvas, BuildingModel building, Offset center) {
    String emoji = '';
    switch (building.type) {
      case BuildingType.castle:
        emoji = '🏰';
        break;
      case BuildingType.corn:
        emoji = '🌽';
        break;
      case BuildingType.windmill:
        emoji = '🌾';
        break;
      case BuildingType.bakery:
        emoji = '🍞';
        break;
      case BuildingType.lumberjack:
        emoji = '🪓';
        break;
      case BuildingType.sawmill:
        emoji = '🪵';
        break;
      case BuildingType.furniture:
        emoji = '🪑';
        break;
      case BuildingType.worker:
        emoji = '🛖';
        break;
      case BuildingType.watchtower:
        emoji = '🗼';
        break;
      case BuildingType.mine:
        emoji = '⛏️';
        break;
      case BuildingType.bridge:
        emoji = '🌉';
        break;
      case BuildingType.fisherman:
        emoji = '🎣';
        break;
      case BuildingType.fishermanHut:
        emoji = '🏠';
        break;
      case BuildingType.shrine:
        emoji = '🗿';
        break;
      default:
        emoji = '';
    }

    _drawText(canvas, emoji, center.translate(0, -6), fontSize: 20);

    // Seviye rozeti
    if (building.type != BuildingType.bridge && building.type != BuildingType.shrine) {
      _drawBadge(
        canvas,
        'Lv.${building.level}',
        center.translate(0, 14),
        bgColor: const Color(0xCC000000),
        textColor: Colors.amberAccent,
      );
    }

    // Birikmiş kaynak varsa göster
    if (building.accumulatedResource > 0.5) {
      _drawBadge(
        canvas,
        '+${building.accumulatedResource.toInt()}',
        center.translate(0, -20),
        bgColor: const Color(0xEE16A34A),
        textColor: Colors.white,
      );
    }
  }

  void _drawSelectionHighlight(Canvas canvas, Offset center) {
    final corners = HexMath.getHexCorners(center, hexSize: hexSize + 2, yScale: yScale);
    final path = Path()..addPolygon(corners, true);

    final highlightPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(path, highlightPaint);

    final fillPaint = Paint()
      ..color = const Color(0x2200E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  void _drawBadge(
    Canvas canvas,
    String text,
    Offset position, {
    required Color bgColor,
    required Color textColor,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: textPainter.width + 8,
        height: textPainter.height + 4,
      ),
      const Radius.circular(6),
    );

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(bgRect, bgPaint);

    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 16,
    Color color = Colors.white,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamilyFallback: const [
          'Segoe UI Emoji',
          'Apple Color Emoji',
          'Noto Color Emoji',
          'sans-serif',
        ],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant HexGridPainter oldDelegate) {
    return oldDelegate.tiles != tiles ||
        oldDelegate.selectedCoord != selectedCoord ||
        oldDelegate.currentSeason != currentSeason;
  }
}
