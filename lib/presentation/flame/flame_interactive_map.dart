import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentState = ref.read(gameStateProvider);
        _game.syncGameState(currentState);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sync Riverpod state changes to the Flame Game instance
    ref.listen(gameStateProvider, (prev, next) {
      _game.syncGameState(next);
    });

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

              // Tek parmak veya fare sürüklemesinde her zaman kaydırma (Pan) yap
              if (details.pointerCount <= 1) {
                _game.panCamera(delta);
              } else {
                // Çok parmaklı dokunmada hem kaydır hem yakınlaştır (Pinch-to-zoom)
                _game.panCamera(delta);
                if ((details.scale - 1.0).abs() > 0.005) {
                  final double zoomDelta = (details.scale - 1.0) * 0.05;
                  _game.zoomCamera(zoomDelta);
                }
              }
            },
            child: ClipRect(
              child: GameWidget(
                game: _game,
                backgroundBuilder: (context) {
                  final activePalette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
                  final theme = NeoBrutalistTheme.getTheme(activePalette);
                  return Container(
                    color: theme.bgDark,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
