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

/// Çift Katmanlı Dönen Altıgen & Rün Çizici
class _NeoHexagonPainter extends CustomPainter {
  final double progress;

  _NeoHexagonPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.46;
    final middleRadius = size.width * 0.32;
    final innerRadius = size.width * 0.16;

    // 1. Dış Altıgen (Saat Yönünde Dönen Çerçeve)
    final outerPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final outerPath = _getHexagonPath(center, outerRadius, rotation: progress * 2 * math.pi);
    canvas.drawPath(outerPath, outerPaint);

    // 2. Köşe Vurguları (Altın Dikdörtgen Rünler)
    final dotPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 * math.pi / 180) + (progress * 2 * math.pi);
      final dotPos = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawRect(
        Rect.fromCenter(center: dotPos, width: 4, height: 4),
        dotPaint,
      );
    }

    // 3. Orta Ters Dönen Altıgen
    final middlePaint = Paint()
      ..color = const Color(0xFFFFC700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final middlePath = _getHexagonPath(center, middleRadius, rotation: -progress * 2 * math.pi);
    canvas.drawPath(middlePath, middlePaint);

    // 4. İç Çekirdek Nabız Rünü (Dolu Çokgen)
    final pulseScale = 0.85 + 0.3 * (math.sin(progress * 4 * math.pi).abs());
    final corePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.fill;

    final corePath = _getHexagonPath(center, innerRadius * pulseScale, rotation: progress * math.pi);
    canvas.drawPath(corePath, corePaint);
  }

  Path _getHexagonPath(Offset center, double radius, {double rotation = 0}) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 * math.pi / 180) + rotation;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _NeoHexagonPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
