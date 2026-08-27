import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../domain/economy/economy_calculator.dart';
import '../providers/game_state_notifier.dart';
import 'great_migration_dialog.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class CrownBreakdownDialog extends ConsumerWidget {
  const CrownBreakdownDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final palette = gameState.settings.activeThemePalette;
    final theme = NeoBrutalistTheme.getTheme(palette);
    final lang = gameState.settings.language;

    final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
      tiles: gameState.tiles.values,
      resources: gameState.resources,
      castleLevel: gameState.progression.castleLevel,
    );

    final double totalResources = gameState.resources.food +
        gameState.resources.wood +
        gameState.resources.stone +
        gameState.resources.iron +
        gameState.resources.fish +
        gameState.resources.flour +
        gameState.resources.plank +
        gameState.resources.bread +
        gameState.resources.furniture +
        (gameState.resources.kumis * 2.0) +
        (gameState.resources.felt * 2.0) +
        (gameState.resources.damascusSteel * 3.0) +
        gameState.resources.wisdom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(color: theme.primaryGold, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: NeoBrutalistTheme.sharpRadius,
                          border: Border.all(color: theme.primaryGold, width: 1.5),
                        ),
                        child: const GameVectorIcon(
                          type: GameIconType.crown,
                          size: 20,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ŞAN & TAÇ DÖKÜMÜ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Büyük Göç Sıfırlama Hesabı',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    height: 28,
                    width: 28,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    backgroundColor: const Color(0xFF1E293B),
                    borderColor: theme.slateBorder,
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: theme.border, thickness: 1.5, height: 1.5),
              const SizedBox(height: 12),

              // Mevcut ve Göçte Kazanılacak Taç Özeti
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'MEVCUT TAÇ',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${gameState.resources.crowns}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Container(width: 1.5, height: 32, color: const Color(0xFF334155)),
                    Column(
                      children: [
                        const Text(
                          'GÖÇTE KAZANILACAK',
                          style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '+${breakdown.totalCrowns} TAÇ',
                          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Detaylı Hesaplama Dökümü
              const Text(
                'TAÇ HESAPLAMA VE KAZANIM DETAYLARI',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // 1. Sahip Olunan Hexler
              _buildBreakdownItem(
                theme: theme,
                icon: Icons.hexagon_outlined,
                iconColor: const Color(0xFF38BDF8),
                title: 'Hüküm Sürülen Topraklar (Hexler)',
                subtitle: '${gameState.progression.ownedCount} Fethedilmiş Karo (Her 5 Karo = 1 Taç)',
                crowns: breakdown.hexCrowns,
              ),
              const SizedBox(height: 8),

              // 2. Ambar Envanteri
              _buildBreakdownItem(
                theme: theme,
                icon: Icons.inventory_2_outlined,
                iconColor: const Color(0xFF34D399),
                title: 'Ambar ve Hammadde Stoğu',
                subtitle: '${NumberFormatter.format(totalResources)} birim hammadde (Kademeli Refah)',
                crowns: breakdown.resourceCrowns,
              ),
              const SizedBox(height: 8),

              // 3. Binalar, Şato ve Kadim Sunaklar
              _buildBreakdownItem(
                theme: theme,
                icon: Icons.account_balance_outlined,
                iconColor: const Color(0xFFF59E0B),
                title: 'Binalar, Sunaklar ve Otağ',
                subtitle: 'Kağan Otağı Sv.${gameState.progression.castleLevel}, Sunaklar & Yapı Kademeleri',
                crowns: breakdown.buildingAndShrineCrowns,
              ),
              const SizedBox(height: 12),

              // Bilgilendirme Notu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(color: const Color(0xFF475569), width: 1),
                ),
                child: const Text(
                  '• Taçlar pasif üretim artışı sağlamaz; Töre Yetenek Ağacı geliştirmeleri ve Meclis Doktrinlerini açmak için harcanır.\n• Büyük Göç başlatıldığında hesaplanan bu miktar doğrudan mevcut Taç bakiyenize eklenir.',
                  style: TextStyle(color: Colors.white70, fontSize: 9.5, height: 1.4),
                ),
              ),
              const SizedBox(height: 14),

              // Aksiyon Butonları
              Row(
                children: [
                  Expanded(
                    child: TactileNeoButton(
                      onTap: () => Navigator.of(context).pop(),
                      height: 36,
                      backgroundColor: const Color(0xFF1E293B),
                      borderColor: theme.slateBorder,
                      alignment: Alignment.center,
                      child: Text(
                        GameLocalization.get('close', lang: lang).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TactileNeoButton(
                      onTap: () {
                        Navigator.of(context).pop();
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => const GreatMigrationDialog(),
                        );
                      },
                      height: 36,
                      backgroundColor: const Color(0xFFFFD700),
                      borderColor: Colors.black,
                      alignment: Alignment.center,
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flight_takeoff, size: 14, color: Colors.black),
                            SizedBox(width: 4),
                            Text(
                              'BÜYÜK GÖÇ',
                              style: TextStyle(color: Colors.black, fontSize: 10.5, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownItem({
    required NeoBrutalistThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int crowns,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: theme.slateBorder, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: iconColor, width: 1),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: const Color(0xFFFFD700), width: 1),
            ),
            child: Text(
              '+$crowns TAÇ',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
