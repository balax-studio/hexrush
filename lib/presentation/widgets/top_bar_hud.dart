import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';

class TopBarHUD extends ConsumerStatefulWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenMarket;
  final VoidCallback onOpenTore;

  const TopBarHUD({
    super.key,
    required this.onOpenSettings,
    required this.onOpenMarket,
    required this.onOpenTore,
  });

  @override
  ConsumerState<TopBarHUD> createState() => _TopBarHUDState();
}

class _TopBarHUDState extends ConsumerState<TopBarHUD> {
  bool _isDrawerExpanded = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final resources = gameState.resources;
    final lang = gameState.settings.language;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: NeoBrutalistTheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ana Kaynak Satırı
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBrutalistChip(GameIconType.food, resources.food, const Color(0xFFFBBF24)),
                const SizedBox(width: 6),
                _buildBrutalistChip(GameIconType.wood, resources.wood, const Color(0xFFD97706)),
                const SizedBox(width: 6),
                if (resources.stone > 0 || gameState.progression.castleLevel >= 2) ...[
                  _buildBrutalistChip(GameIconType.stone, resources.stone, const Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                ],
                _buildBrutalistChip(GameIconType.crown, resources.crowns.toDouble(), const Color(0xFFFFD700), isInt: true),
                const SizedBox(width: 6),
                _buildLandChip(gameState.progression.ownedCount),
                const SizedBox(width: 8),

                // İkincil kaynak çekmecesi butonu
                _buildIconButton(
                  icon: Icon(
                    _isDrawerExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _isDrawerExpanded = !_isDrawerExpanded;
                    });
                  },
                  tooltip: 'Genişletilmiş Envanter',
                ),
                const SizedBox(width: 4),

                // Pazar Butonu (Vector Terazi)
                _buildIconButton(
                  icon: const GameVectorIcon(type: GameIconType.market, size: 16),
                  onPressed: widget.onOpenMarket,
                  tooltip: GameLocalization.get('market_title', lang: lang),
                ),
                const SizedBox(width: 4),

                // Töre Butonu (Vector Parşömen)
                _buildIconButton(
                  icon: const GameVectorIcon(type: GameIconType.tore, size: 16),
                  onPressed: widget.onOpenTore,
                  tooltip: GameLocalization.get('tore_title', lang: lang),
                ),
                const SizedBox(width: 6),

                // Frenzy Butonu (Neo-brutalist sert kutu)
                InkWell(
                  onTap: () {
                    ref.read(gameStateProvider.notifier).activateFrenzy();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: gameState.frenzyTimer > 0 ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: Colors.black, width: 1.8),
                      boxShadow: NeoBrutalistTheme.hardShadowSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GameVectorIcon(type: GameIconType.frenzy, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          gameState.frenzyTimer > 0
                              ? '${gameState.frenzyTimer.toInt()}s'
                              : GameLocalization.get('frenzy_boost', lang: lang),
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
                const SizedBox(width: 6),

                // Ayarlar butonu (Vector Çark)
                _buildIconButton(
                  icon: const GameVectorIcon(type: GameIconType.settings, size: 16),
                  onPressed: widget.onOpenSettings,
                  tooltip: 'Ayarlar',
                ),
              ],
            ),
          ),

          // Genişletilmiş Kaynak Çekmecesi (Un, Kereste, Ekmek, Mobilya, Demir)
          if (_isDrawerExpanded) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBrutalistChip(GameIconType.flour, resources.flour, const Color(0xFFFEF08A)),
                  const SizedBox(width: 6),
                  _buildBrutalistChip(GameIconType.plank, resources.plank, const Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  _buildBrutalistChip(GameIconType.bread, resources.bread, const Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  _buildBrutalistChip(GameIconType.furniture, resources.furniture, const Color(0xFFB45309)),
                  const SizedBox(width: 6),
                  _buildBrutalistChip(GameIconType.iron, resources.iron, const Color(0xFFCBD5E1)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 6),

          // Sezon & İpucu Bilgi Çubuğu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildSeasonBadge(gameState.season, lang),
                  if (gameState.season.isZud) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: NeoBrutalistTheme.sharpRadius,
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: NeoBrutalistTheme.hardShadowSmall,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GameVectorIcon(type: GameIconType.zud, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'ZUD AFETİ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: NeoBrutalistTheme.hardShadowSmall,
                ),
                child: Text(
                  'KALE LV.${gameState.progression.castleLevel}',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: NeoBrutalistTheme.hardShadowSmall,
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      ),
    );
  }

  Widget _buildBrutalistChip(GameIconType type, double value, Color color, {bool isInt = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: Colors.black, width: 1.8),
        boxShadow: NeoBrutalistTheme.hardShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameVectorIcon(type: type, size: 14),
          const SizedBox(width: 5),
          Text(
            isInt ? value.toInt().toString() : value.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: Colors.black, width: 1.8),
        boxShadow: NeoBrutalistTheme.hardShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GameVectorIcon(type: GameIconType.land, size: 14),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonBadge(dynamic season, String lang) {
    GameIconType iconType = GameIconType.spring;
    String name = GameLocalization.get('spring', lang: lang);
    Color color = const Color(0xFF4ADE80);

    if (season.current == 'SUMMER') {
      iconType = GameIconType.summer;
      name = GameLocalization.get('summer', lang: lang);
      color = const Color(0xFFFBBF24);
    } else if (season.current == 'AUTUMN') {
      iconType = GameIconType.autumn;
      name = GameLocalization.get('autumn', lang: lang);
      color = const Color(0xFFEA580C);
    } else if (season.current == 'WINTER') {
      iconType = GameIconType.winter;
      name = GameLocalization.get('winter', lang: lang);
      color = const Color(0xFF38BDF8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: Colors.black, width: 1.6),
        boxShadow: NeoBrutalistTheme.hardShadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameVectorIcon(type: iconType, size: 13),
          const SizedBox(width: 5),
          Text(
            '$name · ${GameLocalization.get('year', lang: lang)} ${season.year}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
