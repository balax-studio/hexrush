import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../flame/flame_interactive_map.dart';
import '../widgets/diorama_lens_overlay.dart';
import '../widgets/market_dialog.dart';
import '../widgets/quest_tracker_hud.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/tile_action_sheet.dart';
import '../widgets/toast_overlay.dart';
import '../widgets/top_bar_hud.dart';
import '../widgets/tore_dialog.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Flame Engine 2.5D İzometrik Harita (Impeller Hızlandırmalı)
          const Positioned.fill(
            child: FlameInteractiveMap(),
          ),

          // 2. Sinematik Minyatür Tilt-Shift Lens & Vinyet
          const Positioned.fill(
            child: DioramaLensOverlay(),
          ),

          // 3. Görev Takipçisi (Sol Üst - HUD Altı)
          const Positioned(
            top: 88,
            left: 12,
            child: SafeArea(
              child: QuestTrackerHUD(),
            ),
          ),

          // 4. Üst HUD Barı (Kaynaklar, Sezon, Pazar, Töre, Ayarlar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: TopBarHUD(
                onOpenSettings: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const SettingsDialog(),
                  );
                },
                onOpenMarket: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const MarketDialog(),
                  );
                },
                onOpenTore: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const ToreDialog(),
                  );
                },
              ),
            ),
          ),

          // 5. Seçili Karo Aksiyon Menüsü (Alt Kısım)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: TileActionSheet(),
            ),
          ),

          // 6. Non-blocking Bildirim Toaster
          const ToastOverlay(),
        ],
      ),
    );
  }
}
