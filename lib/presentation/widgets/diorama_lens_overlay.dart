import 'package:flutter/material.dart';

/// 3D Voxel Diorama için Minyatür Lens & Tilt-Shift Atmosfer Efekti
class DioramaLensOverlay extends StatelessWidget {
  const DioramaLensOverlay({super.key});

  @override
  Widget build(BuildContext context) {
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

          // 2. Üst ve Alt Tilt-Shift Derinlik Gradyanı
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
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
            height: 120,
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
