import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// HexRush GPU Atmosfer ve Mevsim Renk Matrisi Yöneticisi (Impeller ColorFilter Pipeline)
/// Mevsim ve gece/gündüz geçişlerini CPU hesaplamaları yerine donanım hızlandırmalı 4x5 ColorFilter matrisleriyle yürütür.
class GpuAtmosphereColorMatrix {
  // 1. Standart İlkbahar Matrisi (Identity / Doğal Bozkır)
  static const List<double> identityMatrix = <double>[
    1.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];

  // 2. Yaz Güneşi Matrisi (Sıcak Altın Işıltısı ve Canlılık)
  static const List<double> summerMatrix = <double>[
    1.08, 0.02, 0.00, 0.0, 4.0,
    0.02, 1.05, 0.00, 0.0, 2.0,
    0.00, 0.00, 0.92, 0.0, -2.0,
    0.00, 0.00, 0.00, 1.0, 0.0,
  ];

  // 3. Sonbahar Matrisi (Amber, Kızıl-Turuncu Yaprak ve Bozkır Tonu)
  static const List<double> autumnMatrix = <double>[
    1.15, 0.05, -0.05, 0.0, 6.0,
    0.04, 0.95, -0.05, 0.0, -2.0,
    -0.08, -0.04, 0.78, 0.0, -8.0,
    0.00, 0.00, 0.00, 1.0, 0.0,
  ];

  // 4. Kış Matrisi (Buzul Mavisi, Soğuk Çelik ve Ayaz Kontrastı)
  static const List<double> winterMatrix = <double>[
    0.85, 0.00, 0.05, 0.0, -4.0,
    0.00, 0.92, 0.08, 0.0, -2.0,
    0.08, 0.12, 1.22, 0.0, 10.0,
    0.00, 0.00, 0.00, 1.0, 0.0,
  ];

  // 5. Zud Kar Fırtınası Matrisi (Yüksek Parlaklık, Desatürasyon, Sert Mavi/Beyaz)
  static const List<double> zudMatrix = <double>[
    0.72, 0.15, 0.12, 0.0, 14.0,
    0.12, 0.78, 0.16, 0.0, 16.0,
    0.15, 0.18, 1.15, 0.0, 28.0,
    0.00, 0.00, 0.00, 1.0, 0.0,
  ];

  // 6. Gece Matrisi (Derin Lacivert, Ay Işığı Modülasyonu)
  static const List<double> nightMatrix = <double>[
    0.45, 0.00, 0.08, 0.0, -18.0,
    0.00, 0.52, 0.12, 0.0, -14.0,
    0.10, 0.15, 0.78, 0.0, -4.0,
    0.00, 0.00, 0.00, 1.0, 0.0,
  ];

  static final Map<String, ColorFilter> _cachedFilters = {
    'spring': const ColorFilter.matrix(identityMatrix),
    'summer': const ColorFilter.matrix(summerMatrix),
    'autumn': const ColorFilter.matrix(autumnMatrix),
    'winter': const ColorFilter.matrix(winterMatrix),
    'zud': const ColorFilter.matrix(zudMatrix),
    'night': const ColorFilter.matrix(nightMatrix),
  };

  /// Mevcut mevsime ve gece durumuna göre donanım hızlandırmalı ColorFilter döndürür
  static ColorFilter getAtmosphereColorFilter({
    required String seasonName,
    required bool isZud,
    required bool isNight,
  }) {
    if (isNight) return _cachedFilters['night']!;
    if (isZud) return _cachedFilters['zud']!;

    final String s = seasonName.toLowerCase();
    return _cachedFilters[s] ?? _cachedFilters['spring']!;
  }

  /// İki mevsim matrisi arasında dinamik GPU interpolasyonu (4x5 array)
  static ColorFilter lerpAtmosphereMatrix({
    required String fromSeason,
    required String toSeason,
    required double t,
    bool isNight = false,
  }) {
    if (isNight) return _cachedFilters['night']!;
    final double factor = t.clamp(0.0, 1.0);

    final mFrom = _getRawMatrix(fromSeason);
    final mTo = _getRawMatrix(toSeason);

    final List<double> interpolated = List<double>.filled(20, 0.0);
    for (int i = 0; i < 20; i++) {
      interpolated[i] = mFrom[i] + (mTo[i] - mFrom[i]) * factor;
    }

    return ColorFilter.matrix(interpolated);
  }

  static List<double> _getRawMatrix(String seasonName) {
    switch (seasonName.toLowerCase()) {
      case 'summer':
        return summerMatrix;
      case 'autumn':
        return autumnMatrix;
      case 'winter':
        return winterMatrix;
      case 'zud':
        return zudMatrix;
      default:
        return identityMatrix;
    }
  }
}
