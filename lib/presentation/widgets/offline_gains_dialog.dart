import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../providers/game_state_notifier.dart';
import 'ad_reward_progress_dialog.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class OfflineGainsDialog extends ConsumerStatefulWidget {
  final OfflineGainsResult gains;
  final IAdRewardService? adService;

  const OfflineGainsDialog({
    super.key,
    required this.gains,
    this.adService,
  });

  @override
  ConsumerState<OfflineGainsDialog> createState() => _OfflineGainsDialogState();
}

class _OfflineGainsDialogState extends ConsumerState<OfflineGainsDialog> {
  int _watchedCount = 0;
  int _multiplier = 1;

  static const int _maxWatches = 3;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = ref.watch(gameStateProvider.select((s) => s.settings.language));

    final bool canWatchAd = _watchedCount < _maxWatches;
    final effectiveGains = widget.gains.multipliedBy(_multiplier.toDouble());

    final hours = widget.gains.seconds ~/ 3600;
    final minutes = (widget.gains.seconds % 3600) ~/ 60;
    final seconds = widget.gains.seconds % 60;

    final hUnit = GameLocalization.get('hours', lang: lang);
    final mUnit = GameLocalization.get('minutes', lang: lang);
    final sUnit = GameLocalization.get('seconds', lang: lang);

    final timeStr = hours > 0
        ? '$hours $hUnit $minutes $mUnit'
        : (minutes > 0 ? '$minutes $mUnit' : '$seconds $sUnit');

    final String subTitle = lang == 'tr'
        ? 'Otağ ve toygunların yokluğunda $timeStr boyunca üretim yaptı.'
        : (lang == 'es'
            ? 'Tu campamento produjo durante $timeStr en tu ausencia.'
            : (lang == 'de'
                ? 'Ihr Lager produzierte $timeStr während Ihrer Abwesenheit.'
                : 'Your realm produced resources for $timeStr in your absence.'));

    final String adBanner = lang == 'tr'
        ? 'BOZKIR BEREKETİ: Reklam izleyerek tüm kaynakları 2 katına çıkarın!'
        : (lang == 'es'
            ? 'BENDICIÓN DE LA ESTEPA: ¡Mira un anuncio para duplicar todos los recursos!'
            : (lang == 'de'
                ? 'STEPPENSEGEN: Verdoppeln Sie alle Ressourcen mit Werbung!'
                : 'STEPPE BLESSING: Watch an ad to double all offline gains!'));

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
                    GameLocalization.get('welcome_khan', lang: lang),
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
                    GameLocalization.get('offline_gains_title', lang: lang),
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
              subTitle,
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
                  if (widget.gains.food > 0)
                    _ResourcePill(
                      icon: GameIconType.food,
                      label: GameLocalization.get('food', lang: lang),
                      amount: effectiveGains.food,
                      baseAmount: widget.gains.food,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.wood > 0)
                    _ResourcePill(
                      icon: GameIconType.wood,
                      label: GameLocalization.get('wood', lang: lang),
                      amount: effectiveGains.wood,
                      baseAmount: widget.gains.wood,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.stone > 0)
                    _ResourcePill(
                      icon: GameIconType.stone,
                      label: GameLocalization.get('stone', lang: lang),
                      amount: effectiveGains.stone,
                      baseAmount: widget.gains.stone,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.iron > 0)
                    _ResourcePill(
                      icon: GameIconType.iron,
                      label: GameLocalization.get('iron', lang: lang),
                      amount: effectiveGains.iron,
                      baseAmount: widget.gains.iron,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.flour > 0)
                    _ResourcePill(
                      icon: GameIconType.flour,
                      label: GameLocalization.get('flour', lang: lang),
                      amount: effectiveGains.flour,
                      baseAmount: widget.gains.flour,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.plank > 0)
                    _ResourcePill(
                      icon: GameIconType.plank,
                      label: GameLocalization.get('plank', lang: lang),
                      amount: effectiveGains.plank,
                      baseAmount: widget.gains.plank,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.bread > 0)
                    _ResourcePill(
                      icon: GameIconType.bread,
                      label: GameLocalization.get('bread', lang: lang),
                      amount: effectiveGains.bread,
                      baseAmount: widget.gains.bread,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.furniture > 0)
                    _ResourcePill(
                      icon: GameIconType.furniture,
                      label: GameLocalization.get('furniture', lang: lang),
                      amount: effectiveGains.furniture,
                      baseAmount: widget.gains.furniture,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.fish > 0)
                    _ResourcePill(
                      icon: GameIconType.food,
                      label: GameLocalization.get('fish', lang: lang),
                      amount: effectiveGains.fish,
                      baseAmount: widget.gains.fish,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.wisdom > 0)
                    _ResourcePill(
                      icon: GameIconType.wisdom,
                      label: GameLocalization.get('wisdom', lang: lang),
                      amount: effectiveGains.wisdom,
                      baseAmount: widget.gains.wisdom,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.kumis > 0)
                    _ResourcePill(
                      icon: GameIconType.kumis,
                      label: GameLocalization.get('kumis', lang: lang),
                      amount: effectiveGains.kumis,
                      baseAmount: widget.gains.kumis,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.felt > 0)
                    _ResourcePill(
                      icon: GameIconType.felt,
                      label: GameLocalization.get('felt', lang: lang),
                      amount: effectiveGains.felt,
                      baseAmount: widget.gains.felt,
                      multiplier: _multiplier,
                    ),
                  if (widget.gains.damascusSteel > 0)
                    _ResourcePill(
                      icon: GameIconType.damascusSteel,
                      label: GameLocalization.get('damascus_steel', lang: lang),
                      amount: effectiveGains.damascusSteel,
                      baseAmount: widget.gains.damascusSteel,
                      multiplier: _multiplier,
                    ),
                ],
              ),
            ),
            if (canWatchAd)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF451A03),
                  borderRadius: NeoBrutalistTheme.standardRadius,
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.0),
                ),
                child: Row(
                  children: [
                    const GameVectorIcon(
                      type: GameIconType.crown,
                      size: 14,
                      color: Color(0xFFFDE047),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        adBanner,
                        style: NeoBrutalistTheme.fontBadge.copyWith(
                          color: const Color(0xFFFDE047),
                          fontSize: 10,
                          letterSpacing: 0.4,
                        ),
                      ),
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
                    onTap: () async {
                      await notifier.claimOfflineGains(effectiveGains);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Center(
                      child: Text(
                        GameLocalization.get('collect', lang: lang).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reklam İzle (2X TOPLA)
                Expanded(
                  flex: 3,
                  child: TactileNeoButton(
                    height: 38,
                    backgroundColor: canWatchAd
                        ? const Color(0xFFD97706)
                        : const Color(0xFF475569),
                    isEnabled: canWatchAd,
                    onTap: () async {
                      final completed = await showAdRewardProgressDialog(
                        context,
                        title: lang == 'tr' ? 'BOZKIR BEREKETİ' : 'STEPPE BLESSING',
                        message: GameLocalization.get('reward_please_wait', lang: lang),
                      );
                      if (completed && context.mounted) {
                        await notifier.claimAdReward(
                          AdRewardType.offlineProgressBoost,
                          adService: widget.adService,
                        );
                        if (mounted) {
                          setState(() {
                            _watchedCount++;
                            _multiplier *= 2;
                          });
                        }
                      }
                    },
                    child: Center(
                      child: Text(
                        canWatchAd
                            ? (lang == 'tr' ? 'REKLAM İZLE ($_watchedCount/$_maxWatches)' : 'WATCH AD ($_watchedCount/$_maxWatches)')
                            : (lang == 'tr' ? 'LİMİT DOLDU ($_maxWatches/$_maxWatches)' : 'MAX REACHED ($_maxWatches/$_maxWatches)'),
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
  final double baseAmount;
  final int multiplier;

  const _ResourcePill({
    required this.icon,
    required this.label,
    required this.amount,
    required this.baseAmount,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    final String amountStr = NumberFormatter.format(amount);
    final String baseStr = NumberFormatter.format(baseAmount);
    final String labelText = multiplier > 1
        ? '+$amountStr $label ($baseStr x $multiplier)'
        : '+$amountStr $label';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(
          color: multiplier > 1 ? const Color(0xFF10B981) : const Color(0xFF334155),
          width: multiplier > 1 ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameVectorIcon(type: icon, size: 14),
          const SizedBox(width: 4),
          Text(
            labelText,
            style: TextStyle(
              color: multiplier > 1 ? const Color(0xFF34D399) : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
