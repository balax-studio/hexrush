import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_notifier.dart';
import 'hex_map_game.dart';

class FlameInteractiveMap extends ConsumerStatefulWidget {
  const FlameInteractiveMap({super.key});

  @override
  ConsumerState<FlameInteractiveMap> createState() => _FlameInteractiveMapState();
}

class _FlameInteractiveMapState extends ConsumerState<FlameInteractiveMap> {
  late final HexMapGame _game;
  Offset _lastFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _game = HexMapGame(
      onTileSelected: (coord) {
        ref.read(gameStateProvider.notifier).selectTile(coord);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sync Riverpod state changes to the Flame Game instance
    ref.listen(gameStateProvider, (prev, next) {
      _game.syncGameState(next);
    });

    // Initial sync
    final currentState = ref.read(gameStateProvider);
    _game.syncGameState(currentState);

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width,
          constraints.maxHeight.isFinite ? constraints.maxHeight : MediaQuery.of(context).size.height,
        );

        return Listener(
          onPointerSignal: (signal) {
            if (signal is PointerScrollEvent) {
              final double zoomDelta = signal.scrollDelta.dy > 0 ? -0.1 : 0.1;
              _game.zoomCamera(zoomDelta);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              _game.handleTapAtScreenPosition(details.localPosition, size);
            },
            onScaleStart: (details) {
              _lastFocalPoint = details.localFocalPoint;
            },
            onScaleUpdate: (details) {
              final Offset delta = details.localFocalPoint - _lastFocalPoint;
              _lastFocalPoint = details.localFocalPoint;

              if (details.scale == 1.0) {
                // Pan
                _game.panCamera(delta);
              } else {
                // Pinch to Zoom
                final double zoomDelta = (details.scale - 1.0) * 0.05;
                _game.zoomCamera(zoomDelta);
              }
            },
            child: ClipRect(
              child: GameWidget(
                game: _game,
                backgroundBuilder: (context) => Container(
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
