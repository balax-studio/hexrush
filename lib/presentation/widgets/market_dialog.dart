import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';

class MarketDialog extends ConsumerWidget {
  const MarketDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final resources = gameState.resources;
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = gameState.settings.language;
    final isMerchant = gameState.titles['merchant'] == true;

    final recipes = [
      {
        'key': 'flour_to_stone',
        'fromIcon': GameIconType.flour,
        'fromAmount': '15 Un',
        'toIcon': GameIconType.stone,
        'toAmount': isMerchant ? '10 Taş' : '8 Taş',
        'desc': isMerchant ? 'Tüccar Unvanı ile +%20 Bonus Taş!' : 'Değirmende öğütülen un ile taş takası.',
        'canAfford': resources.flour >= 15.0,
      },
      {
        'key': 'bread_to_iron',
        'fromIcon': GameIconType.bread,
        'fromAmount': '10 Ekmek',
        'toIcon': GameIconType.iron,
        'toAmount': isMerchant ? '6 Demir' : '5 Demir',
        'desc': isMerchant ? 'Tüccar Unvanı ile +%20 Bonus Demir!' : 'Fırından çıkan taze ekmekle maden takası.',
        'canAfford': resources.bread >= 10.0,
      },
      {
        'key': 'furniture_to_stone',
        'fromIcon': GameIconType.furniture,
        'fromAmount': '10 Mobilya',
        'toIcon': GameIconType.stone,
        'toAmount': isMerchant ? '18 Taş' : '15 Taş',
        'desc': 'İşlenmiş mobilya karşılığında zengin taş kütleleri.',
        'canAfford': resources.furniture >= 10.0,
      },
      {
        'key': 'iron_stone_to_crown',
        'fromIcon': GameIconType.iron,
        'fromAmount': '25 Demir + 25 Taş',
        'toIcon': GameIconType.crown,
        'toAmount': '1 Taç',
        'desc': 'Değerli madenleri birleştirerek krallık prestij tacı döv.',
        'canAfford': resources.iron >= 25.0 && resources.stone >= 25.0,
      },
    ];

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
                    const GameVectorIcon(type: GameIconType.market, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      GameLocalization.get('market_title', lang: lang).toUpperCase(),
                      style: NeoBrutalistTheme.fontTitle,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: NeoBrutalistTheme.hardShadowSmall,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              GameLocalization.get('market_desc', lang: lang),
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: recipes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final r = recipes[i];
                  final bool canAfford = r['canAfford'] as bool;
                  final String key = r['key'] as String;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(
                        color: canAfford ? const Color(0xFFFFC700) : Colors.black,
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
                                  GameVectorIcon(type: r['fromIcon'] as GameIconType, size: 14),
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
                                  GameVectorIcon(type: r['toIcon'] as GameIconType, size: 14),
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
                              const SizedBox(height: 4),
                              Text(
                                r['desc'] as String,
                                style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: canAfford ? () => notifier.executeMarketTrade(key) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? const Color(0xFFFFC700) : const Color(0xFF475569),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: const RoundedRectangleBorder(
                              borderRadius: NeoBrutalistTheme.sharpRadius,
                              side: BorderSide(color: Colors.black, width: 1.8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            GameLocalization.get('trade', lang: lang).toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.3),
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
}
