import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../providers/game_state_notifier.dart';
import 'achievements_dialog.dart';
import 'ad_reward_progress_dialog.dart';
import 'great_migration_dialog.dart';
import 'hexpedia_dialog.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_dialog_route.dart';
import 'tactile_neo_button.dart';

/// Kağanlık Meclisi & Birleşik Yönetim Menüsü
/// Üst bardaki küçük butonların yerine 2x3 ferah ve taktil aksiyon kartları sunar.
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
    final unclaimedAchievements = gameState.unclaimedAchievementCount;

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
                                lang == 'tr'
                                    ? 'KURULTAY & YÖNETİM'
                                    : (lang == 'es'
                                        ? 'CONSEJO Y GESTIÓN'
                                        : (lang == 'de' ? 'RAT & VERWALTUNG' : 'COUNCIL & MANAGEMENT')),
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
                                lang == 'tr'
                                    ? 'Kağanlık İdari İşleri'
                                    : (lang == 'es'
                                        ? 'Administración del Kaganato'
                                        : (lang == 'de' ? 'Reichsverwaltung' : 'Realm Administration')),
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
                  final notifier = ref.read(gameStateProvider.notifier);
                  final completed = await showAdRewardProgressDialog(
                    context,
                    title: lang == 'tr'
                        ? '10X TOY COŞKUSU'
                        : (lang == 'es'
                            ? '10X FRENESÍ REAL'
                            : (lang == 'de' ? '10X REICHSFRENZY' : '10X REALM FRENZY')),
                    message: lang == 'tr'
                        ? 'Ödül alınıyor lütfen bekleyiniz...'
                        : 'Claiming reward, please wait...',
                  );
                  if (completed) {
                    await notifier.claimAdReward(
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
                      decoration: const BoxDecoration(
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
                                  ? (lang == 'tr'
                                      ? '10X TOY COŞKUSU (${gameState.frenzyTimer.toInt()}s)'
                                      : (lang == 'es'
                                          ? '10X FRENESÍ REAL (${gameState.frenzyTimer.toInt()}s)'
                                          : (lang == 'de'
                                              ? '10X REICHSFRENZY (${gameState.frenzyTimer.toInt()}s)'
                                              : '10X REALM FRENZY (${gameState.frenzyTimer.toInt()}s)')))
                                  : (lang == 'tr'
                                      ? '10X TOY COŞKUSU'
                                      : (lang == 'es'
                                          ? '10X FRENESÍ REAL'
                                          : (lang == 'de' ? '10X REICHSFRENZY' : '10X REALM FRENZY'))),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              gameState.frenzyTimer > 0
                                  ? (lang == 'tr'
                                      ? '10x üretim & lojistik verimi devrede'
                                      : (lang == 'es'
                                          ? '10x producción y logística activa'
                                          : (lang == 'de'
                                              ? '10x Produktion & Logistik aktiv'
                                              : '10x production & logistics active')))
                                  : (lang == 'tr'
                                      ? '4 dk boyunca 10x üretim ve lojistik verimi'
                                      : (lang == 'es'
                                          ? '10x producción y logística por 4 min'
                                          : (lang == 'de'
                                              ? '10x Produktion & Logistik für 4 Min'
                                              : '10x production & logistics efficiency for 4 min'))),
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
                    if (gameState.frenzyTimer > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: NeoBrutalistTheme.sharpRadius,
                          border: Border.all(color: const Color(0xFFFDE047), width: 1),
                        ),
                        child: Text(
                          '${gameState.frenzyTimer.toInt()}s',
                          style: const TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 2. 2x3 Izgara Düzeni:
              // Satır 1: Pazar, Töre
              Row(
                children: [
                  // İpek Yolu Pazarı
                  Expanded(
                    child: _buildMenuCard(
                      title: lang == 'tr'
                          ? 'İPEK YOLU PAZARI'
                          : (lang == 'es'
                              ? 'MERCADO DE LA SEDA'
                              : (lang == 'de' ? 'SEIDENSTRASSE-MARKT' : 'SILK ROAD MARKET')),
                      subtitle: lang == 'tr'
                          ? 'Takas & Ticaret'
                          : (lang == 'es'
                              ? 'Comercio'
                              : (lang == 'de' ? 'Ressourcentausch' : 'Resource Trade')),
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
                      title: lang == 'tr'
                          ? 'TÖRE & DOKTRİN'
                          : (lang == 'es'
                              ? 'TRADICIÓN Y TALENTOS'
                              : (lang == 'de' ? 'TRADITION & TALENTE' : 'CUSTOM & TALENTS')),
                      subtitle: lang == 'tr'
                          ? 'Kalıcı Yetenekler'
                          : (lang == 'es'
                              ? 'Árbol de Talentos'
                              : (lang == 'de' ? 'Talentbaum' : 'Steppe Lore Tree')),
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

              // Satır 2: Başarılarım, Yaşlılara Danış (Wiki)
              Row(
                children: [
                  // Başarılarım
                  Expanded(
                    child: _buildMenuCard(
                      title: GameLocalization.get('achievements', lang: lang).toUpperCase(),
                      subtitle: GameLocalization.get('achievements_subtitle', lang: lang),
                      icon: Icons.workspace_premium,
                      iconColor: const Color(0xFFFDE047),
                      badgeCount: unclaimedAchievements > 0 ? unclaimedAchievements : null,
                      theme: theme,
                      onTap: () {
                        Navigator.of(context).pop();
                        showNeoTactileDialog<void>(
                          context: context,
                          builder: (_) => const AchievementsDialog(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Yaşlılara Danış (Wiki)
                  Expanded(
                    child: _buildMenuCard(
                      title: GameLocalization.get('consult_elders', lang: lang).toUpperCase(),
                      subtitle: GameLocalization.get('consult_elders_subtitle', lang: lang),
                      icon: Icons.menu_book,
                      iconColor: const Color(0xFF10B981),
                      theme: theme,
                      onTap: () {
                        Navigator.of(context).pop();
                        showNeoTactileDialog<void>(
                          context: context,
                          builder: (_) => const HexpediaDialog(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Satır 3: Büyük Göç, Ayarlar
              Row(
                children: [
                  // Büyük Göç (Prestij)
                  Expanded(
                    child: _buildMenuCard(
                      title: lang == 'tr'
                          ? 'BÜYÜK GÖÇ'
                          : (lang == 'es'
                              ? 'GRAN MIGRACIÓN'
                              : (lang == 'de' ? 'GROSSE WANDERUNG' : 'GREAT MIGRATION')),
                      subtitle: lang == 'tr'
                          ? 'Yeni Çağ & Tamgalar'
                          : (lang == 'es'
                              ? 'Prestigio y Sellos'
                              : (lang == 'de' ? 'Prestige & Siegel' : 'Prestige & Seals')),
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
                      title: lang == 'tr'
                          ? 'OBAYI YÖNET'
                          : (lang == 'es'
                              ? 'AJUSTES DEL REINO'
                              : (lang == 'de' ? 'REICHSOPTIONEN' : 'REALM SETTINGS')),
                      subtitle: lang == 'tr'
                          ? 'Ses, Dil & Veriler'
                          : (lang == 'es'
                              ? 'Audio e Idioma'
                              : (lang == 'de' ? 'Audio & Sprache' : 'Audio & Language')),
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
                    ? GameVectorIcon(
                        type: iconType,
                        size: 16,
                      )
                    : Icon(
                        icon,
                        size: 18,
                        color: iconColor ?? theme.primaryGold,
                      ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
          const Icon(
            Icons.chevron_right,
            size: 14,
            color: Color(0xFF64748B),
          ),
        ],
      ),
    );
  }
}
