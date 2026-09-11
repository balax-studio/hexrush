import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';
import 'trade_orders_dialog.dart';
import 'tactile_dialog_route.dart';

class MarketDialog extends ConsumerWidget {
  final IAdRewardService? adService;

  const MarketDialog({super.key, this.adService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final settings = gameState.settings;
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = settings.language;
    final isMerchant = gameState.titles['merchant'] == true;
    final resources = gameState.resources;

    final recipes = EconomyCalculator.getMarketRecipes(
      season: gameState.season.current,
      isZud: gameState.season.isZud,
      isMerchant: isMerchant,
      resources: resources,
    );

    final GameIconType seasonIcon;
    final String seasonName;
    switch (gameState.season.current) {
      case 'SPRING':
        seasonIcon = GameIconType.spring;
        seasonName = GameLocalization.get('spring', lang: lang).toUpperCase();
        break;
      case 'SUMMER':
        seasonIcon = GameIconType.summer;
        seasonName = GameLocalization.get('summer', lang: lang).toUpperCase();
        break;
      case 'AUTUMN':
        seasonIcon = GameIconType.autumn;
        seasonName = GameLocalization.get('autumn', lang: lang).toUpperCase();
        break;
      case 'WINTER':
      default:
        seasonIcon = gameState.season.isZud ? GameIconType.zud : GameIconType.winter;
        seasonName = gameState.season.isZud
            ? (lang == 'tr' ? 'ZUD (AFET)' : 'ZUD BLIZZARD')
            : GameLocalization.get('winter', lang: lang).toUpperCase();
        break;
    }

    final marketTitle = lang == 'tr' ? 'BOZKIR PİYASASI' : 'STEPPE BAZAAR';
    final yearTitle = lang == 'tr' ? 'YIL' : 'YEAR';

    return Dialog(
      backgroundColor: NeoBrutalistTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: NeoBrutalistTheme.standardRadius,
        side: BorderSide(color: Colors.black, width: 2.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NeoBrutalistTheme.surface,
          borderRadius: NeoBrutalistTheme.standardRadius,
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
                    const GameVectorIcon(type: GameIconType.market, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      GameLocalization.get('market_title', lang: lang).toUpperCase(),
                      style: NeoBrutalistTheme.fontHeaderMonolith,
                    ),
                  ],
                ),
                TactileNeoButton(
                  onTap: () => Navigator.of(context).pop(),
                  backgroundColor: const Color(0xFF334155),
                  shadowOffset: 2.0,
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Mevsimsel Piyasa Göstergesi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(color: const Color(0xFF334155), width: 1.2),
                boxShadow: NeoBrutalistTheme.hardShadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GameVectorIcon(type: seasonIcon, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '$marketTitle: $seasonName',
                        style: const TextStyle(
                          color: Color(0xFFFFC700),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$yearTitle ${gameState.season.year}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Gezgin Kervan Ödüllü İkram Bannerı
            Builder(
              builder: (context) {
                final caravanWatches = gameState.adTracking.getWatchCount(AdRewardType.caravanBonus);
                final maxCaravan = EconomyCalculator.getMaxDailyWatches(AdRewardType.caravanBonus);
                final bool canCaravan = caravanWatches < maxCaravan;

                final giftTitle = lang == 'tr' ? 'GEZGİN KERVAN İKRAMI' : 'TRAVELING CARAVAN GIFT';
                final giftDesc = lang == 'tr'
                    ? 'Bozkır tüccarından karşılıksız acil hammadde desteği.'
                    : 'Emergency supplies gift from traveling steppe merchants.';
                final giftBtn = canCaravan
                    ? '${lang == 'tr' ? 'AL' : 'CLAIM'} ($caravanWatches/$maxCaravan)'
                    : (lang == 'tr' ? 'DOLDU' : 'FULL');

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              giftTitle,
                              style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              giftDesc,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TactileNeoButton(
                        height: 30,
                        backgroundColor: canCaravan ? const Color(0xFFD97706) : const Color(0xFF475569),
                        isEnabled: canCaravan,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        onTap: () => notifier.claimAdReward(AdRewardType.caravanBonus, adService: adService),
                        child: Text(
                          giftBtn,
                          style: TextStyle(
                            color: canCaravan ? Colors.black : const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // İpek Yolu Elçi Siparişleri Açma Butonu
            TactileNeoButton(
              onTap: () {
                showNeoTactileDialog<void>(
                  context: context,
                  builder: (_) => const TradeOrdersDialog(),
                );
              },
              backgroundColor: const Color(0xFF451A03),
              borderColor: const Color(0xFFF59E0B),
              shadowOffset: 2.5,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Color(0xFFFDE047)),
                  const SizedBox(width: 8),
                  Text(
                    lang == 'tr' ? 'İPEK YOLU ELÇİ SİPARİŞLERİ' : 'SILK ROAD ENVOY ORDERS',
                    style: const TextStyle(
                      color: Color(0xFFFDE047),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: recipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final r = recipes[index];
                  final bool canAfford = r['canAfford'] as bool? ?? false;
                  final String key = r['key'] as String? ?? '';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(
                        color: canAfford ? const Color(0xFF10B981) : const Color(0xFF334155),
                        width: canAfford ? 1.8 : 1.2,
                      ),
                      boxShadow: NeoBrutalistTheme.hardShadowSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GameVectorIcon(type: _getIconType(r['fromIcon']), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              r['fromAmount'] as String? ?? '',
                              style: NeoBrutalistTheme.fontValue.copyWith(color: const Color(0xFFEF4444)),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.swap_horiz, color: Colors.white, size: 16),
                            ),
                            GameVectorIcon(type: _getIconType(r['toIcon']), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              r['toAmount'] as String? ?? '',
                              style: NeoBrutalistTheme.fontValue.copyWith(color: const Color(0xFF10B981)),
                            ),
                          ],
                        ),
                        TactileNeoButton(
                          onTap: canAfford ? () => notifier.executeMarketTrade(key) : null,
                          backgroundColor: canAfford ? const Color(0xFF10B981) : const Color(0xFF334155),
                          borderColor: Colors.black,
                          shadowOffset: 2.0,
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          child: Text(
                            GameLocalization.get('trade', lang: lang).toUpperCase(),
                            style: TextStyle(
                              color: canAfford ? Colors.black : const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  GameIconType _getIconType(dynamic type) {
    if (type is GameIconType) return type;
    switch (type.toString().toLowerCase()) {
      case 'flour':
        return GameIconType.flour;
      case 'stone':
        return GameIconType.stone;
      case 'bread':
        return GameIconType.bread;
      case 'iron':
        return GameIconType.iron;
      case 'furniture':
        return GameIconType.furniture;
      case 'crowns':
        return GameIconType.crown;
      case 'wood':
      default:
        return GameIconType.wood;
    }
  }
}
