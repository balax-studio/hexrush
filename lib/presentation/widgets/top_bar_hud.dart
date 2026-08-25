import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/game_state_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

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

    final double globalMult = EconomyCalculator.getGlobalMultiplier(
      castleLevel: gameState.progression.castleLevel,
      crowns: resources.crowns,
      toreTalents: gameState.toreTalents,
      titles: gameState.titles,
    );

    final double seasonMult = gameState.season.isZud
        ? 0.2
        : (gameState.season.current == 'WINTER' ? 0.5 : 1.0);

    final netRates = EconomyCalculator.calculateNetRates(
      tiles: gameState.tiles.values.toList(),
      globalMultiplier: globalMult,
      seasonMultiplier: seasonMult * gameState.frenzyMultiplier,
      shrineMultiplier: gameState.shrineMultiplier,
    );

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
                ResourcePulseChip(
                  type: GameIconType.food,
                  value: resources.food,
                  color: const Color(0xFFFBBF24),
                  rate: netRates.food,
                ),
                const SizedBox(width: 6),
                ResourcePulseChip(
                  type: GameIconType.wood,
                  value: resources.wood,
                  color: const Color(0xFFD97706),
                  rate: netRates.wood,
                ),
                const SizedBox(width: 6),
                if (resources.stone > 0 || gameState.progression.castleLevel >= 2) ...[
                  ResourcePulseChip(
                    type: GameIconType.stone,
                    value: resources.stone,
                    color: const Color(0xFF94A3B8),
                    rate: netRates.stone,
                  ),
                  const SizedBox(width: 6),
                ],
                ResourcePulseChip(
                  type: GameIconType.crown,
                  value: resources.crowns.toDouble(),
                  color: const Color(0xFFFFD700),
                  isInt: true,
                ),
                const SizedBox(width: 6),
                _buildLandChip(gameState.progression.ownedCount),
                const SizedBox(width: 8),

                // İkincil kaynak çekmecesi butonu
                _buildIconButton(
                  icon: Icon(
                    _isDrawerExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      _isDrawerExpanded = !_isDrawerExpanded;
                    });
                  },
                  tooltip: 'Genişletilmiş Envanter',
                ),
                const SizedBox(width: 5),

                // Pazar Butonu (Vector Terazi)
                _buildIconButton(
                  icon: const GameVectorIcon(type: GameIconType.market, size: 15),
                  onPressed: widget.onOpenMarket,
                  tooltip: GameLocalization.get('market_title', lang: lang),
                ),
                const SizedBox(width: 5),

                // Töre Butonu (Vector Parşömen)
                _buildIconButton(
                  icon: const GameVectorIcon(type: GameIconType.tore, size: 15),
                  onPressed: widget.onOpenTore,
                  tooltip: GameLocalization.get('tore_title', lang: lang),
                ),
                const SizedBox(width: 6),

                // Frenzy Butonu (TactileNeoButton)
                TactileNeoButton(
                  onTap: () {
                    ref.read(gameStateProvider.notifier).activateFrenzy();
                  },
                  backgroundColor: gameState.frenzyTimer > 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF8B5CF6),
                  shadowOffset: 2.0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GameVectorIcon(type: GameIconType.frenzy, size: 13, color: Colors.white),
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
                const SizedBox(width: 5),

                // Ayarlar butonu (Vector Çark)
                _buildIconButton(
                  icon: const GameVectorIcon(type: GameIconType.settings, size: 15),
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
                  ResourcePulseChip(
                    type: GameIconType.flour,
                    value: resources.flour,
                    color: const Color(0xFFFEF08A),
                    rate: netRates.flour,
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.plank,
                    value: resources.plank,
                    color: const Color(0xFFD97706),
                    rate: netRates.plank,
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.bread,
                    value: resources.bread,
                    color: const Color(0xFFF59E0B),
                    rate: netRates.bread,
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.furniture,
                    value: resources.furniture,
                    color: const Color(0xFFB45309),
                    rate: netRates.furniture,
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.iron,
                    value: resources.iron,
                    color: const Color(0xFFCBD5E1),
                    rate: netRates.iron,
                  ),
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
    return TactileNeoButton(
      onTap: onPressed,
      backgroundColor: const Color(0xFF334155),
      borderColor: Colors.black,
      shadowOffset: 2.0,
      padding: const EdgeInsets.all(6),
      child: Tooltip(
        message: tooltip,
        child: icon,
      ),
    );
  }

  Widget _buildLandChip(int count) {
    final lang = ref.watch(gameStateProvider).settings.language;
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
            GameLocalization.get('land', lang: lang).toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
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

/// Kaynak Değişim Nabzı Animasyonlu Çip
class ResourcePulseChip extends StatefulWidget {
  final GameIconType type;
  final double value;
  final Color color;
  final bool isInt;
  final double? rate;

  const ResourcePulseChip({
    super.key,
    required this.type,
    required this.value,
    required this.color,
    this.isInt = false,
    this.rate,
  });

  @override
  State<ResourcePulseChip> createState() => _ResourcePulseChipState();
}

class _ResourcePulseChipState extends State<ResourcePulseChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  double _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _colorAnimation = ColorTween(
      begin: const Color(0xFF0F172A),
      end: const Color(0xFF0F172A),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant ResourcePulseChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.value - oldWidget.value).abs() >= 0.1) {
      final bool increased = widget.value > oldWidget.value;
      _lastValue = widget.value;
      _colorAnimation = ColorTween(
        begin: increased ? const Color(0xFF78350F) : const Color(0xFF7F1D1D),
        end: const Color(0xFF0F172A),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRate = widget.rate != null && widget.rate!.abs() >= 0.01;
    final bool isPositive = widget.rate != null && widget.rate! > 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: _colorAnimation.value ?? const Color(0xFF0F172A),
            borderRadius: NeoBrutalistTheme.sharpRadius,
            border: Border.all(
              color: _controller.isAnimating
                  ? (widget.value >= _lastValue ? const Color(0xFFD97706) : const Color(0xFFEF4444))
                  : Colors.black,
              width: 1.8,
            ),
            boxShadow: NeoBrutalistTheme.hardShadowSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameVectorIcon(type: widget.type, size: 14),
              const SizedBox(width: 5),
              Text(
                widget.isInt ? widget.value.toInt().toString() : widget.value.toStringAsFixed(1),
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              if (hasRate) ...[
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${widget.rate!.toStringAsFixed(1)}/s',
                  style: TextStyle(
                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
