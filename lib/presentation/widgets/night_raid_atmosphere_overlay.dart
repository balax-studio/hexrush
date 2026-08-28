import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_notifier.dart';

/// Gece Akını Atmosferi ve Savaş Karartması (Night Raid Atmosphere)
/// Akın başladığında hava kararır, haritaya karanlık mor/lacivert savaş sisi çöker.
class NightRaidAtmosphereOverlay extends ConsumerWidget {
  const NightRaidAtmosphereOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActiveWave = ref.watch(
      gameStateProvider.select((s) => s.combatState.isActiveWave),
    );

    if (!isActiveWave) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: isActiveWave ? 1.0 : 0.0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Genel Gece Karartma Filtresi (Deep Twilight Night Tint)
            Container(
              color: const Color(0x77060913),
            ),

            // 2. Kenar Savaş Sisi ve Vinyet (Radial Dark War Vignette)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: const [
                    Colors.transparent,
                    Color(0x331E1B4B),
                    Color(0xBB020617),
                  ],
                  stops: const [0.45, 0.75, 1.0],
                ),
              ),
            ),

            // 3. Hafif Kırmızı Savaş Alarmı Kenar Çerçevesi
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0x44EF4444),
                  width: 3.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
