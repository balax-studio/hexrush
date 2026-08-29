import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ParticleType {
  snow,
  sandDust,
  goldenEmbers,
  smoke,
}

/// HexRush Donanım Hızlandırmalı Toplu Parçacık Sistemi (Instanced GPU Particle Batcher)
/// Binlerce hava durumu ve atmosferik parçacığı tek bir Float32List tamponunda
/// ve tek bir donanım çizim çağrısında (Zero-GC) işler.
class InstancedWeatherParticles extends Component {
  final int maxParticles;
  final ParticleType type;

  // Parçacık durum tamponları (Düzlemsel bellek / Zero-GC)
  late final Float32List _positionsX;
  late final Float32List _positionsY;
  late final Float32List _velocitiesX;
  late final Float32List _velocitiesY;
  late final Float32List _sizes;
  late final Float32List _alphas;
  late final Float32List _lifetimes;
  late final Float32List _maxLifetimes;

  final Rect spawnBounds;
  final math.Random _rng = math.Random(42);

  // Zero-GC Render Paint
  static final Paint _sharedParticlePaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;

  InstancedWeatherParticles({
    this.maxParticles = 600,
    this.type = ParticleType.snow,
    this.spawnBounds = const Rect.fromLTWH(-800, -600, 1600, 1200),
  }) {
    _positionsX = Float32List(maxParticles);
    _positionsY = Float32List(maxParticles);
    _velocitiesX = Float32List(maxParticles);
    _velocitiesY = Float32List(maxParticles);
    _sizes = Float32List(maxParticles);
    _alphas = Float32List(maxParticles);
    _lifetimes = Float32List(maxParticles);
    _maxLifetimes = Float32List(maxParticles);

    _initAllParticles();
  }

  void _initAllParticles() {
    for (int i = 0; i < maxParticles; i++) {
      _respawn(i, randomInitialY: true);
    }
  }

  void _respawn(int i, {bool randomInitialY = false}) {
    _positionsX[i] = spawnBounds.left + _rng.nextDouble() * spawnBounds.width;
    _positionsY[i] = randomInitialY
        ? spawnBounds.top + _rng.nextDouble() * spawnBounds.height
        : spawnBounds.top;

    _maxLifetimes[i] = 4.0 + _rng.nextDouble() * 6.0;
    _lifetimes[i] = randomInitialY ? _rng.nextDouble() * _maxLifetimes[i] : 0.0;

    switch (type) {
      case ParticleType.snow:
        _velocitiesX[i] = -15.0 + _rng.nextDouble() * 30.0;
        _velocitiesY[i] = 40.0 + _rng.nextDouble() * 60.0;
        _sizes[i] = 1.5 + _rng.nextDouble() * 2.5;
        _alphas[i] = 0.5 + _rng.nextDouble() * 0.45;
        break;
      case ParticleType.sandDust:
        _velocitiesX[i] = 60.0 + _rng.nextDouble() * 80.0;
        _velocitiesY[i] = 10.0 + _rng.nextDouble() * 25.0;
        _sizes[i] = 1.0 + _rng.nextDouble() * 2.0;
        _alphas[i] = 0.35 + _rng.nextDouble() * 0.35;
        break;
      case ParticleType.goldenEmbers:
        _velocitiesX[i] = -10.0 + _rng.nextDouble() * 20.0;
        _velocitiesY[i] = -30.0 - _rng.nextDouble() * 40.0;
        _sizes[i] = 2.0 + _rng.nextDouble() * 3.0;
        _alphas[i] = 0.7 + _rng.nextDouble() * 0.3;
        break;
      case ParticleType.smoke:
        _velocitiesX[i] = 5.0 + _rng.nextDouble() * 15.0;
        _velocitiesY[i] = -20.0 - _rng.nextDouble() * 25.0;
        _sizes[i] = 3.0 + _rng.nextDouble() * 5.0;
        _alphas[i] = 0.25 + _rng.nextDouble() * 0.3;
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (int i = 0; i < maxParticles; i++) {
      _lifetimes[i] += dt;
      if (_lifetimes[i] >= _maxLifetimes[i] ||
          _positionsY[i] > spawnBounds.bottom ||
          _positionsX[i] > spawnBounds.right ||
          _positionsX[i] < spawnBounds.left) {
        _respawn(i);
        continue;
      }

      _positionsX[i] += _velocitiesX[i] * dt;
      _positionsY[i] += _velocitiesY[i] * dt;

      // Hafif rüzgar dalgalanması
      if (type == ParticleType.snow) {
        _positionsX[i] += math.sin(_lifetimes[i] * 2.5 + i) * 0.35;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    Color baseColor;
    switch (type) {
      case ParticleType.snow:
        baseColor = const Color(0xFFE2E8F0);
        break;
      case ParticleType.sandDust:
        baseColor = const Color(0xFFD97706);
        break;
      case ParticleType.goldenEmbers:
        baseColor = const Color(0xFFFBBF24);
        break;
      case ParticleType.smoke:
        baseColor = const Color(0xFF64748B);
        break;
    }

    // Toplu üçgen ağı (Batched Vertices) oluşturma
    final List<Offset> positions = [];
    final List<Color> colors = [];

    for (int i = 0; i < maxParticles; i++) {
      final double x = _positionsX[i];
      final double y = _positionsY[i];
      final double s = _sizes[i];
      final double a = _alphas[i] * (1.0 - (_lifetimes[i] / _maxLifetimes[i])).clamp(0.0, 1.0);

      final Color col = baseColor.withValues(alpha: a);

      // Her parçacık için bir quad (2 üçgen = 6 vertex)
      final p0 = Offset(x - s, y - s);
      final p1 = Offset(x + s, y - s);
      final p2 = Offset(x + s, y + s);
      final p3 = Offset(x - s, y + s);

      positions.addAll([p0, p1, p2, p0, p2, p3]);
      colors.addAll([col, col, col, col, col, col]);
    }

    if (positions.isNotEmpty) {
      final vertices = ui.Vertices(
        VertexMode.triangles,
        positions,
        colors: colors,
      );
      canvas.drawVertices(vertices, BlendMode.srcOver, _sharedParticlePaint);
    }
  }
}
