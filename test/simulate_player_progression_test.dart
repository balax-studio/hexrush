import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/hexpedia_entry_model.dart';

void main() {
  group('Hexpedia Comprehensive Entry & Search Verification Tests', () {
    test('All Hexpedia entries have valid metadata and non-empty content', () {
      final entries = HexpediaRepository.getAllEntries();
      expect(entries.isNotEmpty, isTrue);

      for (final entry in entries) {
        expect(entry.id.isNotEmpty, isTrue);
        expect(entry.titleTr.isNotEmpty, isTrue);
        expect(entry.titleEn.isNotEmpty, isTrue);
        expect(entry.contentTr.isNotEmpty, isTrue);
        expect(entry.contentEn.isNotEmpty, isTrue);
        expect(entry.summaryTr.isNotEmpty, isTrue);
        expect(entry.summaryEn.isNotEmpty, isTrue);
      }
    });

    test('New Migration & Celestial entries exist and provide tactical guidance', () {
      final entries = HexpediaRepository.getAllEntries();
      final ids = entries.map((e) => e.id).toSet();

      expect(ids, contains('migration_prestige_tamga'));
      expect(ids, contains('migration_optimal_timing'));
      expect(ids, contains('seasons_celestial_omens'));
      expect(ids, contains('core_celestial_age'));

      final timing = entries.firstWhere((e) => e.id == 'migration_optimal_timing');
      expect(timing.category, equals(HexpediaCategory.migration));
      expect(timing.contentTr, contains('5 Altın Eşik'));
      expect(timing.contentTr, contains('11.0x'));

      final celestialAge = entries.firstWhere((e) => e.id == 'core_celestial_age');
      expect(celestialAge.category, equals(HexpediaCategory.core));
      expect(celestialAge.contentTr, contains('Göksel Örs'));
      expect(celestialAge.contentTr, contains('Atalar Totemi'));
      expect(celestialAge.contentTr, contains('Prizmatik Rezonatör'));
    });

    test('Search correctly resolves Turkish and English queries for new entries', () {
      final searchResultsTiming = HexpediaRepository.search('göç');
      expect(searchResultsTiming.any((e) => e.id == 'migration_optimal_timing'), isTrue);

      final searchResultsCelestial = HexpediaRepository.search('göksel');
      expect(searchResultsCelestial.any((e) => e.id == 'core_celestial_age'), isTrue);
      expect(searchResultsCelestial.any((e) => e.id == 'seasons_celestial_omens'), isTrue);

      final searchByEnglish = HexpediaRepository.search('celestial');
      expect(searchByEnglish.any((e) => e.id == 'core_celestial_age'), isTrue);
    });
  });
}
