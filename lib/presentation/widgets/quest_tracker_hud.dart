import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/quest_model.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

/// Görev Takip HUD Bileşeni
/// Arkeolojik Bozkır Neo-Brutalizm standartlarına uygun, nefes alan rün parıltılı görev kutusu.
class QuestTrackerHUD extends ConsumerStatefulWidget {
  const QuestTrackerHUD({super.key});

  @override
  ConsumerState<QuestTrackerHUD> createState() => _QuestTrackerHUDState();
}

class _QuestTrackerHUDState extends ConsumerState<QuestTrackerHUD>
    with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;
  late AnimationController _glowController;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _borderColorAnimation = ColorTween(
      begin: const Color(0xFFD97706),
      end: const Color(0xFF10B981),
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(gameStateProvider.select((s) => s.quests));
    final isTr = ref.watch(gameStateProvider.select((s) => s.settings.language == 'tr'));
    final notifier = ref.read(gameStateProvider.notifier);
    final activePalette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final theme = NeoBrutalistTheme.getTheme(activePalette);

    // İlk teslim alınmamış görevi bul
    final activeQuest = quests.firstWhere(
      (q) => !q.isClaimed,
      orElse: () => const QuestModel(
        id: 'done',
        titleTr: 'Bozkırın Hükümdarı',
        titleEn: 'Ruler of the Steppe',
        descriptionTr: 'Mevcut tüm görevler tamamlandı. Bozkır senin hükmünde!',
        descriptionEn: 'All current quests completed. The steppe is yours!',
        type: QuestType.conquerTiles,
        targetAmount: 0,
        currentAmount: 0,
        rewardType: QuestRewardType.food,
        rewardAmount: 0,
        isCompleted: true,
        isClaimed: true,
      ),
    );

    final bool allDone = activeQuest.id == 'done';
    final bool isCompleted = activeQuest.isCompleted && !allDone;
    final double progressRatio = activeQuest.progress;
    final String title = isTr ? activeQuest.titleTr : activeQuest.titleEn;
    final String description =
        isTr ? activeQuest.descriptionTr : activeQuest.descriptionEn;

    // Animasyon Ticker'ı sadece görev tamamlandığında çalıştırılır (60 FPS CPU döngüsünü sıfırlar)
    if (isCompleted) {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      if (_glowController.isAnimating) {
        _glowController.stop();
      }
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _borderColorAnimation,
        builder: (context, child) {
        return Container(
          width: 250,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isCompleted
                  ? (_borderColorAnimation.value ?? theme.accentColor)
                  : theme.border,
              width: isCompleted ? 2.2 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted ? theme.shadowColor : const Color(0xFF020617),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              InkWell(
                onTap: () {
                  TactileAudioService.instance.play(TactileSoundType.tap);
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: isCompleted
                      ? theme.shadowColor
                      : theme.surfaceLight,
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.military_tech_rounded
                            : Icons.explore_rounded,
                        size: 15,
                        color: isCompleted
                            ? theme.primaryGold
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _isCollapsed && !allDone
                              ? '${isTr ? 'GÖREV' : 'QUEST'}: ${activeQuest.currentAmount}/${activeQuest.targetAmount}'
                              : (isTr ? 'GÖREV' : 'OBJECTIVE'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isCompleted
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                      Icon(
                        _isCollapsed
                            ? Icons.expand_more_rounded
                            : Icons.expand_less_rounded,
                        size: 16,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),

              // Body Content
              if (!_isCollapsed)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: NeoBrutalistTheme.fontTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (!allDone) ...[
                        // Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isTr ? 'İlerleme' : 'Progress',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '${activeQuest.currentAmount} / ${activeQuest.targetAmount}',
                              style: NeoBrutalistTheme.fontTelemetry.copyWith(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Container(
                            height: 6,
                            color: theme.surfaceLight,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progressRatio,
                              child: Container(
                                color: activeQuest.isCompleted
                                    ? const Color(0xFF10B981)
                                    : theme.accentColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Reward Section or Tactile Claim Button
                        if (activeQuest.isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: TactileNeoButton(
                              onTap: () {
                                notifier.claimQuestReward(activeQuest.id);
                              },
                              backgroundColor: theme.primaryGold,
                              borderColor: theme.border,
                              shadowColor: theme.shadowColor,
                              shadowOffset: 2.5,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              soundType: TactileSoundType.reward,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.redeem_rounded,
                                    size: 14,
                                    color: Color(0xFF0F172A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isTr
                                        ? 'ÖDÜLÜ AL (+${activeQuest.rewardAmount} ${activeQuest.rewardType.name.toUpperCase()})'
                                        : 'CLAIM (+${activeQuest.rewardAmount} ${activeQuest.rewardType.name.toUpperCase()})',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.surfaceLight,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: theme.slateBorder,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.card_giftcard_rounded,
                                  size: 11,
                                  color: theme.primaryGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isTr
                                      ? 'Ödül: +${activeQuest.rewardAmount} ${activeQuest.rewardType.name.toUpperCase()}'
                                      : 'Reward: +${activeQuest.rewardAmount} ${activeQuest.rewardType.name.toUpperCase()}',
                                  style: NeoBrutalistTheme.fontBadge.copyWith(
                                    color: theme.primaryGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ),
    );
  }
}
