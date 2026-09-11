import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class RealmSelectionDialog extends ConsumerWidget {
  const RealmSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final lang = ref.watch(gameStateProvider.select((s) => s.settings.language));
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
                  Expanded(
                    child: Text(
                      GameLocalization.get('realm_selection_title', lang: lang),
                      style: const TextStyle(
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
                    lang: lang,
                    id: 'altay',
                    title: GameLocalization.get('realm_altay_name', lang: lang),
                    subtitle: GameLocalization.get('realm_altay_sub', lang: lang),
                    description: GameLocalization.get('realm_altay_desc', lang: lang),
                    accentColor: const Color(0xFF818CF8),
                    isSelected: currentRealm == 'altay',
                  ),
                  const SizedBox(height: 12),
                  _buildRealmCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    lang: lang,
                    id: 'idil',
                    title: GameLocalization.get('realm_idil_name', lang: lang),
                    subtitle: GameLocalization.get('realm_idil_sub', lang: lang),
                    description: GameLocalization.get('realm_idil_desc', lang: lang),
                    accentColor: const Color(0xFF34D399),
                    isSelected: currentRealm == 'idil',
                  ),
                  const SizedBox(height: 12),
                  _buildRealmCard(
                    context: context,
                    ref: ref,
                    theme: theme,
                    lang: lang,
                    id: 'karakum',
                    title: GameLocalization.get('realm_karakum_name', lang: lang),
                    subtitle: GameLocalization.get('realm_karakum_sub', lang: lang),
                    description: GameLocalization.get('realm_karakum_desc', lang: lang),
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
    required String lang,
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
                    GameLocalization.get('realm_active', lang: lang),
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
                    child: Text(
                      GameLocalization.get('select_realm_btn', lang: lang),
                      style: const TextStyle(
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
