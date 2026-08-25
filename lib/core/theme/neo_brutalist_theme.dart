import 'package:flutter/material.dart';

/// Neo-Brutalist & Arkeolojik Bozkır Tema Veri Modeli
class NeoBrutalistThemeData {
  final String id;
  final String nameTr;
  final String titleTr;
  final Color bgDark;
  final Color surface;
  final Color surfaceLight;
  final Color slateBorder;
  final Color border;
  final Color borderLight;
  final Color primaryGold;
  final Color amberRune;
  final Color accentColor;
  final Color shadowColor;

  const NeoBrutalistThemeData({
    required this.id,
    required this.nameTr,
    required this.titleTr,
    required this.bgDark,
    required this.surface,
    required this.surfaceLight,
    required this.slateBorder,
    required this.border,
    required this.borderLight,
    required this.primaryGold,
    required this.amberRune,
    required this.accentColor,
    required this.shadowColor,
  });

  List<BoxShadow> hardShadow({double offset = 3.0}) => [
        BoxShadow(
          color: shadowColor,
          offset: Offset(offset, offset),
          blurRadius: 0.0,
        ),
      ];

  List<BoxShadow> get hardShadowSmall => [
        BoxShadow(
          color: shadowColor,
          offset: const Offset(2.0, 2.0),
          blurRadius: 0.0,
        ),
      ];
}

/// Neo-Brutalist & Arkeolojik Bozkır Tasarım Sistemi Tokenları
class NeoBrutalistTheme {
  // Palet 1: Kadim Bazalt & Bozkır Kehribarı (Varsayılan / Obabaşı & Göçer)
  static const NeoBrutalistThemeData basaltTheme = NeoBrutalistThemeData(
    id: 'basalt',
    nameTr: 'KADİM BAZALT',
    titleTr: 'Bozkır Göçeri',
    bgDark: Color(0xFF060913),
    surface: Color(0xFF0F172A),
    surfaceLight: Color(0xFF1E293B),
    slateBorder: Color(0xFF334155),
    border: Colors.black,
    borderLight: Color(0xFF64748B),
    primaryGold: Color(0xFFFFC700),
    amberRune: Color(0xFFD97706),
    accentColor: Color(0xFFD97706),
    shadowColor: Colors.black,
  );

  // Palet 2: Kızıl Kurgan & Kanlı Demir (Tarkan / Akıncı)
  static const NeoBrutalistThemeData kurganTheme = NeoBrutalistThemeData(
    id: 'kurgan',
    nameTr: 'KIZIL KURGAN',
    titleTr: 'Bozkır Fatihi / Tarkan',
    bgDark: Color(0xFF0B0507),
    surface: Color(0xFF1A0B10),
    surfaceLight: Color(0xFF2E1018),
    slateBorder: Color(0xFF4C0519),
    border: Colors.black,
    borderLight: Color(0xFF991B1B),
    primaryGold: Color(0xFFF97316),
    amberRune: Color(0xFFDC2626),
    accentColor: Color(0xFFDC2626),
    shadowColor: Colors.black,
  );

  // Palet 3: Altay Yeşimi & Kutsal Kayın (Yabgu / Ulu Bilge / Kervan Başı)
  static const NeoBrutalistThemeData jadeTheme = NeoBrutalistThemeData(
    id: 'jade',
    nameTr: 'ALTAY YEŞİMİ',
    titleTr: 'Kervan Başı / Yabgu',
    bgDark: Color(0xFF040D0A),
    surface: Color(0xFF0B1F17),
    surfaceLight: Color(0xFF133629),
    slateBorder: Color(0xFF064E3B),
    border: Colors.black,
    borderLight: Color(0xFF059669),
    primaryGold: Color(0xFF34D399),
    amberRune: Color(0xFF10B981),
    accentColor: Color(0xFF10B981),
    shadowColor: Colors.black,
  );

  // Palet 4: Gök Tengri & Lapis Lazuli (Şad / Zud Ustası)
  static const NeoBrutalistThemeData tengriTheme = NeoBrutalistThemeData(
    id: 'tengri',
    nameTr: 'GÖK TENGRİ',
    titleTr: 'Zud Ustası / Şad',
    bgDark: Color(0xFF030712),
    surface: Color(0xFF0C1830),
    surfaceLight: Color(0xFF152A54),
    slateBorder: Color(0xFF1E3A8A),
    border: Colors.black,
    borderLight: Color(0xFF2563EB),
    primaryGold: Color(0xFF38BDF8),
    amberRune: Color(0xFF0284C7),
    accentColor: Color(0xFF38BDF8),
    shadowColor: Colors.black,
  );

  // Palet 5: Altın Orda Monoliti & İlteriş Kut (Büyük Kağan)
  static const NeoBrutalistThemeData khaganTheme = NeoBrutalistThemeData(
    id: 'khagan',
    nameTr: 'ALTIN KAĞANLIK',
    titleTr: 'Büyük Kağan',
    bgDark: Color(0xFF000000),
    surface: Color(0xFF171206),
    surfaceLight: Color(0xFF2B200A),
    slateBorder: Color(0xFF78350F),
    border: Colors.black,
    borderLight: Color(0xFFB45309),
    primaryGold: Color(0xFFFDE047),
    amberRune: Color(0xFFF59E0B),
    accentColor: Color(0xFFF59E0B),
    shadowColor: Colors.black,
  );

  static const List<NeoBrutalistThemeData> allPalettes = [
    basaltTheme,
    kurganTheme,
    jadeTheme,
    tengriTheme,
    khaganTheme,
  ];

  static NeoBrutalistThemeData getTheme(String? id) {
    switch (id) {
      case 'kurgan':
        return kurganTheme;
      case 'jade':
        return jadeTheme;
      case 'tengri':
        return tengriTheme;
      case 'khagan':
        return khaganTheme;
      case 'basalt':
      default:
        return basaltTheme;
    }
  }

  // Geriye dönük uyumluluk için varsayılan statik sabitler
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
