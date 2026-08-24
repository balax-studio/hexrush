import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';

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
                      style: NeoBrutalistTheme.fontTitle,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: NeoBrutalistTheme.hardShadowSmall,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
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
                IconButton(
                  icon: Icon(
                    settings.sfxMuted ? Icons.volume_off : Icons.volume_up,
                    color: settings.sfxMuted ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                  onPressed: () => notifier.toggleMute(),
                ),
              ],
            ),
            if (!settings.sfxMuted)
              Slider(
                value: settings.sfxVolume,
                min: 0.0,
                max: 1.0,
                activeColor: const Color(0xFFFFC700),
                inactiveColor: const Color(0xFF0F172A),
                onChanged: (val) => notifier.setSfxVolume(val),
              ),

            const SizedBox(height: 16),

            // Sıfırlama Butonu
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
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
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          notifier.resetGame();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: const RoundedRectangleBorder(
                            borderRadius: NeoBrutalistTheme.sharpRadius,
                            side: BorderSide(color: Colors.black, width: 1.5),
                          ),
                        ),
                        child: const Text('SIFIRLA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(GameLocalization.get('reset_game', lang: lang).toUpperCase()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF991B1B),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  side: BorderSide(color: Colors.black, width: 1.8),
                ),
                elevation: 0,
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
    return InkWell(
      onTap: () => notifier.setLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC700) : const Color(0xFF0F172A),
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(
            color: Colors.black,
            width: 1.8,
          ),
          boxShadow: NeoBrutalistTheme.hardShadowSmall,
        ),
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
}
