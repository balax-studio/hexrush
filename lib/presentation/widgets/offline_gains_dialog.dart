import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../core/utils/number_formatter.dart';
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
    final timeStr = hours > 0
        ? '$hours saat $minutes dakika'
        : (minutes > 0 ? '$minutes dakika' : '${gains.seconds} saniye');

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
            // Üst Karşılama Rozeti
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF451A03),
                borderRadius: NeoBrutalistTheme.standardRadius,
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GameVectorIcon(
                    type: GameIconType.crown,
                    size: 14,
                    color: Color(0xFFFDE047),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'HOŞ GELDİNİZ, BOZKIR KAĞANI',
                    style: NeoBrutalistTheme.fontBadge.copyWith(
                      color: const Color(0xFFFDE047),
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Başlık
            Row(
              children: [
                const GameVectorIcon(
                  type: GameIconType.granary,
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
              'Otağ ve toygunların yokluğunda $timeStr boyunca üretim yaptı.',
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
                  if (gains.fish > 0)
                    _ResourcePill(
                      icon: GameIconType.food,
                      label: 'Balık',
                      amount: gains.fish,
                    ),
                  if (gains.wisdom > 0)
                    _ResourcePill(
                      icon: GameIconType.wisdom,
                      label: 'Bilgelik',
                      amount: gains.wisdom,
                    ),
                  if (gains.kumis > 0)
                    _ResourcePill(
                      icon: GameIconType.kumis,
                      label: 'Kımız',
                      amount: gains.kumis,
                    ),
                  if (gains.felt > 0)
                    _ResourcePill(
                      icon: GameIconType.felt,
                      label: 'Keçe',
                      amount: gains.felt,
                    ),
                  if (gains.damascusSteel > 0)
                    _ResourcePill(
                      icon: GameIconType.damascusSteel,
                      label: 'Şam Çeliği',
                      amount: gains.damascusSteel,
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
                      notifier.claimOfflineGains(gains, isBoosted: false);
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
                      final success = await notifier.claimAdReward(
                        AdRewardType.offlineProgressBoost,
                        adService: adService,
                      );
                      if (success && context.mounted) {
                        await notifier.claimOfflineGains(gains, isBoosted: true);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
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
          '+${NumberFormatter.format(amount, decimals: 1)} $label',
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
