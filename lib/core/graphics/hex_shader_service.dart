import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// HexRush İleri Seviye GPU Shader ve Donanım Hızlandırmalı Render Yöneticisi
class HexShaderService {
  static ui.FragmentProgram? _fogProgram;
  static ui.FragmentProgram? _waterProgram;
  static ui.FragmentProgram? _lavaProgram;
  static ui.FragmentProgram? _frostProgram;
  static ui.FragmentProgram? _crystalProgram;
  static ui.FragmentProgram? _frenzyProgram;
  static ui.FragmentProgram? _dioramaProgram;
  static ui.FragmentProgram? _heatHazeProgram;
  static ui.FragmentProgram? _shockwaveProgram;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;
  static bool get hasFogShader => _fogProgram != null;
  static bool get hasWaterShader => _waterProgram != null;
  static bool get hasLavaShader => _lavaProgram != null;
  static bool get hasFrostShader => _frostProgram != null;
  static bool get hasCrystalShader => _crystalProgram != null;
  static bool get hasFrenzyShader => _frenzyProgram != null;
  static bool get hasDioramaShader => _dioramaProgram != null;
  static bool get hasHeatHazeShader => _heatHazeProgram != null;
  static bool get hasShockwaveShader => _shockwaveProgram != null;

  // Zero-GC Pre-allocated Paint Objects
  static final Paint _fogPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _waterPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _lavaPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _frostPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _crystalPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _frenzyPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _dioramaPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _heatHazePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _shockwavePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _meshPaint = Paint()..style = PaintingStyle.fill;

  /// Asenkron olarak shader programlarını GPU belleğine yükler
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _fogProgram = await ui.FragmentProgram.fromAsset('shaders/fog_of_war.frag');
    } catch (_) {
      _fogProgram = null;
    }

    try {
      _waterProgram = await ui.FragmentProgram.fromAsset('shaders/water_ripple.frag');
    } catch (_) {
      _waterProgram = null;
    }

    try {
      _lavaProgram = await ui.FragmentProgram.fromAsset('shaders/lava_flow.frag');
    } catch (_) {
      _lavaProgram = null;
    }

    try {
      _frostProgram = await ui.FragmentProgram.fromAsset('shaders/frost_freeze.frag');
    } catch (_) {
      _frostProgram = null;
    }

    try {
      _crystalProgram = await ui.FragmentProgram.fromAsset('shaders/crystal_shimmer.frag');
    } catch (_) {
      _crystalProgram = null;
    }

    try {
      _frenzyProgram = await ui.FragmentProgram.fromAsset('shaders/frenzy_aurora.frag');
    } catch (_) {
      _frenzyProgram = null;
    }

    try {
      _heatHazeProgram = await ui.FragmentProgram.fromAsset('shaders/heat_haze.frag');
    } catch (_) {
      _heatHazeProgram = null;
    }

    try {
      _shockwaveProgram = await ui.FragmentProgram.fromAsset('shaders/shockwave_distortion.frag');
    } catch (_) {
      _shockwaveProgram = null;
    }

    try {
      _dioramaProgram = await ui.FragmentProgram.fromAsset('shaders/post_process_diorama.frag');
    } catch (_) {
      _dioramaProgram = null;
    }

    _initialized = true;
  }

  /// Sis (Fog of War) için Fragment Shader boyasını hazırlar
  static Paint? getFogShaderPaint({
    required Size resolution,
    required double time,
    required Offset center,
    required double alpha,
    required double seed,
  }) {
    if (_fogProgram == null) return null;
    try {
      final shader = _fogProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform vec2 uCenter;
      shader.setFloat(3, center.dx);
      shader.setFloat(4, center.dy);
      // uniform float uAlpha;
      shader.setFloat(5, alpha);
      // uniform float uSeed;
      shader.setFloat(6, seed);

      _fogPaint.shader = shader;
      return _fogPaint;
    } catch (_) {
      return null;
    }
  }

  /// Su (Water Ripple) için Fragment Shader boyasını hazırlar
  static Paint? getWaterShaderPaint({
    required Size resolution,
    required double time,
    required Offset center,
    required double alpha,
    required bool isNight,
  }) {
    if (_waterProgram == null) return null;
    try {
      final shader = _waterProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform vec2 uCenter;
      shader.setFloat(3, center.dx);
      shader.setFloat(4, center.dy);
      // uniform float uAlpha;
      shader.setFloat(5, alpha);
      // uniform float uIsNight;
      shader.setFloat(6, isNight ? 1.0 : 0.0);

      _waterPaint.shader = shader;
      return _waterPaint;
    } catch (_) {
      return null;
    }
  }

  /// Magma / Lav (Lava Flow) için Fragment Shader boyasını hazırlar
  static Paint? getLavaShaderPaint({
    required Size resolution,
    required double time,
    double intensity = 1.0,
  }) {
    if (_lavaProgram == null) return null;
    try {
      final shader = _lavaProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform float uIntensity;
      shader.setFloat(3, intensity);

      _lavaPaint.shader = shader;
      return _lavaPaint;
    } catch (_) {
      return null;
    }
  }

  /// Kış / Ayaz Buzlanma (Frost Freeze) için Fragment Shader boyasını hazırlar
  static Paint? getFrostShaderPaint({
    required Size resolution,
    required double time,
    double frostProgress = 1.0,
  }) {
    if (_frostProgram == null) return null;
    try {
      final shader = _frostProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform float uFrostProgress;
      shader.setFloat(3, frostProgress);

      _frostPaint.shader = shader;
      return _frostPaint;
    } catch (_) {
      return null;
    }
  }

  /// Göksel Krater & Kristal Işıması (Crystal Shimmer) için Fragment Shader boyasını hazırlar
  static Paint? getCrystalShaderPaint({
    required Size resolution,
    required double time,
    double prismPower = 1.0,
  }) {
    if (_crystalProgram == null) return null;
    try {
      final shader = _crystalProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform float uPrismPower;
      shader.setFloat(3, prismPower);

      _crystalPaint.shader = shader;
      return _crystalPaint;
    } catch (_) {
      return null;
    }
  }

  /// 10x Toy Coşkusu Altın Aurası (Frenzy Aurora) için Fragment Shader boyasını hazırlar
  static Paint? getFrenzyShaderPaint({
    required Size resolution,
    required double time,
    double intensity = 1.0,
  }) {
    if (_frenzyProgram == null) return null;
    try {
      final shader = _frenzyProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform float uIntensity;
      shader.setFloat(3, intensity);

      _frenzyPaint.shader = shader;
      return _frenzyPaint;
    } catch (_) {
      return null;
    }
  }

  /// Ekran Uzayı Tilt-Shift Diorama & Post-Processing Shader boyasını hazırlar
  static Paint? getDioramaShaderPaint({
    required Size resolution,
    required double time,
    double dioramaStrength = 1.0,
  }) {
    if (_dioramaProgram == null) return null;
    try {
      final shader = _dioramaProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform float uDioramaStrength;
      shader.setFloat(3, dioramaStrength);

      _dioramaPaint.shader = shader;
      return _dioramaPaint;
    } catch (_) {
      return null;
    }
  }

  /// Sıcaklık Titremesi ve Serap Kırılması (Heat Haze) Fragment Shader boyasını hazırlar
  static Paint? getHeatHazeShaderPaint({
    required Size resolution,
    required double time,
    required Offset center,
    double intensity = 1.0,
  }) {
    if (_heatHazeProgram == null) return null;
    try {
      final shader = _heatHazeProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform vec2 uCenter;
      shader.setFloat(3, center.dx);
      shader.setFloat(4, center.dy);
      // uniform float uIntensity;
      shader.setFloat(5, intensity);

      _heatHazePaint.shader = shader;
      return _heatHazePaint;
    } catch (_) {
      return null;
    }
  }

  /// Bozkır Borusu ve Kadim Keşif Şok Dalgası (Shockwave Distortion) Fragment Shader boyasını hazırlar
  static Paint? getShockwaveShaderPaint({
    required Size resolution,
    required double time,
    required Offset center,
    required double progress,
  }) {
    if (_shockwaveProgram == null) return null;
    try {
      final shader = _shockwaveProgram!.fragmentShader();
      // uniform vec2 uResolution;
      shader.setFloat(0, resolution.width);
      shader.setFloat(1, resolution.height);
      // uniform float uTime;
      shader.setFloat(2, time);
      // uniform vec2 uCenter;
      shader.setFloat(3, center.dx);
      shader.setFloat(4, center.dy);
      // uniform float uProgress;
      shader.setFloat(5, progress.clamp(0.0, 1.0));

      _shockwavePaint.shader = shader;
      return _shockwavePaint;
    } catch (_) {
      return null;
    }
  }

  /// Donanım Hızlandırmalı Toplu Üçgen / Mesh Çizimi (Canvas.drawVertices)
  static void drawBatchedVertices(
    Canvas canvas, {
    required ui.Vertices vertices,
    ui.BlendMode blendMode = ui.BlendMode.srcOver,
    Paint? customPaint,
  }) {
    canvas.drawVertices(vertices, blendMode, customPaint ?? _meshPaint);
  }

  /// Test ve geliştirme ortamları için sıfırlama
  static void resetForTesting() {
    _fogProgram = null;
    _waterProgram = null;
    _lavaProgram = null;
    _frostProgram = null;
    _crystalProgram = null;
    _frenzyProgram = null;
    _dioramaProgram = null;
    _heatHazeProgram = null;
    _shockwaveProgram = null;
    _initialized = false;
  }
}
