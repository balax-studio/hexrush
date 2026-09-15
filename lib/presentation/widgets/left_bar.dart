import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'diorama_snapshot_dialog.dart';
import 'hexpedia_dialog.dart';
import 'horn_of_steppe_dialog.dart';
import 'icons/game_vector_icons.dart';
import 'realm_selection_dialog.dart';
import 'steppe_lore_tree_dialog.dart';
import 'tactile_dialog_route.dart';
import 'tactile_neo_button.dart';
import 'trade_orders_dialog.dart';

/// HexRush Taktiksel Sol Hızlı Eylem Barı (LeftBar)
/// Arkeolojik Bozkır Neo-Brutalizm standartlarına uygun, %100 font-bağımsız vektörel ikonlar
/// ile güçlendirilmiş, Android/iOS/Web release derlemelerinde asla sembol kaybı (X) yaşamayan navigasyon paneli.
class LeftBar extends ConsumerWidget {
  final VoidCallback onOpenStory;

  const LeftBar({
    super.key,
    required this.onOpenStory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMacroOverview = ref.watch(gameStateProvider.select((s) => s.isMacroOverview));
    final activePalette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final theme = NeoBrutalistTheme.getTheme(activePalette);

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Kuş Bakışı Mercek Butonu
          TactileNeoButton(
            onTap: () {
              ref.read(gameStateProvider.notifier).toggleMacroOverview();
            },
            backgroundColor: isMacroOverview ? theme.primaryGold : theme.surfaceLight,
            borderColor: isMacroOverview ? const Color(0xFFF59E0B) : theme.border,
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: Center(
              child: GameVectorIcon(
                type: GameIconType.macroOverview,
                size: 18,
                color: isMacroOverview ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Orhun Bitig Ağacı Butonu
          TactileNeoButton(
            onTap: () {
              showNeoTactileDialog<void>(
                context: context,
                builder: (_) => const SteppeLoreTreeDialog(),
              );
            },
            backgroundColor: const Color(0xFF083344),
            borderColor: const Color(0xFF06B6D4),
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: const Center(
              child: GameVectorIcon(
                type: GameIconType.loreTree,
                size: 18,
                color: Color(0xFF67E8F9),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 3. İpek Yolu Elçi Siparişleri Butonu
          TactileNeoButton(
            onTap: () {
              showNeoTactileDialog<void>(
                context: context,
                builder: (_) => const TradeOrdersDialog(),
              );
            },
            backgroundColor: const Color(0xFF451A03),
            borderColor: const Color(0xFFF59E0B),
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: const Center(
              child: GameVectorIcon(
                type: GameIconType.tradeOrders,
                size: 18,
                color: Color(0xFFFDE047),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 4. Bozkır Akın Borusu & Meydan Okuma Butonu
          TactileNeoButton(
            onTap: () {
              showNeoTactileDialog<void>(
                context: context,
                builder: (_) => const HornOfSteppeDialog(),
              );
            },
            backgroundColor: const Color(0xFF78350F),
            borderColor: const Color(0xFFD97706),
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            soundType: TactileSoundType.tap,
            child: const Center(
              child: GameVectorIcon(
                type: GameIconType.steppeHorn,
                size: 19,
                color: Color(0xFFFDE047),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 5. Büyük Göç Sefer Diyarları Butonu
          TactileNeoButton(
            onTap: () {
              showNeoTactileDialog<void>(
                context: context,
                builder: (_) => const RealmSelectionDialog(),
              );
            },
            backgroundColor: const Color(0xFF1E1B4B),
            borderColor: const Color(0xFF818CF8),
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: const Center(
              child: GameVectorIcon(
                type: GameIconType.realmMap,
                size: 18,
                color: Color(0xFFA5B4FC),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 6. Diorama Mühür & Fotoğraf Butonu
          TactileNeoButton(
            onTap: () {
              showNeoTactileDialog<void>(
                context: context,
                builder: (_) => const DioramaSnapshotDialog(),
              );
            },
            backgroundColor: theme.surfaceLight,
            borderColor: theme.border,
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: const Center(
              child: GameVectorIcon(
                type: GameIconType.dioramaCamera,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 7. Hexpedia (Bozkır Ansiklopedisi) Butonu
          TactileNeoButton(
            onTap: () {
              showNeoTactileDialog<void>(
                context: context,
                builder: (_) => const HexpediaDialog(),
              );
            },
            backgroundColor: const Color(0xFF064E3B),
            borderColor: const Color(0xFF10B981),
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: const Center(
              child: GameVectorIcon(
                type: GameIconType.hexpedia,
                size: 18,
                color: Color(0xFF6EE7B7),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 8. Bozkır Destanı (Giriş Hikayesi) Butonu
          TactileNeoButton(
            onTap: onOpenStory,
            backgroundColor: const Color(0xFF451A03),
            borderColor: const Color(0xFFD97706),
            shadowColor: theme.shadowColor,
            shadowOffset: 2.0,
            height: 36,
            width: 36,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: const Center(
              child: GameVectorIcon(
                type: GameIconType.steppeStory,
                size: 18,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
