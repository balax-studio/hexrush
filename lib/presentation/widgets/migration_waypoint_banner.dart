import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../providers/game_state_notifier.dart';
import 'great_migration_dialog.dart';
import 'tactile_neo_button.dart';
import 'tactile_dialog_route.dart';

/// İlk Seferde Oyuncuya Yol Gösteren Waypoint & Kutlu Göç Tavsiye Banner'ı
class MigrationWaypointBanner extends ConsumerStatefulWidget {
  const MigrationWaypointBanner({super.key});

  @override
  ConsumerState<MigrationWaypointBanner> createState() => _MigrationWaypointBannerState();
}

class _MigrationWaypointBannerState extends ConsumerState<MigrationWaypointBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final activePalette = gameState.settings.activeThemePalette;
    final theme = NeoBrutalistTheme.getTheme(activePalette);

    final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
      tiles: gameState.tiles.values,
      resources: gameState.resources,
      castleLevel: gameState.progression.castleLevel,
    );
    final newTamgas = gameState.tiles.values.where((t) => t.isOwned).length ~/ 3;

    // Yalnızca 1. Seferde (0 göç yapılmışken) ve olgunlaşmış göç eşiği sağlandığında gösterilir
    final bool isFirstRun = gameState.progression.totalMigrations == 0;
    final bool isEligible = gameState.progression.castleLevel >= 5 &&
        gameState.progression.ownedCount >= 12 &&
        (breakdown.totalCrowns >= 3 || newTamgas >= 4);

    if (!isFirstRun || !isEligible) {
      return const SizedBox.shrink();
    }

    if (_isMinimized) {
      // Küçültülmüş Waypoint Rozeti (Sağ üstte parıldayan taktil yön oku)
      return AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnim.value,
            child: child,
          );
        },
        child: TactileNeoButton(
          onTap: () {
            setState(() {
              _isMinimized = false;
            });
          },
          height: 32,
          backgroundColor: const Color(0xFF78350F),
          borderColor: const Color(0xFFF59E0B),
          shadowOffset: 2.0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.navigation, size: 13, color: Color(0xFFFBBF24)),
              SizedBox(width: 5),
              Text(
                'GÖÇ VAKTİ!',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tam Açık Waypoint & Rehberlik Kartı
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: NeoBrutalistTheme.sharpRadius,
            border: Border.all(color: const Color(0xFFF59E0B), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25 * _pulseAnim.value),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              const BoxShadow(
                color: Colors.black,
                blurRadius: 0,
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Başlık & Waypoint İkonu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(Icons.navigation, size: 14, color: Color(0xFFFBBF24)),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KUTLU GÖÇ VAKTİ GELDİ!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'İlk çağ tamamlandı • Büyüme yavaşlıyor',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMinimized = true;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.remove, size: 16, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Açıklama Metni
            const Text(
              'Oban ilk sınırlarına ulaştı. Şimdi Büyük Göç başlatarak kalıcı Atalar Tamgası ve Kut Çarpanı kazanabilir, yeni sefere çok daha güçlü başlayabilirsin!',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Kazanılacak Miras Özeti
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    '+${breakdown.totalCrowns} TAÇ',
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  Container(width: 1, height: 12, color: const Color(0xFF475569)),
                  Text(
                    '+$newTamgas TAMGA',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  Container(width: 1, height: 12, color: const Color(0xFF475569)),
                  const Text(
                    '+%40 KUT HIZI',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: TactileNeoButton(
                    onTap: () {
                      setState(() {
                        _isMinimized = true;
                      });
                    },
                    height: 28,
                    backgroundColor: const Color(0xFF1E293B),
                    borderColor: theme.slateBorder,
                    alignment: Alignment.center,
                    child: const Text(
                      'DAHA SONRA',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TactileNeoButton(
                    onTap: () {
                      TactileAudioService.instance.play(TactileSoundType.conquer);
                      showNeoTactileDialog<void>(
                        context: context,
                        builder: (_) => const GreatMigrationDialog(),
                      );
                    },
                    height: 28,
                    backgroundColor: const Color(0xFFDC2626),
                    borderColor: Colors.black,
                    shadowOffset: 2.0,
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flight_takeoff, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'ŞİMDİ GÖÇ ET',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                        ),
                      ],
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
