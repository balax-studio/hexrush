import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class ToreDialog extends ConsumerWidget {
  const ToreDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final crowns = gameState.resources.crowns;
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = gameState.settings.language;
    final tore = gameState.toreTalents;
    final titles = gameState.titles;

    final int rainLvl = (tore['gokTengri']?['rainBlessing'] as num? ?? 0).toInt();
    final int silkLvl = (tore['tonyukuk']?['silkNetwork'] as num? ?? 0).toInt();
    final int roadsLvl = (tore['tonyukuk']?['pavedRoads'] as num? ?? 0).toInt();
    final int braveLvl = (tore['kulTigin']?['braveHeart'] as num? ?? 0).toInt();

    final talents = [
      {
        'branch': 'gokTengri',
        'key': 'rainBlessing',
        'icon': GameIconType.food,
        'title': 'GÖK TENGRİ: YAĞMUR BEREKETİ (LV.$rainLvl)',
        'desc': 'Tüm krallık üretim hızını her seviyede +%5 artırır.',
        'cost': rainLvl + 1,
        'lvl': rainLvl,
      },
      {
        'branch': 'tonyukuk',
        'key': 'silkNetwork',
        'icon': GameIconType.tore,
        'title': 'TONYUKUK: İPEK AĞI (LV.$silkLvl)',
        'desc': 'Üretim çarpanını her seviyede +%4 artırır.',
        'cost': silkLvl + 1,
        'lvl': silkLvl,
      },
      {
        'branch': 'tonyukuk',
        'key': 'pavedRoads',
        'icon': GameIconType.wood,
        'title': 'TONYUKUK: TAŞ YOLLAR (LV.$roadsLvl)',
        'desc': 'İşçi taşıma hızını her seviyede +%8 artırır.',
        'cost': roadsLvl + 1,
        'lvl': roadsLvl,
      },
      {
        'branch': 'kulTigin',
        'key': 'braveHeart',
        'icon': GameIconType.frenzy,
        'title': 'KÜL TİGİN: CESUR YÜREK (LV.$braveLvl)',
        'desc': 'Toprak fethetme gıda maliyetini her seviyede %5 düşürür.',
        'cost': braveLvl + 1,
        'lvl': braveLvl,
      },
    ];

    final titleList = [
      {
        'key': 'khagan',
        'icon': GameIconType.crown,
        'title': 'BÜYÜK KAĞAN',
        'desc': 'Şato Lv.4 ve 10 Toprak gerektirir. (+%15 Küresel Hız)',
        'owned': titles['khagan'] == true,
        'canClaim': gameState.progression.castleLevel >= 4 && gameState.progression.ownedCount >= 10,
      },
      {
        'key': 'conqueror',
        'icon': GameIconType.land,
        'title': 'TOPRAK FATİHİ',
        'desc': '15 Toprak gerektirir. (Fetih Maliyeti -%10)',
        'owned': titles['conqueror'] == true,
        'canClaim': gameState.progression.ownedCount >= 15,
      },
      {
        'key': 'merchant',
        'icon': GameIconType.market,
        'title': 'İPEK YOLU TÜCCARI',
        'desc': '50 Un ve 50 Kereste gerektirir. (Pazar Gelirleri +%20)',
        'owned': titles['merchant'] == true,
        'canClaim': gameState.resources.flour >= 50 && gameState.resources.plank >= 50,
      },
      {
        'key': 'zudMaster',
        'icon': GameIconType.winter,
        'title': 'ZUD FATİHİ',
        'desc': 'Kış Yılı 2\'ye ulaşmayı gerektirir. (Kış Kayıpları -%20)',
        'owned': titles['zudMaster'] == true,
        'canClaim': gameState.season.year >= 2,
      },
    ];

    return Dialog(
      backgroundColor: NeoBrutalistTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: NeoBrutalistTheme.standardRadius,
        side: BorderSide(color: Colors.black, width: 2.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
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
                    const GameVectorIcon(type: GameIconType.tore, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      GameLocalization.get('tore_title', lang: lang).toUpperCase(),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: const Color(0xFF334155), width: 1.5),
                    boxShadow: NeoBrutalistTheme.hardShadowSmall,
                  ),
                  child: Row(
                    children: [
                      const GameVectorIcon(type: GameIconType.crown, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'KULLANILABİLİR TAÇ: $crowns',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TÖRE KANUNLARI (KALICI YÜKSELTMELER):',
                      style: TextStyle(
                        color: Color(0xFFFFC700),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...talents.map((t) {
                      final int cost = t['cost'] as int;
                      final bool canAfford = crowns >= cost;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: NeoBrutalistTheme.sharpRadius,
                          border: Border.all(
                            color: canAfford ? const Color(0xFF8B5CF6) : const Color(0xFF334155),
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
                                      GameVectorIcon(type: t['icon'] as GameIconType, size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          t['title'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    t['desc'] as String,
                                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            TactileNeoButton(
                              onTap: canAfford
                                  ? () => notifier.upgradeToreTalent(
                                        t['branch'] as String,
                                        t['key'] as String,
                                        cost,
                                      )
                                  : null,
                              isEnabled: canAfford,
                              backgroundColor: const Color(0xFF8B5CF6),
                              borderColor: Colors.black,
                              shadowColor: const Color(0xFF4C1D95),
                              shadowOffset: 2.0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              soundType: TactileSoundType.upgrade,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const GameVectorIcon(type: GameIconType.crown, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$cost TAÇ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    const Text(
                      'KRALLIK UNVANLARI & BAŞARIMLAR:',
                      style: TextStyle(
                        color: Color(0xFFFFC700),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...titleList.map((t) {
                      final bool isOwned = t['owned'] as bool;
                      final bool canClaim = t['canClaim'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isOwned ? const Color(0xFF064E3B) : const Color(0xFF0F172A),
                          borderRadius: NeoBrutalistTheme.sharpRadius,
                          border: Border.all(
                            color: isOwned ? const Color(0xFF10B981) : const Color(0xFF334155),
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
                                      GameVectorIcon(type: t['icon'] as GameIconType, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        t['title'] as String,
                                        style: TextStyle(
                                          color: isOwned ? const Color(0xFF10B981) : Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    t['desc'] as String,
                                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isOwned)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: NeoBrutalistTheme.sharpRadius,
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: const Text(
                                  'AÇILDI',
                                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              )
                            else
                              TactileNeoButton(
                                onTap: canClaim ? () => notifier.claimTitle(t['key'] as String) : null,
                                isEnabled: canClaim,
                                backgroundColor: const Color(0xFFFFC700),
                                borderColor: Colors.black,
                                shadowColor: const Color(0xFF78350F),
                                shadowOffset: 2.0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                soundType: TactileSoundType.reward,
                                child: Text(
                                  GameLocalization.get('claim_title', lang: lang).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
