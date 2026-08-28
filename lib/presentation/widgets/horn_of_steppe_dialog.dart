import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/combat_calculator.dart';
import '../../domain/models/combat_model.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

class HornOfSteppeDialog extends ConsumerWidget {
  const HornOfSteppeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final combat = gameState.combatState;
    final castleLevel = gameState.progression.castleLevel;
    final theme = NeoBrutalistTheme.getTheme(gameState.settings.activeThemePalette);
    final notifier = ref.read(gameStateProvider.notifier);

    final int currentTier = combat.currentWaveTier;
    final victoryReward = CombatCalculator.calculateWaveVictoryReward(currentTier);
    final bool isCastleDamaged = combat.isCastleDestroyed || combat.castleCurrentHp < combat.castleMaxHp;

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
                        'BOZKIR AKINI: SEVİYE $currentTier',
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
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 14, color: Color(0xFF94A3B8)),
                        SizedBox(width: 6),
                        Text(
                          'AKIN BİLGİSİ & SAVUNMA PLANI',
                          style: TextStyle(
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
                      'Bozkır Yağmacıları sınır karolardan Kağan Otağı\'na doğru taarruz edecek. Geçtikleri karolar tahrip olur (%50 üretim kaybı). Gözcü Kuleleri (R=3) ve Surlar ile Otağ\'ı savunun!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
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
                              'KAĞAN OTAĞI (SV. $castleLevel)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Can Puanı: ${combat.castleCurrentHp.toInt()} / ${combat.castleMaxHp.toInt()} HP',
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
                    if (isCastleDamaged)
                      TactileNeoButton(
                        onTap: () => notifier.repairCastle(),
                        backgroundColor: const Color(0xFFDC2626),
                        borderColor: const Color(0xFF020617),
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.build, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'ONAR',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
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
                    const Row(
                      children: [
                        Icon(Icons.military_tech, size: 14, color: Color(0xFF6EE7B7)),
                        SizedBox(width: 6),
                        Text(
                          'SEVİYE ZAFER GANİMETİ (TEK SEFERLİK)',
                          style: TextStyle(
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
                          '+${victoryReward.crowns} TAÇ',
                          style: const TextStyle(color: Color(0xFFFDE047), fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                        if (victoryReward.tamgas > 0)
                          Text(
                            '+${victoryReward.tamgas} ATALAR TAMGASI',
                            style: const TextStyle(color: Color(0xFF67E8F9), fontSize: 11, fontWeight: FontWeight.w900),
                          ),
                        ...victoryReward.resources.entries.map((e) {
                          return Text(
                            '+${e.value.toInt()} ${e.key.toUpperCase()}',
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
                      combat.isCastleDestroyed ? 'ÖNCE ŞATOYU ONARIN' : 'BORUYU ÇAL (AKINI BAŞLAT)',
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
