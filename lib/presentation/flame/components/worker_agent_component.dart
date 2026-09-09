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
  Vector2 endPos;         // Hedef konumu (Depo veya Şato)
  final Color cargoColor;
  final int seed;

  double _progress = 0.0; // 0.0 -> 1.0
  WorkerState _state = WorkerState.walkingToCastle;
  double _stateTimer = 0.0;
  double _walkAnim = 0.0;

  double _walkDuration = 12.0;
  static const double _unloadDuration = 3.0; // Sakin boşaltma süresi
  static const double _loadDuration = 3.0;   // Sakin yükleme süresi

  WorkerAgentComponent({
    required this.startPos,
    required this.endPos,
    required this.cargoColor,
    required this.seed,
  }) : super(
          position: startPos.clone(),
          size: Vector2(28, 28),
          anchor: Anchor.center,
          priority: (startPos.y + 1100).toInt(),
        ) {
    // İşçilerin aynı anda hareket etmesini önlemek için deterministik faz kayması
    _progress = (seed % 100) / 100.0;
    _recalculateWalkDuration();
  }

  void _recalculateWalkDuration() {
    final double dist = (endPos - startPos).length;
    // Sakin ve huzurlu yürüyüş temposu: saniyede bir değil, 8-20 saniye aralığında
    _walkDuration = (dist / 16.0).clamp(8.0, 22.0);
  }

  void updateEndPos(Vector2 newEndPos) {
    if (endPos != newEndPos) {
      endPos = newEndPos;
      _recalculateWalkDuration();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Sakin, telaşsız adım salınımı
    _walkAnim += dt * 3.5;

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

    // Dinamik Z-derinlik: Karo ve binaların üzerinde izometrik sıralamayı koru
    priority = (position.y + 1100).toInt();
  }

  @override
  void render(Canvas canvas) {
    // Geniş marjlı Viewport Culling: Harita gezinirken kaybolmayı önle
    final game = findGame();
    if (game is HexMapGame) {
      final Rect bounds = game.visibleWorldBounds;
      if (position.x < bounds.left - 120 ||
          position.x > bounds.right + 120 ||
          position.y < bounds.top - 120 ||
          position.y > bounds.bottom + 120) {
        return;
      }
    }

    final Offset center = Offset(size.x / 2, size.y / 2);
    final bool hasCargo = _state == WorkerState.walkingToCastle || _state == WorkerState.unloadingAtCastle;

    // Yön tespiti (Hareket yönüne göre karakter yönü)
    final bool isMovingToCastle = _state == WorkerState.walkingToCastle || _state == WorkerState.unloadingAtCastle;
    final bool facingLeft = isMovingToCastle ? (endPos.x < startPos.x) : (startPos.x < endPos.x);

    // Eylem durumu tespiti: 0 = yürüme, 1 = çalışma/yük alma, 2 = boşaltma/teslimat
    int actionState = 0;
    if (_state == WorkerState.loadingAtBuilding) {
      actionState = 1;
    } else if (_state == WorkerState.unloadingAtCastle) {
      actionState = 2;
    }

    // Karakterin belirgin ve net seçilebilmesi için %35 ölçeklendirme
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.35, 1.35);

    VoxelIsometricRenderer.drawVoxelWorker(
      canvas,
      Offset.zero,
      cargoColor: cargoColor,
      walkAnim: _walkAnim,
      hasCargo: hasCargo,
      facingLeft: facingLeft,
      seed: seed,
      actionState: actionState,
    );

    canvas.restore();
  }
}
