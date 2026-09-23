import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/achievement_model.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

class AchievementsDialog extends ConsumerStatefulWidget {
  const AchievementsDialog({super.key});

  @override
  ConsumerState<AchievementsDialog> createState() => _AchievementsDialogState();
}

class _AchievementsDialogState extends ConsumerState<AchievementsDialog> {
  AchievementCategory? _selectedCategory; // null = Tümü

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final lang = gameState.settings.language;
    final theme = NeoBrutalistTheme.getTheme(gameState.settings.activeThemePalette);
    final achievements = gameState.achievements.isNotEmpty
        ? gameState.achievements
        : AchievementCatalog.getInitialList();

    final filtered = _selectedCategory == null
        ? achievements
        : achievements.where((a) => a.category == _selectedCategory).toList();

    final totalCount = achievements.length;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final unclaimedCount = gameState.unclaimedAchievementCount;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFD97706), width: 2.5),
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
            // 1. Üst Başlık Barı (Header)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                border: Border(bottom: BorderSide(color: theme.border, width: 2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF451A03),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.workspace_premium, size: 16, color: Color(0xFFFDE047)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GameLocalization.get('achievements', lang: lang).toUpperCase(),
                          style: TextStyle(
                            color: theme.primaryGold,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          GameLocalization.get('achievements_subtitle', lang: lang),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // İlerleme Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xFFD97706), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          '$unlockedCount / $totalCount',
                          style: const TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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

            // 2. Kategori Filtreleme Çipleri
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF060913),
                border: Border(bottom: BorderSide(color: theme.border, width: 1.5)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(
                      label: GameLocalization.get('all_categories', lang: lang),
                      category: null,
                      theme: theme,
                      badgeCount: unclaimedCount > 0 ? unclaimedCount : null,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryChip(
                      label: GameLocalization.get('category_conquest', lang: lang),
                      category: AchievementCategory.conquest,
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryChip(
                      label: GameLocalization.get('category_industry', lang: lang),
                      category: AchievementCategory.industry,
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryChip(
                      label: GameLocalization.get('category_winter', lang: lang),
                      category: AchievementCategory.winter,
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryChip(
                      label: GameLocalization.get('category_prestige', lang: lang),
                      category: AchievementCategory.prestige,
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryChip(
                      label: GameLocalization.get('category_trade', lang: lang),
                      category: AchievementCategory.trade,
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryChip(
                      label: GameLocalization.get('category_mastery', lang: lang),
                      category: AchievementCategory.mastery,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            // 3. Başarımlar Listesi
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        lang == 'tr' ? 'Bu kategoride başarım bulunamadı.' : 'No achievements in this category.',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ach = filtered[index];
                        return _buildAchievementCard(
                          ach: ach,
                          lang: lang,
                          theme: theme,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required AchievementCategory? category,
    required NeoBrutalistThemeData theme,
    int? badgeCount,
  }) {
    final bool isSelected = _selectedCategory == category;
    return TactileNeoButton(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      backgroundColor: isSelected ? const Color(0xFFD97706) : theme.surfaceLight,
      borderColor: isSelected ? const Color(0xFFFDE047) : theme.border,
      shadowColor: theme.shadowColor,
      shadowOffset: isSelected ? 2.0 : 1.0,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
          if (badgeCount != null && badgeCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required AchievementModel ach,
    required String lang,
    required NeoBrutalistThemeData theme,
  }) {
    final bool isUnlocked = ach.isUnlocked;
    final bool isClaimed = ach.isRewardClaimed;
    final bool canClaim = isUnlocked && !isClaimed;

    final Color cardBg = isUnlocked
        ? const Color(0xFF0F172A)
        : const Color(0xFF090D1A);
    final Color borderCol = isUnlocked
        ? (canClaim ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
        : const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: borderCol, width: isUnlocked ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: isUnlocked ? const Color(0x33000000) : Colors.transparent,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol İkon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: isUnlocked ? const Color(0xFFD97706) : const Color(0xFF334155),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              _getIconForCode(ach.iconCode),
              size: 18,
              color: isUnlocked ? const Color(0xFFFDE047) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 10),

          // Orta Alan: Başlık, Açıklama, İlerleme
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ach.getTitle(lang),
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : const Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Ödül Etiketi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF451A03),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 9, color: Color(0xFFFDE047)),
                          const SizedBox(width: 2),
                          Text(
                            '+${ach.crownReward}',
                            style: const TextStyle(
                              color: Color(0xFFFEF08A),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  ach.getDescription(lang),
                  style: TextStyle(
                    color: isUnlocked ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // İlerleme Çubuğu
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1.5),
                        child: LinearProgressIndicator(
                          value: ach.progressRatio,
                          backgroundColor: const Color(0xFF1E293B),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUnlocked ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ach.currentProgress.toInt()} / ${ach.targetProgress.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Sağ Aksiyon Butonu
          if (canClaim)
            TactileNeoButton(
              onTap: () {
                ref.read(gameStateProvider.notifier).claimAchievementReward(ach.id);
              },
              backgroundColor: const Color(0xFF10B981),
              borderColor: const Color(0xFF6EE7B7),
              shadowColor: theme.shadowColor,
              shadowOffset: 2.0,
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                GameLocalization.get('claim_reward', lang: lang).toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else if (isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF059669), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.done_all, size: 12, color: Color(0xFF34D399)),
                  const SizedBox(width: 2),
                  Text(
                    GameLocalization.get('claimed', lang: lang).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.lock_outline, size: 16, color: Color(0xFF475569)),
            ),
        ],
      ),
    );
  }

  IconData _getIconForCode(String code) {
    switch (code) {
      case 'flag':
        return Icons.flag;
      case 'map':
        return Icons.map;
      case 'crown':
        return Icons.military_tech;
      case 'globe':
        return Icons.public;
      case 'water':
        return Icons.water_drop;
      case 'mountain':
        return Icons.terrain;
      case 'wood':
      case 'wood_pile':
        return Icons.forest;
      case 'food':
        return Icons.grass;
      case 'iron':
      case 'anvil':
        return Icons.construction;
      case 'castle':
        return Icons.fort;
      case 'factory':
        return Icons.precision_manufacturing;
      case 'snowflake':
        return Icons.ac_unit;
      case 'fire':
        return Icons.local_fire_department;
      case 'sun_snow':
        return Icons.wb_sunny;
      case 'horse':
        return Icons.pets;
      case 'seal':
        return Icons.shield;
      case 'scroll':
        return Icons.auto_stories;
      case 'eagle':
        return Icons.flight;
      case 'camel':
      case 'coins':
      case 'chest':
        return Icons.savings;
      case 'lightning':
        return Icons.bolt;
      case 'hammer':
        return Icons.build;
      case 'drum':
        return Icons.music_note;
      default:
        return Icons.workspace_premium;
    }
  }
}
