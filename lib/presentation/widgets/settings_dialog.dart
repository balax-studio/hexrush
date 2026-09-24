import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'great_migration_dialog.dart';
import 'icons/game_vector_icons.dart';
import 'intro_story_dialog.dart';
import 'tactile_neo_button.dart';
import 'tactile_dialog_route.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final settings = gameState.settings;
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = settings.language;

    final onLabel = GameLocalization.get('on', lang: lang);
    final offLabel = GameLocalization.get('off', lang: lang);

    return Dialog(
      backgroundColor: NeoBrutalistTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: NeoBrutalistTheme.standardRadius,
        side: BorderSide(color: Colors.black, width: 2.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NeoBrutalistTheme.surface,
          borderRadius: NeoBrutalistTheme.standardRadius,
          boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const GameVectorIcon(
                        type: GameIconType.settings,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        GameLocalization.get(
                          'settings',
                          lang: lang,
                        ).toUpperCase(),
                        style: NeoBrutalistTheme.fontHeaderMonolith,
                      ),
                    ],
                  ),
                  Semantics(
                    button: true,
                    label: GameLocalization.get('close', lang: lang),
                    child: TactileNeoButton(
                      onTap: () => Navigator.of(context).pop(),
                      backgroundColor: const Color(0xFF334155),
                      shadowOffset: 2.0,
                      height: 44,
                      width: 44,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      child: const Center(
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
              const SizedBox(height: 12),

              // Dil Seçimi
              Text(
                GameLocalization.get('language', lang: lang).toUpperCase(),
                style: NeoBrutalistTheme.fontLabel,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLangButton(
                    context,
                    notifier,
                    'tr',
                    'TR',
                    settings.language == 'tr',
                  ),
                  _buildLangButton(
                    context,
                    notifier,
                    'en',
                    'EN',
                    settings.language == 'en',
                  ),
                  _buildLangButton(
                    context,
                    notifier,
                    'es',
                    'ES',
                    settings.language == 'es',
                  ),
                  _buildLangButton(
                    context,
                    notifier,
                    'de',
                    'DE',
                    settings.language == 'de',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ses Efektleri (SFX) Kontrolü
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    GameLocalization.get('sfx_effects', lang: lang),
                    style: NeoBrutalistTheme.fontLabel,
                  ),
                  Semantics(
                    button: true,
                    label: GameLocalization.get('sfx_effects', lang: lang),
                    child: TactileNeoButton(
                      onTap: () => notifier.toggleMute(),
                      backgroundColor: settings.sfxMuted
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFF065F46),
                      borderColor: Colors.black,
                      shadowOffset: 2.0,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            settings.sfxMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            settings.sfxMuted ? offLabel : onLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!settings.sfxMuted) ...[
                const SizedBox(height: 6),
                Semantics(
                  slider: true,
                  value: (settings.sfxVolume * 100).toStringAsFixed(0),
                  label: GameLocalization.get('sfx_effects', lang: lang),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: const Color(0xFFFFC700),
                      activeTrackColor: const Color(0xFFFFC700),
                      inactiveTrackColor: const Color(0xFF0F172A),
                      trackHeight: 6,
                      thumbShape: const _NeoRectSliderThumbShape(),
                    ),
                    child: Slider(
                      value: settings.sfxVolume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) => notifier.setSfxVolume(val),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Bozkır Müziği (Chill BGM) Kontrolü
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    GameLocalization.get('music_steppe', lang: lang),
                    style: NeoBrutalistTheme.fontLabel,
                  ),
                  Semantics(
                    button: true,
                    label: GameLocalization.get('music_steppe', lang: lang),
                    child: TactileNeoButton(
                      onTap: () => notifier.toggleMusicMute(),
                      backgroundColor: settings.musicMuted
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFF065F46),
                      borderColor: Colors.black,
                      shadowOffset: 2.0,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            settings.musicMuted
                                ? Icons.music_off_rounded
                                : Icons.music_note_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            settings.musicMuted ? offLabel : onLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!settings.musicMuted) ...[
                const SizedBox(height: 6),
                Semantics(
                  slider: true,
                  value: (settings.musicVolume * 100).toStringAsFixed(0),
                  label: GameLocalization.get('music_steppe', lang: lang),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: const Color(0xFF38BDF8),
                      activeTrackColor: const Color(0xFF38BDF8),
                      inactiveTrackColor: const Color(0xFF0F172A),
                      trackHeight: 6,
                      thumbShape: const _NeoRectSliderThumbShape(),
                    ),
                    child: Slider(
                      value: settings.musicVolume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) => notifier.setMusicVolume(val),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Görsel Konfor & Erişilebilirlik
              Text(
                GameLocalization.get('visual_comfort_access', lang: lang),
                style: NeoBrutalistTheme.fontLabel,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(
                    color: const Color(0xFF334155),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildNotificationToggle(
                      GameLocalization.get('calm_visual_mode', lang: lang),
                      settings.reducedMotion,
                      (val) => notifier.setReducedMotion(val),
                    ),
                    _buildNotificationToggle(
                      GameLocalization.get('hide_quest_tracker', lang: lang),
                      settings.notifications.questPanelHidden,
                      (val) => notifier.updateNotificationSettings(
                        questPanelHidden: val,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dinamik Neo-Brutalist Tema Paleti
              Text(
                GameLocalization.get('theme_palette', lang: lang),
                style: NeoBrutalistTheme.fontLabel,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: NeoBrutalistTheme.allPalettes.map((p) {
                  final bool isSelected = settings.activeThemePalette == p.id;
                  final paletteName = p.getName(lang);

                  return Semantics(
                    button: true,
                    label:
                        '${GameLocalization.get('theme_palette', lang: lang)}: $paletteName',
                    selected: isSelected,
                    child: GestureDetector(
                      onTap: () => notifier.setThemePalette(p.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: NeoBrutalistTheme.sharpRadius,
                          border: Border.all(
                            color: isSelected ? p.primaryGold : p.slateBorder,
                            width: isSelected ? 2.0 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: p.primaryGold.withValues(alpha: 0.4),
                                    offset: const Offset(2.0, 2.0),
                                    blurRadius: 0.0,
                                  ),
                                ]
                              : NeoBrutalistTheme.hardShadowSmall,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: p.accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              paletteName,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Büyük Göç & Sıfırlama Butonu
              Semantics(
                button: true,
                label: GameLocalization.get(
                  'great_migration_screen_btn',
                  lang: lang,
                ),
                child: TactileNeoButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    showNeoTactileDialog<void>(
                      context: context,
                      builder: (ctx) => const GreatMigrationDialog(),
                    );
                  },
                  backgroundColor: const Color(0xFF78350F),
                  borderColor: const Color(0xFFD97706),
                  shadowColor: const Color(0xFF450A0A),
                  shadowOffset: 2.5,
                  height: 44,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.flight_takeoff,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        GameLocalization.get(
                          'great_migration_screen_btn',
                          lang: lang,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Bozkır Destanı & Başlangıç Hikayesi Butonu
              Semantics(
                button: true,
                label: GameLocalization.get('steppe_story_btn', lang: lang),
                child: TactileNeoButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    IntroStoryDialog.show(context);
                  },
                  backgroundColor: const Color(0xFF1E293B),
                  borderColor: const Color(0xFFF59E0B),
                  shadowColor: const Color(0xFF020617),
                  shadowOffset: 2.5,
                  height: 44,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history_edu,
                        color: Color(0xFFF59E0B),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        GameLocalization.get('steppe_story_btn', lang: lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Geliştirici Hesabı Butonu
              Semantics(
                button: true,
                label: GameLocalization.get('developer_account', lang: lang),
                child: TactileNeoButton(
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://www.instagram.com/balaxstudio',
                    );
                    try {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {}
                  },
                  backgroundColor: const Color(0xFF4C1D95),
                  borderColor: const Color(0xFFC084FC),
                  shadowColor: const Color(0xFF2E1065),
                  shadowOffset: 2.5,
                  height: 44,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.code_rounded,
                        color: Color(0xFFC084FC),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        GameLocalization.get(
                          'developer_account',
                          lang: lang,
                        ).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Gizlilik Politikası Butonu
              Semantics(
                button: true,
                label: GameLocalization.get('privacy_policy', lang: lang),
                child: TactileNeoButton(
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://docs.google.com/document/d/e/2PACX-1vT3zbnKsGeO3fr4Or-GmlSlB9v91gu_SQ8kMHlTfu7WywoCh3y8MGKJ5WFhnDC8pdmeddzqFtsAaosr/pub',
                    );
                    try {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (_) {}
                  },
                  backgroundColor: const Color(0xFF0F172A),
                  borderColor: const Color(0xFF38BDF8),
                  shadowColor: const Color(0xFF020617),
                  shadowOffset: 2.5,
                  height: 44,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.privacy_tip_outlined,
                        color: Color(0xFF38BDF8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        GameLocalization.get(
                          'privacy_policy',
                          lang: lang,
                        ).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Verilerimi Sil Butonu
              Semantics(
                button: true,
                label: GameLocalization.get('delete_data', lang: lang),
                child: TactileNeoButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    showNeoTactileDialog<void>(
                      context: context,
                      builder: (ctx) => const DeleteDataConfirmDialog(),
                    );
                  },
                  backgroundColor: const Color(0xFF7F1D1D),
                  borderColor: const Color(0xFFFCA5A5),
                  shadowColor: const Color(0xFF450A0A),
                  shadowOffset: 2.5,
                  height: 44,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_forever,
                        color: Color(0xFFFCA5A5),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        GameLocalization.get(
                          'delete_data',
                          lang: lang,
                        ).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Hex Idle v2.0.0 • Flame + Impeller Hybrid',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(
    BuildContext context,
    GameStateNotifier notifier,
    String code,
    String label,
    bool isSelected,
  ) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: TactileNeoButton(
        onTap: () => notifier.setLanguage(code),
        backgroundColor: isSelected
            ? const Color(0xFFFFC700)
            : const Color(0xFF0F172A),
        borderColor: isSelected ? const Color(0xFFFBBF24) : Colors.black,
        shadowOffset: 2.0,
        height: 44,
        width: 60,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        soundType: TactileSoundType.tap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Semantics(
      toggled: value,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ExcludeSemantics(
              child: Switch(
                value: value,
                activeThumbColor: const Color(0xFFFFC700),
                activeTrackColor: const Color(0xFF78350F),
                inactiveThumbColor: const Color(0xFF94A3B8),
                inactiveTrackColor: const Color(0xFF1E293B),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeoRectSliderThumbShape extends SliderComponentShape {
  const _NeoRectSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 32);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(center: center, width: 20, height: 28);

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? const Color(0xFFFFC700)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }
}

class DeleteDataConfirmDialog extends ConsumerWidget {
  const DeleteDataConfirmDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = ref.watch(
      gameStateProvider.select((s) => s.settings.language),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFDC2626),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            GameLocalization.get('delete_data_confirm_title', lang: lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF450A0A),
              border: Border.all(color: const Color(0xFF7F1D1D), width: 2),
              borderRadius: NeoBrutalistTheme.sharpRadius,
            ),
            child: Text(
              GameLocalization.get('delete_data_confirm_desc', lang: lang),
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TactileNeoButton(
                  onTap: () => Navigator.of(context).pop(),
                  backgroundColor: const Color(0xFF1E293B),
                  borderColor: const Color(0xFF64748B),
                  shadowColor: const Color(0xFF020617),
                  height: 44,
                  child: const Center(
                    child: Text(
                      'X',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TactileNeoButton(
                  onTap: () {
                    notifier.wipeAllData();
                    Navigator.of(context).pop();
                  },
                  backgroundColor: const Color(0xFF7F1D1D),
                  borderColor: const Color(0xFFFCA5A5),
                  shadowColor: const Color(0xFF450A0A),
                  height: 44,
                  child: Center(
                    child: Text(
                      GameLocalization.get(
                        'delete_data',
                        lang: lang,
                      ).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
