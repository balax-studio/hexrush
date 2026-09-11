import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/localization/game_localization.dart';

void main() {
  test('Find keys in en, es, de that are EXACT copies of tr values', () {
    final trKeys = GameLocalization.getAllKeysForLanguage('tr');

    // Words/terms that are expected to be identical in TR and EN/ES/DE (acronyms, proper nouns, brand names)
    final identicalAllowed = <String>{
      'language', // TR / Language / Idioma / Sprache - wait, 'language' key
      'tr',
      'en',
      'es',
      'de',
      'ok',
      'cancel',
      'close',
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

      if (enVal == trVal && trVal.length > 2) {
        exactCopiesEn[key] = trVal;
      }
      if (esVal == trVal && trVal.length > 2) {
        exactCopiesEs[key] = trVal;
      }
      if (deVal == trVal && trVal.length > 2) {
        exactCopiesDe[key] = trVal;
      }
    }

    print('=== EXACT TR COPIES IN EN (${exactCopiesEn.length}) ===');
    exactCopiesEn.forEach((k, v) => print('  EN "$k": "$v"'));

    print('=== EXACT TR COPIES IN ES (${exactCopiesEs.length}) ===');
    exactCopiesEs.forEach((k, v) => print('  ES "$k": "$v"'));

    print('=== EXACT TR COPIES IN DE (${exactCopiesDe.length}) ===');
    exactCopiesDe.forEach((k, v) => print('  DE "$k": "$v"'));
  });
}
