import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/game_localization.dart';
import '../../../core/theme/neo_brutalist_theme.dart';
import '../../providers/game_state_notifier.dart';
import '../icons/game_vector_icons.dart';

/// Bozkır taktiksel bağlamsal ipucu modeli.
/// Oyuncunun özerkliğini koruyan, sıfır-slop, hafif dokunsal bilgi şeridi.
class TactileContextHint extends ConsumerWidget {
  const TactileContextHint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final season = gameState.season.current;
    final int castleLevel = gameState.progression.castleLevel;
    final int ownedHexes = gameState.progression.ownedCount;

    final lang = gameState.settings.language;

    // Bağlamsal ipucu belirleme (Öncelik sırasına göre)
    String? hintTitle;
    String? hintDesc;
    GameIconType iconType = GameIconType.land;

    // 1. Zud Kışı Yaklaşıyorsa
    if (season == 'AUTUMN' && gameState.season.timer >= 45) {
      hintTitle = GameLocalization.get('hint_zud_approaching_title', lang: lang);
      hintDesc = GameLocalization.get('hint_zud_approaching_desc', lang: lang);
      iconType = GameIconType.winter;
    }
    // 2. Erken Aşama İşçi Menzil Uyarısı
    else if (ownedHexes >= 5 && castleLevel >= 2) {
      final hasWorker = gameState.tiles.values.any((t) => t.isOwned && t.building?.type != null && t.building!.type.name.contains('worker'));
      if (!hasWorker) {
        hintTitle = GameLocalization.get('hint_steppe_logistics_title', lang: lang);
        hintDesc = GameLocalization.get('hint_steppe_logistics_desc', lang: lang);
        iconType = GameIconType.food;
      }
    }

    if (hintTitle == null || hintDesc == null) {
      return const SizedBox.shrink();
    }

    final theme = NeoBrutalistTheme.getTheme(gameState.settings.activeThemePalette);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: theme.primaryGold, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF020617),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          GameVectorIcon(type: iconType, size: 16, color: theme.primaryGold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hintTitle,
                  style: TextStyle(
                    color: theme.primaryGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hintDesc,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
