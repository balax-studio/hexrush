import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_state_notifier.dart';

class TranshumanceBannerWidget extends ConsumerWidget {
  const TranshumanceBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final bool anyResting = state.tiles.values.any((t) => t.isOwned && t.isResting);
    final int combo = state.rhythmCombo;
    final double rhythmMult = state.rhythmMultiplier;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Dokunsal Ritim Ahenk Rozeti (Tactile Chimes Combo)
        if (combo > 1)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: combo >= 5
                  ? const Color(0xFF831843)
                  : (combo >= 3 ? const Color(0xFF78350F) : const Color(0xFF0C4A6E)),
              border: Border.all(
                color: combo >= 5
                    ? const Color(0xFFF43F5E)
                    : (combo >= 3 ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8)),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [
                BoxShadow(color: Color(0xFF020617), offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.music_note,
                  size: 14,
                  color: combo >= 5
                      ? const Color(0xFFFDA4AF)
                      : (combo >= 3 ? const Color(0xFFFDE68A) : const Color(0xFFBAE6FD)),
                ),
                const SizedBox(width: 4),
                Text(
                  '${combo}x RİTİM (${rhythmMult.toStringAsFixed(1)}x)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

        // 2. Yaylak-Kışlak Dinlendirme Butonu
        InkWell(
          onTap: () {
            ref.read(gameStateProvider.notifier).toggleTranshumance();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: anyResting ? const Color(0xFF064E3B) : const Color(0xFF1E293B),
              border: Border.all(
                color: anyResting ? const Color(0xFF10B981) : const Color(0xFF334155),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [
                BoxShadow(color: Color(0xFF020617), offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  anyResting ? Icons.spa : Icons.terrain,
                  size: 16,
                  color: anyResting ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  anyResting ? 'YAYLAKTA DİNLENİYOR' : 'KIŞLAKTA OTLUYOR',
                  style: TextStyle(
                    color: anyResting ? const Color(0xFF10B981) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
