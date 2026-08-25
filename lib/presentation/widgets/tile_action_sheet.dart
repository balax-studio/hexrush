import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/hex_tile_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class TileActionSheet extends ConsumerStatefulWidget {
  const TileActionSheet({super.key});

  @override
  ConsumerState<TileActionSheet> createState() => _TileActionSheetState();
}

class _TileActionSheetState extends ConsumerState<TileActionSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: NeoBrutalistTheme.springSlideCurve,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final selectedCoord = gameState.selectedCoord;

    if (selectedCoord == null) {
      if (_slideController.isCompleted) {
        _slideController.reverse();
      }
      return const SizedBox.shrink();
    }

    final tile = gameState.tiles[selectedCoord];
    if (tile == null || tile.isFog) {
      return const SizedBox.shrink();
    }

    if (!_slideController.isAnimating && _slideController.value == 0.0) {
      _slideController.forward();
    }

    final lang = gameState.settings.language;

    return SlideTransition(
      position: _slideAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
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
              // Tutorial Hint Section
              if (gameState.progression.tutorialStep < 9)
                _buildTutorialHint(gameState.progression.tutorialStep, lang),

              // Header: Yapı/Biyom Adı, Durum ve Kapat Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (tile.building?.type == BuildingType.castle)
                          const GameVectorIcon(type: GameIconType.crown, size: 18, color: Color(0xFFFFD700))
                        else if (tile.hasBuilding)
                          _getBuildingVectorIcon(tile.building!.type, true)
                        else if (tile.hasShrine)
                          const GameVectorIcon(type: GameIconType.crown, size: 18, color: Color(0xFFFFD700))
                        else
                          _getBiomeVectorIcon(tile.biome),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            tile.building?.type == BuildingType.castle
                                ? '${GameLocalization.get('castle_title', lang: lang).toUpperCase()} (LV.${gameState.progression.castleLevel})'
                                : (tile.hasBuilding
                                    ? '${_getBuildingName(tile.building!.type, lang).toUpperCase()} (LV.${tile.building!.level})'
                                    : (tile.hasShrine
                                        ? 'KUTLU TAPINAK'
                                        : _getBiomeTitle(tile.biome, lang))),
                            style: NeoBrutalistTheme.fontHeaderMonolith,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tile.building?.type == BuildingType.castle
                                ? const Color(0xFF8B5CF6)
                                : (tile.isOwned ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                            borderRadius: NeoBrutalistTheme.sharpRadius,
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: NeoBrutalistTheme.hardShadowSmall,
                          ),
                          child: Text(
                            tile.building?.type == BuildingType.castle
                                ? 'KAĞAN OTAĞI'
                                : (tile.isOwned ? 'SAHİPLİ' : 'KEŞFEDİLDİ'),
                            style: NeoBrutalistTheme.fontBadge.copyWith(
                              color: tile.building?.type == BuildingType.castle ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (tile.hasBuilding && tile.building?.type != BuildingType.castle) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: NeoBrutalistTheme.sharpRadius,
                              border: Border.all(color: const Color(0xFF475569), width: 1),
                            ),
                            child: Text(
                              _getBiomeTitle(tile.biome, lang),
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                        if (tile.isWarmed) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              borderRadius: NeoBrutalistTheme.sharpRadius,
                              border: Border.all(color: Colors.black, width: 1.5),
                              boxShadow: NeoBrutalistTheme.hardShadowSmall,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const GameVectorIcon(type: GameIconType.frenzy, size: 10, color: Colors.black),
                                const SizedBox(width: 4),
                                Text(
                                  'ISITILDI (${tile.warmTimer.toInt()}s)',
                                  style: NeoBrutalistTheme.fontBadge.copyWith(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TactileNeoButton(
                    onTap: () {
                      ref.read(gameStateProvider.notifier).clearSelection();
                    },
                    backgroundColor: const Color(0xFF334155),
                    shadowOffset: 2.0,
                    padding: const EdgeInsets.all(5),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
              const SizedBox(height: 10),

              // Durum 1: Keşfedilmiş ama Sahipsiz (Fethet Butonu)
              if (!tile.isOwned) ...[
                _buildConquerSection(context, ref, tile, lang),
              ]
              // Durum 2: Sahipli ve Şato
              else if (tile.building?.type == BuildingType.castle) ...[
                _buildCastleSection(context, ref, tile, gameState, lang),
              ]
              // Durum 3: Sahipli ve Üretim Binası Var
              else if (tile.hasBuilding) ...[
                _buildBuildingDetailSection(context, ref, tile, gameState, lang),
              ]
              // Durum 4: Sahipli ve Boş (İnşaat Seçenekleri)
              else ...[
                _buildBuildOptionsSection(context, ref, tile, gameState, lang),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConquerSection(
      BuildContext context, WidgetRef ref, HexTileModel tile, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final double cost = notifier.calculateExpansionCost(tile.coord);
    final double currentFood = ref.watch(gameStateProvider).resources.food;
    final bool canAfford = currentFood >= cost;
    final double deficit = cost - currentFood;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${GameLocalization.get('cost', lang: lang)}:',
              style: NeoBrutalistTheme.fontLabel,
            ),
            Row(
              children: [
                const GameVectorIcon(type: GameIconType.food, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${cost.toInt()} ${GameLocalization.get('food', lang: lang)}',
                  style: TextStyle(
                    color: canAfford ? const Color(0xFFFBBF24) : const Color(0xFFEF4444),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!canAfford) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xFFEF4444), width: 1),
                    ),
                    child: Text(
                      'Eksik: -${deficit.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TactileNeoButton(
            onTap: canAfford ? () => notifier.conquerTile(tile.coord) : null,
            isEnabled: canAfford,
            backgroundColor: const Color(0xFFFFC700),
            borderColor: Colors.black,
            shadowColor: const Color(0xFF78350F),
            padding: const EdgeInsets.symmetric(vertical: 10),
            soundType: TactileSoundType.conquer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GameVectorIcon(type: GameIconType.land, size: 16, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  GameLocalization.get('conquer', lang: lang).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCastleSection(BuildContext context, WidgetRef ref,
      HexTileModel tile, GameState gameState, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final int lvl = gameState.progression.castleLevel;
    final int nextLvl = lvl + 1;
    final costs = EconomyCalculator.getCastleUpgradeCost(nextLvl);
    final double nextFood = costs['food']!;
    final double nextWood = costs['wood']!;

    final bool canAfford = gameState.resources.food >= nextFood &&
        gameState.resources.wood >= nextWood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${GameLocalization.get('global_bonus', lang: lang)}: +${((lvl - 1) * 25)}%',
          style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 13,
              fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          lvl == 1
              ? 'Seviye 2\'de Hızar Otağı, Vaha Sarnıcı & Kule açılır!'
              : (lvl == 2
                  ? 'Seviye 3\'te Yel Değirmeni, Köz Fırını, Maden, Kervansaray & Köprü açılır!'
                  : (lvl == 3
                      ? 'Seviye 4\'te Marangoz Otağı, Gök Gözlemevi & Kağan Unvanı açılır!'
                      : 'Azami Otağ Kudreti!')),
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TactileNeoButton(
                onTap: canAfford ? () => notifier.upgradeCastle() : null,
                isEnabled: canAfford,
                backgroundColor: const Color(0xFF8B5CF6),
                borderColor: Colors.black,
                shadowColor: const Color(0xFF4C1D95),
                padding: const EdgeInsets.symmetric(vertical: 10),
                soundType: TactileSoundType.upgrade,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const GameVectorIcon(type: GameIconType.crown, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '${GameLocalization.get('upgrade', lang: lang).toUpperCase()} (${nextFood.toInt()} GIDA${nextWood > 0 ? ' + ${nextWood.toInt()} ODUN' : ''})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TactileNeoButton(
                onTap: () => notifier.collectFromTile(tile.coord),
                backgroundColor: const Color(0xFF10B981),
                borderColor: Colors.black,
                shadowColor: const Color(0xFF065F46),
                padding: const EdgeInsets.symmetric(vertical: 10),
                soundType: TactileSoundType.tap,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameVectorIcon(type: GameIconType.food, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      'İAŞE (+1)',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBuildingDetailSection(BuildContext context, WidgetRef ref,
      HexTileModel tile, GameState gameState, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final b = tile.building!;
    final double cost = b.upgradeCost;
    final bool canUpgrade = gameState.resources.food >= cost;
    final bool hasAccum = b.accumulatedResource > 0;
    final bool isWinter = gameState.season.current == 'WINTER';
    final double warmWoodCost =
        EconomyCalculator.getWinterWarmWoodCost(notifier.getActiveDoctrines());
    final bool canWarm =
        isWinter && !tile.isWarmed && gameState.resources.wood >= warmWoodCost;

    final neighborTiles = tile.coord.neighbors
        .map((nc) => gameState.tiles[nc])
        .whereType<HexTileModel>()
        .toList();

    final activeSynergies = EconomyCalculator.getActiveSynergyLabels(
      targetTile: tile,
      neighborTiles: neighborTiles,
      season: gameState.season.current,
      isZud: gameState.season.isZud,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getBuildingName(b.type, lang).toUpperCase()} (LV.${b.level})',
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 13,
                  fontWeight: FontWeight.w900),
            ),
            Text(
              '+${b.currentProductionRate.toStringAsFixed(2)}${GameLocalization.get('per_sec', lang: lang)}',
              style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        if (activeSynergies.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: NeoBrutalistTheme.sharpRadius,
              border: Border.all(
                color: activeSynergies.any((s) => s.startsWith('+'))
                    ? const Color(0xFFD97706)
                    : const Color(0xFF334155),
                width: 1.5,
              ),
              boxShadow: activeSynergies.any((s) => s.startsWith('+'))
                  ? NeoBrutalistTheme.hardShadowSmall
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeSynergies.any((s) => s.startsWith('+')))
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GameVectorIcon(
                          type: GameIconType.crown,
                          size: 10,
                          color: Color(0xFFD97706),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'SİNERJİ PARILTISI',
                          style: TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: activeSynergies.map((label) {
                    final isPositive = label.startsWith('+');
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                        border: Border.all(
                          color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPositive ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
        // Arazi Uzmanlaşması Rozeti (Biome Mastery)
        if (tile.isOwned) ...[
          () {
            final biomeCount = gameState.progression.cumulativeBiomeCounts[tile.biome.name] ?? 0;
            if (biomeCount >= 5) {
              final isLevel2 = biomeCount >= 10;
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(
                      color: isLevel2 ? const Color(0xFFFFD700) : const Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GameVectorIcon(
                        type: GameIconType.land,
                        size: 11,
                        color: isLevel2 ? const Color(0xFFFFD700) : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isLevel2
                            ? 'ARAZİ UZMANLIĞI: SEVİYE 2 (+%10 VERİM)'
                            : 'ARAZİ UZMANLIĞI: SEVİYE 1 (+%5 VERİM)',
                        style: TextStyle(
                          color: isLevel2 ? const Color(0xFFFFD700) : const Color(0xFF10B981),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }(),
        ],
        if (hasAccum) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BİRİKMİŞ STOK:',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800)),
              Text(
                '+${b.accumulatedResource.toStringAsFixed(1)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            if (hasAccum) ...[
              Expanded(
                child: TactileNeoButton(
                  onTap: () => notifier.collectFromTile(tile.coord),
                  backgroundColor: const Color(0xFF10B981),
                  borderColor: Colors.black,
                  shadowOffset: 2.5,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  soundType: TactileSoundType.tap,
                  child: Center(
                    child: Text(
                      GameLocalization.get('collect', lang: lang).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TactileNeoButton(
                onTap: canUpgrade ? () => notifier.upgradeBuilding(tile.coord) : null,
                isEnabled: canUpgrade,
                backgroundColor: const Color(0xFFFFC700),
                borderColor: Colors.black,
                shadowOffset: 2.5,
                padding: const EdgeInsets.symmetric(vertical: 8),
                soundType: TactileSoundType.upgrade,
                child: Center(
                  child: Text(
                    '${GameLocalization.get('upgrade', lang: lang).toUpperCase()} (${cost.toInt()})',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
            if (isWinter && !tile.isWarmed) ...[
              const SizedBox(width: 8),
              TactileNeoButton(
                onTap: canWarm ? () => notifier.warmTile(tile.coord) : null,
                isEnabled: canWarm,
                backgroundColor: const Color(0xFFF97316),
                borderColor: Colors.black,
                shadowOffset: 2.5,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                soundType: TactileSoundType.tap,
                child: Text(
                  'ISIT (${warmWoodCost.toInt()} ODUN)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
            if (b.type != BuildingType.castle) ...[
              const SizedBox(width: 8),
              TactileNeoButton(
                onTap: () => _confirmDemolish(context, notifier, tile, b),
                backgroundColor: const Color(0xFFDC2626),
                borderColor: Colors.black,
                shadowOffset: 2.5,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                soundType: TactileSoundType.tap,
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _confirmDemolish(BuildContext context, GameStateNotifier notifier,
      HexTileModel tile, BuildingModel b) {
    final lang = ref.read(gameStateProvider).settings.language;
    final double refund = (b.baseCost * 0.5).roundToDouble();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: NeoBrutalistTheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: NeoBrutalistTheme.standardRadius,
          side: BorderSide(color: Colors.black, width: 2.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: NeoBrutalistTheme.surface,
            borderRadius: NeoBrutalistTheme.standardRadius,
            boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'YAPIYI KALDIR: ${_getBuildingName(b.type, lang).toUpperCase()}',
                style: NeoBrutalistTheme.fontHeaderMonolith,
              ),
              const SizedBox(height: 10),
              Text(
                'Bu yapıyı kaldırarak toprağı boşaltmak istiyor musunuz? İade: +${refund.toInt()} Gıda.',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TactileNeoButton(
                      onTap: () => Navigator.of(ctx).pop(),
                      backgroundColor: const Color(0xFF334155),
                      borderColor: Colors.black,
                      shadowOffset: 2.0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Center(
                        child: Text(
                          'VAZGEÇ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TactileNeoButton(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        notifier.demolishBuilding(tile.coord);
                      },
                      backgroundColor: const Color(0xFFDC2626),
                      borderColor: Colors.black,
                      shadowOffset: 2.0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Center(
                        child: Text(
                          'YIK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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
        ),
      ),
    );
  }

  Widget _buildBuildOptionsSection(BuildContext context, WidgetRef ref,
      HexTileModel tile, GameState gameState, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final available = _getAvailableBuildingsForBiome(tile.biome);
    final int castleLvl = gameState.progression.castleLevel;

    final neighborTiles = tile.coord.neighbors
        .map((nc) => gameState.tiles[nc])
        .whereType<HexTileModel>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İNŞA EDİLEBİLİR YAPILAR:',
          style: TextStyle(
              color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.4),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: available.map((type) {
            final dummy = BuildingModel(type: type);
            final int requiredLvl = _getRequiredCastleLevel(type);
            final bool isUnlocked = castleLvl >= requiredLvl;
            final bool canAfford = gameState.resources.food >= dummy.baseCost;

            final previewTile = tile.copyWith(
              building: BuildingModel(type: type, level: 1),
            );
            final previewSynergies = EconomyCalculator.getActiveSynergyLabels(
              targetTile: previewTile,
              neighborTiles: neighborTiles,
              season: gameState.season.current,
              isZud: gameState.season.isZud,
            );

            return TactileNeoButton(
              onTap: isUnlocked
                  ? () => notifier.buildStructure(tile.coord, type)
                  : () {
                      notifier.showToast(
                          'Bu yapı için Kağan Otağı Seviye $requiredLvl gereklidir!');
                    },
              backgroundColor: !isUnlocked
                  ? const Color(0xFF0F172A)
                  : (canAfford ? const Color(0xFF1E3A8A) : const Color(0xFF334155)),
              borderColor: Colors.black,
              shadowOffset: 2.0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              soundType: TactileSoundType.build,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getBuildingVectorIcon(type, isUnlocked),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isUnlocked
                                ? '${_getBuildingName(type, lang)} (${dummy.baseCost.toInt()})'
                                : '${_getBuildingName(type, lang)} (LV.$requiredLvl)',
                            style: TextStyle(
                              color: !isUnlocked
                                  ? Colors.grey.shade500
                                  : (canAfford ? Colors.white : Colors.white70),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (previewSynergies.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: previewSynergies.first.startsWith('+')
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFF7F1D1D),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                previewSynergies.first.split(' ').first,
                                style: TextStyle(
                                  color: previewSynergies.first.startsWith('+')
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFFFCA5A5),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _getBuildingDescription(type, lang),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTutorialHint(int step, String lang) {
    String hint = "";
    switch (step) {
      case 0:
        hint = "Ötüken ovasında ilk obanı kurmak için bitişikteki boş bir Çayır arazisi seç.";
        break;
      case 1:
        hint = "Seçilen bozkır toprağını 'FETHET' emriyle obanın sınırlarına dahil et.";
        break;
      case 2:
        hint = "Kutlu toprağa erzak ambarı kurmak için 'Buğday Tarlası' inşa et.";
        break;
      case 3:
        hint = "Hasadı düzenli toplamak için araziye 'İşçi Kulübesi' dik.";
        break;
      case 4:
        hint = "Biriken buğday ve erzakı doğrudan toplamak için tarlaya dokun.";
        break;
      case 5:
        hint = "Otağı büyütmek ve kışa hazırlanmak için bir Orman arazisi belirle.";
        break;
      case 6:
        hint = "Orman arazisini 'FETHET' emriyle obaya bağla.";
        break;
      case 7:
        hint = "Kereste tedariği için ormana 'Oduncu Kulübesi' kur.";
        break;
      case 8:
        hint = "İlk oba nizamı kuruldu. Kağan Otağını yükselterek töreleri ve yeni yapıları aç.";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: NeoBrutalistTheme.hardShadowSmall,
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.black, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBuildingDescription(BuildingType type, String lang) {
    switch (type) {
      case BuildingType.castle:
        return GameLocalization.get('castle_desc', lang: lang);
      case BuildingType.corn:
        return GameLocalization.get('corn_desc', lang: lang);
      case BuildingType.barley:
        return GameLocalization.get('barley_desc', lang: lang);
      case BuildingType.pasture:
        return GameLocalization.get('pasture_desc', lang: lang);
      case BuildingType.orchard:
        return GameLocalization.get('orchard_desc', lang: lang);
      case BuildingType.quarry:
        return GameLocalization.get('quarry_desc', lang: lang);
      case BuildingType.resinCamp:
        return GameLocalization.get('resin_camp_desc', lang: lang);
      case BuildingType.lumberjack:
        return GameLocalization.get('lumberjack_desc', lang: lang);
      case BuildingType.windmill:
        return GameLocalization.get('windmill_desc', lang: lang);
      case BuildingType.sawmill:
        return GameLocalization.get('sawmill_desc', lang: lang);
      case BuildingType.bakery:
        return GameLocalization.get('bakery_desc', lang: lang);
      case BuildingType.furniture:
        return GameLocalization.get('furniture_desc', lang: lang);
      case BuildingType.worker:
        return GameLocalization.get('worker_desc', lang: lang);
      case BuildingType.watchtower:
        return GameLocalization.get('watchtower_desc', lang: lang);
      case BuildingType.mine:
        return GameLocalization.get('mine_desc', lang: lang);
      case BuildingType.bridge:
        return GameLocalization.get('bridge_desc', lang: lang);
      case BuildingType.fisherman:
        return GameLocalization.get('fisherman_desc', lang: lang);
      case BuildingType.fishermanHut:
        return GameLocalization.get('fisherman_hut_desc', lang: lang);
      case BuildingType.shrine:
        return 'Kadim güçler barındıran gizemli yapı.';
      // Çöl
      case BuildingType.oasisCistern:
        return GameLocalization.get('oasis_cistern_desc', lang: lang);
      case BuildingType.caravanserai:
        return GameLocalization.get('caravanserai_desc', lang: lang);
      case BuildingType.astrolabe:
        return GameLocalization.get('astrolabe_desc', lang: lang);
      // Tundra
      case BuildingType.reindeerSanctuary:
        return GameLocalization.get('reindeer_sanctuary_desc', lang: lang);
      case BuildingType.geothermalBath:
        return GameLocalization.get('geothermal_bath_desc', lang: lang);
      case BuildingType.permafrostDig:
        return GameLocalization.get('permafrost_dig_desc', lang: lang);
      // Volkan
      case BuildingType.steamVent:
        return GameLocalization.get('steam_vent_desc', lang: lang);
      case BuildingType.obsidianForge:
        return GameLocalization.get('obsidian_forge_desc', lang: lang);
      // Sazlık
      case BuildingType.herbalistYurt:
        return GameLocalization.get('herbalist_yurt_desc', lang: lang);
      case BuildingType.scribeWorkshop:
        return GameLocalization.get('scribe_workshop_desc', lang: lang);
      // Efsanevi
      case BuildingType.celestialAnvil:
        return GameLocalization.get('celestial_anvil_desc', lang: lang);
      case BuildingType.ancestralTotem:
        return GameLocalization.get('ancestral_totem_desc', lang: lang);
      case BuildingType.prismaticResonator:
        return GameLocalization.get('prismatic_resonator_desc', lang: lang);
    }
  }

  int _getRequiredCastleLevel(BuildingType type) {
    return type.requiredCastleLevel;
  }

  List<BuildingType> _getAvailableBuildingsForBiome(TileBiome biome) {
    return GameStateNotifier.getAllowedBuildingsForBiome(biome);
  }

  Widget _getBiomeVectorIcon(TileBiome biome) {
    switch (biome) {
      case TileBiome.meadow:
        return const GameVectorIcon(type: GameIconType.food, size: 16);
      case TileBiome.forest:
        return const GameVectorIcon(type: GameIconType.wood, size: 16);
      case TileBiome.mountain:
        return const GameVectorIcon(type: GameIconType.stone, size: 16);
      case TileBiome.sea:
        return const GameVectorIcon(type: GameIconType.winter, size: 16);
      case TileBiome.desert:
        return const GameVectorIcon(type: GameIconType.desert, size: 16);
      case TileBiome.tundra:
        return const GameVectorIcon(type: GameIconType.tundra, size: 16);
      case TileBiome.volcano:
        return const GameVectorIcon(type: GameIconType.volcano, size: 16);
      case TileBiome.wetland:
        return const GameVectorIcon(type: GameIconType.wetland, size: 16);
      case TileBiome.celestialCrater:
        return const GameVectorIcon(type: GameIconType.frenzy, size: 16, color: Color(0xFF818CF8));
      case TileBiome.kurganValley:
        return const GameVectorIcon(type: GameIconType.crown, size: 16, color: Color(0xFFCBD5E1));
      case TileBiome.crystalChasm:
        return const GameVectorIcon(type: GameIconType.shrine, size: 16, color: Color(0xFFC084FC));
    }
  }

  Widget _getBuildingVectorIcon(BuildingType type, bool isUnlocked) {
    if (!isUnlocked) {
      return const Icon(Icons.lock, size: 13, color: Colors.grey);
    }
    switch (type) {
      case BuildingType.castle:
        return const GameVectorIcon(type: GameIconType.crown, size: 13);
      case BuildingType.corn:
        return const GameVectorIcon(type: GameIconType.food, size: 13);
      case BuildingType.barley:
        return const GameVectorIcon(type: GameIconType.food, size: 13, color: Color(0xFFFBBF24));
      case BuildingType.pasture:
        return const GameVectorIcon(type: GameIconType.land, size: 13, color: Color(0xFF10B981));
      case BuildingType.orchard:
        return const GameVectorIcon(type: GameIconType.food, size: 13, color: Color(0xFFF43F5E));
      case BuildingType.quarry:
        return const GameVectorIcon(type: GameIconType.stone, size: 13, color: Color(0xFF94A3B8));
      case BuildingType.resinCamp:
        return const GameVectorIcon(type: GameIconType.wood, size: 13, color: Color(0xFFB45309));
      case BuildingType.lumberjack:
        return const GameVectorIcon(type: GameIconType.wood, size: 13);
      case BuildingType.windmill:
        return const GameVectorIcon(type: GameIconType.flour, size: 13);
      case BuildingType.sawmill:
        return const GameVectorIcon(type: GameIconType.plank, size: 13);
      case BuildingType.bakery:
        return const GameVectorIcon(type: GameIconType.bread, size: 13);
      case BuildingType.furniture:
        return const GameVectorIcon(type: GameIconType.furniture, size: 13);
      case BuildingType.worker:
        return const GameVectorIcon(type: GameIconType.land, size: 13);
      case BuildingType.watchtower:
        return const GameVectorIcon(type: GameIconType.frenzy, size: 13);
      case BuildingType.mine:
        return const GameVectorIcon(type: GameIconType.iron, size: 13);
      case BuildingType.bridge:
        return const GameVectorIcon(type: GameIconType.land, size: 13);
      case BuildingType.fisherman:
        return const GameVectorIcon(type: GameIconType.food, size: 13);
      case BuildingType.fishermanHut:
        return const GameVectorIcon(type: GameIconType.land, size: 13);
      case BuildingType.shrine:
        return const GameVectorIcon(type: GameIconType.shrine, size: 13);
      // Çöl
      case BuildingType.oasisCistern:
        return const GameVectorIcon(type: GameIconType.food, size: 13, color: Color(0xFF38BDF8));
      case BuildingType.caravanserai:
        return const GameVectorIcon(type: GameIconType.crown, size: 13, color: Color(0xFFF59E0B));
      case BuildingType.astrolabe:
        return const GameVectorIcon(type: GameIconType.frenzy, size: 13, color: Color(0xFFFDE047));
      // Tundra
      case BuildingType.reindeerSanctuary:
        return const GameVectorIcon(type: GameIconType.food, size: 13, color: Color(0xFF93C5FD));
      case BuildingType.geothermalBath:
        return const GameVectorIcon(type: GameIconType.frenzy, size: 13, color: Color(0xFFF97316));
      case BuildingType.permafrostDig:
        return const GameVectorIcon(type: GameIconType.iron, size: 13, color: Color(0xFF60A5FA));
      // Volkan
      case BuildingType.steamVent:
        return const GameVectorIcon(type: GameIconType.stone, size: 13, color: Color(0xFFFB7185));
      case BuildingType.obsidianForge:
        return const GameVectorIcon(type: GameIconType.iron, size: 13, color: Color(0xFFDC2626));
      // Sazlık
      case BuildingType.herbalistYurt:
        return const GameVectorIcon(type: GameIconType.food, size: 13, color: Color(0xFF34D399));
      case BuildingType.scribeWorkshop:
        return const GameVectorIcon(type: GameIconType.plank, size: 13, color: Color(0xFFA7F3D0));
      // Efsanevi
      case BuildingType.celestialAnvil:
        return const GameVectorIcon(type: GameIconType.iron, size: 13, color: Color(0xFF818CF8));
      case BuildingType.ancestralTotem:
        return const GameVectorIcon(type: GameIconType.crown, size: 13, color: Color(0xFFFFD700));
      case BuildingType.prismaticResonator:
        return const GameVectorIcon(type: GameIconType.shrine, size: 13, color: Color(0xFFC084FC));
    }
  }

  String _getBiomeTitle(TileBiome biome, String lang) {
    switch (biome) {
      case TileBiome.meadow:
        return GameLocalization.get('biome_meadow', lang: lang).toUpperCase();
      case TileBiome.forest:
        return GameLocalization.get('biome_forest', lang: lang).toUpperCase();
      case TileBiome.mountain:
        return GameLocalization.get('biome_mountain', lang: lang).toUpperCase();
      case TileBiome.sea:
        return GameLocalization.get('biome_sea', lang: lang).toUpperCase();
      case TileBiome.desert:
        return GameLocalization.get('biome_desert', lang: lang).toUpperCase();
      case TileBiome.tundra:
        return GameLocalization.get('biome_tundra', lang: lang).toUpperCase();
      case TileBiome.volcano:
        return GameLocalization.get('biome_volcano', lang: lang).toUpperCase();
      case TileBiome.wetland:
        return GameLocalization.get('biome_wetland', lang: lang).toUpperCase();
      case TileBiome.celestialCrater:
        return GameLocalization.get('biome_celestial_crater', lang: lang).toUpperCase();
      case TileBiome.kurganValley:
        return GameLocalization.get('biome_kurgan_valley', lang: lang).toUpperCase();
      case TileBiome.crystalChasm:
        return GameLocalization.get('biome_crystal_chasm', lang: lang).toUpperCase();
    }
  }

  String _getBuildingName(BuildingType type, String lang) {
    switch (type) {
      case BuildingType.castle:
        return GameLocalization.get('castle_title', lang: lang);
      case BuildingType.corn:
        return GameLocalization.get('corn_name', lang: lang);
      case BuildingType.barley:
        return GameLocalization.get('barley_name', lang: lang);
      case BuildingType.pasture:
        return GameLocalization.get('pasture_name', lang: lang);
      case BuildingType.orchard:
        return GameLocalization.get('orchard_name', lang: lang);
      case BuildingType.quarry:
        return GameLocalization.get('quarry_name', lang: lang);
      case BuildingType.resinCamp:
        return GameLocalization.get('resin_camp_name', lang: lang);
      case BuildingType.lumberjack:
        return GameLocalization.get('lumberjack_name', lang: lang);
      case BuildingType.windmill:
        return GameLocalization.get('windmill_name', lang: lang);
      case BuildingType.sawmill:
        return GameLocalization.get('sawmill_name', lang: lang);
      case BuildingType.bakery:
        return GameLocalization.get('bakery_name', lang: lang);
      case BuildingType.furniture:
        return GameLocalization.get('furniture_name', lang: lang);
      case BuildingType.worker:
        return GameLocalization.get('worker_name', lang: lang);
      case BuildingType.watchtower:
        return GameLocalization.get('watchtower_name', lang: lang);
      case BuildingType.mine:
        return GameLocalization.get('mine_name', lang: lang);
      case BuildingType.bridge:
        return GameLocalization.get('bridge_name', lang: lang);
      case BuildingType.fisherman:
        return GameLocalization.get('fisherman_name', lang: lang);
      case BuildingType.fishermanHut:
        return GameLocalization.get('fisherman_hut_name', lang: lang);
      case BuildingType.shrine:
        return 'Kadim Sunak';
      // Çöl
      case BuildingType.oasisCistern:
        return GameLocalization.get('oasis_cistern_name', lang: lang);
      case BuildingType.caravanserai:
        return GameLocalization.get('caravanserai_name', lang: lang);
      case BuildingType.astrolabe:
        return GameLocalization.get('astrolabe_name', lang: lang);
      // Tundra
      case BuildingType.reindeerSanctuary:
        return GameLocalization.get('reindeer_sanctuary_name', lang: lang);
      case BuildingType.geothermalBath:
        return GameLocalization.get('geothermal_bath_name', lang: lang);
      case BuildingType.permafrostDig:
        return GameLocalization.get('permafrost_dig_name', lang: lang);
      // Volkan
      case BuildingType.steamVent:
        return GameLocalization.get('steam_vent_name', lang: lang);
      case BuildingType.obsidianForge:
        return GameLocalization.get('obsidian_forge_name', lang: lang);
      // Sazlık
      case BuildingType.herbalistYurt:
        return GameLocalization.get('herbalist_yurt_name', lang: lang);
      case BuildingType.scribeWorkshop:
        return GameLocalization.get('scribe_workshop_name', lang: lang);
      // Efsanevi
      case BuildingType.celestialAnvil:
        return GameLocalization.get('celestial_anvil_name', lang: lang);
      case BuildingType.ancestralTotem:
        return GameLocalization.get('ancestral_totem_name', lang: lang);
      case BuildingType.prismaticResonator:
        return GameLocalization.get('prismatic_resonator_name', lang: lang);
    }
  }
}
