import 'package:flutter/material.dart';

/// Neo-Brutalist & Arkeolojik Bozkır Tasarım Sistemi Tokenları
class NeoBrutalistTheme {
  // Arkeolojik Bozkır & Bazalt Renk Paleti
  static const Color bgDark = Color(0xFF060913);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color slateBorder = Color(0xFF334155);
  static const Color border = Color(0xFF000000);
  static const Color borderLight = Color(0xFF64748B);

  // Vurgu & Rün Renkleri
  static const Color primaryGold = Color(0xFFFFC700);
  static const Color amberRune = Color(0xFFD97706);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color frostCyan = Color(0xFF38BDF8);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentRed = Color(0xFFEF4444);

  // Kenarlık & Çerçeve
  static const BorderSide standardBorder = BorderSide(
    color: Colors.black,
    width: 2.0,
  );

  static const BorderSide subtleBorder = BorderSide(
    color: Color(0xFF334155),
    width: 1.5,
  );

  static const BorderSide amberBorder = BorderSide(
    color: Color(0xFFD97706),
    width: 2.0,
  );

  static const BorderRadius standardRadius = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius sharpRadius = BorderRadius.all(Radius.circular(3.0));

  // Neo-Brutalist Sert Gölgeler (Hard 0-Blur Offset Shadows)
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

  static List<BoxShadow> amberShadow = [
    const BoxShadow(
      color: Color(0xFF78350F),
      offset: Offset(3.0, 3.0),
      blurRadius: 0.0,
    ),
  ];

  // Tipografi (Monolith & Monospace Telemetri)
  static const TextStyle fontHeaderMonolith = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.3,
    color: Color(0xFFF8FAFC),
  );

  static const TextStyle fontTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
    color: Colors.white,
  );

  static const TextStyle fontLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
    color: Color(0xFF94A3B8),
  );

  static const TextStyle fontValue = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
    color: Colors.white,
  );

  static const TextStyle fontTelemetry = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.6,
    color: Color(0xFFCBD5E1),
  );

  static const TextStyle fontBadge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.4,
  );

  // Animasyon Eğrileri
  static const Curve springSlideCurve = Curves.easeOutBack;
  static const Curve mechanicalPressCurve = Curves.easeOutQuad;
  static const Duration fastTransition = Duration(milliseconds: 180);
  static const Duration normalTransition = Duration(milliseconds: 320);
}
