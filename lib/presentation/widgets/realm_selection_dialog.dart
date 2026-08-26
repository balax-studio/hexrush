import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class RealmSelectionDialog extends ConsumerWidget {
  const RealmSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final theme = NeoBrutalistTheme.getTheme(palette);
    final state = ref.watch(gameStateProvider);
    final currentRealm = state.progression.activeRealmId;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.primaryGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                border: Border(bottom: BorderSide(color: theme.border, width: 2)),
              ),
              child: Row(
                children: [
                  const GameVectorIcon(type: GameIconType.land, size: 20, color: Color(0xFFFFD700)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'BÜYÜK GÖÇ SEFER DİYARLARI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    height: 28,
                    width: 28,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    backgroundColor: theme.surfaceLight,
                    borderColor: theme.slateBorder,
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Realms List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildRealmCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    id: 'altay',
                    title: 'ALTAY GÖKSEL PLATOLARI',
                    subtitle: 'Madenler, Taş Ocakları ve Şam Çeliği Bereketi',
                    description: '• Taş, Demir ve Şam Çeliği üretimi 2 Katına çıkar.\n• Dağ ve Krater arazisi fetih maliyetinde %30 indirim.\n• Sert kışlar ve yüksek Kurgan mirası sinerjisi.',
                    accentColor: const Color(0xFF818CF8),
                    isSelected: currentRealm == 'altay',
                  ),
                  const SizedBox(height: 12),
                  _buildRealmCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    id: 'idil',
                    title: 'İDİL-YAYIK NEHİR HAVZASI',
                    subtitle: 'Balıkçılık, Sulak Alanlar ve Kımız Otağı Bereketi',
                    description: '• Balık, Gıda, Un ve Kımız üretimi 2 Katına çıkar.\n• Deniz ve Sazlık arazisi fetih maliyetinde %30 indirim.\n• Nehir ve göl komşuluğunda +%50 bereket rezonansı.',
                    accentColor: const Color(0xFF34D399),
                    isSelected: currentRealm == 'idil',
                  ),
                  const SizedBox(height: 12),
                  _buildRealmCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    id: 'karakum',
                    title: 'KARAKUM & TARIM VAHALARI',
                    subtitle: 'İpek Yolu Kervanları, Pazar Takası ve Keçe Bereketi',
                    description: '• Kervan hızı, Pazar takas karları ve Taç getirisi 2 Katına çıkar.\n• Keçe ve çadır üretimi %50 daha hızlıdır.\n• Çöl ve vaha arazisi fetih maliyetinde %25 indirim.',
                    accentColor: const Color(0xFFF59E0B),
                    isSelected: currentRealm == 'karakum',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealmCard({
    required BuildContext context,
    required WidgetRef ref,
    required NeoBrutalistThemeData theme,
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required Color accentColor,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E293B) : theme.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isSelected ? accentColor : theme.border,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? accentColor : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: accentColor, width: 1),
                  ),
                  child: Text(
                    'AKTİF DİYAR',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 9.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: isSelected
                ? const SizedBox.shrink()
                : TactileNeoButton(
                    onTap: () {
                      ref.read(gameStateProvider.notifier).selectMigrationRealm(id);
                      Navigator.of(context).pop();
                    },
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    backgroundColor: accentColor,
                    borderColor: accentColor,
                    child: const Text(
                      'BU DİYARI SEÇ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
