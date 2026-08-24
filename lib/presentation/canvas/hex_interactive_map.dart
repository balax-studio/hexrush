import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../core/hex/hex_math.dart';
import '../providers/game_state_notifier.dart';
import 'hex_grid_painter.dart';

class HexInteractiveMap extends ConsumerStatefulWidget {
  const HexInteractiveMap({super.key});

  @override
  ConsumerState<HexInteractiveMap> createState() => _HexInteractiveMapState();
}

class _HexInteractiveMapState extends ConsumerState<HexInteractiveMap> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details, Size viewportSize) {
    final Matrix4 transform = _transformController.value;
    final Matrix4 inverted = Matrix4.tryInvert(transform) ?? Matrix4.identity();
    final Offset scenePoint =
        MatrixUtils.transformPoint(inverted, details.localPosition);

    // Viewport merkezine göre (0, 0) koordinatı
    final Offset center =
        Offset(viewportSize.width / 2, viewportSize.height / 2);
    final Offset localToCenter = scenePoint - center;

    final HexAxial clickedCoord = HexMath.pixelToHex(localToCenter);

    final gameState = ref.read(gameStateProvider);
    if (gameState.tiles.containsKey(clickedCoord)) {
      ref.read(gameStateProvider.notifier).selectTile(clickedCoord);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = MediaQuery.of(context).size;
        final double w =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : screen.width;
        final double h =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : screen.height;
        final viewportSize = Size(w, h);

        return InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.3,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(2000),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _handleTapUp(details, viewportSize),
            child: CustomPaint(
              size: viewportSize,
              painter: HexGridPainter(
                tiles: gameState.tiles,
                selectedCoord: gameState.selectedCoord,
                currentSeason: gameState.season.current,
              ),
            ),
          ),
        );
      },
    );
  }
}
