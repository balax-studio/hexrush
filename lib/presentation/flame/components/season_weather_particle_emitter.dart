import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 4 Mevsim Atmosferik Hava Parçacık Sistemi (Season Weather Particle Emitter)
/// Zero-GC bütçesiyle çalışan; Kışın voksel kar kristalleri ve Zud fırtınası,
/// Güzün dökülen altın yapraklar, Baharda çiçek taç yaprakları ve polenler,
/// Yazın sıcak hava güneş tozu zerreciklerini canlandırır.
class SeasonWeatherParticleEmitter extends Component {
  final int particleCount;
  final math.Random _random = math.Random(42);
  final List<_WeatherParticle> _particles = [];

  String _currentSeason = 'SPRING';
  String _previousSeason = 'SPRING';
  bool isZud = false;
  double _transitionTimer = 0.0;
  static const double _transitionDuration = 2.0;
  double _animTime = 0.0;

  bool isActive = true;

  SeasonWeatherParticleEmitter({this.particleCount = 70});

  @override
  Future<void> onLoad() async {
    _initParticles();
  }

  void setSeason(String newSeason, {bool newIsZud = false}) {
    if (newSeason != _currentSeason || newIsZud != isZud) {
      _previousSeason = _currentSeason;
      _currentSeason = newSeason;
      isZud = newIsZud;
      _transitionTimer = _transitionDuration;
    }
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < particleCount; i++) {
      _particles.add(_WeatherParticle(
        x: (_random.nextDouble() - 0.5) * 1100,
        y: (_random.nextDouble() - 0.5) * 1100,
        size: _random.nextDouble() * 3.0 + 2.0,
        speedY: _random.nextDouble() * 35 + 25,
        speedX: (_random.nextDouble() - 0.5) * 20,
        opacity: _random.nextDouble() * 0.5 + 0.35,
        seed: _random.nextDouble() * 100.0,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 3.5,
        colorVariant: i % 4,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    _animTime += dt;
    if (_transitionTimer > 0) {
      _transitionTimer = math.max(0.0, _transitionTimer - dt);
    }

    final double speedMult = isZud ? 3.2 : (_currentSeason == 'SUMMER' ? 0.6 : 1.0);

    for (final p in _particles) {
      p.rotation += p.rotationSpeed * dt;

      if (_currentSeason == 'WINTER' || isZud) {
        // Kar ve Tipi Fiziği (Aşağı ve yana doğru rüzgar savrulması)
        final double windSway = math.sin(_animTime * 2.0 + p.seed) * (isZud ? 45.0 : 15.0);
        p.y += p.speedY * speedMult * dt;
        p.x += (p.speedX + windSway) * dt;
      } else if (_currentSeason == 'AUTUMN') {
        // Sonbahar Yaprak Fiziği (Yavaşça salınarak düşen yapraklar)
        final double leafSway = math.sin(_animTime * 2.8 + p.seed) * 28.0;
        p.y += (p.speedY * 0.7) * dt;
        p.x += (p.speedX * 0.5 + leafSway) * dt;
      } else if (_currentSeason == 'SPRING') {
        // Bahar Polen / Çiçek Yaprağı Fiziği (Hafif yukarı ve çapraz süzülme)
        final double breezeX = math.cos(_animTime * 1.5 + p.seed) * 18.0 + 12.0;
        final double breezeY = math.sin(_animTime * 1.8 + p.seed) * 12.0 - 15.0;
        p.y += breezeY * dt;
        p.x += breezeX * dt;
      } else {
        // Yaz Güneş Tozu & Sıcak Hava Zerrecikleri (Ağır ağır yükselen altın zerrecikler)
        final double hazeY = -12.0 + math.sin(_animTime * 1.2 + p.seed) * 6.0;
        final double hazeX = math.cos(_animTime * 1.0 + p.seed) * 8.0;
        p.y += hazeY * dt;
        p.x += hazeX * dt;
      }

      // Sınır Kontrolü ve Yeniden Doğma (Wrap-around boundaries)
      if (p.y > 550) {
        p.y = -550;
        p.x = (_random.nextDouble() - 0.5) * 1100;
      } else if (p.y < -550) {
        p.y = 550;
        p.x = (_random.nextDouble() - 0.5) * 1100;
      }

      if (p.x > 550) {
        p.x = -550;
      } else if (p.x < -550) {
        p.x = 550;
      }
    }
  }

  static final Paint _particlePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _blizzardPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  @override
  void render(Canvas canvas) {
    if (!isActive) return;

    final double blend = _transitionTimer > 0
        ? (1.0 - (_transitionTimer / _transitionDuration)).clamp(0.0, 1.0)
        : 1.0;

    for (final p in _particles) {
      final Color targetColor = _getParticleColor(_currentSeason, isZud, p.colorVariant);
      final Color fromColor = _getParticleColor(_previousSeason, false, p.colorVariant);
      final Color activeColor = Color.lerp(fromColor, targetColor, blend) ?? targetColor;

      _particlePaint.color = activeColor.withValues(alpha: p.opacity);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (_currentSeason == 'WINTER' || isZud) {
        // 3D Voksel Kar Kristali (Elmas / Kare Şeklinde)
        final Rect r = Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size);
        canvas.drawRect(r, _particlePaint);
      } else if (_currentSeason == 'AUTUMN') {
        // Salınan Voksel Yaprak (Huş/Meşe Yaprağı Eşkenar Dörtgeni)
        final Rect r = Rect.fromCenter(center: Offset.zero, width: p.size * 1.5, height: p.size * 0.85);
        canvas.drawRect(r, _particlePaint);
      } else if (_currentSeason == 'SPRING') {
        // Bahar Çiçek Taç Yaprağı (Yumuşak oval voksel)
        final Rect r = Rect.fromCenter(center: Offset.zero, width: p.size * 1.2, height: p.size * 1.2);
        canvas.drawRect(r, _particlePaint);
      } else {
        // Yaz Güneş Tozu Zerreciği (Minik parıltı küpü)
        final Rect r = Rect.fromCenter(center: Offset.zero, width: p.size * 0.9, height: p.size * 0.9);
        canvas.drawRect(r, _particlePaint);
      }

      canvas.restore();
    }

    // Zud Afeti Şiddetli Tipi Rüzgar Çizgileri (Blizzard Wind Streaks)
    if (isZud) {
      _blizzardPaint.color = const Color(0xFFE0F2FE).withValues(alpha: 0.28);
      for (int i = 0; i < 8; i++) {
        final double streakY = -400.0 + (i * 110.0) + math.sin(_animTime * 4.0 + i) * 20.0;
        final double streakX = -450.0 + ((_animTime * 350.0 + i * 150.0) % 950.0);
        canvas.drawLine(
          Offset(streakX, streakY),
          Offset(streakX + 75.0, streakY + 22.0),
          _blizzardPaint,
        );
      }
    }
  }

  Color _getParticleColor(String season, bool zud, int variant) {
    if (zud) {
      switch (variant) {
        case 0:
          return const Color(0xFFF8FAFC);
        case 1:
          return const Color(0xFFBAE6FD);
        case 2:
          return const Color(0xFF38BDF8);
        default:
          return const Color(0xFFE2E8F0);
      }
    }

    switch (season) {
      case 'WINTER':
        switch (variant) {
          case 0:
            return const Color(0xFFFFFFFF);
          case 1:
            return const Color(0xFFF1F5F9);
          case 2:
            return const Color(0xFFE2E8F0);
          default:
            return const Color(0xFFBAE6FD);
        }
      case 'AUTUMN':
        switch (variant) {
          case 0:
            return const Color(0xFFF59E0B); // Amber
          case 1:
            return const Color(0xFFD97706); // Koyu Altın
          case 2:
            return const Color(0xFFEA580C); // Kızıl Yaprak
          default:
            return const Color(0xFFB45309); // Bakır
        }
      case 'SPRING':
        switch (variant) {
          case 0:
            return const Color(0xFFF472B6); // Gelincik / Çiçek Pembesi
          case 1:
            return const Color(0xFFFDE047); // Polen Sarısı
          case 2:
            return const Color(0xFFFFFFFF); // Beyaz Taç Yaprağı
          default:
            return const Color(0xFF86EFAC); // Taze Yeşil Filiz
        }
      case 'SUMMER':
      default:
        switch (variant) {
          case 0:
            return const Color(0xFFFDE047); // Güneş Tozu
          case 1:
            return const Color(0xFFFBBF24); // Kehribar Işıltı
          case 2:
            return const Color(0xFFFEF08A); // Sıcak Parıltı
          default:
            return const Color(0xFFFFD700); // Altın Zerrecik
        }
    }
  }
}

class _WeatherParticle {
  double x;
  double y;
  final double size;
  final double speedY;
  final double speedX;
  final double opacity;
  final double seed;
  double rotation;
  final double rotationSpeed;
  final int colorVariant;

  _WeatherParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.opacity,
    required this.seed,
    required this.rotation,
    required this.rotationSpeed,
    required this.colorVariant,
  });
}
