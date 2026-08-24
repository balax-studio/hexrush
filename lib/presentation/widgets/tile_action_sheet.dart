import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/hex_tile_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';

class TileActionSheet extends ConsumerWidget {
  const TileActionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final selectedCoord = gameState.selectedCoord;
    if (selectedCoord == null) return const SizedBox.shrink();

    final tile = gameState.tiles[selectedCoord];
    if (tile == null || tile.isFog) return const SizedBox.shrink();

    final lang = gameState.settings.language;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
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
            // Header: Biyom Adı ve Kapat Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _getBiomeVectorIcon(tile.biome),
                    const SizedBox(width: 8),
                    Text(
                      _getBiomeTitle(tile.biome, lang),
                      style: NeoBrutalistTheme.fontTitle,
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
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
                              style: const TextStyle(
                                color: Colors.black,
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: NeoBrutalistTheme.hardShadowSmall,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).clearSelection();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
            const SizedBox(height: 12),

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
    );
  }

  Widget _buildConquerSection(
      BuildContext context, WidgetRef ref, HexTileModel tile, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final double cost = notifier.calculateExpansionCost(tile.biome);
    final double currentFood = ref.watch(gameStateProvider).resources.food;
    final bool canAfford = currentFood >= cost;

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
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            notifier.conquerTile(tile.coord);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? const Color(0xFFFFC700) : const Color(0xFF475569),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: const RoundedRectangleBorder(
              borderRadius: NeoBrutalistTheme.sharpRadius,
              side: BorderSide(color: Colors.black, width: 2),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GameVectorIcon(type: GameIconType.land, size: 16, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                GameLocalization.get('conquer', lang: lang).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCastleSection(BuildContext context, WidgetRef ref,
      HexTileModel tile, dynamic gameState, String lang) {
    final notifier = ref.read(gameStateProvider.notifier);
    final int lvl = gameState.progression.castleLevel;
    final double nextFood = 50.0 * (lvl == 1 ? 1.0 : (lvl == 2 ? 1.5 : 2.25));
    final double nextWood = 25.0 * (lvl == 1 ? 1.0 : (lvl == 2 ? 1.5 : 2.25));
    final bool canAfford = gameState.resources.food >= nextFood &&
        gameState.resources.wood >= nextWood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${GameLocalization.get('global_bonus', lang: lang)}: +${((lvl - 1) * 25)}%',
          style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w900),
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
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => notifier.upgradeCastle(),
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? const Color(0xFF8B5CF6) : const Color(0xFF475569),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: const RoundedRectangleBorder(
              borderRadius: NeoBrutalistTheme.sharpRadius,
              side: BorderSide(color: Colors.black, width: 2),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GameVectorIcon(type: GameIconType.crown, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '${GameLocalization.get('upgrade', lang: lang).toUpperCase()} (${nextFood.toInt()} GIDA + ${nextWood.toInt()} ODUN)',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.3),
              ),
            ],
          ),
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${b.type.name.toUpperCase()} (LV.${b.level})',
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 14,
                  fontWeight: FontWeight.w900),
            ),
            Text(
              '+${b.currentProductionRate.toStringAsFixed(2)}${GameLocalization.get('per_sec', lang: lang)}',
              style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        if (hasAccum) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BİRİKMİŞ STOK:',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
              Text(
                '+${b.accumulatedResource.toStringAsFixed(1)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            if (hasAccum) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => notifier.collectFromTile(tile.coord),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    GameLocalization.get('collect', lang: lang).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () => notifier.upgradeBuilding(tile.coord),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canUpgrade ? const Color(0xFFFFC700) : const Color(0xFF475569),
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    side: BorderSide(color: Colors.black, width: 2),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '${GameLocalization.get('upgrade', lang: lang).toUpperCase()} (${cost.toInt()})',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ),
            if (isWinter && !tile.isWarmed) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: canWarm ? () => notifier.warmTile(tile.coord) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canWarm ? const Color(0xFFF97316) : const Color(0xFF475569),
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    side: BorderSide(color: Colors.black, width: 2),
                  ),
                  elevation: 0,
                ),
                child: const Text('ISIT (5 ODUN)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İNŞA EDİLEBİLİR YAPILAR:',
          style: TextStyle(
              color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.4),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: available.map((type) {
            final dummy = BuildingModel(type: type);
            final int requiredLvl = _getRequiredCastleLevel(type);
            final bool isUnlocked = castleLvl >= requiredLvl;
            final bool canAfford = gameState.resources.food >= dummy.baseCost;

            return InkWell(
              onTap: isUnlocked
                  ? () => notifier.buildStructure(tile.coord, type)
                  : () {
                      notifier.showToast('Bu yapı için Kale Seviye $requiredLvl gereklidir!');
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: !isUnlocked
                      ? const Color(0xFF0F172A)
                      : (canAfford ? const Color(0xFF1E3A8A) : const Color(0xFF334155)),
                  borderRadius: NeoBrutalistTheme.sharpRadius,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.8,
                  ),
                  boxShadow: NeoBrutalistTheme.hardShadowSmall,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getBuildingVectorIcon(type, isUnlocked),
                    const SizedBox(width: 6),
                    Text(
                      isUnlocked
                          ? '${_getBuildingName(type, lang)} (${dummy.baseCost.toInt()})'
                          : '${_getBuildingName(type, lang)} (LV.$requiredLvl)',
                      style: TextStyle(
                        color: !isUnlocked
                            ? Colors.grey.shade500
                            : (canAfford ? Colors.white : Colors.white70),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
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
        ];
    }
  }

  Widget _getBiomeVectorIcon(TileBiome biome) {
    switch (biome) {
      case TileBiome.meadow:
        return const GameVectorIcon(type: GameIconType.food, size: 18);
      case TileBiome.forest:
        return const GameVectorIcon(type: GameIconType.wood, size: 18);
      case TileBiome.mountain:
        return const GameVectorIcon(type: GameIconType.stone, size: 18);
      case TileBiome.sea:
        return const GameVectorIcon(type: GameIconType.winter, size: 18);
    }
  }

  Widget _getBuildingVectorIcon(BuildingType type, bool isUnlocked) {
    if (!isUnlocked) {
      return const Icon(Icons.lock, size: 14, color: Colors.grey);
    }
    switch (type) {
      case BuildingType.castle:
        return const GameVectorIcon(type: GameIconType.crown, size: 14);
      case BuildingType.corn:
        return const GameVectorIcon(type: GameIconType.food, size: 14);
      case BuildingType.lumberjack:
        return const GameVectorIcon(type: GameIconType.wood, size: 14);
      case BuildingType.windmill:
        return const GameVectorIcon(type: GameIconType.flour, size: 14);
      case BuildingType.sawmill:
        return const GameVectorIcon(type: GameIconType.plank, size: 14);
      case BuildingType.bakery:
        return const GameVectorIcon(type: GameIconType.bread, size: 14);
      case BuildingType.furniture:
        return const GameVectorIcon(type: GameIconType.furniture, size: 14);
      case BuildingType.worker:
        return const GameVectorIcon(type: GameIconType.land, size: 14);
      case BuildingType.watchtower:
        return const GameVectorIcon(type: GameIconType.frenzy, size: 14);
      case BuildingType.mine:
        return const GameVectorIcon(type: GameIconType.iron, size: 14);
      case BuildingType.bridge:
        return const GameVectorIcon(type: GameIconType.land, size: 14);
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
    }
  }
}
