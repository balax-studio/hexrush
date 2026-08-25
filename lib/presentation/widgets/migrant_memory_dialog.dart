import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class MigrantMemoryDialog extends ConsumerWidget {
  const MigrantMemoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final history = gameState.progression.migrationHistory;
    final totalMigrations = gameState.progression.totalMigrations;
    final tamga = gameState.resources.tamgas;
    final tamgaMultiplier = EconomyCalculator.getTamgaMultiplier(tamga);
    final lang = gameState.settings.language;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NeoBrutalistTheme.surface,
          borderRadius: NeoBrutalistTheme.standardRadius,
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const GameVectorIcon(
                      type: GameIconType.crown,
                      size: 20,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GÖÇMEN HAFIZASI',
                      style: NeoBrutalistTheme.fontHeaderMonolith.copyWith(
                        color: const Color(0xFFD97706),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFF475569), width: 1.5),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Kümülâtif Tamga ve Göç Özeti
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                boxShadow: NeoBrutalistTheme.hardShadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'TOPLAM GÖÇ',
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalMigrations',
                        style: const TextStyle(color: Color(0xFFD97706), fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      const Text(
                        'TAMGA SAYISI',
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$tamga',
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 30, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      const Text(
                        'KALICI BONUS',
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${((tamgaMultiplier - 1.0) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Geçmiş Göçler Listesi
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: history.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: NeoBrutalistTheme.sharpRadius,
                        border: Border.all(color: const Color(0xFF334155), width: 1),
                      ),
                      child: const Text(
                        'Henüz bir Büyük Göç tamamlanmadı.\nİlk göçünüz sonrasında kadim bozkır hafızası burada kaydedilecektir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final record = history[history.length - 1 - index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: NeoBrutalistTheme.sharpRadius,
                            border: Border.all(color: const Color(0xFF475569), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${record.migrationNumber}. BÜYÜK GÖÇ',
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '+${record.tamgasGained} Tamga',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Fethedilen: ${record.ownedCount} Karo',
                                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Atlatılan Zud: ${record.zudCount}',
                                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10),
                                  ),
                                ],
                              ),
                              if (record.topSynergy.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'En Yüksek Verim: ${record.topSynergy}',
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 14),

            TactileNeoButton(
              onTap: () => Navigator.of(context).pop(),
              backgroundColor: const Color(0xFFD97706),
              borderColor: Colors.black,
              shadowOffset: 2.0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                GameLocalization.get('close', lang: lang).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
