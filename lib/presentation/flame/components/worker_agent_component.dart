import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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

  late double _speed;
  late double _loadDuration;
  late double _unloadDuration;

  WorkerState _state = WorkerState.walkingToCastle;
  double _progress = 0.0;
  double _stateTimer = 0.0;
  double _walkAnim = 0.0;

  WorkerAgentComponent({
    required this.startPos,
    required this.endPos,
    this.cargoColor = const Color(0xFFFBBF24),
    double speed = 0.26,
    this.seed = 0,
  }) : super(
          position: startPos.clone(),
          size: Vector2(24, 24),
          anchor: Anchor.center,
          priority: 2500, // Top layer above tiles
        ) {
    // Koordinat tohumuna (seed) göre farklı yürüme hızı ve duraklama süreleri
    final double speedVariance = ((seed % 11) - 5) * 0.012;
    _speed = (speed + speedVariance).clamp(0.18, 0.36);
    _loadDuration = 0.8 + ((seed * 7) % 8) * 0.12;
    _unloadDuration = 0.6 + ((seed * 13) % 7) * 0.1;

    // İlk açılışta tüm işçilerin aynı noktada olmaması için rastgele faz kaydırma
    _progress = ((seed * 37) % 100) / 100.0;
    if ((seed % 2) == 0) {
      _state = WorkerState.walkingToCastle;
    } else {
      _state = WorkerState.walkingToBuilding;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (_state) {
      case WorkerState.walkingToCastle:
        _walkAnim += dt * 10.0;
        _progress += dt * _speed;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _state = WorkerState.unloadingAtCastle;
          _stateTimer = 0.0;
        }
        break;

      case WorkerState.unloadingAtCastle:
        _walkAnim += dt * 2.0; // Şatoda dururken hafif nefes/bekleme
        _stateTimer += dt;
        if (_stateTimer >= _unloadDuration) {
          _state = WorkerState.walkingToBuilding;
          _stateTimer = 0.0;
        }
        break;

      case WorkerState.walkingToBuilding:
        _walkAnim += dt * 10.0;
        _progress -= dt * _speed;
        if (_progress <= 0.0) {
          _progress = 0.0;
          _state = WorkerState.loadingAtBuilding;
          _stateTimer = 0.0;
        }
        break;

      case WorkerState.loadingAtBuilding:
        _walkAnim += dt * 3.5; // Hammadde yükleme/çalışma ritmi
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
    final Offset center = Offset(size.x / 2, size.y / 2);
    final bool hasCargo = _state == WorkerState.walkingToCastle || _state == WorkerState.unloadingAtCastle;

    VoxelIsometricRenderer.drawVoxelWorker(
      canvas,
      center,
      cargoColor: cargoColor,
      walkAnim: _walkAnim,
      hasCargo: hasCargo,
    );
  }
}
