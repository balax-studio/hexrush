import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/utils/number_formatter.dart';
import 'package:hex_rush/domain/economy/economy_calculator.dart';

void main() {
  group('NumberFormatter & Compact Formatting Tests', () {
    test('Formats values under 1000 with exact precision', () {
      expect(NumberFormatter.format(0), equals('0'));
      expect(NumberFormatter.format(5), equals('5'));
      expect(NumberFormatter.format(42), equals('42'));
      expect(NumberFormatter.format(42.5), equals('42.5'));
      expect(NumberFormatter.format(999), equals('999'));
    });

    test('Formats thousands with K suffix', () {
      expect(NumberFormatter.format(1000), equals('1K'));
      expect(NumberFormatter.format(1200), equals('1.2K'));
      expect(NumberFormatter.format(15000), equals('15K'));
      expect(NumberFormatter.format(25500), equals('25.5K'));
      expect(NumberFormatter.format(999000), equals('999K'));
    });

    test('Formats millions with M suffix', () {
      expect(NumberFormatter.format(1000000), equals('1M'));
      expect(NumberFormatter.format(2500000), equals('2.5M'));
      expect(NumberFormatter.format(125000000), equals('125M'));
    });

    test('Formats billions, trillions, and high-order tiers', () {
      expect(NumberFormatter.format(1000000000), equals('1B'));
      expect(NumberFormatter.format(3400000000), equals('3.4B'));
      expect(NumberFormatter.format(1e12), equals('1T'));
      expect(NumberFormatter.format(2.5e15), equals('2.5Qa'));
      expect(NumberFormatter.format(4.2e18), equals('4.2Qi'));
      expect(NumberFormatter.format(7.8e21), equals('7.8Sx'));
      expect(NumberFormatter.format(9.1e24), equals('9.1Sp'));
      expect(NumberFormatter.format(5.5e27), equals('5.5Oc'));
      expect(NumberFormatter.format(6.3e30), equals('6.3No'));
      expect(NumberFormatter.format(8.9e33), equals('8.9Dc'));
    });

    test('Handles negative numbers and explicit signs', () {
      expect(NumberFormatter.format(-220), equals('-220'));
      expect(NumberFormatter.format(-1500), equals('-1.5K'));
      expect(NumberFormatter.format(-2500000), equals('-2.5M'));
      expect(NumberFormatter.format(1000, explicitSign: true), equals('+1K'));
      expect(NumberFormatter.format(-1000, explicitSign: true), equals('-1K'));
    });

    test('formatRate adds units and proper sign', () {
      expect(NumberFormatter.formatRate(0), equals('0.00/sn'));
      expect(NumberFormatter.formatRate(250), equals('+250/sn'));
      expect(NumberFormatter.formatRate(-220), equals('-220/sn'));
      expect(NumberFormatter.formatRate(1200), equals('+1.2K/sn'));
      expect(NumberFormatter.formatRate(1000000), equals('+1M/sn'));
      expect(NumberFormatter.formatRate(-5000000), equals('-5M/sn'));
    });

    test('EconomyCalculator.formatCompactNumber delegates correctly', () {
      expect(EconomyCalculator.formatCompactNumber(1000), equals('1K'));
      expect(EconomyCalculator.formatCompactNumber(2500000), equals('2.5M'));
    });
  });
}
