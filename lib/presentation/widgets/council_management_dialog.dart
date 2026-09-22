import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../providers/game_state_notifier.dart';
import 'ad_reward_progress_dialog.dart';
import 'great_migration_dialog.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

/// Kağanlık Meclisi & Birleşik Yönetim Menüsü
/// Üst bardaki küçük butonların yerine 2x2 ferah ve taktil aksiyon kartları sunar.
class CouncilManagementDialog extends ConsumerWidget {
  final VoidCallback onOpenMarket;
  final VoidCallback onOpenTore;
  final VoidCallback onOpenSettings;
  final IAdRewardService? adService;

  const CouncilManagementDialog({
    super.key,
    required this.onOpenMarket,
    required this.onOpenTore,
    required this.onOpenSettings,
    this.adService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final lang = gameState.settings.language;
    final theme = NeoBrutalistTheme.getTheme(gameState.settings.activeThemePalette);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: NeoBrutalistTheme.standardRadius,
          border: Border.all(color: theme.border, width: 2.5),
          boxShadow: theme.hardShadow(offset: 4.0),
        ),
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık ve Kapat Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.surfaceLight,
                            borderRadius: NeoBrutalistTheme.sharpRadius,
                            border: Border.all(color: theme.primaryGold, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: const GameVectorIcon(
                            type: GameIconType.tore,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang == 'tr' ? 'KURULTAY & YÖNETİM' : 'COUNCIL & MANAGEMENT',
                                style: TextStyle(
                                  color: theme.primaryGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                lang == 'tr' ? 'Kağanlık İdari İşleri' : 'Realm Administration',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor: theme.surfaceLight,
                    borderColor: theme.border,
                    height: 28,
                    width: 28,
                    padding: EdgeInsets.zero,
                    child: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 16),
                  ),
                ],
              ),

            const SizedBox(height: 14),

            // 1. Üst Tam Genişlikli 10x Toy Coşkusu (Frenzy Boost) Bannerı
            TactileNeoButton(
              onTap: () async {
                unawaited(TactileAudioService.instance.play(TactileSoundType.tap));
                unawaited(HapticFeedback.lightImpact());
                Navigator.of(context).pop();
                final completed = await showAdRewardProgressDialog(
                  context,
                  title: '10X TOY COŞKUSU',
                  message: 'Ödül alınıyor lütfen bekleyiniz...',
                );
                if (completed) {
                  await ref.read(gameStateProvider.notifier).claimAdReward(
                        AdRewardType.frenzyBoost,
                        adService: adService,
                      );
                }
              },
              backgroundColor: gameState.frenzyTimer > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFD97706),
              borderColor: theme.border,
              shadowColor: theme.shadowColor,
              shadowOffset: 3.0,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                    ),
                    alignment: Alignment.center,
                    child: const GameVectorIcon(
                      type: GameIconType.frenzy,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameState.frenzyTimer > 0
                                ? (lang == 'tr' ? 'TOY COŞKUSU AKTİF!' : 'FRENZY ACTIVE!')
                                : (lang == 'tr' ? '10X TOY COŞKUSU' : '10X REALM FRENZY'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            gameState.frenzyTimer > 0
                                ? '${gameState.frenzyTimer.toInt()}s ${lang == 'tr' ? 'kaldı (2x Hız)' : 'left (2x Speed)'}'
                                : (lang == 'tr' ? '10 dk boyunca küresel üretimi 2 katına çıkar' : 'Boost all production 2x for 10 min'),
                            style: const TextStyle(
                              color: Color(0xFFFEF3C7),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 2. 2x2 Izgara Düzeni: Pazar, Töre, Göç, Ayarlar
            Row(
              children: [
                // İpek Yolu Pazarı
                Expanded(
                  child: _buildMenuCard(
                    title: lang == 'tr' ? 'İPEK YOLU PAZARI' : 'SILK ROAD MARKET',
                    subtitle: lang == 'tr' ? 'Takas & Ticaret' : 'Resource Trade',
                    iconType: GameIconType.market,
                    theme: theme,
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpenMarket();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Töre & Meclis
                Expanded(
                  child: _buildMenuCard(
                    title: lang == 'tr' ? 'TÖRE & DOKTRİN' : 'CUSTOM & TALENTS',
                    subtitle: lang == 'tr' ? 'Kalıcı Yetenekler' : 'Steppe Lore Tree',
                    iconType: GameIconType.tore,
                    badgeCount: gameState.resources.crowns.toInt(),
                    theme: theme,
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpenTore();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                // Büyük Göç (Prestij)
                Expanded(
                  child: _buildMenuCard(
                    title: lang == 'tr' ? 'BÜYÜK GÖÇ' : 'GREAT MIGRATION',
                    subtitle: lang == 'tr' ? 'Yeni Çağ & Tamgalar' : 'Prestige & Seals',
                    icon: Icons.flight_takeoff,
                    iconColor: const Color(0xFFFFD700),
                    theme: theme,
                    onTap: () {
                      Navigator.of(context).pop();
                      unawaited(TactileAudioService.instance.play(TactileSoundType.tap));
                      unawaited(HapticFeedback.lightImpact());
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => const GreatMigrationDialog(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Ayarlar & Obayı Yönet
                Expanded(
                  child: _buildMenuCard(
                    title: lang == 'tr' ? 'OBAYI YÖNET' : 'REALM SETTINGS',
                    subtitle: lang == 'tr' ? 'Ses, Dil & Veriler' : 'Audio & Language',
                    iconType: GameIconType.settings,
                    theme: theme,
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpenSettings();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    GameIconType? iconType,
    IconData? icon,
    Color? iconColor,
    int? badgeCount,
    required NeoBrutalistThemeData theme,
    required VoidCallback onTap,
  }) {
    return TactileNeoButton(
      onTap: () {
        unawaited(TactileAudioService.instance.play(TactileSoundType.tap));
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      backgroundColor: theme.surfaceLight,
      borderColor: theme.border,
      shadowColor: theme.shadowColor,
      shadowOffset: 2.5,
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(color: theme.border, width: 1.5),
                ),
                alignment: Alignment.center,
                child: iconType != null
                    ? GameVectorIcon(type: iconType, size: 16)
                    : Icon(icon, size: 16, color: iconColor ?? Colors.white),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.primaryGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.border, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
