import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

class DioramaSnapshotDialog extends ConsumerWidget {
  const DioramaSnapshotDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final lang = state.settings.language;
    final int totalTiles = state.tiles.values.where((t) => t.isOwned).length;
    final int migrations = state.progression.totalMigrations;
    final omen = state.celestialOmen;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          border: Border.all(color: const Color(0xFFD97706), width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Color(0xFF020617), offset: Offset(4, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt, color: Color(0xFFF59E0B), size: 22),
                const SizedBox(width: 8),
                Text(
                  GameLocalization.get('diorama_seal_title', lang: lang),
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border.all(color: const Color(0xFF334155)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    GameLocalization.get('diorama_khaganate_title', lang: lang),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${GameLocalization.get('conquered_tiles_count', lang: lang, args: [totalTiles.toString()])} | ${GameLocalization.get('total_migrations', lang: lang)}: $migrations | Yıl: ${omen.getTitle(lang)}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aktif İpek Yolları: ${state.caravanRoutes.length} Hat | Ata Mirasları: ${state.discoveredKurgans.length} Kurgan',
                    style: const TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TactileNeoButton(
                    onTap: () {
                      ref.read(gameStateProvider.notifier).toggleDioramaMode();
                      Navigator.of(context).pop();
                    },
                    backgroundColor: const Color(0xFFF59E0B),
                    borderColor: Colors.black,
                    shadowColor: const Color(0xFF78350F),
                    shadowOffset: 2.5,
                    height: 40,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fullscreen, size: 18, color: Colors.black),
                        const SizedBox(width: 6),
                        Text(
                          GameLocalization.get('fullscreen_diorama', lang: lang),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TactileNeoButton(
                  onTap: () => Navigator.of(context).pop(),
                  backgroundColor: const Color(0xFF1E293B),
                  borderColor: const Color(0xFF334155),
                  shadowOffset: 2.0,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Text(
                    GameLocalization.get('close', lang: lang),
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
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
