import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class OfflineGainsDialog extends ConsumerWidget {
  final OfflineGainsResult gains;
  final IAdRewardService? adService;

  const OfflineGainsDialog({
    super.key,
    required this.gains,
    this.adService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);

    final currentWatches =
        gameState.adTracking.getWatchCount(AdRewardType.offlineProgressBoost);
    final maxWatches =
        EconomyCalculator.getMaxDailyWatches(AdRewardType.offlineProgressBoost);
    final bool canWatchAd = currentWatches < maxWatches;

    final hours = gains.seconds ~/ 3600;
    final minutes = (gains.seconds % 3600) ~/ 60;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: NeoBrutalistTheme.surface,
          borderRadius: NeoBrutalistTheme.standardRadius,
          border: Border.all(color: const Color(0xFFD97706), width: 2.5),
          boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Row(
              children: [
                const GameVectorIcon(
                  type: GameIconType.food,
                  size: 20,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'BOZKIR ÇEVRİMDIŞI KAZANCI',
                    style: NeoBrutalistTheme.fontHeaderMonolith.copyWith(
                      color: const Color(0xFFD97706),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Otağ ve toygunların yokluğunda ${hours > 0 ? '$hours saat ' : ''}$minutes dakika boyunca üretim yaptı.',
              style: NeoBrutalistTheme.fontLabel.copyWith(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),

            // Kaynak Izgarası
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF060913),
                borderRadius: NeoBrutalistTheme.standardRadius,
                border: Border.all(color: const Color(0xFF334155), width: 1.5),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (gains.food > 0)
                    _ResourcePill(
                      icon: GameIconType.food,
                      label: 'Gıda',
                      amount: gains.food,
                    ),
                  if (gains.wood > 0)
                    _ResourcePill(
                      icon: GameIconType.wood,
                      label: 'Odun',
                      amount: gains.wood,
                    ),
                  if (gains.stone > 0)
                    _ResourcePill(
                      icon: GameIconType.stone,
                      label: 'Taş',
                      amount: gains.stone,
                    ),
                  if (gains.iron > 0)
                    _ResourcePill(
                      icon: GameIconType.iron,
                      label: 'Demir',
                      amount: gains.iron,
                    ),
                  if (gains.flour > 0)
                    _ResourcePill(
                      icon: GameIconType.flour,
                      label: 'Un',
                      amount: gains.flour,
                    ),
                  if (gains.plank > 0)
                    _ResourcePill(
                      icon: GameIconType.plank,
                      label: 'Kereste',
                      amount: gains.plank,
                    ),
                  if (gains.bread > 0)
                    _ResourcePill(
                      icon: GameIconType.bread,
                      label: 'Ekmek',
                      amount: gains.bread,
                    ),
                  if (gains.furniture > 0)
                    _ResourcePill(
                      icon: GameIconType.furniture,
                      label: 'Eşya',
                      amount: gains.furniture,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Aksiyon Butonları
            Row(
              children: [
                // Standart Topla
                Expanded(
                  flex: 2,
                  child: TactileNeoButton(
                    height: 38,
                    backgroundColor: const Color(0xFF1E293B),
                    onTap: () {
                      notifier.state = notifier.state.copyWith(
                        resources: notifier.state.resources.copyWith(
                          food: notifier.state.resources.food + gains.food,
                          wood: notifier.state.resources.wood + gains.wood,
                          flour: notifier.state.resources.flour + gains.flour,
                          plank: notifier.state.resources.plank + gains.plank,
                          bread: notifier.state.resources.bread + gains.bread,
                          furniture:
                              notifier.state.resources.furniture + gains.furniture,
                          stone: notifier.state.resources.stone + gains.stone,
                          iron: notifier.state.resources.iron + gains.iron,
                        ),
                        activeToast: 'Bozkır kazancı ambara aktarıldı.',
                      );
                      notifier.saveGame();
                      Navigator.of(context).pop();
                    },
                    child: const Center(
                      child: Text(
                        'TOPLA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 1.5x Reklamlı Bereketli Topla
                Expanded(
                  flex: 3,
                  child: TactileNeoButton(
                    height: 38,
                    backgroundColor: canWatchAd
                        ? const Color(0xFFD97706)
                        : const Color(0xFF475569),
                    isEnabled: canWatchAd,
                    onTap: () async {
                      final boosted =
                          EconomyCalculator.calculateOfflineAdBoostedGains(gains);
                      final success = await notifier.claimAdReward(
                        AdRewardType.offlineProgressBoost,
                        adService: adService,
                      );
                      if (success && context.mounted) {
                        notifier.state = notifier.state.copyWith(
                          resources: notifier.state.resources.copyWith(
                            food: notifier.state.resources.food + boosted.food,
                            wood: notifier.state.resources.wood + boosted.wood,
                            flour: notifier.state.resources.flour + boosted.flour,
                            plank: notifier.state.resources.plank + boosted.plank,
                            bread: notifier.state.resources.bread + boosted.bread,
                            furniture:
                                notifier.state.resources.furniture + boosted.furniture,
                            stone: notifier.state.resources.stone + boosted.stone,
                            iron: notifier.state.resources.iron + boosted.iron,
                          ),
                          activeToast: 'Kervan bereketiyle 1.5x kazanç sağlandı!',
                        );
                        notifier.saveGame();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Center(
                      child: Text(
                        canWatchAd
                            ? '1.5X TOPLA ($currentWatches/$maxWatches)'
                            : 'LİMİT DOLDU ($maxWatches/$maxWatches)',
                        style: TextStyle(
                          color: canWatchAd ? Colors.black : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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

class _ResourcePill extends StatelessWidget {
  final GameIconType icon;
  final String label;
  final double amount;

  const _ResourcePill({
    required this.icon,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameVectorIcon(type: icon, size: 14, color: const Color(0xFFF59E0B)),
        const SizedBox(width: 4),
        Text(
          '+${amount.toStringAsFixed(1)} $label',
          style: const TextStyle(
            color: Color(0xFFF1F5F9),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
