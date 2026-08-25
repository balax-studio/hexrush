import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_notifier.dart';

/// 3D Voxel Diorama için Minyatür Lens, Tilt-Shift ve Mevsimsel Atmosfer Efekti
class DioramaLensOverlay extends ConsumerWidget {
  const DioramaLensOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final season = gameState.season;
    final bool isWinter = season.current == 'WINTER' || season.isZud;
    final bool isSummer = season.current == 'SUMMER';

    Color seasonTint;
    if (season.isZud) {
      seasonTint = const Color(0xFFEF4444).withValues(alpha: 0.18);
    } else if (isWinter) {
      seasonTint = const Color(0xFF38BDF8).withValues(alpha: 0.15);
    } else if (isSummer) {
      seasonTint = const Color(0xFFFBBF24).withValues(alpha: 0.08);
    } else {
      seasonTint = Colors.transparent;
    }

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Kenar Vinyet Gradyanı (Derinlik & Odak)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF0F172A).withValues(alpha: 0.35),
                  const Color(0xFF020617).withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.55, 0.85, 1.0],
              ),
            ),
          ),

          // 2. Mevsimsel Atmosferik Renk Katmanı
          if (seasonTint != Colors.transparent)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    seasonTint,
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

          // 3. Kış & Zud Buzlanma / Kar Kristali Katmanı (CustomPainter)
          if (isWinter)
            const Positioned.fill(
              child: CustomPaint(
                painter: _WinterFrostPainter(),
              ),
            ),

          // 4. Üst ve Alt Tilt-Shift Derinlik Gradyanı
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF0F172A).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kış ve Zud afeti için köşelerde hafif buzlanma ve kristal çizgileri çizer
class _WinterFrostPainter extends CustomPainter {
  const _WinterFrostPainter();

  static final Paint _frostPaint = Paint()
    ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.3)
    ..strokeWidth = 1.2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    const double cornerSize = 40.0;

    // Sol Üst Köşe Buz Çizgileri
    canvas.drawLine(const Offset(0, 0), const Offset(cornerSize, 0), _frostPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerSize), _frostPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(cornerSize * 0.7, cornerSize * 0.7), _frostPaint);

    // Sağ Üst Köşe Buz Çizgileri
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerSize, 0), _frostPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), _frostPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerSize * 0.7, cornerSize * 0.7), _frostPaint);

    // Sol Alt Köşe Buz Çizgileri
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), _frostPaint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerSize), _frostPaint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize * 0.7, size.height - cornerSize * 0.7), _frostPaint);

    // Sağ Alt Köşe Buz Çizgileri
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerSize, size.height), _frostPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize), _frostPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerSize * 0.7, size.height - cornerSize * 0.7), _frostPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
