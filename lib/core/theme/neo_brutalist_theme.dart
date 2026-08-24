import 'package:flutter/material.dart';

/// Neo-Brutalist tasarım sistemi tokenları ve sabitleri
class NeoBrutalistTheme {
  // Renk Paleti (Yüksek Kontrast & Doygunluk)
  static const Color bgDark = Color(0xFF0D131F);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF334155);
  static const Color border = Color(0xFF0F172A);
  static const Color borderLight = Color(0xFF64748B);

  // Vurgu Renkleri
  static const Color primaryGold = Color(0xFFFFC700);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentRed = Color(0xFFEF4444);

  // Kenarlık & Çerçeve
  static const BorderSide standardBorder = BorderSide(
    color: Colors.black,
    width: 2.0,
  );

  static const BorderSide subtleBorder = BorderSide(
    color: Color(0xFF475569),
    width: 1.5,
  );

  static const BorderRadius standardRadius = BorderRadius.all(Radius.circular(6.0));
  static const BorderRadius sharpRadius = BorderRadius.all(Radius.circular(3.0));

  // Neo-Brutalist Sert Gölgeler (Hard Offset Shadows)
  static List<BoxShadow> hardShadow({Color color = Colors.black, double offset = 3.0}) => [
        BoxShadow(
          color: color,
          offset: Offset(offset, offset),
          blurRadius: 0.0,
        ),
      ];

  static List<BoxShadow> hardShadowSmall = [
    const BoxShadow(
      color: Colors.black,
      offset: Offset(2.0, 2.0),
      blurRadius: 0.0,
    ),
  ];

  // Tipografi
  static const TextStyle fontTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const TextStyle fontLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: Colors.white70,
  );

  static const TextStyle fontValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
    color: Colors.white,
  );
}
