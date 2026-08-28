import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../../domain/models/combat_model.dart';
import '../../providers/game_state_notifier.dart';

/// Akın Savaşında Ekranın Üstünde Görünen Canlı Savaş HUD'ı
class ActiveRaidCombatHUD extends ConsumerWidget {
  const ActiveRaidCombatHUD({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combat = ref.watch(gameStateProvider.select((s) => s.combatState));
    if (!combat.isActiveWave) {
      return const SizedBox.shrink();
    }

    final double hpRatio = combat.castleHpPercentage;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B4B), // Koyu Gece Laciverti
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(color: const Color(0xFF818CF8), width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF020617),
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Color(0xFFFDE047), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'BOZKIR BASKINI: SEVİYE ${combat.currentWaveTier}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: const Color(0xFF020617), width: 1),
                  ),
                  child: Text(
                    'KALAN DÜŞMAN: ${combat.remainingEnemyCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Şato HP Barı
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
