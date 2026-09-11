import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/models/celestial_omen_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';
import 'tactile_dialog_route.dart';

class CelestialOmenHud extends ConsumerWidget {
  final IAdRewardService? adService;

  const CelestialOmenHud({super.key, this.adService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final omen = ref.watch(gameStateProvider.select((s) => s.celestialOmen));
    final lang = ref.watch(gameStateProvider.select((s) => s.settings.language));

    IconData getAnimalIcon(CelestialAnimal animal) {
      switch (animal) {
        case CelestialAnimal.rat:
          return Icons.grain;
        case CelestialAnimal.ox:
          return Icons.agriculture;
        case CelestialAnimal.tiger:
          return Icons.park;
        case CelestialAnimal.rabbit:
          return Icons.speed;
        case CelestialAnimal.dragon:
          return Icons.auto_awesome;
        case CelestialAnimal.snake:
          return Icons.healing;
        case CelestialAnimal.horse:
          return Icons.directions_run;
        case CelestialAnimal.sheep:
          return Icons.nature;
        case CelestialAnimal.monkey:
          return Icons.build;
        case CelestialAnimal.rooster:
          return Icons.wb_sunny;
        case CelestialAnimal.dog:
          return Icons.shield;
        case CelestialAnimal.pig:
          return Icons.landscape;
      }
    }

    final title = omen.getTitle(lang);
    final desc = omen.getDescription(lang);

    return Tooltip(
      message: '$title: $desc',
      preferBelow: true,
      child: GestureDetector(
        onTap: () {
          showNeoTactileDialog<void>(
            context: context,
            builder: (ctx) => _ShamanBlessingDialog(adService: adService),
          );
        },
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(color: const Color(0xFFD97706), width: 1.5),
            borderRadius: BorderRadius.circular(3),
            boxShadow: const [
              BoxShadow(color: Color(0xFF020617), offset: Offset(2, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(getAnimalIcon(omen.animal), color: const Color(0xFFF59E0B), size: 14),
              const SizedBox(width: 5),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShamanBlessingDialog extends ConsumerWidget {
  final IAdRewardService? adService;

  const _ShamanBlessingDialog({this.adService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = gameState.settings.language;
    final omen = gameState.celestialOmen;

    final blessingWatches =
        gameState.adTracking.getWatchCount(AdRewardType.celestialBlessing);
    final maxBlessing =
        EconomyCalculator.getMaxDailyWatches(AdRewardType.celestialBlessing);
    final bool canBlessing = blessingWatches < maxBlessing;

    final title = omen.getTitle(lang);
    final desc = omen.getDescription(lang);

    final dialogTitle = lang == 'tr'
        ? 'ŞAMAN KEHANETİ & GÖK BEREKETİ'
        : 'SHAMAN PROPHECY & CELESTIAL BLESSING';

    final activeYearLabel = lang == 'tr'
        ? 'AKTİF YIL: ${title.toUpperCase()}'
        : 'ACTIVE YEAR: ${title.toUpperCase()}';

    final prayerTitle = lang == 'tr'
        ? 'GÖK TENGRİ DUASI (+%25 KUT)'
        : 'PRAYER TO GÖK TENGRİ (+25% GLORY)';

    final prayerDesc = lang == 'tr'
        ? 'Şaman duasıyla tüm toprakların üretim ve bereketini 10 dakika boyunca %25 güçlendir.'
        : 'Empower all production and pasture yields by +25% for 10 minutes through shamanic prayer.';

    final btnText = canBlessing
        ? (lang == 'tr'
            ? 'DUAYI KABUL ET ($blessingWatches/$maxBlessing)'
            : 'ACCEPT PRAYER ($blessingWatches/$maxBlessing)')
        : (lang == 'tr'
            ? 'GÜNLÜK DUA LİMİTİ DOLDU'
            : 'DAILY PRAYER LIMIT REACHED');

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      dialogTitle,
                      style: NeoBrutalistTheme.fontHeaderMonolith.copyWith(
                        color: const Color(0xFFD97706),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                TactileNeoButton(
                  height: 26,
                  width: 26,
                  backgroundColor: const Color(0xFF1E293B),
                  padding: EdgeInsets.zero,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Center(child: Icon(Icons.close, color: Colors.white, size: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF060913),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(color: const Color(0xFF334155), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeYearLabel,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(color: const Color(0xFFD97706), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerTitle,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    prayerDesc,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  TactileNeoButton(
                    height: 32,
                    backgroundColor:
                        canBlessing ? const Color(0xFFD97706) : const Color(0xFF475569),
                    isEnabled: canBlessing,
                    onTap: () async {
                      final success = await notifier.claimAdReward(
                        AdRewardType.celestialBlessing,
                        adService: adService,
                      );
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Center(
                      child: Text(
                        btnText,
                        style: TextStyle(
                          color: canBlessing ? Colors.black : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
