import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/combat_calculator.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

class HornOfSteppeDialog extends ConsumerWidget {
  const HornOfSteppeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final lang = gameState.settings.language;
    final combat = gameState.combatState;
    final castleLevel = gameState.progression.castleLevel;
    final theme = NeoBrutalistTheme.getTheme(gameState.settings.activeThemePalette);
    final notifier = ref.read(gameStateProvider.notifier);

    final int currentTier = combat.currentWaveTier;
    final victoryReward = CombatCalculator.calculateWaveVictoryReward(currentTier);
    final bool isCastleDamaged = combat.isCastleDestroyed || combat.castleCurrentHp < combat.castleMaxHp;

    final headerTitle = '${lang == 'tr' ? 'BOZKIR AKINI' : 'STEPPE RAID'}: ${lang == 'tr' ? 'SEVİYE' : 'LEVEL'} $currentTier';
    final infoTitle = lang == 'tr' ? 'AKIN BİLGİSİ & SAVUNMA PLANI' : 'RAID INFO & DEFENSE STRATEGY';
    final infoDesc = lang == 'tr'
        ? 'Bozkır Yağmacıları sınır karolardan Kağan Otağı\'na doğru taarruz edecek. Geçtikleri karolar tahrip olur (%50 üretim kaybı). Gözcü Kuleleri (R=3) ve Surlar ile Otağ\'ı savunun!'
        : 'Steppe raiders attack from border tiles towards the Khan Yurt. Damaged tiles suffer -50% yield. Defend with Watchtowers (R=3) and Walls!';

    final castleLabel = '${lang == 'tr' ? 'KAĞAN OTAĞI' : 'KHAGAN YURT'} (${lang == 'tr' ? 'SV' : 'LV'}. $castleLevel)';
    final hpLabel = '${lang == 'tr' ? 'Can Puanı' : 'Hit Points'}: ${combat.castleCurrentHp.toInt()} / ${combat.castleMaxHp.toInt()} HP';

    final victoryTitle = lang == 'tr' ? 'SEVİYE ZAFER GANİMETİ (TEK SEFERLİK)' : 'LEVEL VICTORY REWARD (ONE-TIME)';
    final crownsLabel = '+${victoryReward.crowns} ${lang == 'tr' ? 'TAÇ' : 'CROWNS'}';
    final tamgaLabel = '+${victoryReward.tamgas} ${lang == 'tr' ? 'ATALAR TAMGASI' : 'ANCESTRAL TAMGAS'}';

    final actionBtnText = combat.isCastleDestroyed
        ? (lang == 'tr' ? 'ÖNCE ŞATOYU ONARIN' : 'REPAIR YURT FIRST')
        : (lang == 'tr' ? 'BORUYU ÇAL (AKINI BAŞLAT)' : 'SOUND HORN (START RAID)');

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 440,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: NeoBrutalistTheme.sharpRadius,
            border: Border.all(color: const Color(0xFFD97706), width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF020617),
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Başlık & Kapat Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign, color: Color(0xFFF59E0B), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        headerTitle,
                        style: const TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor: theme.slateBorder,
                    borderColor: theme.border,
                    height: 28,
                    width: 28,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Açıklama & İstihbarat
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 6),
                        Text(
                          infoTitle,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      infoDesc,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 3. Şato Can Durumu (Castle HP)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(
                    color: isCastleDamaged ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.fort,
                          size: 18,
                          color: isCastleDamaged ? const Color(0xFFEF4444) : const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              castleLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              hpLabel,
                              style: TextStyle(
                                color: isCastleDamaged ? const Color(0xFFFCA5A5) : const Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isCastleDamaged) () {
                      final castleRepairCost = CombatCalculator.calculateCastleRepairCost(
                        castleLevel: castleLevel,
                        castleCurrentHp: combat.castleCurrentHp,
                        castleMaxHp: combat.castleMaxHp,
                      );
                      bool canAffordCastleRepair = true;
                      for (final e in castleRepairCost.entries) {
                        final double avail = switch (e.key) {
                          'wood' => gameState.resources.wood,
                          'stone' => gameState.resources.stone,
                          _ => 0.0,
                        };
                        if (avail < e.value) {
                          canAffordCastleRepair = false;
                          break;
                        }
                      }
                      final woodName = GameLocalization.get('wood', lang: lang);
                      final stoneName = GameLocalization.get('stone', lang: lang);
                      final costStr = castleRepairCost.entries
                          .map((e) => '${e.value.toInt()} ${e.key == 'wood' ? woodName : stoneName}')
                          .join(', ');
                      final repairLabel = '${lang == 'tr' ? 'ONAR' : 'REPAIR'} ($costStr)';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TactileNeoButton(
                            onTap: canAffordCastleRepair ? () => notifier.repairCastle() : null,
                            isEnabled: canAffordCastleRepair,
                            backgroundColor: canAffordCastleRepair ? const Color(0xFFDC2626) : theme.slateBorder,
                            borderColor: const Color(0xFF020617),
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.build, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  repairLabel,
                                  style: TextStyle(
                                    color: canAffordCastleRepair ? Colors.white : Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }(),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 4. Zafer Ganimeti (Victory Rewards)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.military_tech, size: 14, color: Color(0xFF6EE7B7)),
                        const SizedBox(width: 6),
                        Text(
                          victoryTitle,
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Text(
                          crownsLabel,
                          style: const TextStyle(color: Color(0xFFFDE047), fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                        if (victoryReward.tamgas > 0)
                          Text(
                            tamgaLabel,
                            style: const TextStyle(color: Color(0xFF67E8F9), fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ...victoryReward.resources.entries.map((e) {
                          final resLabel = GameLocalization.get(e.key.toLowerCase(), lang: lang).toUpperCase();
                          return Text(
                            '+${e.value.toInt()} $resLabel',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Ana Eylem Butonu (Boruyu Çal / Savaşa Gir)
              TactileNeoButton(
                onTap: combat.isCastleDestroyed
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        notifier.soundSteppeHorn();
                      },
                isEnabled: !combat.isCastleDestroyed,
                backgroundColor: combat.isCastleDestroyed ? theme.slateBorder : const Color(0xFFD97706),
                borderColor: const Color(0xFF020617),
                shadowOffset: 3.0,
                height: 42,
                alignment: Alignment.center,
                soundType: TactileSoundType.horn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign,
                      size: 20,
                      color: combat.isCastleDestroyed ? const Color(0xFF94A3B8) : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      actionBtnText,
                      style: TextStyle(
                        color: combat.isCastleDestroyed ? const Color(0xFF94A3B8) : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
