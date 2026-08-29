import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/domain/models/hexpedia_entry_model.dart';
import 'package:hex_rush/presentation/widgets/hexpedia_dialog.dart';

void main() {
  group('Hexpedia Repository & Model Tests', () {
    test('getAllEntries returns comprehensive list with all categories represented', () {
      final entries = HexpediaRepository.getAllEntries();
      expect(entries.isNotEmpty, isTrue);
      expect(entries.length, greaterThanOrEqualTo(10));

      for (final cat in HexpediaCategory.values) {
        if (cat == HexpediaCategory.all) continue;
        final count = entries.where((e) => e.category == cat).length;
        expect(count, greaterThanOrEqualTo(1), reason: 'Category $cat should have at least 1 entry');
      }
    });

    test('search filters entries by Turkish, English and tag keywords', () {
      final caravanTr = HexpediaRepository.search('kervan');
      expect(caravanTr.any((e) => e.id == 'trade_caravan_routes'), isTrue);

      final caravanEn = HexpediaRepository.search('Caravan');
      expect(caravanEn.any((e) => e.id == 'trade_caravan_routes'), isTrue);

      final zudResults = HexpediaRepository.search('zud');
      expect(zudResults.any((e) => e.id == 'seasons_zud_mechanic'), isTrue);

      final symbiosisResults = HexpediaRepository.search('simbiyoz');
      expect(symbiosisResults.any((e) => e.id == 'biome_symbiosis'), isTrue);

      final raidResults = HexpediaRepository.search('akın');
      expect(raidResults.any((e) => e.id == 'defense_horn_of_steppe'), isTrue);

      final watchtowerResults = HexpediaRepository.search('kule');
      expect(watchtowerResults.any((e) => e.id == 'defense_watchtower'), isTrue);

      final wallResults = HexpediaRepository.search('sur');
      expect(wallResults.any((e) => e.id == 'defense_perimeter_walls'), isTrue);
    });

    test('getByCategory filters correctly', () {
      final tradeEntries = HexpediaRepository.getByCategory(HexpediaCategory.trade);
      expect(tradeEntries.every((e) => e.category == HexpediaCategory.trade), isTrue);
      expect(tradeEntries.length, greaterThanOrEqualTo(2));

      final defenseEntries = HexpediaRepository.getByCategory(HexpediaCategory.defense);
      expect(defenseEntries.every((e) => e.category == HexpediaCategory.defense), isTrue);
      expect(defenseEntries.length, greaterThanOrEqualTo(4));
    });

    test('step guide and stats are populated for key mechanics', () {
      final caravanEntry = HexpediaRepository.getAllEntries().firstWhere((e) => e.id == 'trade_caravan_routes');
      expect(caravanEntry.stats.isNotEmpty, isTrue);
      expect(caravanEntry.stepGuideTr.isNotEmpty, isTrue);
      expect(caravanEntry.stepGuideTr.length, greaterThanOrEqualTo(3));
      expect(caravanEntry.tipsTr.isNotEmpty, isTrue);
    });
  });

  group('HexpediaDialog Widget Tests', () {
    testWidgets('renders dialog, title, search box and category tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HexpediaDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and icons
      expect(find.text('HEXPEDIA - BOZKIR ANSİKLOPEDİSİ'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);

      // Check Category tabs exist
      expect(find.text('TÜMÜ'), findsOneWidget);
      expect(find.text('TEMEL MEKANİK'), findsOneWidget);
      expect(find.text('BİYOMLAR & SİMBİYOZ'), findsOneWidget);
      expect(find.text('KERVAN & PAZAR'), findsOneWidget);
    });

    testWidgets('filtering by search input updates displayed entries', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HexpediaDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'kervan hatları');
      await tester.pumpAndSettle();

      expect(find.text('İpek Yolu Kervan Hatları Nasıl Kurulur?'), findsOneWidget);
    });

    testWidgets('expanding and collapsing an entry card works smoothly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HexpediaDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default expanded card contains stats
      expect(find.text('MEKANİK VERİLERİ & FORMÜLLER'), findsWidgets);

      // Tap on the top card title to collapse/expand it
      final cardHeader = find.text('Kağan Otağı & İlerleme');
      expect(cardHeader, findsOneWidget);
      await tester.tap(cardHeader);
      await tester.pumpAndSettle();
    });
  });
}
