import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/building_model.dart';
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

              // Header: Biyom Adı, Durum ve Kapat Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _getBiomeVectorIcon(tile.biome),
                      const SizedBox(width: 8),
                      Text(
                        _getBiomeTitle(tile.biome, lang),
                        style: NeoBrutalistTheme.fontHeaderMonolith,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tile.isOwned ? const Color(0xFF10B981) : const Color(0xFF64748B),
                          borderRadius: NeoBrutalistTheme.sharpRadius,
                          border: Border.all(color: Colors.black, width: 1.5),
                          boxShadow: NeoBrutalistTheme.hardShadowSmall,
                        ),
                        child: Text(
                          tile.isOwned ? 'SAHİPLİ' : 'KEŞFEDİLDİ',
                          style: NeoBrutalistTheme.fontBadge.copyWith(color: Colors.black),
                        ),
                      ),
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
    final double cost = notifier.calculateExpansionCost(tile.biome);
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
      HexTileModel tile, dynamic gameState, String lang) {
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
              ? 'Seviye 2\'de Oduncu Kulübesi & Kule açılır!'
              : (lvl == 2
                  ? 'Seviye 3\'te Değirmen, Fırın, Maden & Köprü açılır!'
                  : (lvl == 3
                      ? 'Seviye 4\'te Mobilyacı & Kağan Unvanı açılır!'
                      : 'Maksimum Krallık Gücü!')),
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
      HexTileModel tile, dynamic gameState, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final b = tile.building!;
    final double cost = b.upgradeCost;
    final bool canUpgrade = gameState.resources.food >= cost;
    final bool hasAccum = b.accumulatedResource > 0;
    final bool isWinter = gameState.season.current == 'WINTER';
    final bool canWarm = isWinter && !tile.isWarmed && gameState.resources.wood >= 5.0;

    final neighborTiles = tile.coord.neighbors
        .map((nc) => gameState.tiles[nc] as HexTileModel?)
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
              '${b.type.name.toUpperCase()} (LV.${b.level})',
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
                child: const Text(
                  'ISIT (5 ODUN)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBuildOptionsSection(BuildContext context, WidgetRef ref,
      HexTileModel tile, dynamic gameState, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final available = _getAvailableBuildingsForBiome(tile.biome);
    final int castleLvl = gameState.progression.castleLevel;

    final neighborTiles = tile.coord.neighbors
        .map((nc) => gameState.tiles[nc] as HexTileModel?)
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
                          'Bu yapı için Kale Seviye $requiredLvl gereklidir!');
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
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
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
        hint = "HexRush'a hoş geldin! Öncelikle boş bir Çayır (Sarı) arazisi seç.";
        break;
      case 1:
        hint = "Harika! Şimdi 'FETHET' diyerek bu toprağı krallığına kat.";
        break;
      case 2:
        hint = "Toprak artık senin! Şimdi buraya bir 'Mısır Tarlası' inşa et.";
        break;
      case 3:
        hint = "Üretime başladık! Ürünleri otomatik toplamak için bir 'İşçi Kulübesi' inşa et.";
        break;
      case 4:
        hint = "İşçiler çalışıyor! Biriken ürünleri manuel toplamak için tarlaya tıkla.";
        break;
      case 5:
        hint = "Harika! Şimdi odun lazım. Bir Orman (Yeşil) arazisi seç ve fethet.";
        break;
      case 6:
        hint = "Orman seçildi! Şimdi 'FETHET' butonuyla krallığına kat.";
        break;
      case 7:
        hint = "Şimdi de buraya bir 'Oduncu Kulübesi' inşa ederek odun üretimine başla.";
        break;
      case 8:
        hint = "Başlangıç eğitimini tamamladın! Şatoyu yükselterek yeni binalar açabilirsin. İyi oyunlar!";
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
    }
  }

  int _getRequiredCastleLevel(BuildingType type) {
    switch (type) {
      case BuildingType.corn:
      case BuildingType.worker:
        return 1;
      case BuildingType.lumberjack:
      case BuildingType.sawmill:
      case BuildingType.watchtower:
        return 2;
      case BuildingType.windmill:
      case BuildingType.bakery:
      case BuildingType.mine:
      case BuildingType.bridge:
      case BuildingType.fisherman:
      case BuildingType.fishermanHut:
        return 3;
      case BuildingType.furniture:
        return 4;
      case BuildingType.castle:
        return 1;
    }
  }

  List<BuildingType> _getAvailableBuildingsForBiome(TileBiome biome) {
    switch (biome) {
      case TileBiome.meadow:
        return [
          BuildingType.corn,
          BuildingType.windmill,
          BuildingType.bakery,
          BuildingType.worker,
          BuildingType.watchtower,
        ];
      case TileBiome.forest:
        return [
          BuildingType.lumberjack,
          BuildingType.sawmill,
          BuildingType.furniture,
          BuildingType.worker,
        ];
      case TileBiome.mountain:
        return [
          BuildingType.mine,
          BuildingType.watchtower,
        ];
      case TileBiome.sea:
        return [
          BuildingType.bridge,
          BuildingType.fisherman,
          BuildingType.fishermanHut,
        ];
      case TileBiome.desert:
        return [
          BuildingType.windmill,
          BuildingType.worker,
          BuildingType.watchtower,
        ];
      case TileBiome.tundra:
        return [
          BuildingType.mine,
          BuildingType.worker,
          BuildingType.watchtower,
        ];
      case TileBiome.volcano:
        return [
          BuildingType.mine,
          BuildingType.watchtower,
          BuildingType.worker,
        ];
      case TileBiome.wetland:
        return [
          BuildingType.bridge,
          BuildingType.fisherman,
          BuildingType.fishermanHut,
          BuildingType.worker,
        ];
    }
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
    }
  }

  String _getBuildingName(BuildingType type, String lang) {
    switch (type) {
      case BuildingType.castle:
        return GameLocalization.get('castle_title', lang: lang);
      case BuildingType.corn:
        return GameLocalization.get('corn_name', lang: lang);
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
    }
  }
}
