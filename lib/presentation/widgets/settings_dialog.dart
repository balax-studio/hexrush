import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'great_migration_dialog.dart';
import 'icons/game_vector_icons.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const GameVectorIcon(type: GameIconType.settings, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      GameLocalization.get('settings', lang: lang).toUpperCase(),
                      style: NeoBrutalistTheme.fontHeaderMonolith,
                    ),
                  ],
                ),
                TactileNeoButton(
                  onTap: () => Navigator.of(context).pop(),
                  backgroundColor: const Color(0xFF334155),
                  shadowOffset: 2.0,
                  height: 28,
                  width: 28,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: const Center(child: Icon(Icons.close, color: Colors.white, size: 16)),
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
                _buildLangButton(context, notifier, 'tr', 'TR', settings.language == 'tr'),
                _buildLangButton(context, notifier, 'en', 'EN', settings.language == 'en'),
                _buildLangButton(context, notifier, 'es', 'ES', settings.language == 'es'),
                _buildLangButton(context, notifier, 'de', 'DE', settings.language == 'de'),
              ],
            ),
            const SizedBox(height: 16),

            // Ses Efektleri (SFX) Kontrolü
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SES EFEKTLERİ',
                  style: NeoBrutalistTheme.fontLabel,
                ),
                TactileNeoButton(
                  onTap: () => notifier.toggleMute(),
                  backgroundColor: settings.sfxMuted ? const Color(0xFF7F1D1D) : const Color(0xFF065F46),
                  borderColor: Colors.black,
                  shadowOffset: 2.0,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        settings.sfxMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        settings.sfxMuted ? 'KAPALI' : 'AÇIK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!settings.sfxMuted) ...[
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbColor: const Color(0xFFFFC700),
                  activeTrackColor: const Color(0xFFFFC700),
                  inactiveTrackColor: const Color(0xFF0F172A),
                  trackHeight: 4,
                  thumbShape: const _NeoRectSliderThumbShape(),
                ),
                child: Slider(
                  value: settings.sfxVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (val) => notifier.setSfxVolume(val),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Bozkır Müziği (Chill BGM) Kontrolü
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BOZKIR MÜZİĞİ',
                  style: NeoBrutalistTheme.fontLabel,
                ),
                TactileNeoButton(
                  onTap: () => notifier.toggleMusicMute(),
                  backgroundColor: settings.musicMuted ? const Color(0xFF7F1D1D) : const Color(0xFF065F46),
                  borderColor: Colors.black,
                  shadowOffset: 2.0,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        settings.musicMuted ? Icons.music_off_rounded : Icons.music_note_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        settings.musicMuted ? 'KAPALI' : 'AÇIK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!settings.musicMuted) ...[
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbColor: const Color(0xFF38BDF8),
                  activeTrackColor: const Color(0xFF38BDF8),
                  inactiveTrackColor: const Color(0xFF0F172A),
                  trackHeight: 4,
                  thumbShape: const _NeoRectSliderThumbShape(),
                ),
                child: Slider(
                  value: settings.musicVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (val) => notifier.setMusicVolume(val),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Bildirim Tercihleri
            const Text(
              'BİLDİRİM TERCİHLERİ',
              style: NeoBrutalistTheme.fontLabel,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(color: const Color(0xFF334155), width: 1.5),
              ),
              child: Column(
                children: [
                  _buildNotificationToggle(
                    'Ambar Dolum Uyarısı (%80)',
                    settings.notifications.storageFullAlert,
                    (val) => notifier.updateNotificationSettings(storageFullAlert: val),
                  ),
                  _buildNotificationToggle(
                    'Mevsim Değişimi Uyarısı',
                    settings.notifications.seasonChangeAlert,
                    (val) => notifier.updateNotificationSettings(seasonChangeAlert: val),
                  ),
                  _buildNotificationToggle(
                    'Görev Tamamlanma Uyarısı',
                    settings.notifications.questCompletedAlert,
                    (val) => notifier.updateNotificationSettings(questCompletedAlert: val),
                  ),
                  _buildNotificationToggle(
                    'Otağ Büyütme Hazır Uyarısı',
                    settings.notifications.castleUpgradeReadyAlert,
                    (val) => notifier.updateNotificationSettings(castleUpgradeReadyAlert: val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dinamik Neo-Brutalist Tema Paleti
            const Text(
              'NEO-BRUTALİST TEMA PALETİ',
              style: NeoBrutalistTheme.fontLabel,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: NeoBrutalistTheme.allPalettes.map((p) {
                final bool isSelected = settings.activeThemePalette == p.id;
                return GestureDetector(
                  onTap: () => notifier.setThemePalette(p.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                              )
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
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.nameTr,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Büyük Göç & Sıfırlama Butonu
            TactileNeoButton(
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
              height: 38,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_takeoff, color: Color(0xFFFFD700), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'BÜYÜK GÖÇ & SIFIRLAMA EKRANI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Hex Idle v2.0.0 • Flame + Impeller Hybrid',
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, GameStateNotifier notifier, String code, String label, bool isSelected) {
    return TactileNeoButton(
      onTap: () => notifier.setLanguage(code),
      backgroundColor: isSelected ? const Color(0xFFFFC700) : const Color(0xFF0F172A),
      borderColor: isSelected ? const Color(0xFFFBBF24) : Colors.black,
      shadowOffset: 2.0,
      height: 34,
      width: 50,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      soundType: TactileSoundType.tap,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w900,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(
                  color: value ? const Color(0xFF10B981) : const Color(0xFF475569),
                  width: 1.5,
                ),
              ),
              child: Text(
                value ? 'AÇIK' : 'KAPALI',
                style: TextStyle(
                  color: value ? Colors.white : Colors.white60,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeoRectSliderThumbShape extends SliderComponentShape {
  static const double width = 12.0;
  static const double height = 16.0;

  const _NeoRectSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(width, height);

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
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final fillPaint = Paint()..color = const Color(0xFFFFC700);
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }
}
