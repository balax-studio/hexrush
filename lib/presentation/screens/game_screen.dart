import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../flame/flame_interactive_map.dart';
import '../providers/game_state_notifier.dart';
import '../widgets/diorama_lens_overlay.dart';
import '../widgets/diorama_snapshot_dialog.dart';
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
    final activePalette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final isDioramaMode = ref.watch(gameStateProvider.select((s) => s.isDioramaMode));
    final isMacroOverview = ref.watch(gameStateProvider.select((s) => s.isMacroOverview));
    final theme = NeoBrutalistTheme.getTheme(activePalette);

    return Scaffold(
      backgroundColor: theme.bgDark,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) {
          ref.read(gameStateProvider.notifier).recordRhythmTap();
        },
        child: Stack(
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

            // DIORAMA MODU AKTİFSE HUD GİZLENİR
            if (!isDioramaMode) ...[
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

              // 6. Sağ Taktiksel Hızlı Eylem Butonları (Kuş Bakışı & Diorama)
              Positioned(
                right: 12,
                top: 140,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Kuş Bakışı Mercek Butonu
                      InkWell(
                        onTap: () {
                          ref.read(gameStateProvider.notifier).toggleMacroOverview();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isMacroOverview ? theme.primaryGold : theme.surfaceLight,
                            border: Border.all(
                              color: isMacroOverview ? const Color(0xFFF59E0B) : theme.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF020617), offset: Offset(2, 2)),
                            ],
                          ),
                          child: Icon(
                            isMacroOverview ? Icons.zoom_in : Icons.zoom_out_map,
                            size: 18,
                            color: isMacroOverview ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Diorama Mühür & Fotoğraf Butonu
                      InkWell(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => const DioramaSnapshotDialog(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.surfaceLight,
                            border: Border.all(color: theme.border, width: 1.5),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF020617), offset: Offset(2, 2)),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Diorama Modu Çıkış Butonu
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryGold,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(
                      'DİORAMADAN ÇIK',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).toggleDioramaMode();
                    },
                  ),
                ),
              ),
            ],

            // 7. Non-blocking Bildirim Toaster
            const ToastOverlay(),
          ],
        ),
      ),
    );
  }
}

