import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../hex_map_game.dart';
import '../renderers/voxel_isometric_renderer.dart';

/// Seyrek Bozkır Ulağı / Kervanı (Steppe Messenger / Wandering Rider)
/// 50-80 saniyede bir otağdan yola çıkarak keşfedilmiş bozkır karolarını gezer.
/// Tamamen Zero-GC, procedural ve asenkron hareket eder.
class SteppeMessengerComponent extends PositionComponent {
  final List<HexAxial> _patrolWaypoints = [];
  int _currentWaypointIndex = 0;

  bool _isActive = false;
  double _spawnTimer = 15.0; // İlk çıkış 15. saniye
  double _animTime = 0.0;
  bool _flipX = false;

  Vector2 _startSegmentPos = Vector2.zero();
  Vector2 _targetSegmentPos = Vector2.zero();
  double _segmentProgress = 0.0;
  double _segmentDuration = 3.0;

  static final Paint _shadowPaint = Paint()
    ..color = const Color(0x33020617)
    ..style = PaintingStyle.fill;

  SteppeMessengerComponent()
      : super(
          size: Vector2(32, 32),
          anchor: Anchor.center,
          priority: 160,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;

    if (!_isActive) {
      _spawnTimer -= dt;
      if (_spawnTimer <= 0.0) {
        _tryStartPatrol();
      }
      return;
    }

    // Aktif devriye hareketi
    _segmentProgress += dt / _segmentDuration;
    if (_segmentProgress >= 1.0) {
      _segmentProgress = 0.0;
      _currentWaypointIndex++;
      if (_currentWaypointIndex >= _patrolWaypoints.length - 1) {
        // Devriye bitti
        _isActive = false;
        _spawnTimer = 50.0 + (math.Random().nextDouble() * 30.0); // 50-80s aralık
        return;
      }
      _advanceToNextSegment();
    }

    final double t = Curves.linear.transform(_segmentProgress);
    position = _startSegmentPos + (_targetSegmentPos - _startSegmentPos) * t;
  }

  void _tryStartPatrol() {
    final game = findGame();
    if (game is! HexMapGame) return;

    final ownedCoords = game.getDiscoveredTileCoords();
    if (ownedCoords.length < 3) {
      _spawnTimer = 20.0;
      return;
    }

    _patrolWaypoints.clear();
    _patrolWaypoints.add(const HexAxial(0, 0)); // Otağ / Merkez

    // Rastgele 3-4 farklı açık karo seç
    final shuffled = List<HexAxial>.from(ownedCoords)..shuffle();
    for (final c in shuffled) {
      if (c != const HexAxial(0, 0) && _patrolWaypoints.length < 5) {
        _patrolWaypoints.add(c);
      }
    }
    _patrolWaypoints.add(const HexAxial(0, 0)); // Geri dönüş

    _currentWaypointIndex = 0;
    _isActive = true;
    _advanceToNextSegment();
  }

  void _advanceToNextSegment() {
    if (_currentWaypointIndex >= _patrolWaypoints.length - 1) return;

    final cA = _patrolWaypoints[_currentWaypointIndex];
    final cB = _patrolWaypoints[_currentWaypointIndex + 1];

    final pA = HexMath.hexToPixel(cA, hexSize: 52.0);
    final pB = HexMath.hexToPixel(cB, hexSize: 52.0);

    _startSegmentPos = Vector2(pA.dx, pA.dy - 6.0);
    _targetSegmentPos = Vector2(pB.dx, pB.dy - 6.0);

    final double dist = _startSegmentPos.distanceTo(_targetSegmentPos);
    _segmentDuration = (dist / 38.0).clamp(1.5, 6.0); // 38 px/s hız
    _segmentProgress = 0.0;
    _flipX = _targetSegmentPos.x < _startSegmentPos.x;
  }

  @override
  void render(Canvas canvas) {
    if (!_isActive) return;

    // Viewport Culling
    final game = findGame();
    if (game is HexMapGame) {
      final Rect bounds = game.visibleWorldBounds;
      if (position.x < bounds.left - 40 ||
          position.x > bounds.right + 40 ||
          position.y < bounds.top - 40 ||
          position.y > bounds.bottom + 40) {
        return;
      }
    }

    final Offset center = Offset(size.x / 2, size.y / 2);

    // Nal Tozu / Hafif Toz İzi
    final double dustPhase = (_animTime * 8.0) % 1.0;
    final double dustX = center.dx + (_flipX ? 12 : -12);
    final double dustY = center.dy + 10;
    canvas.drawCircle(Offset(dustX, dustY), 1.5 * (1.0 - dustPhase), _shadowPaint);

    // Bozkır Atı & Süvari (Doru At, Ulak Pelerini)
    VoxelIsometricRenderer.drawVoxelHorse(
      canvas,
      center,
      animTime: _animTime * 1.6, // Dörtnala koşu ritmi
      scale: 0.85,
      seed: 42,
      flipX: _flipX,
    );

    // Ulak Başlığı & Bayrak Flama
    final double bob = (math.sin(_animTime * 8.0).abs()) * 2.0;
    final Offset riderPos = Offset(center.dx + (_flipX ? 2 : -2), center.dy - 16 - bob);

    // Ulak Gövdesi (Taktik Kürk Kaftan)
    VoxelIsometricRenderer.drawIsoCube(
      canvas,
      riderPos,
      w: 4.5,
      d: 4.5,
      h: 5.0,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF92400E),
    );

    // Ulak Börk (Kürk Şapka)
    VoxelIsometricRenderer.drawIsoCube(
      canvas,
      Offset(riderPos.dx, riderPos.dy - 4.5),
      w: 3.5,
      d: 3.5,
      h: 3.0,
      topColor: const Color(0xFF1E293B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF020617),
    );
  }
}
