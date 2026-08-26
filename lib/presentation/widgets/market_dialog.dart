import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class MarketDialog extends ConsumerWidget {
  final IAdRewardService? adService;

  const MarketDialog({super.key, this.adService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final resources = gameState.resources;
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = gameState.settings.language;
    final isMerchant = gameState.titles['merchant'] == true;

    final recipes = EconomyCalculator.getMarketRecipes(
      season: gameState.season.current,
      isZud: gameState.season.isZud,
      isMerchant: isMerchant,
      resources: resources,
    );

    final GameIconType seasonIcon;
    final String seasonNameTr;
    switch (gameState.season.current) {
      case 'SPRING':
        seasonIcon = GameIconType.spring;
        seasonNameTr = 'İLKBAHAR';
        break;
      case 'SUMMER':
        seasonIcon = GameIconType.summer;
        seasonNameTr = 'YAZ';
        break;
      case 'AUTUMN':
        seasonIcon = GameIconType.autumn;
        seasonNameTr = 'SONBAHAR';
        break;
      case 'WINTER':
      default:
        seasonIcon = gameState.season.isZud ? GameIconType.zud : GameIconType.winter;
        seasonNameTr = gameState.season.isZud ? 'ZUD (AFET)' : 'KIŞ';
        break;
    }

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
                        'BOZKIR PİYASASI: $seasonNameTr',
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
                    'YIL ${gameState.season.year}',
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
                            const Text(
                              'GEZGİN KERVAN İKRAMI',
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Bozkır tüccarından karşılıksız acil hammadde desteği.',
                              style: TextStyle(
                                color: Colors.white.withAlpha(160),
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
                          canCaravan ? 'AL ($caravanWatches/$maxCaravan)' : 'DOLDU',
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
            const SizedBox(height: 10),
            const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: recipes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final r = recipes[i];
                  final bool canAfford = r['canAfford'] as bool;
                  final String key = r['key'] as String;
                  final String seasonTag = r['seasonTag'] as String;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(
                        color: canAfford ? const Color(0xFFFFC700) : const Color(0xFF334155),
                        width: 1.8,
                      ),
                      boxShadow: NeoBrutalistTheme.hardShadowSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GameVectorIcon(type: _getIconType(r['fromIcon']), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    r['fromAmount'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 12, color: Colors.white54),
                                  const SizedBox(width: 6),
                                  GameVectorIcon(type: _getIconType(r['toIcon']), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    r['toAmount'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFFFFC700),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              if (seasonTag.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1B4B),
                                    borderRadius: NeoBrutalistTheme.sharpRadius,
                                    border: Border.all(color: const Color(0xFFA855F7), width: 1.0),
                                  ),
                                  child: Text(
                                    seasonTag,
                                    style: const TextStyle(
                                      color: Color(0xFFC084FC),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                r['desc'] as String,
                                style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TactileNeoButton(
                          onTap: canAfford ? () => notifier.executeMarketTrade(key) : null,
                          isEnabled: canAfford,
                          backgroundColor: const Color(0xFFFFC700),
                          borderColor: Colors.black,
                          shadowColor: const Color(0xFF78350F),
                          shadowOffset: 2.0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          soundType: TactileSoundType.market,
                          child: Text(
                            GameLocalization.get('trade', lang: lang).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
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

  GameIconType _getIconType(dynamic key) {
    if (key is GameIconType) return key;
    switch (key.toString()) {
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
      case 'crown':
        return GameIconType.crown;
      case 'food':
        return GameIconType.food;
      case 'wood':
        return GameIconType.wood;
      default:
        return GameIconType.market;
    }
  }
}
