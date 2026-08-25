import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

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
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
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

            // Ses Kontrolü
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  GameLocalization.get('sound', lang: lang).toUpperCase(),
                  style: NeoBrutalistTheme.fontLabel,
                ),
                TactileNeoButton(
                  onTap: () => notifier.toggleMute(),
                  backgroundColor: settings.sfxMuted ? const Color(0xFF7F1D1D) : const Color(0xFF065F46),
                  borderColor: Colors.black,
                  shadowOffset: 2.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: settings.sfxVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (val) => notifier.setSfxVolume(val),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Sıfırlama Butonu
            TactileNeoButton(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: NeoBrutalistTheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: NeoBrutalistTheme.standardRadius,
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    title: const Text('OYUNU SIFIRLA?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    content: const Text(
                      'Tüm krallık ilerlemeniz silinecektir. Devam etmek istiyor musunuz?',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('İPTAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900)),
                      ),
                      TactileNeoButton(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          notifier.resetGame();
                          Navigator.of(context).pop();
                        },
                        backgroundColor: const Color(0xFFEF4444),
                        borderColor: Colors.black,
                        shadowOffset: 2.0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: const Text('SIFIRLA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );
              },
              backgroundColor: const Color(0xFF991B1B),
              borderColor: Colors.black,
              shadowColor: const Color(0xFF450A0A),
              shadowOffset: 2.5,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    GameLocalization.get('reset_game', lang: lang).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      soundType: TactileSoundType.tap,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
