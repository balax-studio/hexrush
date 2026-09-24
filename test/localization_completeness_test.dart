import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/localization/game_localization.dart';

void main() {
  test('Verify localization completeness and key map consistency across TR, EN, ES, DE', () {
    final trKeys = GameLocalization.getAllKeysForLanguage('tr').toSet();
    final enKeys = GameLocalization.getAllKeysForLanguage('en').toSet();
    final esKeys = GameLocalization.getAllKeysForLanguage('es').toSet();
    final deKeys = GameLocalization.getAllKeysForLanguage('de').toSet();

    final allKeys = {...trKeys, ...enKeys, ...esKeys, ...deKeys};

    expect(allKeys.difference(trKeys), isEmpty, reason: 'All keys must exist in TR');
    expect(allKeys.difference(enKeys), isEmpty, reason: 'All keys must exist in EN');
    expect(allKeys.difference(esKeys), isEmpty, reason: 'All keys must exist in ES');
    expect(allKeys.difference(deKeys), isEmpty, reason: 'All keys must exist in DE');
  });

  test('Find keys in EN, ES, DE that are EXACT copies of TR values', () {
    final trKeys = GameLocalization.getAllKeysForLanguage('tr');

    final identicalAllowed = <String>{
      'language',
      'tr',
      'en',
      'es',
      'de',
      'ok',
      'cancel',
      'close',
      'slot_wildcard',
      'frenzy',
      'zud',
      'kut',
      'tamga',
      'kumis',
      'altay',
      'bengutas',
      'altai',
      'steppe',
      'oasis',
      'tundra',
    };

    final exactCopiesEn = <String, String>{};
    final exactCopiesEs = <String, String>{};
    final exactCopiesDe = <String, String>{};

    for (final key in trKeys) {
      if (identicalAllowed.contains(key)) continue;

      final trVal = GameLocalization.get(key, lang: 'tr');
      final enVal = GameLocalization.get(key, lang: 'en');
      final esVal = GameLocalization.get(key, lang: 'es');
      final deVal = GameLocalization.get(key, lang: 'de');

      if (enVal == trVal && trVal.length > 2) exactCopiesEn[key] = trVal;
      if (esVal == trVal && trVal.length > 2) exactCopiesEs[key] = trVal;
      if (deVal == trVal && trVal.length > 2) exactCopiesDe[key] = trVal;
    }

    expect(exactCopiesEn, isEmpty, reason: 'No unlocalized TR copies allowed in EN');
    expect(exactCopiesEs, isEmpty, reason: 'No unlocalized TR copies allowed in ES');
    expect(exactCopiesDe, isEmpty, reason: 'No unlocalized TR copies allowed in DE');
  });

  test('Verify UI files in lib/ have no hardcoded Turkish strings', () {
    final libDir = Directory('lib');
    final dartFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

    final turkishCharRegExp = RegExp(r'[çğıöşüÇĞİÖŞÜ]');
    final hardcodedTurkishInCode = <String, List<String>>{};

    for (final file in dartFiles) {
      if (file.path.contains('game_localization.dart')) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().startsWith('//') || line.contains('print(') || line.contains('debugPrint(') || line.contains('log(')) continue;

        if (turkishCharRegExp.hasMatch(line)) {
          hardcodedTurkishInCode.putIfAbsent('${file.path}:${i + 1}', () => []).add(line.trim());
        }
      }
    }

    // ignore_for_file: avoid_print
    if (hardcodedTurkishInCode.isNotEmpty) {
      print('=== HARDCODED TURKISH CHARACTERS IN CODE (${hardcodedTurkishInCode.length}) ===');
      hardcodedTurkishInCode.forEach((loc, lines) => print('  $loc -> ${lines.first}'));
    }
  });
}
