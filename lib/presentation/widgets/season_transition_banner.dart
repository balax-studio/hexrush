import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/game_state_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';

/// SwiftUI-tarzı Yaylanma Fiziğine (Curves.easeOutBack) Sahip Taktil Mevsim Geçiş Bildirim Başlığı
class SeasonTransitionBanner extends ConsumerStatefulWidget {
  const SeasonTransitionBanner({super.key});

  @override
  ConsumerState<SeasonTransitionBanner> createState() => _SeasonTransitionBannerState();
}

class _SeasonTransitionBannerState extends ConsumerState<SeasonTransitionBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  SeasonModel? _lastSeason;
  Timer? _dismissTimer;
  String _activeTitle = '';
  String _activeBonus = '';
  Color _activeColor = const Color(0xFFFFC700);
  GameIconType _activeIcon = GameIconType.spring;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 240),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _updateActiveSeasonInfo(SeasonModel season, String lang) {
    final String sName = season.current.toUpperCase();
    final bool isZud = season.isZud;

    if (isZud) {
      _activeTitle = '${GameLocalization.get('zud_blizzard_alert', lang: lang)} · ${GameLocalization.get('year', lang: lang)} ${season.year}'.toUpperCase();
      _activeBonus = GameLocalization.get('zud_production_penalty', lang: lang);
      _activeColor = const Color(0xFFEF4444);
      _activeIcon = GameIconType.zud;
    } else if (sName == 'SUMMER') {
      _activeTitle = '${GameLocalization.get('season_summer', lang: lang)} · ${GameLocalization.get('year', lang: lang)} ${season.year}'.toUpperCase();
      _activeBonus = GameLocalization.get('summer_bonus_desc', lang: lang);
      _activeColor = const Color(0xFFFBBF24);
      _activeIcon = GameIconType.summer;
    } else if (sName == 'AUTUMN') {
      _activeTitle = '${GameLocalization.get('season_autumn', lang: lang)} · ${GameLocalization.get('year', lang: lang)} ${season.year}'.toUpperCase();
      _activeBonus = GameLocalization.get('autumn_bonus_desc', lang: lang);
      _activeColor = const Color(0xFFEA580C);
      _activeIcon = GameIconType.autumn;
    } else if (sName == 'WINTER') {
      _activeTitle = '${GameLocalization.get('season_winter', lang: lang)} · ${GameLocalization.get('year', lang: lang)} ${season.year}'.toUpperCase();
      _activeBonus = GameLocalization.get('winter_penalty_desc', lang: lang);
      _activeColor = const Color(0xFF38BDF8);
      _activeIcon = GameIconType.winter;
    } else {
      // SPRING
      _activeTitle = '${GameLocalization.get('season_spring', lang: lang)} · ${GameLocalization.get('year', lang: lang)} ${season.year}'.toUpperCase();
      _activeBonus = GameLocalization.get('spring_bonus_desc', lang: lang);
      _activeColor = const Color(0xFF22C55E);
      _activeIcon = GameIconType.spring;
    }
  }

  @override
  Widget build(BuildContext context) {
    final season = ref.watch(gameStateProvider.select((s) => s.season));
    final lang = ref.watch(gameStateProvider.select((s) => s.settings.language));
    final activePalette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final theme = NeoBrutalistTheme.getTheme(activePalette);

    if (_lastSeason == null) {
      _lastSeason = season;
    } else if (_lastSeason!.current != season.current ||
        _lastSeason!.year != season.year ||
        _lastSeason!.isZud != season.isZud) {
      _lastSeason = season;
      _updateActiveSeasonInfo(season, lang);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          HapticFeedback.mediumImpact();
          _animController.forward(from: 0.0);
          _dismissTimer?.cancel();
          _dismissTimer = Timer(const Duration(milliseconds: 3800), () {
            if (mounted) {
              _animController.reverse();
            }
          });
        }
      });
    }

    if (_activeTitle.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 52,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: GestureDetector(
              onTap: () {
                _animController.reverse();
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: NeoBrutalistTheme.standardRadius,
                  border: Border.all(color: _activeColor, width: 2.0),
                  boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sol Taktil Sezon Rozeti
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _activeColor.withValues(alpha: 0.18),
                        borderRadius: NeoBrutalistTheme.sharpRadius,
                        border: Border.all(color: _activeColor, width: 1.5),
                      ),
                      child: Center(
                        child: GameVectorIcon(
                          type: _activeIcon,
                          size: 18,
                          color: _activeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Başlık ve Bonus Metinleri
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _activeTitle,
                            style: TextStyle(
                              color: _activeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _activeBonus,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Kapatma İkonu
                    Icon(
                      Icons.close,
                      size: 16,
                      color: theme.slateBorder,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
