import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../flame/flame_interactive_map.dart';
import '../providers/game_state_notifier.dart';
import '../widgets/diorama_lens_overlay.dart';
import '../widgets/diorama_snapshot_dialog.dart';
import '../widgets/market_dialog.dart';
import '../widgets/offline_gains_dialog.dart';
import '../widgets/quest_tracker_hud.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/tactile_neo_button.dart';
import '../widgets/tile_action_sheet.dart';
import '../widgets/toast_overlay.dart';
import '../widgets/top_bar_hud.dart';
import '../widgets/tore_dialog.dart';
import '../widgets/steppe_lore_tree_dialog.dart';
import '../widgets/trade_orders_dialog.dart';
import '../widgets/realm_selection_dialog.dart';
import '../widgets/debug_menu_dialog.dart';
import '../widgets/hexpedia_dialog.dart';
import '../widgets/tactile_dialog_route.dart';
import '../widgets/horn_of_steppe_dialog.dart';
import '../widgets/hud/active_raid_combat_hud.dart';
import '../widgets/night_raid_atmosphere_overlay.dart';
import '../widgets/season_transition_banner.dart';
import '../widgets/migration_waypoint_banner.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  int? _pauseTimestamp;
  bool _isOfflineDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingOfflineGains();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pauseTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      ref.read(gameStateProvider.notifier).saveGame();
    } else if (state == AppLifecycleState.resumed) {
      if (_pauseTimestamp != null) {
        ref
            .read(gameStateProvider.notifier)
            .processResumeOfflineGains(_pauseTimestamp!);
        _pauseTimestamp = null;
      }
    }
  }

  void _checkPendingOfflineGains() {
    if (!mounted || _isOfflineDialogShowing) return;
    final pending = ref.read(gameStateProvider).pendingOfflineGains;
    if (pending != null && pending.hasGains) {
      _showOfflineGainsDialog(pending);
    }
  }

  Future<void> _showOfflineGainsDialog(OfflineGainsResult gains) async {
    _isOfflineDialogShowing = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OfflineGainsDialog(gains: gains),
    );
    _isOfflineDialogShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OfflineGainsResult?>(
      gameStateProvider.select((s) => s.pendingOfflineGains),
      (previous, next) {
        if (next != null && next.hasGains && mounted && !_isOfflineDialogShowing) {
          _showOfflineGainsDialog(next);
        }
      },
    );

    final selectedCoord = ref.watch(gameStateProvider.select((s) => s.selectedCoord));
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

            // 2.5. Gece Akını Karartması & Savaş Atmosferi (Sadece Savaşta Aktif)
            const Positioned.fill(
              child: NightRaidAtmosphereOverlay(),
            ),

            // DIORAMA MODU AKTİFSE HUD GİZLENİR
            if (!isDioramaMode) ...[
              // 3. Gece Akın Savaşı Canlı Üst Can Barı (Sadece Savaş Sırasında Görünür)
              const Positioned(
                top: 52,
                left: 12,
                right: 12,
                child: SafeArea(
                  child: ActiveRaidCombatHUD(),
                ),
              ),

              // 3.2. Görev Takipçisi (Sol Üst)
              const Positioned(
                top: 92,
                left: 12,
                child: SafeArea(
                  child: QuestTrackerHUD(),
                ),
              ),

              // 3.5. İlk Sefer Kutlu Göç Waypoint Rehberlik Banner'ı
              const Positioned(
                top: 92,
                right: 12,
                child: SafeArea(
                  child: MigrationWaypointBanner(),
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
                      showNeoTactileDialog<void>(
                        context: context,
                        builder: (_) => const SettingsDialog(),
                      );
                    },
                    onOpenMarket: () {
                      showNeoTactileDialog<void>(
                        context: context,
                        builder: (_) => const MarketDialog(),
                      );
                    },
                    onOpenTore: () {
                      showNeoTactileDialog<void>(
                        context: context,
                        builder: (_) => const ToreDialog(),
                      );
                    },
                  ),
                ),
              ),

              // 4.5. Seçili Karo Menüsü Dışına Dokunulduğunda Kapatma Bariyeri
              if (selectedCoord != null)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      ref.read(gameStateProvider.notifier).clearSelection();
                    },
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
                          child: Icon(
                            isMacroOverview ? Icons.zoom_in : Icons.zoom_out_map,
                            size: 18,
                            color: isMacroOverview ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Orhun Bitig Ağacı Butonu
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
                          child: Icon(
                            Icons.auto_stories,
                            size: 18,
                            color: Color(0xFF67E8F9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // İpek Yolu Elçi Siparişleri Butonu
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
                          child: Icon(
                            Icons.local_shipping,
                            size: 18,
                            color: Color(0xFFFDE047),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bozkır Akın Borusu & Meydan Okuma Butonu
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
                        soundType: TactileSoundType.horn,
                        child: const Center(
                          child: Icon(
                            Icons.campaign,
                            size: 20,
                            color: Color(0xFFFDE047),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Büyük Göç Sefer Diyarları Butonu
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
                          child: Icon(
                            Icons.map,
                            size: 18,
                            color: Color(0xFFA5B4FC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Diorama Mühür & Fotoğraf Butonu
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
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Hexpedia (Bozkır Ansiklopedisi) Butonu
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
                          child: Icon(
                            Icons.menu_book,
                            size: 18,
                            color: Color(0xFF6EE7B7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Geliştirici Denetim Konsolu (Debug Menü) Butonu
                      TactileNeoButton(
                        onTap: () {
                          showNeoTactileDialog<void>(
                            context: context,
                            builder: (_) => const DebugMenuDialog(),
                          );
                        },
                        backgroundColor: const Color(0xFF581C87),
                        borderColor: const Color(0xFFA855F7),
                        shadowColor: theme.shadowColor,
                        shadowOffset: 2.0,
                        height: 36,
                        width: 36,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.center,
                        child: const Center(
                          child: Icon(
                            Icons.terminal,
                            size: 18,
                            color: Color(0xFFE9D5FF),
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
                  child: TactileNeoButton(
                    onTap: () {
                      ref.read(gameStateProvider.notifier).toggleDioramaMode();
                    },
                    backgroundColor: theme.primaryGold,
                    borderColor: theme.border,
                    shadowColor: theme.shadowColor,
                    shadowOffset: 3.0,
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 16, color: Colors.black),
                        SizedBox(width: 6),
                        Text(
                          'DİORAMADAN ÇIK',
                          style: TextStyle(
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
              ),
            ],

            // 7. Taktil Mevsim Geçiş Başlığı
            const SeasonTransitionBanner(),

            // 8. Non-blocking Bildirim Toaster
            const ToastOverlay(),
          ],
        ),
      ),
    );
  }
}

