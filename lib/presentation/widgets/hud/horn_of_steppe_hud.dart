import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/tactile_audio_service.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../domain/models/combat_model.dart';
import '../../providers/game_state_notifier.dart';
import '../tactile_neo_button.dart';

class HornOfSteppeHUD extends ConsumerWidget {
  const HornOfSteppeHUD({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combat = ref.watch(gameStateProvider.select((s) => s.combatState));
    final castleLevel = ref.watch(gameStateProvider.select((s) => s.progression.castleLevel));
    final theme = NeoBrutalistTheme.getTheme(
      ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette)),
    );

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: combat.isActiveWave
              ? const Color(0xFF1E1B4B)
              : const Color(0xFF0F172A),
          border: Border.all(
            color: combat.isActiveWave ? const Color(0xFF818CF8) : const Color(0xFF334155),
            width: 2.0,
          ),
          borderRadius: NeoBrutalistTheme.sharpRadius,
          boxShadow: const [
            BoxShadow(color: Color(0xFF020617), offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: combat.isActiveWave
            ? _buildActiveCombatHUD(context, ref, combat, theme)
            : _buildIdleHornHUD(context, ref, combat, castleLevel, theme),
      ),
    );
  }

  Widget _buildActiveCombatHUD(
      BuildContext context, WidgetRef ref, CombatState combat, NeoBrutalistThemeData theme) {
    final double hpRatio = combat.castleHpPercentage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Color(0xFFFDE047), size: 16),
                const SizedBox(width: 4),
                Text(
                  'AKIN SAVAŞI: SEVİYE ${combat.currentWaveTier}',
                  style: const TextStyle(
                    color: Color(0xFFFDE047),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: NeoBrutalistTheme.sharpRadius,
              ),
              child: Text(
                'KALAN: ${combat.remainingEnemyCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.fort, color: Color(0xFF38BDF8), size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF090D16),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xFF334155), width: 1),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: hpRatio.clamp(0.0, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: hpRatio > 0.5
                            ? const Color(0xFF10B981)
                            : (hpRatio > 0.25 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${combat.castleCurrentHp.toInt()} / ${combat.castleMaxHp.toInt()} HP',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdleHornHUD(BuildContext context, WidgetRef ref, CombatState combat, int castleLevel,
      NeoBrutalistThemeData theme) {
    final notifier = ref.read(gameStateProvider.notifier);
    final bool isCastleDestroyed = combat.isCastleDestroyed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.sports_martial_arts, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AKIN BORUSU: SEVİYE ${combat.currentWaveTier}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  isCastleDestroyed
                      ? 'Şato Hasarlı (Onarım Gerekli)'
                      : (combat.maxCompletedWaveTier > 0
                          ? 'En Yüksek: Seviye ${combat.maxCompletedWaveTier}'
                          : 'Bozkır Yağmacılarına Meydan Oku'),
                  style: TextStyle(
                    color: isCastleDestroyed ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (isCastleDestroyed)
          TactileNeoButton(
            onTap: () => notifier.repairCastle(),
            backgroundColor: const Color(0xFFEF4444),
            borderColor: theme.border,
            shadowOffset: 2.0,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.build, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'ŞATOYU ONAR',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          )
        else
          TactileNeoButton(
            onTap: () => notifier.soundSteppeHorn(),
            backgroundColor: const Color(0xFFD97706),
            borderColor: theme.border,
            shadowOffset: 2.0,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            soundType: TactileSoundType.horn,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.campaign, size: 14, color: Colors.black),
                SizedBox(width: 5),
                Text(
                  'BORUYU ÇAL',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
