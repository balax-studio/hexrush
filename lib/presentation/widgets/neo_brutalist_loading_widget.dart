import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/neo_brutalist_theme.dart';

/// Arkeolojik Neo-Brutalist Çokgen ve Dikdörtgen Yükleme Animasyon Bileşeni
class NeoBrutalistHexLoader extends StatefulWidget {
  final double size;
  final String statusText;
  final String subText;
  final bool showProgressTrack;

  const NeoBrutalistHexLoader({
    super.key,
    this.size = 80.0,
    this.statusText = 'KADİM BOZKIR MATRİSİ',
    this.subText = 'İzometrik Voksel Motoru Aktif Ediliyor...',
    this.showProgressTrack = true,
  });

  @override
  State<NeoBrutalistHexLoader> createState() => _NeoBrutalistHexLoaderState();
}

class _NeoBrutalistHexLoaderState extends State<NeoBrutalistHexLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: NeoBrutalistTheme.surface,
        borderRadius: NeoBrutalistTheme.standardRadius,
        border: Border.all(color: NeoBrutalistTheme.slateBorder, width: 2.5),
        boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Telemetry Header
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.statusText.toUpperCase(),
                style: NeoBrutalistTheme.fontHeaderMonolith.copyWith(
                  color: const Color(0xFFF8FAFC),
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NeoBrutalistTheme.amberRune,
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  'YÜKLENİYOR',
                  style: NeoBrutalistTheme.fontBadge.copyWith(
                    color: const Color(0xFF020617),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Painted Animated Polygon & Hexagon Monolith
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _NeoHexagonPainter(progress: _controller.value),
              );
            },
          ),
          const SizedBox(height: 16),

          // Segmented Rectangular Progress Bar
          if (widget.showProgressTrack) ...[
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return _buildSegmentedProgress(_controller.value);
              },
            ),
            const SizedBox(height: 12),
          ],

          // Subtext Readout
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: NeoBrutalistTheme.accentGreen,
                  shape: BoxShape.rectangle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.subText,
                style: NeoBrutalistTheme.fontTelemetry.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgress(double progress) {
    const int totalSegments = 8;
    final int activeIndex = (progress * totalSegments * 2).floor() % totalSegments;

    return Container(
      height: 14,
      width: widget.size * 2.2,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: NeoBrutalistTheme.bgDark,
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: NeoBrutalistTheme.slateBorder, width: 1.5),
      ),
      child: Row(
        children: List.generate(totalSegments, (index) {
          final bool isActive = index <= activeIndex;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isActive
                    ? (index == activeIndex ? NeoBrutalistTheme.primaryGold : NeoBrutalistTheme.amberRune)
                    : const Color(0xFF1E293B),
                borderRadius: const BorderRadius.all(Radius.circular(1.0)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 3D İzometrik Voksel Karo, Kadim Tamga & Uçuşan Kaynak Küpleri Çizici
class _NeoHexagonPainter extends CustomPainter {
  final double progress;

  _NeoHexagonPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h * 0.52;

    final rw = w * 0.44;
    final rh = h * 0.24;
    final extrudeH = h * 0.18;

    // 1. 3D Sol Kaya Duvarı (Extruded Bedrock Left Wall)
    final leftWallPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final wallBorderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final leftWallPath = Path()
      ..moveTo(cx - rw, cy)
      ..lineTo(cx, cy + rh)
      ..lineTo(cx, cy + rh + extrudeH)
      ..lineTo(cx - rw, cy + extrudeH)
      ..close();
    canvas.drawPath(leftWallPath, leftWallPaint);
    canvas.drawPath(leftWallPath, wallBorderPaint);

    // 2. 3D Sağ Kaya Duvarı (Extruded Bedrock Right Wall)
    final rightWallPaint = Paint()
      ..color = const Color(0xFF090D1A)
      ..style = PaintingStyle.fill;

    final rightWallPath = Path()
      ..moveTo(cx, cy + rh)
      ..lineTo(cx + rw, cy)
      ..lineTo(cx + rw, cy + extrudeH)
      ..lineTo(cx, cy + rh + extrudeH)
      ..close();
    canvas.drawPath(rightWallPath, rightWallPaint);
    canvas.drawPath(rightWallPath, wallBorderPaint);

    // 3. İzometrik Üst Yüzey (Isometric Top Face)
    final topFacePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final topBorderPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final topPath = Path()
      ..moveTo(cx, cy - rh)
      ..lineTo(cx + rw, cy)
      ..lineTo(cx, cy + rh)
      ..lineTo(cx - rw, cy)
      ..close();
    canvas.drawPath(topPath, topFacePaint);
    canvas.drawPath(topPath, topBorderPaint);

    // 4. İç İzometrik Girinti (Inner Steppe Inset)
    final inW = rw * 0.72;
    final inH = rh * 0.72;
    final inPath = Path()
      ..moveTo(cx, cy - inH)
      ..lineTo(cx + inW, cy)
      ..lineTo(cx, cy + inH)
      ..lineTo(cx - inW, cy)
      ..close();
    final inFillPaint = Paint()..color = const Color(0xFF0F172A);
    final inBorderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(inPath, inFillPaint);
    canvas.drawPath(inPath, inBorderPaint);

    // 5. Kadim Göktürk Kağanlık Tamgası (Pulsing Center Tamga Rune)
    final pulse = 0.8 + 0.25 * math.sin(progress * 2 * math.pi).abs();
    final runePaint = Paint()
      ..color = Color.lerp(const Color(0xFFD97706), const Color(0xFFFFC700), pulse)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final runeH = rh * 0.55;
    final runeW = inW * 0.45;

    // Omurga çizgisi
    canvas.drawLine(Offset(cx, cy - runeH), Offset(cx, cy + runeH), runePaint);
    // Üst Kağan Yayı
    final topBow = Path()
      ..moveTo(cx - runeW, cy - runeH * 0.4)
      ..lineTo(cx, cy - runeH)
      ..lineTo(cx + runeW, cy - runeH * 0.4);
    canvas.drawPath(topBow, runePaint);
    // Orta Kut Dalı
    canvas.drawLine(Offset(cx - runeW * 0.7, cy), Offset(cx + runeW * 0.7, cy), runePaint);
    // Alt Dağ / Tengri Çapası
    final bottomAnchor = Path()
      ..moveTo(cx - runeW, cy + runeH * 0.4)
      ..lineTo(cx, cy + runeH)
      ..lineTo(cx + runeW, cy + runeH * 0.4);
    canvas.drawPath(bottomAnchor, runePaint);

    // 6. Üç Adet Uçuşan İzometrik Kaynak Voksel Küpü (Floating Voxel Cubes)
    _drawVoxelCube(
      canvas,
      Offset(cx - rw * 0.6, cy - rh * 1.1 + math.sin(progress * 2 * math.pi) * 4),
      size: w * 0.09,
      topColor: const Color(0xFFFBBF24),
      leftColor: const Color(0xFFD97706),
      rightColor: const Color(0xFFB45309),
    );

    _drawVoxelCube(
      canvas,
      Offset(cx, cy - rh * 1.6 + math.sin(progress * 2 * math.pi + 1.2) * 5),
      size: w * 0.095,
      topColor: const Color(0xFF34D399),
      leftColor: const Color(0xFF10B981),
      rightColor: const Color(0xFF047857),
    );

    _drawVoxelCube(
      canvas,
      Offset(cx + rw * 0.6, cy - rh * 1.1 + math.sin(progress * 2 * math.pi + 2.4) * 4),
      size: w * 0.09,
      topColor: const Color(0xFF60A5FA),
      leftColor: const Color(0xFF3B82F6),
      rightColor: const Color(0xFF1D4ED8),
    );
  }

  void _drawVoxelCube(
    Canvas canvas,
    Offset pos, {
    required double size,
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
  }) {
    final strokePaint = Paint()
      ..color = const Color(0xFF020617)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dx = size * 0.866;
    final dy = size * 0.5;

    // Top
    final topPath = Path()
      ..moveTo(pos.dx, pos.dy - dy)
      ..lineTo(pos.dx + dx, pos.dy)
      ..lineTo(pos.dx, pos.dy + dy)
      ..lineTo(pos.dx - dx, pos.dy)
      ..close();
    canvas.drawPath(topPath, Paint()..color = topColor);
    canvas.drawPath(topPath, strokePaint);

    // Left
    final leftPath = Path()
      ..moveTo(pos.dx - dx, pos.dy)
      ..lineTo(pos.dx, pos.dy + dy)
      ..lineTo(pos.dx, pos.dy + dy + size)
      ..lineTo(pos.dx - dx, pos.dy + size)
      ..close();
    canvas.drawPath(leftPath, Paint()..color = leftColor);
    canvas.drawPath(leftPath, strokePaint);

    // Right
    final rightPath = Path()
      ..moveTo(pos.dx, pos.dy + dy)
      ..lineTo(pos.dx + dx, pos.dy)
      ..lineTo(pos.dx + dx, pos.dy + size)
      ..lineTo(pos.dx, pos.dy + dy + size)
      ..close();
    canvas.drawPath(rightPath, Paint()..color = rightColor);
    canvas.drawPath(rightPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _NeoHexagonPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
