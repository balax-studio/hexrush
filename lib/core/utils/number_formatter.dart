import 'dart:math' as math;

/// Oyun genelinde matematiksel büyüklükleri kompakt gösterimle (K, M, B, T vb.) biçimlendiren yardımcı sınıf.
class NumberFormatter {
  static const List<String> _suffixes = [
    '',
    'K',
    'M',
    'B',
    'T',
    'Qa',
    'Qi',
    'Sx',
    'Sp',
    'Oc',
    'No',
    'Dc',
    'Ud',
    'Dd',
    'Td',
    'Qad',
    'Qid',
    'Sxd',
    'Spd',
    'Ocd',
    'Nod',
    'Vg',
  ];

  /// Sayıyı kompakt formata dönüştürür (Örn: 950 -> "950", 1200 -> "1.2K", 1000000 -> "1M")
  static String format(
    num value, {
    int decimals = 1,
    bool explicitSign = false,
    bool stripTrailingZeros = true,
  }) {
    if (value.isNaN || value.isInfinite) return '0';

    final double dValue = value.toDouble();
    if (dValue == 0.0) return '0';

    final bool isNegative = dValue < 0;
    final double absVal = dValue.abs();

    String result;

    if (absVal < 1000.0) {
      if (absVal == absVal.roundToDouble()) {
        result = absVal.toInt().toString();
      } else if (absVal >= 100.0) {
        result = absVal.toStringAsFixed(1);
      } else if (absVal >= 10.0) {
        result = absVal.toStringAsFixed(1);
      } else {
        result = absVal.toStringAsFixed(decimals > 0 ? decimals : 1);
      }
    } else {
      // 1000 ve üzeri için log10 tabanlı indeks hesabı
      int tier = (math.log(absVal) / math.ln10 / 3).floor();
      if (tier >= _suffixes.length) {
        tier = _suffixes.length - 1;
      }

      final double scale = math.pow(10.0, tier * 3).toDouble();
      final double scaledValue = absVal / scale;

      // Eğer yuvarlama sonrası 1000 olursa sonraki kademeye geçir
      if (scaledValue >= 999.95 && tier < _suffixes.length - 1) {
        tier++;
        final double nextScale = math.pow(10.0, tier * 3).toDouble();
        result = '${(absVal / nextScale).toStringAsFixed(decimals)}${_suffixes[tier]}';
      } else {
        result = '${scaledValue.toStringAsFixed(decimals)}${_suffixes[tier]}';
      }
    }

    if (stripTrailingZeros && result.contains('.')) {
      // Suffix'i ayır (varsa)
      final match = RegExp(r'^([\d\.]+)([A-Za-z]*)$').firstMatch(result);
      if (match != null) {
        String numPart = match.group(1)!;
        final String suffixPart = match.group(2) ?? '';
        while (numPart.endsWith('0')) {
          numPart = numPart.substring(0, numPart.length - 1);
        }
        if (numPart.endsWith('.')) {
          numPart = numPart.substring(0, numPart.length - 1);
        }
        result = '$numPart$suffixPart';
      }
    }

    if (isNegative) {
      return '-$result';
    } else if (explicitSign && dValue > 0) {
      return '+$result';
    }
    return result;
  }

  /// Saniyelik üretim oranlarını biçimlendirir (Örn: +1.2K/sn, -250/sn)
  static String formatRate(
    num rate, {
    int decimals = 1,
    String unitSuffix = '/sn',
  }) {
    if (rate == 0 || rate.toDouble().abs() < 0.001) {
      return '0.00$unitSuffix';
    }
    final String formatted = format(
      rate,
      decimals: decimals,
      explicitSign: true,
      stripTrailingZeros: true,
    );
    return '$formatted$unitSuffix';
  }
}
