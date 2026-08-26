import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../hex_map_game.dart';
import '../renderers/voxel_isometric_renderer.dart';

enum WorkerState {
  walkingToCastle,
  unloadingAtCastle,
  walkingToBuilding,
  loadingAtBuilding,
}

class WorkerAgentComponent extends PositionComponent {
  final Vector2 startPos; // Bina konumu
  final Vector2 endPos;   // Şato konumu
  final Color cargoColor;
  final int seed;

  double _progress = 0.0; // 0.0 -> 1.0
  WorkerState _state = WorkerState.walkingToCastle;
  double _stateTimer = 0.0;
  double _walkAnim = 0.0;

  static const double _walkDuration = 4.0;
  static const double _unloadDuration = 1.0;
  static const double _loadDuration = 1.0;

  WorkerAgentComponent({
    required this.startPos,
    required this.endPos,
    required this.cargoColor,
    required this.seed,
  }) : super(
          position: startPos.clone(),
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 150,
        ) {
    // İşçilerin aynı anda hareket etmesini önlemek için deterministik faz kayması
    _progress = (seed % 100) / 100.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _walkAnim += dt * 6.0;

    switch (_state) {
      case WorkerState.walkingToCastle:
        _progress += dt / _walkDuration;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _state = WorkerState.unloadingAtCastle;
          _stateTimer = 0.0;
        }
        break;
      case WorkerState.unloadingAtCastle:
        _stateTimer += dt;
        if (_stateTimer >= _unloadDuration) {
          _state = WorkerState.walkingToBuilding;
          _stateTimer = 0.0;
        }
        break;
      case WorkerState.walkingToBuilding:
        _progress -= dt / _walkDuration;
        if (_progress <= 0.0) {
          _progress = 0.0;
          _state = WorkerState.loadingAtBuilding;
          _stateTimer = 0.0;
        }
        break;
      case WorkerState.loadingAtBuilding:
        _stateTimer += dt;
        if (_stateTimer >= _loadDuration) {
          _state = WorkerState.walkingToCastle;
          _stateTimer = 0.0;
        }
        break;
    }

    // Pozisyon interpolasyonu
    position = startPos + (endPos - startPos) * _progress;
  }

  @override
  void render(Canvas canvas) {
    // Frustum / Viewport Culling: Ekran dışındaki işçileri hesaplamadan atla
    final game = findGame();
    if (game is HexMapGame) {
      final Rect bounds = game.visibleWorldBounds;
      if (position.x < bounds.left - 30 ||
          position.x > bounds.right + 30 ||
          position.y < bounds.top - 30 ||
          position.y > bounds.bottom + 30) {
        return;
      }
    }

    final Offset center = Offset(size.x / 2, size.y / 2);
    final bool hasCargo = _state == WorkerState.walkingToCastle || _state == WorkerState.unloadingAtCastle;

    // Yön tespiti (Hareket yönüne göre karakter yönü)
    final bool isMovingToCastle = _state == WorkerState.walkingToCastle || _state == WorkerState.unloadingAtCastle;
    final bool facingLeft = isMovingToCastle ? (endPos.x < startPos.x) : (startPos.x < endPos.x);

    // Eylem durumu tespiti
    int actionState = 0; // 0: yürüme
    if (_state == WorkerState.loadingAtBuilding) {
      actionState = 1; // 1: çalışma / kazma
    } else if (_state == WorkerState.unloadingAtCastle) {
      actionState = 2; // 2: boşaltma / dinlenme
    }

    VoxelIsometricRenderer.drawVoxelWorker(
      canvas,
      center,
      cargoColor: cargoColor,
      walkAnim: _walkAnim,
      hasCargo: hasCargo,
      facingLeft: facingLeft,
      seed: seed,
      actionState: actionState,
    );
  }
}
