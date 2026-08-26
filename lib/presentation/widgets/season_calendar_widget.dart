import 'package:flutter/material.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/game_state_model.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class SeasonCalendarWidget extends StatelessWidget {
  final SeasonModel season;
  final String language;
  final VoidCallback? onClose;

  const SeasonCalendarWidget({
    super.key,
    required this.season,
    required this.language,
    this.onClose,
  });

  static const double seasonDuration = 300.0;

  String _formatTime(double seconds) {
    final int sec = seconds.clamp(0.0, 1200.0).toInt();
    final int m = sec ~/ 60;
    final int s = sec % 60;
    return '${m}dk ${s.toString().padLeft(2, '0')}sn';
  }

  @override
  Widget build(BuildContext context) {
    const seasons = ['SPRING', 'SUMMER', 'AUTUMN', 'WINTER'];
    final int currentIdx = seasons.indexOf(season.current.toUpperCase());
    final int validIdx = currentIdx >= 0 ? currentIdx : 0;
    final double elapsedInCurrent = season.timer.clamp(0.0, seasonDuration);
    final double remainingInCurrent = seasonDuration - elapsedInCurrent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NeoBrutalistTheme.surface,
        borderRadius: NeoBrutalistTheme.standardRadius,
        border: Border.all(color: Colors.black, width: 2.5),
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
                  const GameVectorIcon(
                    type: GameIconType.winter,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MEVSİM TAKVİMİ (YIL ${season.year})',
                    style: NeoBrutalistTheme.fontHeaderMonolith.copyWith(
                      color: const Color(0xFFD97706),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (onClose != null)
                TactileNeoButton(
                  onTap: onClose,
                  backgroundColor: const Color(0xFF1E293B),
                  borderColor: const Color(0xFF475569),
                  shadowOffset: 1.5,
                  height: 24,
                  width: 24,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(4, (index) {
              final String sName = seasons[index];
              final bool isCurrent = index == validIdx;
              final double remainingSec;

              if (index == validIdx) {
                remainingSec = remainingInCurrent;
              } else if (index > validIdx) {
                remainingSec = remainingInCurrent + ((index - validIdx - 1) * seasonDuration);
              } else {
                remainingSec = remainingInCurrent + ((3 - validIdx + index) * seasonDuration);
              }

              final Color seasonColor = _getSeasonColor(sName, season.isZud && isCurrent);
              final GameIconType iconType = _getSeasonIcon(sName, season.isZud && isCurrent);

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF1E293B) : const Color(0xFF0B1120),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(
                      color: isCurrent ? const Color(0xFFD97706) : const Color(0xFF334155),
                      width: isCurrent ? 2.0 : 1.0,
                    ),
                    boxShadow: isCurrent ? NeoBrutalistTheme.hardShadowSmall : null,
                  ),
                  child: Column(
                    children: [
                      GameVectorIcon(type: iconType, size: 14, color: seasonColor),
                      const SizedBox(height: 4),
                      Text(
                        GameLocalization.get(sName.toLowerCase(), lang: language).toUpperCase(),
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.white60,
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCurrent
                          ? '${remainingSec.toInt()}sn'
                          : _formatTime(remainingSec),
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getSeasonBonusText(sName, season.isZud && isCurrent, language),
                        style: TextStyle(
                          color: seasonColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (elapsedInCurrent / seasonDuration).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: seasonColor,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getSeasonColor(String sName, bool isZud) {
    if (isZud) return const Color(0xFFEF4444);
    switch (sName) {
      case 'SUMMER':
        return const Color(0xFFFBBF24);
      case 'AUTUMN':
        return const Color(0xFFEA580C);
      case 'WINTER':
        return const Color(0xFF38BDF8);
      case 'SPRING':
      default:
        return const Color(0xFF10B981);
    }
  }

  GameIconType _getSeasonIcon(String sName, bool isZud) {
    if (isZud) return GameIconType.zud;
    switch (sName) {
      case 'SUMMER':
        return GameIconType.summer;
      case 'AUTUMN':
        return GameIconType.autumn;
      case 'WINTER':
        return GameIconType.winter;
      case 'SPRING':
      default:
        return GameIconType.spring;
    }
  }

  String _getSeasonBonusText(String sName, bool isZud, String lang) {
    final bool isTr = lang == 'tr';
    if (isZud) return isTr ? 'ZUD -%80' : 'ZUD -80%';
    switch (sName) {
      case 'SPRING':
        return isTr ? '+%20 Gıda' : '+20% Food';
      case 'SUMMER':
        return isTr ? '+%15 Odun' : '+15% Wood';
      case 'AUTUMN':
        return isTr ? '+%15 Maden' : '+15% Mine';
      case 'WINTER':
      default:
        return isTr ? '-%50 Don' : '-50% Freeze';
    }
  }
}
