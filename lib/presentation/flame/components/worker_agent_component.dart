import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../renderers/voxel_isometric_renderer.dart';

class WorkerAgentComponent extends PositionComponent {
  final Vector2 startPos;
  final Vector2 endPos;
  final Color cargoColor;
  final double speed;

  double _progress = 0.0;
  bool _forward = true;
  double _walkAnim = 0.0;

  WorkerAgentComponent({
    required this.startPos,
    required this.endPos,
    this.cargoColor = const Color(0xFFFBBF24),
    this.speed = 0.35,
  }) : super(
          position: startPos.clone(),
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 2500, // Top layer above tiles
        );

  @override
  void update(double dt) {
    super.update(dt);
    _walkAnim += dt * 10.0;

    if (_forward) {
      _progress += dt * speed;
      if (_progress >= 1.0) {
        _progress = 1.0;
        _forward = false;
      }
    } else {
      _progress -= dt * speed;
      if (_progress <= 0.0) {
        _progress = 0.0;
        _forward = true;
      }
    }

    position = startPos + (endPos - startPos) * _progress;
  }

  @override
  void render(Canvas canvas) {
    final Offset center = Offset(size.x / 2, size.y / 2);
    VoxelIsometricRenderer.drawVoxelWorker(
      canvas,
      center,
      cargoColor: cargoColor,
      walkAnim: _walkAnim,
    );
  }
}
