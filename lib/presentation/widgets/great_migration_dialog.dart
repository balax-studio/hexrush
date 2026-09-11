import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class GreatMigrationDialog extends ConsumerStatefulWidget {
  const GreatMigrationDialog({super.key});

  @override
  ConsumerState<GreatMigrationDialog> createState() => _GreatMigrationDialogState();
}

class _GreatMigrationDialogState extends ConsumerState<GreatMigrationDialog> {
  bool _isBreakdownExpanded = false;

  void _confirmAndExecuteMigration(
    BuildContext context,
    int newCrowns,
    int newTamgas,
    String lang,
  ) {
    final title = GameLocalization.get('migration_confirm_title', lang: lang);
    final content = GameLocalization.get('migration_confirm_body', lang: lang, args: [
      newCrowns.toString(),
      newTamgas.toString(),
    ]);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: const RoundedRectangleBorder(
          borderRadius: NeoBrutalistTheme.sharpRadius,
          side: BorderSide(color: Color(0xFFEF4444), width: 2.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
          ),
        ),
        actions: [
          TactileNeoButton(
            onTap: () => Navigator.of(ctx).pop(),
            backgroundColor: const Color(0xFF1E293B),
            borderColor: const Color(0xFF475569),
            shadowOffset: 2.0,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              GameLocalization.get('cancel', lang: lang).toUpperCase(),
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          TactileNeoButton(
            onTap: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ref.read(gameStateProvider.notifier).resetGame();
            },
            backgroundColor: const Color(0xFFDC2626),
            borderColor: Colors.black,
            shadowOffset: 2.5,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              GameLocalization.get('confirm_migration_btn', lang: lang),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final palette = gameState.settings.activeThemePalette;
    final theme = NeoBrutalistTheme.getTheme(palette);
    final lang = gameState.settings.language;

    final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
      tiles: gameState.tiles.values,
      resources: gameState.resources,
      castleLevel: gameState.progression.castleLevel,
    );

    final int ownedHexes = gameState.progression.ownedCount;
    final int castleLvl = gameState.progression.castleLevel;
    final bool isEligible = castleLvl >= 5;

    final int newTamgas = 1 + (ownedHexes ~/ 20);
    final double nextKut = gameState.progression.kutMultiplier + 0.25;

    final victories = gameState.progression.victoryMilestones;
    final activeOaths = gameState.progression.activeOaths;
    final selectedRealm = gameState.progression.activeRealmId;

    final headerTitle = GameLocalization.get('migration_header_title', lang: lang);
    final legacyHeader = GameLocalization.get('migration_legacy_header', lang: lang);
    final breakdownTitle = GameLocalization.get('migration_breakdown_title', lang: lang);
    final oathsTitle = GameLocalization.get('migration_oaths_title', lang: lang);
    final targetRealmTitle = GameLocalization.get('migration_target_realm_title', lang: lang);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(color: theme.primaryGold, width: 2.5),
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
            // Üst Başlık Barı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: theme.border, width: 2)),
              ),
              child: Row(
                children: [
                  const GameVectorIcon(type: GameIconType.land, size: 22, color: Color(0xFFFFD700)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headerTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          GameLocalization.get('migration_cycle_subtitle', lang: lang),
                          style: const TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    height: 28,
                    width: 28,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    backgroundColor: const Color(0xFF1E293B),
                    borderColor: theme.slateBorder,
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            // İçerik
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // 1. Kazanılacak Miraslar Özeti
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          legacyHeader,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  GameLocalization.get('crowns_to_gain', lang: lang),
                                  style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+${breakdown.totalCrowns}',
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFF334155)),
                            Column(
                              children: [
                                Text(
                                  GameLocalization.get('ancestral_tamga', lang: lang),
                                  style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+$newTamgas',
                                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFF334155)),
                            Column(
                              children: [
                                Text(
                                  GameLocalization.get('kut_multiplier', lang: lang),
                                  style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${nextKut.toStringAsFixed(2)}x',
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. DETAYLI KAZANIM & KAYNAK DAĞILIM DÖKÜMÜ (BREAKDOWN)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFF334155), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isBreakdownExpanded = !_isBreakdownExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: const Color(0xFF1E293B),
                            child: Row(
                              children: [
                                const Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF38BDF8)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    breakdownTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _isBreakdownExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF94A3B8),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isBreakdownExpanded)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                _buildBreakdownRow(
                                  title: GameLocalization.get('castle_title', lang: lang),
                                  desc: 'Otağ Sv. $castleLvl',
                                  yieldText: '+${breakdown.buildingAndShrineCrowns} Taç',
                                  color: const Color(0xFFFFD700),
                                ),
                                const Divider(color: Color(0xFF334155), height: 8),
                                _buildBreakdownRow(
                                  title: GameLocalization.get('land', lang: lang),
                                  desc: '$ownedHexes Hex Toprak',
                                  yieldText: '+${breakdown.hexCrowns} Taç',
                                  color: const Color(0xFF38BDF8),
                                ),
                                const Divider(color: Color(0xFF334155), height: 8),
                                _buildBreakdownRow(
                                  title: GameLocalization.get('migration_resources_label', lang: lang),
                                  desc: 'Gıda, Odun, Taş, Demir...',
                                  yieldText: '+${breakdown.resourceCrowns} Taç',
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Bengü İl Zafer Rozetleri
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFF475569), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GameLocalization.get('migration_victories_title', lang: lang),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        _buildVictoryRow(GameLocalization.get('migration_victory_bengutas', lang: lang), victories['culturalBenguTas'] == true),
                        _buildVictoryRow(GameLocalization.get('migration_victory_silkroad', lang: lang), victories['silkRoadNetwork'] == true),
                        _buildVictoryRow(GameLocalization.get('migration_victory_realms', lang: lang), victories['realmConquest'] == true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Kutsal Andlar (Meydan Okuma Modifikatörleri)
                  Text(
                    oathsTitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildOathOption(
                    id: 'oath_of_iron',
                    title: GameLocalization.get('migration_oath_iron_title', lang: lang),
                    desc: GameLocalization.get('migration_oath_iron_desc', lang: lang),
                    isSelected: activeOaths.contains('oath_of_iron'),
                  ),
                  const SizedBox(height: 6),
                  _buildOathOption(
                    id: 'oath_of_frost',
                    title: GameLocalization.get('migration_oath_frost_title', lang: lang),
                    desc: GameLocalization.get('migration_oath_frost_desc', lang: lang),
                    isSelected: activeOaths.contains('oath_of_frost'),
                  ),
                  const SizedBox(height: 12),

                  // 5. Hedef Sefer Diyarı Seçimi
                  Text(
                    targetRealmTitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildRealmOption(
                    id: 'great_steppe',
                    title: GameLocalization.get('migration_realm_steppe_title', lang: lang),
                    desc: GameLocalization.get('migration_realm_steppe_desc', lang: lang),
                    color: const Color(0xFFF59E0B),
                    isSelected: selectedRealm == 'great_steppe',
                    lang: lang,
                  ),
                  const SizedBox(height: 6),
                  _buildRealmOption(
                    id: 'silk_road',
                    title: GameLocalization.get('migration_realm_silk_title', lang: lang),
                    desc: GameLocalization.get('migration_realm_silk_desc', lang: lang),
                    color: const Color(0xFF38BDF8),
                    isSelected: selectedRealm == 'silk_road',
                    lang: lang,
                  ),
                  const SizedBox(height: 6),
                  _buildRealmOption(
                    id: 'altay_highlands',
                    title: GameLocalization.get('migration_realm_altay_title', lang: lang),
                    desc: GameLocalization.get('migration_realm_altay_desc', lang: lang),
                    color: const Color(0xFF10B981),
                    isSelected: selectedRealm == 'altay_highlands',
                    lang: lang,
                  ),
                ],
              ),
            ),

            // Alt Aksiyon Barı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(top: BorderSide(color: theme.border, width: 2)),
              ),
              child: Column(
                children: [
                  if (!isEligible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.white70, size: 12),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                GameLocalization.get('migration_not_ready_warning', lang: lang),
                                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TactileNeoButton(
                          onTap: () => Navigator.of(context).pop(),
                          height: 38,
                          backgroundColor: const Color(0xFF1E293B),
                          borderColor: theme.slateBorder,
                          alignment: Alignment.center,
                          child: Text(
                            GameLocalization.get('close', lang: lang).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TactileNeoButton(
                          onTap: isEligible
                              ? () => _confirmAndExecuteMigration(context, breakdown.totalCrowns, newTamgas, lang)
                              : () {
                                  ref.read(gameStateProvider.notifier).showToast(
                                        GameLocalization.get('migration_not_ready_toast', lang: lang),
                                      );
                                },
                          height: 38,
                          backgroundColor: isEligible ? const Color(0xFFDC2626) : const Color(0xFF334155),
                          borderColor: Colors.black,
                          shadowOffset: 2.5,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isEligible ? Icons.flight_takeoff : Icons.lock, color: isEligible ? Colors.white : Colors.white60, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isEligible
                                    ? GameLocalization.get('start_migration_btn', lang: lang)
                                    : GameLocalization.get('migration_locked_btn', lang: lang),
                                style: TextStyle(
                                  color: isEligible ? Colors.white : Colors.white60,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String title,
    required String desc,
    required String yieldText,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              yieldText,
              style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryRow(String title, bool isAchieved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isAchieved ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isAchieved ? const Color(0xFF10B981) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isAchieved ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 9.5,
                fontWeight: isAchieved ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          if (isAchieved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text('+25%', style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 8, fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }

  Widget _buildOathOption({
    required String id,
    required String title,
    required String desc,
    required bool isSelected,
  }) {
    return TactileNeoButton(
      onTap: () {
        ref.read(gameStateProvider.notifier).toggleOath(id);
      },
      height: 38,
      backgroundColor: isSelected ? const Color(0xFF3B0764) : const Color(0xFF1E293B),
      borderColor: isSelected ? const Color(0xFFA855F7) : const Color(0xFF475569),
      shadowOffset: isSelected ? 2.0 : 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16,
            color: isSelected ? const Color(0xFFC084FC) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE9D5FF) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealmOption({
    required String id,
    required String title,
    required String desc,
    required Color color,
    required bool isSelected,
    required String lang,
  }) {
    return TactileNeoButton(
      onTap: () {
        ref.read(gameStateProvider.notifier).selectMigrationRealm(id);
      },
      height: 44,
      backgroundColor: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1E293B),
      borderColor: isSelected ? color : const Color(0xFF475569),
      shadowOffset: isSelected ? 2.5 : 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? color : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                GameLocalization.get('realm_selected_badge', lang: lang),
                style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}
