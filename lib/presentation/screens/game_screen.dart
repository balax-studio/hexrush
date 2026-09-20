import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../flame/flame_interactive_map.dart';
import '../providers/game_state_notifier.dart';
import '../widgets/diorama_lens_overlay.dart';
import '../widgets/left_bar.dart';
import '../widgets/market_dialog.dart';
import '../widgets/offline_gains_dialog.dart';
import '../widgets/quest_tracker_hud.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/tactile_neo_button.dart';
import '../widgets/tile_action_sheet.dart';
import '../widgets/toast_overlay.dart';
import '../widgets/top_bar_hud.dart';
import '../widgets/tore_dialog.dart';
import '../widgets/tactile_dialog_route.dart';
import '../widgets/hud/active_raid_combat_hud.dart';
import '../widgets/night_raid_atmosphere_overlay.dart';
import '../widgets/season_transition_banner.dart';
import '../widgets/migration_waypoint_banner.dart';
import '../widgets/hud/tactile_context_hint.dart';
import '../widgets/intro_story_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  bool _isOfflineDialogShowing = false;
  bool _isManualStoryOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingOfflineGains();
      final settings = ref.read(gameStateProvider).settings;
      TactileAudioService.instance.updateSettings(
        isSoundEnabled: !settings.sfxMuted,
        isMusicEnabled: !settings.musicMuted,
        sfxVolume: settings.sfxVolume,
        musicVolume: settings.musicVolume,
      );
      TactileAudioService.instance.startBackgroundMusic();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TactileAudioService.instance.pauseBackgroundMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      TactileAudioService.instance.pauseBackgroundMusic();
      ref.read(gameStateProvider.notifier).pauseGameLoop();
    } else if (state == AppLifecycleState.resumed) {
      TactileAudioService.instance.resumeBackgroundMusic();
      ref.read(gameStateProvider.notifier).resumeGameLoop().then((_) {
        if (mounted) {
          _checkPendingOfflineGains();
        }
      });
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
    if (_isOfflineDialogShowing || !mounted) return;
    _isOfflineDialogShowing = true;
    try {
      await showNeoTactileDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => OfflineGainsDialog(gains: gains),
      );
    } finally {
      if (mounted) {
        _isOfflineDialogShowing = false;
      }
    }
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
    final isRaidActive = ref.watch(gameStateProvider.select((s) => s.combatState.isActiveWave));
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
            // 1. Flame Engine 2.5D İzometrik Harita (Impeller Hızlandırmalı & RepaintBoundary İzolasyonu)
            const Positioned.fill(
              child: RepaintBoundary(
                child: FlameInteractiveMap(),
              ),
            ),

            // 2. Sinematik Minyatür Tilt-Shift Lens & Vinyet
            const Positioned.fill(
              child: RepaintBoundary(
                child: DioramaLensOverlay(),
              ),
            ),

            // 2.5. Gece Akını Karartması & Savaş Atmosferi (Sadece Savaşta Aktif)
            const Positioned.fill(
              child: RepaintBoundary(
                child: NightRaidAtmosphereOverlay(),
              ),
            ),

            // DIORAMA MODU AKTİFSE HUD GİZLENİR
            if (!isDioramaMode) ...[
              // 3. Gece Akın Savaşı Canlı Üst Can Barı (Sadece Savaş Sırasında Görünür)
              const Positioned(
                top: 52,
                left: 12,
                right: 12,
                child: SafeArea(
                  child: RepaintBoundary(
                    child: ActiveRaidCombatHUD(),
                  ),
                ),
              ),

              // 3.2. Görev Takipçisi (Sağ Üst - Savaşta Can Barının Altına İner)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                top: isRaidActive ? 116 : 60,
                right: 12,
                child: const SafeArea(
                  child: RepaintBoundary(
                    child: QuestTrackerHUD(),
                  ),
                ),
              ),

              // 3.5. İlk Sefer Kutlu Göç Waypoint Rehberlik Banner'ı
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                top: isRaidActive ? 116 : 60,
                left: 12,
                child: const SafeArea(
                  child: RepaintBoundary(
                    child: MigrationWaypointBanner(),
                  ),
                ),
              ),

              // 4. Üst HUD Barı (Kaynaklar, Sezon, Pazar, Töre, Ayarlar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: RepaintBoundary(
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
                  child: RepaintBoundary(
                    child: TileActionSheet(),
                  ),
                ),
              ),

              // 5.5. Taktiksel Bozkır Bağlamsal İpucu (FTUE & Zud Kışı)
              if (selectedCoord == null)
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: const RepaintBoundary(
                          child: TactileContextHint(),
                        ),
                      ),
                    ),
                  ),
                ),

              // 6. Sol Taktiksel Hızlı Eylem Barı (LeftBar)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: 12,
                top: isRaidActive ? 220 : 160,
                child: SafeArea(
                  child: RepaintBoundary(
                    child: LeftBar(
                      onOpenStory: () {
                        setState(() => _isManualStoryOpen = true);
                      },
                    ),
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

            // 9. Bozkır Destanı Giriş Hikayesi Ekranı (İlk Açılışta veya Butonla Tetiklendiğinde)
            if (!ref.watch(gameStateProvider.select((s) => s.progression.hasSeenIntro)) || _isManualStoryOpen)
              Positioned.fill(
                child: Container(
                  color: const Color(0xE6020617),
                  child: IntroStoryDialog(
                    onComplete: () {
                      if (_isManualStoryOpen) {
                        setState(() => _isManualStoryOpen = false);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

