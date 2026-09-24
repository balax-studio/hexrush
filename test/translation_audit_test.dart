import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/localization/game_localization.dart';

void main() {
  test('Audit all translation keys across tr, en, es, de', () {
    final trKeys = GameLocalization.getAllKeysForLanguage('tr').toSet();
    final enKeys = GameLocalization.getAllKeysForLanguage('en').toSet();
    final esKeys = GameLocalization.getAllKeysForLanguage('es').toSet();
    final deKeys = GameLocalization.getAllKeysForLanguage('de').toSet();

    final allKeys = {...trKeys, ...enKeys, ...esKeys, ...deKeys};

    final missingInTr = allKeys.difference(trKeys);
    final missingInEn = allKeys.difference(enKeys);
    final missingInEs = allKeys.difference(esKeys);
    final missingInDe = allKeys.difference(deKeys);

    // ignore_for_file: avoid_print
    print('=== TRANSLATION AUDIT RESULTS ===');
    print('Total Unique Keys: ${allKeys.length}');
    print('Keys in TR: ${trKeys.length}');
    print('Keys in EN: ${enKeys.length}');
    print('Keys in ES: ${esKeys.length}');
    print('Keys in DE: ${deKeys.length}');

    if (missingInTr.isNotEmpty) {
      print('\n--- MISSING IN TR (${missingInTr.length}) ---');
      for (final k in missingInTr) {
        print('  $k');
      }
    }

    if (missingInEn.isNotEmpty) {
      print('\n--- MISSING IN EN (${missingInEn.length}) ---');
      for (final k in missingInEn) {
        print('  $k');
      }
    }

    if (missingInEs.isNotEmpty) {
      print('\n--- MISSING IN ES (${missingInEs.length}) ---');
      for (final k in missingInEs) {
        print('  $k');
      }
    }

    if (missingInDe.isNotEmpty) {
      print('\n--- MISSING IN DE (${missingInDe.length}) ---');
      for (final k in missingDe) {
        print('  $k');
      }
    }

    // Check for keys where value in en/es/de is equal to key name (fallback behavior or unlocalized)
    final langs = ['tr', 'en', 'es', 'de'];
    for (final lang in langs) {
      final unlocalized = <String>[];
      for (final key in allKeys) {
        final val = GameLocalization.get(key, lang: lang);
        if (val == key) {
          unlocalized.add(key);
        }
      }
      if (unlocalized.isNotEmpty) {
        print('\n--- UNLOCALIZED/FALLBACK TO KEY IN $lang (${unlocalized.length}) ---');
        for (final k in unlocalized) {
          print('  $k');
        }
      }
    }
  });
}
