import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../core/hex/hex_math.dart';
import '../../data/save_repository.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/ad_reward_model.dart';
import '../../domain/services/ad_reward_service.dart';
import '../../domain/models/ancestral_kurgan_model.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/caravan_route_model.dart';
import '../../domain/models/celestial_omen_model.dart';
import '../../domain/models/doctrine_model.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/game_state_model.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/hex_tile_model.dart';
import '../../domain/models/quest_model.dart';
import '../../domain/models/trade_order_model.dart';
import '../../domain/models/steppe_lore_tree_model.dart';
import '../../domain/services/symbiosis_engine.dart';

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  Timer? _gameLoopTimer;
  Timer? _autoSaveTimer;
  bool _isSaveDirty = false;
  int _autoSaveTickCounter = 0;

  GameStateNotifier() : super(_createInitialState()) {
    initialize();
  }

  static List<QuestModel> _generateInitialQuests() {
    return const [
      QuestModel(
        id: 'q_corn_1',
        titleTr: 'Bozkırın Ekmeği',
        titleEn: 'Bread of the Steppe',
        descriptionTr: 'Kağanlığı beslemek için 1 adet Buğday Tarlası inşa et.',
        descriptionEn: 'Build 1 Wheat Field to feed your realm.',
        type: QuestType.buildStructure,
        targetBuilding: BuildingType.corn,
        targetAmount: 1,
        rewardType: QuestRewardType.wood,
        rewardAmount: 30,
      ),
      QuestModel(
        id: 'q_conquer_3',
        titleTr: 'Toprakları Genişlet',
        titleEn: 'Expand Territory',
        descriptionTr: 'Sisi yararak toplam 3 karo fethet.',
        descriptionEn: 'Conquer a total of 3 hex tiles.',
        type: QuestType.conquerTiles,
        targetAmount: 3,
        rewardType: QuestRewardType.food,
        rewardAmount: 50,
      ),
      QuestModel(
        id: 'q_lumberjack_1',
        titleTr: 'Kereste Tedariği',
        titleEn: 'Timber Supply',
        descriptionTr: 'Ormana 1 adet Oduncu Kulübesi kur.',
        descriptionEn: 'Build 1 Lumberjack Lodge in the forest.',
        type: QuestType.buildStructure,
        targetBuilding: BuildingType.lumberjack,
        targetAmount: 1,
        rewardType: QuestRewardType.food,
        rewardAmount: 60,
      ),
      QuestModel(
        id: 'q_windmill_1',
        titleTr: 'Değirmen Çarkı',
        titleEn: 'Mill Wheel',
        descriptionTr: 'Buğdayı una dönüştürmek için 1 Değirmen inşa et.',
        descriptionEn: 'Build 1 Windmill to process grain into flour.',
        type: QuestType.buildStructure,
        targetBuilding: BuildingType.windmill,
        targetAmount: 1,
        rewardType: QuestRewardType.wood,
        rewardAmount: 80,
      ),
      QuestModel(
        id: 'q_castle_2',
        titleTr: 'Han Otağı Yükselişi',
        titleEn: 'Seat of the Khan',
        descriptionTr: 'Kağan Otağını Seviye 2\'ye yükselt.',
        descriptionEn: 'Upgrade your Khan\'s Yurt to Level 2.',
        type: QuestType.upgradeCastle,
        targetAmount: 2,
        rewardType: QuestRewardType.crowns,
        rewardAmount: 2,
      ),
      QuestModel(
        id: 'q_bakery_1',
        titleTr: 'Sıcak Tandır',
        titleEn: 'Warm Bakery',
        descriptionTr: 'Unu ekmeğe dönüştürmek için 1 Fırın inşa et.',
        descriptionEn: 'Build 1 Bakery to bake bread from flour.',
        type: QuestType.buildStructure,
        targetBuilding: BuildingType.bakery,
        targetAmount: 1,
        rewardType: QuestRewardType.wood,
        rewardAmount: 100,
      ),
      QuestModel(
        id: 'q_shrine_1',
        titleTr: 'Kadim Rünlerin Gücü',
        titleEn: 'Ancient Rune Power',
        descriptionTr: 'Bozkırda 1 adet Kadim Sunak keşfet ve fethet.',
        descriptionEn: 'Discover and conquer 1 Ancient Shrine.',
        type: QuestType.discoverShrine,
        targetAmount: 1,
        rewardType: QuestRewardType.crowns,
        rewardAmount: 3,
      ),
    ];
  }

  static GameState _createInitialState() {
    final Map<HexAxial, HexTileModel> map = {};
    const int gridRadius = 20; // Harita çapı 20 birim
    final random = math.Random();

    // Biyom Tohumları (Seeds) - Belirgin kümeler oluşturmak için
    // Merkeze uzak ama ulaşılabilir noktalara devasa deniz ve dağ odakları koyuyoruz.
    final seaSeeds = [
      const HexAxial(12, -6),
      const HexAxial(-6, 12),
      const HexAxial(-6, -6),
    ];
    final mountainSeeds = [
      const HexAxial(-12, 6),
      const HexAxial(6, -12),
      const HexAxial(12, 0),
    ];

    // Tüm ızgarayı oluştur
    for (int q = -gridRadius; q <= gridRadius; q++) {
      final int r1 = math.max(-gridRadius, -q - gridRadius);
      final int r2 = math.min(gridRadius, -q + gridRadius);
      for (int r = r1; r <= r2; r++) {
        final coord = HexAxial(q, r);
        final int dist = HexMath.hexDistance(const HexAxial(0, 0), coord);

        TileBiome biome;

        if (coord.q == 0 && coord.r == 0) {
          // Merkez (0,0) - Şato yeri
          biome = TileBiome.meadow;
        } else if (dist == 1) {
          // Radius 1: Ağırlıklı Çayır ve Orman (%80 Çayır, %20 Orman - Yanardağ, Su, Dağ yok)
          biome = random.nextDouble() < 0.80 ? TileBiome.meadow : TileBiome.forest;
        } else if (dist == 2) {
          // Radius 2: Çayır (%65), Orman (%25), Çöl (%10 - Yanardağ, Su, Dağ yok)
          final roll = random.nextDouble();
          if (roll < 0.65) {
            biome = TileBiome.meadow;
          } else if (roll < 0.90) {
            biome = TileBiome.forest;
          } else {
            biome = TileBiome.desert;
          }
        } else if (dist == 3) {
          // Radius 3: Çayır (%50), Orman (%30), Dağ (%10), Çöl (%10)
          final roll = random.nextDouble();
          if (roll < 0.50) {
            biome = TileBiome.meadow;
          } else if (roll < 0.80) {
            biome = TileBiome.forest;
          } else if (roll < 0.90) {
            biome = TileBiome.mountain;
          } else {
            biome = TileBiome.desert;
          }
        } else {
          // 4 ve üzeri: Özel biyom kümeleri veya dengeli bozkır
          // Önce tohumlara yakınlığa bakıyoruz (Deniz ve Dağ kümeleri)
          double minSeaDist = 999;
          for (final s in seaSeeds) {
            minSeaDist = math.min(minSeaDist, HexMath.hexDistance(s, coord).toDouble());
          }

          double minMtnDist = 999;
          for (final m in mountainSeeds) {
            minMtnDist = math.min(minMtnDist, HexMath.hexDistance(m, coord).toDouble());
          }

          if (minSeaDist < 3.5 + random.nextInt(2)) {
            biome = TileBiome.sea;
          } else if (minMtnDist < 3.5 + random.nextInt(2)) {
            biome = TileBiome.mountain;
          } else {
            // Özel biyomlar %50 azaltıldı (Bozkır ve Orman baskın)
            final roll = random.nextDouble();
            if (roll < 0.50) {
              biome = TileBiome.meadow;
            } else if (roll < 0.80) {
              biome = TileBiome.forest;
            } else if (roll < 0.88) {
              biome = TileBiome.desert;
            } else if (roll < 0.93) {
              biome = TileBiome.tundra;
            } else if (roll < 0.97) {
              biome = TileBiome.wetland;
            } else {
              biome = TileBiome.volcano;
            }
          }
        }

        map[coord] = HexTileModel(
          coord: coord,
          biome: biome,
          state: dist <= 4 ? TileState.discovered : TileState.fog,
        );
      }
    }

    // 3 Efsanevi Biyomun Derin Sis Halkasına (Radius 6-8) Yerleştirilmesi
    const craterCoord = HexAxial(6, 2);
    const kurganCoord = HexAxial(-4, 7);
    const crystalCoord = HexAxial(3, -7);

    if (map.containsKey(craterCoord)) {
      map[craterCoord] = map[craterCoord]!.copyWith(biome: TileBiome.celestialCrater);
    }
    if (map.containsKey(kurganCoord)) {
      map[kurganCoord] = map[kurganCoord]!.copyWith(biome: TileBiome.kurganValley);
    }
    if (map.containsKey(crystalCoord)) {
      map[crystalCoord] = map[crystalCoord]!.copyWith(biome: TileBiome.crystalChasm);
    }

    // Merkez karo (0,0) mutlaka Owned ve Castle olmalı
    map[const HexAxial(0, 0)] = map[const HexAxial(0, 0)]!.copyWith(
      state: TileState.owned,
      building: const BuildingModel(type: BuildingType.castle, level: 1),
    );

    // 2. TAPINAK YERLEŞİMİ
    // Merkeze uzaklık < 5 olan 1 tane rastgele tapınak
    final potentialCloseShrines = map.keys.where((c) {
      final d = HexMath.hexDistance(const HexAxial(0, 0), c);
      return d > 2 && d < 5 && map[c]!.biome != TileBiome.sea && map[c]!.biome != TileBiome.mountain;
    }).toList();
    if (potentialCloseShrines.isNotEmpty) {
      final shrineCoord = potentialCloseShrines[random.nextInt(potentialCloseShrines.length)];
      map[shrineCoord] = map[shrineCoord]!.copyWith(
        building: const BuildingModel(type: BuildingType.shrine, level: 1),
      );
    }

    // Uzak Tapınaklar (Biyom Sınırlarına)
    // Deniz veya Dağ kenarındaki kara parçalarına stratejik tapınaklar serpiştiriyoruz
    final farCoords = map.keys.where((c) => HexMath.hexDistance(const HexAxial(0, 0), c) > 10).toList();
    int farShrineCount = 0;
    for (final c in farCoords) {
      if (farShrineCount >= 4) break;
      final tile = map[c]!;
      if (tile.biome == TileBiome.meadow || tile.biome == TileBiome.forest) {
        // Komşularında Deniz veya Dağ var mı? (Sınır takibi)
        bool isBoundary = false;
        for (final n in c.neighbors) {
          if (map.containsKey(n) && (map[n]!.biome == TileBiome.sea || map[n]!.biome == TileBiome.mountain)) {
            isBoundary = true;
            break;
          }
        }
        if (isBoundary && random.nextDouble() < 0.05) {
          map[c] = map[c]!.copyWith(
            building: const BuildingModel(type: BuildingType.shrine, level: 1),
          );
          farShrineCount++;
        }
      }
    }

    return GameState(
      tiles: map,
      resources: const ResourcesModel(food: 100.0, wood: 50.0),
      progression: ProgressionModel(
        castleLevel: 1,
        ownedCount: 1,
        activeTradeOrders: EconomyCalculator.generateInitialTradeOrders(),
      ),
      quests: _generateInitialQuests(),
      doctrines: DoctrineCardModel.getInitialDoctrines(),
      celestialOmen: CelestialOmen.fromYearIndex(0),
      yearIndex: 0,
    );
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      final save = await SaveRepository.loadGame();
      if (!mounted) return;

      if (save != null && save.tiles.isNotEmpty) {
        final tilesMap = {
          for (final t in save.tiles)
            t.coord: (t.building?.type == BuildingType.castle &&
                    t.building!.level != save.progression.castleLevel)
                ? t.copyWith(
                    building: t.building!
                        .copyWith(level: save.progression.castleLevel))
                : t
        };
        final loadedOrders = save.progression.activeTradeOrders.isNotEmpty
            ? save.progression.activeTradeOrders
            : EconomyCalculator.generateInitialTradeOrders();

        state = state.copyWith(
          tiles: tilesMap,
          resources: save.resources,
          progression: save.progression.copyWith(
            totalSessions: save.progression.totalSessions + 1,
            activeTradeOrders: loadedOrders,
          ),
          season: save.season,
          settings: save.settings,
          toreTalents: save.toreTalents,
          titles: save.titles,
          stats: save.stats,
          quests: save.quests.isNotEmpty ? save.quests : _generateInitialQuests(),
          doctrines: save.doctrines.isNotEmpty ? save.doctrines : DoctrineCardModel.getInitialDoctrines(),
          activeDoctrineSlots: save.activeDoctrineSlots.isNotEmpty ? save.activeDoctrineSlots : state.activeDoctrineSlots,
          caravanRoutes: save.caravanRoutes,
          celestialOmen: save.celestialOmen ?? CelestialOmen.fromYearIndex(save.yearIndex),
          yearIndex: save.yearIndex,
          discoveredKurgans: save.discoveredKurgans,
          adTracking: save.adTracking.checkDailyReset(),
        );

        _syncQuestProgress();

        // Offline gelir hesapla
        final double globalMult = EconomyCalculator.getGlobalMultiplier(
          castleLevel: save.progression.castleLevel,
          crowns: save.resources.crowns,
          toreTalents: save.toreTalents,
          titles: save.titles,
        );
        final double elapsed =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000 - save.timestamp)
                .toDouble();
        final offline = EconomyCalculator.calculateOfflineGains(
          tiles: save.tiles,
          elapsedSeconds: elapsed,
          globalMultiplier: globalMult,
        );

        if (offline.hasGains && mounted) {
          state = state.copyWith(
            resources: state.resources.copyWith(
              food: state.resources.food + offline.food,
              wood: state.resources.wood + offline.wood,
              flour: state.resources.flour + offline.flour,
              plank: state.resources.plank + offline.plank,
              bread: state.resources.bread + offline.bread,
              furniture: state.resources.furniture + offline.furniture,
              stone: state.resources.stone + offline.stone,
              iron: state.resources.iron + offline.iron,
              fish: state.resources.fish + offline.fish,
              wisdom: state.resources.wisdom + offline.wisdom,
              kumis: state.resources.kumis + offline.kumis,
              felt: state.resources.felt + offline.felt,
              damascusSteel: state.resources.damascusSteel + offline.damascusSteel,
            ),
            activeToast:
                'Çevrimdışı Gelir: +${offline.food.toStringAsFixed(1)} Gıda, +${offline.wood.toStringAsFixed(1)} Odun',
          );
        }
      }
    } catch (_) {
      // Güvenli başlatma: Hata durumunda varsayılan harita korunur
    }

    _startGameLoop();
    _startAutoSave();
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (mounted) _tick();
    });
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && _isSaveDirty) {
        saveGame();
      }
    });
  }

  @visibleForTesting
  void testTick() => _tick();

  void _tick() {
    _autoSaveTickCounter++;
    if (_autoSaveTickCounter >= 30) {
      _isSaveDirty = true;
      _autoSaveTickCounter = 0;
    }
    final double globalMult = EconomyCalculator.getGlobalMultiplier(
          castleLevel: state.progression.castleLevel,
          crowns: state.resources.crowns,
          toreTalents: state.toreTalents,
          titles: state.titles,
        ) *
        state.frenzyMultiplier;

    // İşçi transfer hız çarpanı
    final double workerTransferMult =
        EconomyCalculator.getWorkerTransferMultiplier(
      toreTalents: state.toreTalents,
    );

    // Sezon güncellemesi (300 saniyede bir sezon değişir - 5 Dakika)
    double newSeasonTimer = state.season.timer + 1.0;
    String newSeason = state.season.current;
    int newYear = state.season.year;
    bool newIsZud = state.season.isZud;
    double newLerp = math.min(1.0, state.seasonLerpProgress + (1.0 / 60.0));

    int newYearIndex = state.yearIndex;
    CelestialOmen? newOmen = state.celestialOmen;

    if (newSeasonTimer >= 300.0) {
      newSeasonTimer = 0.0;
      newLerp = 0.0; // Yeni mevsim başladığında lerp sıfırlanır
      if (newSeason == 'SPRING') {
        newSeason = 'SUMMER';
      } else if (newSeason == 'SUMMER') {
        newSeason = 'AUTUMN';
      } else if (newSeason == 'AUTUMN') {
        newSeason = 'WINTER';
        // Kış başlangıcında %25 olasılıkla Zud afeti
        newIsZud = math.Random().nextDouble() < 0.25;
        if (newIsZud) {
          showToast('DİKKAT: Şiddetli Zud Afeti Başladı! (Üretim: -%40)');
        }
      } else {
        newSeason = 'SPRING';
        newYear += 1;
        newIsZud = false;
        newYearIndex = (state.yearIndex + 1) % 12;
        newOmen = CelestialOmen.fromYearIndex(newYearIndex);
        showToast('GÖKSEL ALAMET: ${newOmen.name} (${newOmen.description})');
      }
    }

    // Frenzy zamanlayıcı
    final double newFrenzyTimer = math.max(0.0, state.frenzyTimer - 1.0);
    final int newFrenzyMultiplier = newFrenzyTimer > 0 ? state.frenzyMultiplier : 1;

    // İşçi ve Şato Taşıma Kaynakları (4 Hex Menzil)
    final List<HexAxial> workerSourceCoords = [];
    final List<double> workerSourceCapacities = [];

    for (final t in state.tiles.values) {
      if (!t.isOwned || t.building == null) continue;
      if (t.building!.type == BuildingType.castle) {
        // Şatodan gelen 1.0 taban taşıma kapasitesi (4 hex menzil)
        workerSourceCoords.add(t.coord);
        workerSourceCapacities.add(1.0 * workerTransferMult);
      } else if (t.building!.type == BuildingType.worker ||
          t.building!.type == BuildingType.fishermanHut) {
        workerSourceCoords.add(t.coord);
        workerSourceCapacities.add(t.building!.currentCarryingCapacity * workerTransferMult);
      }
    }

    double addedFood = 0.0;
    double addedWood = 0.0;
    double addedFish = 0.0;
    double addedFlour = 0.0;
    double addedPlank = 0.0;
    double addedBread = 0.0;
    double addedFurniture = 0.0;
    double addedStone = 0.0;
    double addedIron = 0.0;
    double addedWisdom = 0.0;
    double addedKumis = 0.0;
    double addedFelt = 0.0;
    double addedDamascusSteel = 0.0;

    final activeDoctrines = getActiveDoctrines();

    // Doktrin: Göçer İaşesi (Boş çayırlardan iaşe)
    final bool hasGrazeDoctrine = activeDoctrines.any((d) => d.effectType == DoctrineEffectType.meadowGrazeYield);
    if (hasGrazeDoctrine) {
      int emptyMeadowCount = 0;
      for (final t in state.tiles.values) {
        if (t.isOwned && t.biome == TileBiome.meadow && !t.hasBuilding) {
          emptyMeadowCount++;
        }
      }
      addedFood += emptyMeadowCount * 0.5;
    }

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    // Kaynakların bir kopyasını al (tüketim kontrolü için)
    double currentFood = state.resources.food;
    double currentWood = state.resources.wood;
    double currentFlour = state.resources.flour;
    double currentPlank = state.resources.plank;

    for (final entry in state.tiles.entries) {
      final tile = entry.value;
      if (!tile.isOwned || tile.building == null) continue;

      final b = tile.building!;
      if (b.type == BuildingType.castle ||
          b.type == BuildingType.worker ||
          b.type == BuildingType.watchtower ||
          b.type == BuildingType.bridge ||
          b.type == BuildingType.fishermanHut ||
          b.type == BuildingType.shrine) {
        continue;
      }

      // 1. Bina Zincir Sinerjisi (Örn: Tarlanın yanındaki Değirmen 2x)
      double chainSynergy = 1.0;
      for (final nCoord in tile.coord.neighbors) {
        final nTile = state.tiles[nCoord];
        if (nTile != null && nTile.isOwned && nTile.building != null) {
          if (b.type == BuildingType.windmill &&
              nTile.building!.type == BuildingType.corn) {
            chainSynergy = 2.0;
          }
          if (b.type == BuildingType.sawmill &&
              nTile.building!.type == BuildingType.lumberjack) {
            chainSynergy = 2.0;
          }
          if (b.type == BuildingType.bakery &&
              nTile.building!.type == BuildingType.windmill) {
            chainSynergy = 2.0;
          }
          if (b.type == BuildingType.furniture &&
              nTile.building!.type == BuildingType.sawmill) {
            chainSynergy = 2.0;
          }
        }
      }

      // 2. Biyom ve Komşuluk Sinerjisi (Sulama Bereketi, Jeotermal Maden, İpek Yolu vb.)
      final neighborTiles = tile.coord.neighbors
          .map((nc) => state.tiles[nc])
          .whereType<HexTileModel>()
          .toList();

      final double biomeSynergy = EconomyCalculator.calculateAdjacencySynergy(
        targetTile: tile,
        neighborTiles: neighborTiles,
        season: newSeason,
        isZud: newIsZud,
      );

      final double totalSynergy = chainSynergy * biomeSynergy;

      // Karo ısıtma süresi ve kış koruması
      bool isWarmed = tile.isWarmed;
      double warmTimer = tile.warmTimer;
      if (isWarmed) {
        warmTimer = math.max(0.0, warmTimer - 1.0);
        if (warmTimer <= 0.0) isWarmed = false;
      }

      final double seasonMult =
          EconomyCalculator.getSeasonProductionMultiplier(
        season: newSeason,
        isZud: newIsZud,
        isTileWarmed: isWarmed,
        titles: state.titles,
      );

      final double docMult = EconomyCalculator.getDoctrineProductionMultiplier(
        buildingType: b.type,
        activeDoctrines: activeDoctrines,
      );

      final double soilMult = EconomyCalculator.calculateSoilHealthMultiplier(tile);
      final double caravanMult = EconomyCalculator.calculateCaravanRouteMultiplier(tile.coord, state.caravanRoutes);
      final double symbiosisMult = EconomyCalculator.calculateSymbiosisMultiplier(tile);
      final double ancestralMult = EconomyCalculator.calculateAncestralRelicMultiplier(state.discoveredKurgans);
      final double omenMult = state.celestialOmen != null
          ? EconomyCalculator.calculateCelestialOmenMultiplier(
              state.celestialOmen!,
              resourceType: b.type == BuildingType.lumberjack || b.type == BuildingType.sawmill
                  ? 'wood'
                  : b.type == BuildingType.mine || b.type == BuildingType.quarry
                      ? 'iron'
                      : 'food',
            )
          : 1.0;

      final double rate = EconomyCalculator.calculateBuildingProduction(
        type: b.type,
        level: b.level,
        baseRate: b.baseProductionRate,
        globalMultiplier: globalMult * docMult * caravanMult * symbiosisMult * ancestralMult * omenMult,
        seasonMultiplier: seasonMult * soilMult,
        synergyMultiplier: totalSynergy,
        workerMultiplier: 1.0, // Kapasite sistemi geldiği için oran sabitlendi
        shrineMultiplier: state.shrineMultiplier,
      );

      // Üretim ve Tüketim Mantığı
      bool canProduce = true;
      double consumeFood = 0;
      double consumeWood = 0;
      double consumeFlour = 0;
      double consumePlank = 0;

      if (b.type == BuildingType.windmill) {
        if (currentFood >= rate * 0.5) {
          consumeFood = rate * 0.5;
        } else {
          canProduce = false;
        }
      } else if (b.type == BuildingType.sawmill) {
        if (currentWood >= rate * 0.5) {
          consumeWood = rate * 0.5;
        } else {
          canProduce = false;
        }
      } else if (b.type == BuildingType.bakery) {
        if (currentFlour >= rate * 0.4 && currentFood >= rate * 0.4) {
          consumeFlour = rate * 0.4;
          consumeFood = rate * 0.4;
        } else {
          canProduce = false;
        }
      } else if (b.type == BuildingType.furniture) {
        if (currentPlank >= rate * 0.4 && currentWood >= rate * 0.4) {
          consumePlank = rate * 0.4;
          consumeWood = rate * 0.4;
        } else {
          canProduce = false;
        }
      }

      double newSoil = tile.soilHealth;
      double newRestTime = tile.restTimeAccumulated;
      if (tile.isResting) {
        newSoil = math.min(1.0, newSoil + 0.05);
        newRestTime += 1.0;
      } else if (tile.hasBuilding) {
        if (newRestTime > 0.0) {
          newRestTime = math.max(0.0, newRestTime - 1.0);
        }
        newSoil = math.max(0.1, newSoil - 0.001);
      }

      if (canProduce) {
        // Tüketimi uygula
        addedFood -= consumeFood;
        currentFood -= consumeFood;
        addedWood -= consumeWood;
        currentWood -= consumeWood;
        addedFlour -= consumeFlour;
        currentFlour -= consumeFlour;
        addedPlank -= consumePlank;
        currentPlank -= consumePlank;

        // Taşıma Kapasitesi ve 4 Hex Menzil Kontrolü
        double carriedAmount = 0.0;
        double neededAmount = rate;

        for (int i = 0; i < workerSourceCoords.length; i++) {
          if (neededAmount <= 0.0) break;
          if (tile.coord.distanceTo(workerSourceCoords[i]) <= 4 && workerSourceCapacities[i] > 0.0) {
            final double take = math.min(neededAmount, workerSourceCapacities[i]);
            workerSourceCapacities[i] -= take;
            carriedAmount += take;
            neededAmount -= take;
          }
        }

        final double storedAmount = rate - carriedAmount;

        // Taşınanları ekle
        switch (b.type) {
          case BuildingType.corn:
          case BuildingType.barley:
          case BuildingType.pasture:
          case BuildingType.orchard:
            addedFood += carriedAmount;
            currentFood += carriedAmount;
            break;
          case BuildingType.lumberjack:
          case BuildingType.resinCamp:
            addedWood += carriedAmount;
            currentWood += carriedAmount;
            break;
          case BuildingType.quarry:
            addedStone += carriedAmount;
            break;
          case BuildingType.windmill:
            addedFlour += carriedAmount;
            currentFlour += carriedAmount;
            break;
          case BuildingType.sawmill:
            addedPlank += carriedAmount;
            currentPlank += carriedAmount;
            break;
          case BuildingType.bakery:
            addedBread += carriedAmount;
            break;
          case BuildingType.furniture:
            addedFurniture += carriedAmount;
            break;
          case BuildingType.mine:
            addedStone += carriedAmount;
            if (state.progression.castleLevel >= 3) {
              final bool hasIronBoost = activeDoctrines.any((d) => d.effectType == DoctrineEffectType.mineIronBoost);
              final double ironRatio = hasIronBoost ? 0.45 : 0.30;
              addedIron += carriedAmount * ironRatio;
            }
            break;
          case BuildingType.fisherman:
            addedFish += carriedAmount;
            break;
          case BuildingType.oasisCistern:
          case BuildingType.reindeerSanctuary:
          case BuildingType.herbalistYurt:
            addedFood += carriedAmount;
            currentFood += carriedAmount;
            break;
          case BuildingType.caravanserai:
            addedBread += carriedAmount;
            addedFood += carriedAmount * 0.5;
            break;
          case BuildingType.scribeWorkshop:
            addedPlank += carriedAmount;
            break;
          case BuildingType.geothermalBath:
          case BuildingType.steamVent:
            addedStone += carriedAmount;
            break;
          case BuildingType.permafrostDig:
          case BuildingType.obsidianForge:
          case BuildingType.celestialAnvil:
            addedStone += carriedAmount;
            addedIron += carriedAmount * 0.5;
            break;
          case BuildingType.ancestralTotem:
          case BuildingType.prismaticResonator:
          case BuildingType.astrolabe:
            final double mBonus = 1.0 + state.progression.totalMigrations * 0.1;
            addedFood += carriedAmount * 0.4 * mBonus;
            addedWood += carriedAmount * 0.4 * mBonus;
            addedStone += carriedAmount * 0.4 * mBonus;
            break;
          case BuildingType.runicStele:
            addedWisdom += carriedAmount;
            break;
          case BuildingType.kumisYurt:
            addedKumis += carriedAmount;
            break;
          case BuildingType.feltTentWorkshop:
            addedFelt += carriedAmount;
            break;
          case BuildingType.damascusForge:
            addedDamascusSteel += carriedAmount;
            break;
          default:
            break;
        }

        // Taşınamayanları binada biriktir
        final double newAccum = math.min(b.maxCapacity, b.accumulatedResource + storedAmount);
        updatedTiles[entry.key] = tile.copyWith(
          building: b.copyWith(accumulatedResource: newAccum),
          isWarmed: isWarmed,
          warmTimer: warmTimer,
          soilHealth: newSoil,
          restTimeAccumulated: newRestTime,
        );
      } else {
        // Üretim yapılamadı (kaynak yok), sadece ısıtma timerı ve toprak durumu güncellensin
        updatedTiles[entry.key] = tile.copyWith(
          isWarmed: isWarmed,
          warmTimer: warmTimer,
          soilHealth: newSoil,
          restTimeAccumulated: newRestTime,
        );
      }
    }

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(
        food: math.max(0.0, state.resources.food + addedFood),
        wood: math.max(0.0, state.resources.wood + addedWood),
        fish: math.max(0.0, state.resources.fish + addedFish),
        flour: math.max(0.0, state.resources.flour + addedFlour),
        plank: math.max(0.0, state.resources.plank + addedPlank),
        bread: math.max(0.0, state.resources.bread + addedBread),
        furniture: math.max(0.0, state.resources.furniture + addedFurniture),
        stone: math.max(0.0, state.resources.stone + addedStone),
        iron: math.max(0.0, state.resources.iron + addedIron),
        wisdom: math.max(0.0, state.resources.wisdom + addedWisdom),
        kumis: math.max(0.0, state.resources.kumis + addedKumis),
        felt: math.max(0.0, state.resources.felt + addedFelt),
        damascusSteel: math.max(0.0, state.resources.damascusSteel + addedDamascusSteel),
      ),
      season: state.season.copyWith(
        timer: newSeasonTimer,
        current: newSeason,
        year: newYear,
        isZud: newIsZud,
      ),
      frenzyTimer: newFrenzyTimer,
      frenzyMultiplier: newFrenzyMultiplier,
      seasonLerpProgress: newLerp,
      yearIndex: newYearIndex,
      celestialOmen: newOmen,
    );
  }

  void selectTile(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null) return;

    if (tile.isFog) {
      showToast('Sisli Bölge: Komşu karoları fethederek sisi aç!');
      return;
    }

    state = state.copyWith(selectedCoord: coord);

    // Tutorial Logic
    final int currentStep = state.progression.tutorialStep;
    if (currentStep == 0 && !tile.isOwned && !tile.isFog) {
      state = state.copyWith(progression: state.progression.copyWith(tutorialStep: 1));
    } else if (currentStep == 6 && tile.biome == TileBiome.forest && !tile.isOwned) {
      state = state.copyWith(progression: state.progression.copyWith(tutorialStep: 7));
    }
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  void showToast(String message) {
    state = state.copyWith(activeToast: message);
  }

  void clearToast() {
    state = state.copyWith(clearToast: true);
  }

  double calculateExpansionCost(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null) return 99999.0;

    final Map<String, int> biomeCounts = {
      'meadow': state.progression.purchasedMeadowCount,
      'forest': state.progression.purchasedForestCount,
      'sea': state.progression.purchasedSeaCount,
      'mountain': state.progression.purchasedMountainCount,
    };

    final int distance = HexMath.hexDistance(const HexAxial(0, 0), coord);

    final double baseCost = EconomyCalculator.getExpansionCost(
      biome: tile.biome,
      ownedCount: state.progression.ownedCount,
      biomeCounts: biomeCounts,
      distance: distance,
      toreTalents: state.toreTalents,
      titles: state.titles,
    );

    final activeDoctrines = getActiveDoctrines();
    final double docMult = EconomyCalculator.getConquestCostMultiplier(activeDoctrines);

    return baseCost * docMult;
  }

  bool conquerTile(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null || tile.isOwned) return false;

    // Komşuluk kontrolü: En az 1 komşusu OWNED olmalı veya Köprülü Deniz olmalı
    final bool hasOwnedNeighbor = coord.neighbors.any((n) {
      final nTile = state.tiles[n];
      if (nTile == null) return false;
      if (nTile.isOwned) return true;
      if (nTile.building?.type == BuildingType.bridge) return true;
      return false;
    });

    if (!hasOwnedNeighbor) {
      showToast('Yalnızca sınır komşusu olan araziler fethedilebilir.');
      return false;
    }

    // Orman ve Çöl kilit kontrolü: Kağan Otağı Seviye >= 2
    if ((tile.biome == TileBiome.forest || tile.biome == TileBiome.desert) && state.progression.castleLevel < 2) {
      showToast(
          'Arazi Kilitli: Çöl ve Orman keşfi için Kağan Otağı Seviye 2 gereklidir.');
      return false;
    }
    // Dağ ve Sazlık kilit kontrolü: Kağan Otağı Seviye >= 3
    if ((tile.biome == TileBiome.mountain || tile.biome == TileBiome.wetland) && state.progression.castleLevel < 3) {
      showToast(
          'Arazi Kilitli: Dağ ve Sazlık keşfi için Kağan Otağı Seviye 3 gereklidir.');
      return false;
    }
    // Deniz ve Tundra kilit kontrolü: Kağan Otağı Seviye >= 4
    if ((tile.biome == TileBiome.sea || tile.biome == TileBiome.tundra) && state.progression.castleLevel < 4) {
      showToast(
          'Arazi Kilitli: Deniz ve Tundra keşfi için Kağan Otağı Seviye 4 gereklidir.');
      return false;
    }
    // Volkan ve Efsanevi Biyomlar kilit kontrolü: Kağan Otağı Seviye >= 5
    if ((tile.biome == TileBiome.volcano ||
            tile.biome == TileBiome.celestialCrater ||
            tile.biome == TileBiome.kurganValley ||
            tile.biome == TileBiome.crystalChasm) &&
        state.progression.castleLevel < 5) {
      showToast(
          'Efsanevi Arazi Kilitli: Bu kadim bölgeyi fethetmek için Kağan Otağı Seviye 5 gereklidir.');
      return false;
    }

    final double cost = calculateExpansionCost(coord);
    if (state.resources.food < cost) {
      showToast(
          'Yetersiz Gıda: Yeni karo için ${cost.toInt()} Gıda gerekli.');
      return false;
    }

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(state: TileState.owned);

    // Ekolojik Biyom Simbiyoz Kontrolü
    final symbiosis = SymbiosisEngine.evaluateSymbiosis(coord, updatedTiles);
    if (symbiosis != SymbiosisType.none) {
      updatedTiles[coord] = updatedTiles[coord]!.copyWith(symbiosis: symbiosis);
      showToast('EKOLOJİK SİMBİYOZ: ${SymbiosisEngine.getSymbiosisName(symbiosis)} Doğdu! (+%50 Bereket)');
    }

    // Çevresindeki fog karoları açığa çıkar (4 Radius Disk)
    final revealRange = coord.getRange(4);
    for (final targetCoord in revealRange) {
      if (updatedTiles.containsKey(targetCoord)) {
        final t = updatedTiles[targetCoord]!;
        if (t.isFog) {
          // Yeni keşfedilen karolarda sunak şansı
          final bool willHaveShrine = math.Random().nextDouble() < 0.10;
          final sType = willHaveShrine
              ? ShrineType.values[1 + math.Random().nextInt(ShrineType.values.length - 1)]
              : ShrineType.none;
          updatedTiles[targetCoord] = t.copyWith(
            state: TileState.discovered,
            shrine: sType,
          );
        }
      } else {
        final randomBiome = TileBiome
            .values[math.Random().nextInt(TileBiome.values.length)];
        // Yeni üretilen karolarda sunak şansı
        final bool willHaveShrine = math.Random().nextDouble() < 0.10;
        final sType = willHaveShrine
            ? ShrineType.values[1 + math.Random().nextInt(ShrineType.values.length - 1)]
            : ShrineType.none;
        updatedTiles[targetCoord] = HexTileModel(
          coord: targetCoord,
          biome: randomBiome,
          state: TileState.discovered,
          shrine: sType,
        );
      }
    }

    double newShrineMult = state.shrineMultiplier;
    if (tile.hasShrine) {
      newShrineMult += 0.5; // Her sunak +%50 toplamsal bonus
      showToast('Kadim Sunak Fethedildi (Üretim Bonusu: +%50).');
    }

    int mCount = state.progression.purchasedMeadowCount;
    int fCount = state.progression.purchasedForestCount;
    int sCount = state.progression.purchasedSeaCount;
    int mtCount = state.progression.purchasedMountainCount;
    if (tile.biome == TileBiome.meadow) {
      mCount++;
    }
    if (tile.biome == TileBiome.forest) {
      fCount++;
    }
    if (tile.biome == TileBiome.sea) {
      sCount++;
    }
    if (tile.biome == TileBiome.mountain) {
      mtCount++;
    }

    int nextTutorial = state.progression.tutorialStep;
    if (nextTutorial == 1) {
      nextTutorial = 2;
    } else if (nextTutorial == 7) {
      nextTutorial = 8;
    }

    final newCumulativeBiomes = Map<String, int>.from(state.progression.cumulativeBiomeCounts);
    newCumulativeBiomes[tile.biome.name] = (newCumulativeBiomes[tile.biome.name] ?? 0) + 1;

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(food: state.resources.food - cost),
      progression: state.progression.copyWith(
        ownedCount: state.progression.ownedCount + 1,
        purchasedMeadowCount: mCount,
        purchasedForestCount: fCount,
        purchasedSeaCount: sCount,
        purchasedMountainCount: mtCount,
        tutorialStep: nextTutorial,
        cumulativeBiomeCounts: newCumulativeBiomes,
      ),
      shrineMultiplier: newShrineMult,
      activeToast: tile.hasShrine
          ? 'Sunak gücüyle beraber yeni arsa fethedildi.'
          : '${cost.toInt()} Gıda karşılığında yeni arsa fethedildi.',
    );

    TactileAudioService.instance.play(TactileSoundType.stoneClick);
    _syncQuestProgress();
    saveGame();
    return true;
  }

  static List<BuildingType> getAllowedBuildingsForBiome(TileBiome biome) {
    switch (biome) {
      case TileBiome.meadow:
        return const [
          BuildingType.corn,
          BuildingType.barley,
          BuildingType.pasture,
          BuildingType.orchard,
          BuildingType.quarry,
          BuildingType.windmill,
          BuildingType.bakery,
          BuildingType.worker,
          BuildingType.watchtower,
          BuildingType.granaryVault,
          BuildingType.kumisYurt,
          BuildingType.feltTentWorkshop,
          BuildingType.runicStele,
        ];
      case TileBiome.forest:
        return const [
          BuildingType.lumberjack,
          BuildingType.resinCamp,
          BuildingType.sawmill,
          BuildingType.furniture,
          BuildingType.worker,
          BuildingType.watchtower,
          BuildingType.granaryVault,
        ];
      case TileBiome.mountain:
        return const [
          BuildingType.mine,
          BuildingType.quarry,
          BuildingType.worker,
          BuildingType.watchtower,
          BuildingType.granaryVault,
          BuildingType.damascusForge,
          BuildingType.runicStele,
        ];
      case TileBiome.sea:
        return const [
          BuildingType.bridge,
          BuildingType.fisherman,
          BuildingType.fishermanHut,
        ];
      case TileBiome.desert:
        return const [
          BuildingType.quarry,
          BuildingType.watchtower,
          BuildingType.oasisCistern,
          BuildingType.caravanserai,
          BuildingType.astrolabe,
          BuildingType.feltTentWorkshop,
          BuildingType.granaryVault,
        ];
      case TileBiome.tundra:
        return const [
          BuildingType.reindeerSanctuary,
          BuildingType.geothermalBath,
          BuildingType.permafrostDig,
          BuildingType.feltTentWorkshop,
          BuildingType.watchtower,
          BuildingType.granaryVault,
          BuildingType.runicStele,
        ];
      case TileBiome.volcano:
        return const [
          BuildingType.quarry,
          BuildingType.steamVent,
          BuildingType.obsidianForge,
          BuildingType.damascusForge,
          BuildingType.granaryVault,
        ];
      case TileBiome.wetland:
        return const [
          BuildingType.pasture,
          BuildingType.fisherman,
          BuildingType.herbalistYurt,
          BuildingType.scribeWorkshop,
          BuildingType.granaryVault,
        ];
      case TileBiome.celestialCrater:
        return const [
          BuildingType.celestialAnvil,
          BuildingType.granaryVault,
          BuildingType.runicStele,
        ];
      case TileBiome.kurganValley:
        return const [
          BuildingType.ancestralTotem,
          BuildingType.kumisYurt,
          BuildingType.granaryVault,
          BuildingType.runicStele,
        ];
      case TileBiome.crystalChasm:
        return const [
          BuildingType.prismaticResonator,
          BuildingType.granaryVault,
          BuildingType.runicStele,
        ];
    }
  }

  bool buildStructure(HexAxial coord, BuildingType type) {
    final tile = state.tiles[coord];
    if (tile == null || !tile.isOwned || tile.hasBuilding) return false;

    final int castleLvl = state.progression.castleLevel;
    if (castleLvl < type.requiredCastleLevel) {
      showToast('Kilitli Yapı: Bu yapı için Kağan Otağı Seviye ${type.requiredCastleLevel} gereklidir.');
      return false;
    }

    final allowedBuildings = getAllowedBuildingsForBiome(tile.biome);
    if (!allowedBuildings.contains(type)) {
      showToast('Geçersiz Arazi: Bu yapı seçili arazide inşa edilemez.');
      return false;
    }

    if (type == BuildingType.bridge) {
      // Köprü için iki kara biyomu arasında olma kontrolü
      final landNeighbors = coord.neighbors.where((n) {
        final t = state.tiles[n];
        return t != null && t.biome != TileBiome.sea && t.biome != TileBiome.wetland;
      }).length;
      if (landNeighbors < 2) {
        showToast('Köprü yalnızca iki kara parçası arasına inşa edilebilir.');
        return false;
      }
    }
    if (type == BuildingType.fishermanHut) {
      // Kıyı kontrolü: En az bir kara komşusu olmalı
      final hasLandNeighbor = coord.neighbors.any((n) {
        final t = state.tiles[n];
        return t != null && t.biome != TileBiome.sea && t.biome != TileBiome.wetland;
      });
      if (!hasLandNeighbor) {
        showToast('Balıkçı Barınağı kıyıya (kara yanına) inşa edilmelidir.');
        return false;
      }
    }

    final dummy = BuildingModel(type: type);
    final cost = dummy.baseCost;

    if (state.resources.food < cost) {
      showToast('Yetersiz kaynak: ${cost.toInt()} Gıda gereklidir.');
      return false;
    }

    final int bVariant = (coord.q * 17 + coord.r * 31 + DateTime.now().millisecond).abs() % 3;
    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(building: BuildingModel(type: type, variant: bVariant));

    // Gözcü Kulesi ise etrafındaki görüş hattı (Bresenham raycast) boyunca sisi aç
    if (type == BuildingType.watchtower) {
      const int towerRadius = 2;
      for (int q = -towerRadius; q <= towerRadius; q++) {
        final int r1 = math.max(-towerRadius, -q - towerRadius);
        final int r2 = math.min(towerRadius, -q + towerRadius);
        for (int r = r1; r <= r2; r++) {
          final targetCoord = coord + HexAxial(q, r);
          for (final rayStep in HexMath.hexLine(coord, targetCoord)) {
            if (updatedTiles.containsKey(rayStep)) {
              final t = updatedTiles[rayStep]!;
              if (t.isFog) {
                updatedTiles[rayStep] =
                    t.copyWith(state: TileState.discovered);
              }
            }
          }
        }
      }
    }

    int nextTutorial = state.progression.tutorialStep;
    if (type == BuildingType.corn && nextTutorial == 2) {
      nextTutorial = 3;
    } else if (type == BuildingType.worker && nextTutorial == 3) {
      nextTutorial = 4;
    } else if (type == BuildingType.lumberjack && nextTutorial == 8) {
      nextTutorial = 9;
    }

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(food: state.resources.food - cost),
      progression: state.progression.copyWith(tutorialStep: nextTutorial),
      activeToast: '${type.name.toUpperCase()} başarıyla inşa edildi!',
    );

    TactileAudioService.instance.play(TactileSoundType.build);
    _syncQuestProgress();
    saveGame();
    return true;
  }

  bool upgradeBuilding(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null || tile.building == null) return false;

    final b = tile.building!;
    if (b.type == BuildingType.castle) {
      return upgradeCastle();
    }

    final cost = b.upgradeCost;

    if (state.resources.food < cost) {
      showToast(
          'Yükseltme için yetersiz kaynak: ${cost.toInt()} Gıda gereklidir.');
      return false;
    }

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(
      building: b.copyWith(level: b.level + 1),
    );

    // Gözcü Kulesi yükseltildiğinde görüş hattı menzili genişler (Bresenham raycast)
    if (b.type == BuildingType.watchtower) {
      final int towerRadius = math.min(5, 1 + b.level);
      for (int q = -towerRadius; q <= towerRadius; q++) {
        final int r1 = math.max(-towerRadius, -q - towerRadius);
        final int r2 = math.min(towerRadius, -q + towerRadius);
        for (int r = r1; r <= r2; r++) {
          final targetCoord = coord + HexAxial(q, r);
          for (final rayStep in HexMath.hexLine(coord, targetCoord)) {
            if (updatedTiles.containsKey(rayStep)) {
              final t = updatedTiles[rayStep]!;
              if (t.isFog) {
                updatedTiles[rayStep] =
                    t.copyWith(state: TileState.discovered);
              }
            }
          }
        }
      }
    }

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(food: state.resources.food - cost),
      activeToast:
          '${b.type.name.toUpperCase()} Seviye ${b.level + 1} oldu.',
    );

    TactileAudioService.instance.play(TactileSoundType.upgrade);
    _syncQuestProgress();
    saveGame();
    return true;
  }

  bool collectFromTile(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null || tile.building == null) return false;

    final b = tile.building!;
    if (b.type == BuildingType.castle) {
      // Şatodan Acil Durum İaşesi (Softlock Önleme: Her tıkta +1 Gıda)
      state = state.copyWith(
        resources: state.resources.copyWith(food: state.resources.food + 1.0),
        activeToast: '+1.0 Gıda (Han Otağı İaşesi)',
      );
      TactileAudioService.instance.play(TactileSoundType.tap);
      return true;
    }

    final double accum = b.accumulatedResource;
    if (accum <= 0.0) return false;

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(
      building: b.copyWith(accumulatedResource: 0.0),
    );

    ResourcesModel res = state.resources;
    int nextTutorial = state.progression.tutorialStep;
    if (b.type == BuildingType.corn && nextTutorial == 4) nextTutorial = 6; // Skip to forest tutorial

    if (b.type == BuildingType.corn ||
        b.type == BuildingType.barley ||
        b.type == BuildingType.pasture ||
        b.type == BuildingType.orchard ||
        b.type == BuildingType.reindeerSanctuary ||
        b.type == BuildingType.herbalistYurt ||
        b.type == BuildingType.oasisCistern) {
      res = res.copyWith(food: res.food + accum);
    } else if (b.type == BuildingType.lumberjack || b.type == BuildingType.resinCamp) {
      res = res.copyWith(wood: res.wood + accum);
    } else if (b.type == BuildingType.quarry) {
      res = res.copyWith(stone: res.stone + accum);
    } else if (b.type == BuildingType.fisherman) {
      res = res.copyWith(fish: res.fish + accum);
    } else if (b.type == BuildingType.windmill) {
      res = res.copyWith(flour: res.flour + accum);
    } else if (b.type == BuildingType.sawmill || b.type == BuildingType.scribeWorkshop) {
      res = res.copyWith(plank: res.plank + accum);
    } else if (b.type == BuildingType.bakery || b.type == BuildingType.caravanserai) {
      res = res.copyWith(bread: res.bread + accum);
    } else if (b.type == BuildingType.furniture) {
      res = res.copyWith(furniture: res.furniture + accum);
    } else if (b.type == BuildingType.mine ||
        b.type == BuildingType.geothermalBath ||
        b.type == BuildingType.steamVent) {
      res = res.copyWith(stone: res.stone + accum);
    } else if (b.type == BuildingType.permafrostDig ||
        b.type == BuildingType.obsidianForge ||
        b.type == BuildingType.celestialAnvil) {
      res = res.copyWith(
        stone: res.stone + accum * 0.7,
        iron: res.iron + accum * 0.3,
      );
    } else if (b.type == BuildingType.ancestralTotem ||
        b.type == BuildingType.prismaticResonator ||
        b.type == BuildingType.astrolabe) {
      final double bonus = 1.0 + state.progression.totalMigrations * 0.1;
      res = res.copyWith(
        food: res.food + (accum * 0.4 * bonus),
        wood: res.wood + (accum * 0.4 * bonus),
        stone: res.stone + (accum * 0.4 * bonus),
      );
    }

    state = state.copyWith(
      tiles: updatedTiles,
      resources: res,
      progression: state.progression.copyWith(tutorialStep: nextTutorial),
      activeToast: '+${accum.toStringAsFixed(1)} toplandı!',
    );

    TactileAudioService.instance.play(TactileSoundType.tap);
    return true;
  }

  bool warmTile(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null || !tile.isOwned) return false;
    if (tile.isWarmed) {
      showToast('Bu karo zaten ısıtılmış.');
      return false;
    }

    final activeDoctrines = getActiveDoctrines();
    final double woodCost = EconomyCalculator.getWinterWarmWoodCost(activeDoctrines);

    if (state.resources.wood < woodCost) {
      showToast('Karoyu ısıtmak için ${woodCost.toInt()} Odun gereklidir.');
      return false;
    }

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(
      isWarmed: true,
      warmTimer: 180.0, // 3 dakika kış koruması
    );

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(wood: state.resources.wood - woodCost),
      activeToast: 'Karo 3 dakika boyunca ısıtıldı (${woodCost.toInt()} Odun)!',
    );

    TactileAudioService.instance.play(TactileSoundType.tap);
    return true;
  }

  bool executeMarketTrade(String recipeKey) {
    final resMap = {
      'food': state.resources.food,
      'wood': state.resources.wood,
      'flour': state.resources.flour,
      'plank': state.resources.plank,
      'bread': state.resources.bread,
      'furniture': state.resources.furniture,
      'stone': state.resources.stone,
      'iron': state.resources.iron,
      'crowns': state.resources.crowns.toDouble(),
    };

    final result = EconomyCalculator.calculateMarketTrade(
      recipeKey: recipeKey,
      resources: resMap,
      titles: state.titles,
      season: state.season.current,
      isZud: state.season.isZud,
    );

    if (!result.success) {
      showToast('Takas için gerekli kaynaklar yetersiz.');
      return false;
    }

    ResourcesModel newRes = state.resources;
    result.consumed.forEach((key, val) {
      if (key == 'flour') newRes = newRes.copyWith(flour: newRes.flour - val);
      if (key == 'bread') newRes = newRes.copyWith(bread: newRes.bread - val);
      if (key == 'furniture') {
        newRes = newRes.copyWith(furniture: newRes.furniture - val);
      }
      if (key == 'iron') newRes = newRes.copyWith(iron: newRes.iron - val);
      if (key == 'stone') newRes = newRes.copyWith(stone: newRes.stone - val);
    });

    result.gained.forEach((key, val) {
      if (key == 'stone') newRes = newRes.copyWith(stone: newRes.stone + val);
      if (key == 'iron') newRes = newRes.copyWith(iron: newRes.iron + val);
      if (key == 'crowns') {
        newRes = newRes.copyWith(crowns: newRes.crowns + val.toInt());
      }
    });

    state = state.copyWith(
      resources: newRes,
      activeToast: 'Ticaret başarılı: Kaynaklar güncellendi.',
    );

    TactileAudioService.instance.play(TactileSoundType.market);
    saveGame();
    return true;
  }

  bool upgradeToreTalent(String branch, String talentKey, int costCrowns) {
    if (state.resources.crowns < costCrowns) {
      showToast('Yetersiz Taç: $costCrowns Taç gereklidir.');
      return false;
    }

    final newTore =
        Map<String, dynamic>.from(state.toreTalents);
    final branchMap = Map<String, dynamic>.from(
        newTore[branch] as Map<String, dynamic>? ?? {});
    final int currentLvl = (branchMap[talentKey] as num? ?? 0).toInt();
    branchMap[talentKey] = currentLvl + 1;
    newTore[branch] = branchMap;

    state = state.copyWith(
      resources: state.resources.copyWith(
        crowns: state.resources.crowns - costCrowns,
      ),
      toreTalents: newTore,
      activeToast: '$talentKey Seviye ${currentLvl + 1} oldu.',
    );

    TactileAudioService.instance.play(TactileSoundType.upgrade);
    saveGame();
    return true;
  }

  void setThemePalette(String paletteKey) {
    if (state.settings.activeThemePalette == paletteKey) return;
    state = state.copyWith(
      settings: state.settings.copyWith(activeThemePalette: paletteKey),
      activeToast: 'Tema Paleti Değiştirildi: ${NeoBrutalistTheme.getTheme(paletteKey).nameTr}',
    );
    TactileAudioService.instance.play(TactileSoundType.tap);
    saveGame();
  }

  bool equipTitle(String titleKey) {
    if (titleKey != 'nomad' && state.titles[titleKey] != true) {
      showToast('Önce bu unvanı meclisten kazanmalısınız.');
      return false;
    }

    String matchingPalette = 'basalt';
    if (titleKey == 'khagan') {
      matchingPalette = 'khagan';
    } else if (titleKey == 'conqueror') {
      matchingPalette = 'kurgan';
    } else if (titleKey == 'merchant') {
      matchingPalette = 'jade';
    } else if (titleKey == 'zudMaster') {
      matchingPalette = 'tengri';
    }

    state = state.copyWith(
      settings: state.settings.copyWith(
        activeTitle: titleKey,
        activeThemePalette: matchingPalette,
      ),
      activeToast: 'Unvan ve ${NeoBrutalistTheme.getTheme(matchingPalette).nameTr} Teması Kuşanıldı.',
    );

    TactileAudioService.instance.play(TactileSoundType.reward);
    saveGame();
    return true;
  }

  bool claimTitle(String titleKey) {
    if (state.titles[titleKey] == true) {
      showToast('Bu unvana zaten sahipsiniz.');
      return false;
    }

    bool qualified = false;
    if (titleKey == 'khagan' &&
        state.progression.castleLevel >= 4 &&
        state.progression.ownedCount >= 10) {
      qualified = true;
    } else if (titleKey == 'conqueror' &&
        state.progression.ownedCount >= 15) {
      qualified = true;
    } else if (titleKey == 'merchant' &&
        state.resources.flour >= 50 &&
        state.resources.plank >= 50) {
      qualified = true;
    } else if (titleKey == 'zudMaster' && state.season.year >= 2) {
      qualified = true;
    }

    if (!qualified) {
      showToast('Unvan şartları henüz sağlanmadı.');
      return false;
    }

    final newTitles = Map<String, dynamic>.from(state.titles);
    newTitles[titleKey] = true;

    String matchingPalette = 'basalt';
    if (titleKey == 'khagan') {
      matchingPalette = 'khagan';
    } else if (titleKey == 'conqueror') {
      matchingPalette = 'kurgan';
    } else if (titleKey == 'merchant') {
      matchingPalette = 'jade';
    } else if (titleKey == 'zudMaster') {
      matchingPalette = 'tengri';
    }

    state = state.copyWith(
      titles: newTitles,
      settings: state.settings.copyWith(
        activeTitle: titleKey,
        activeThemePalette: matchingPalette,
      ),
      activeToast: 'Kutlu Unvan Açıldı & Kuşanıldı: ${titleKey.toUpperCase()}',
    );

    TactileAudioService.instance.play(TactileSoundType.reward);
    saveGame();
    return true;
  }

  bool upgradeCastle() {
    final int nextLvl = state.progression.castleLevel + 1;
    final costs = EconomyCalculator.getCastleUpgradeCost(nextLvl);
    final double foodCost = costs['food']!;
    final double woodCost = costs['wood']!;

    if (state.resources.food < foodCost || state.resources.wood < woodCost) {
      String costMsg = 'Otağ yükseltmesi için ${foodCost.toInt()} Gıda';
      if (woodCost > 0) costMsg += ' ve ${woodCost.toInt()} Odun';
      costMsg += ' gereklidir.';
      showToast(costMsg);
      return false;
    }

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    for (final entry in updatedTiles.entries) {
      if (entry.value.building?.type == BuildingType.castle) {
        updatedTiles[entry.key] = entry.value.copyWith(
          building: entry.value.building!.copyWith(level: nextLvl),
        );
      }
    }

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(
        food: state.resources.food - foodCost,
        wood: state.resources.wood - woodCost,
      ),
      progression: state.progression.copyWith(castleLevel: nextLvl),
      activeToast: 'Kağan Otağı Seviye $nextLvl oldu (Küresel Hız: +%25).',
    );

    TactileAudioService.instance.play(TactileSoundType.upgrade);
    _syncQuestProgress();
    saveGame();
    return true;
  }

  void _syncQuestProgress() {
    final int ownedCount = state.progression.ownedCount;
    final int castleLevel = state.progression.castleLevel;
    final int shrineCount = state.tiles.values.where((t) => t.isOwned && t.hasShrine).length;

    final updatedQuests = state.quests.map((q) {
      if (q.isClaimed) return q;

      int current = q.currentAmount;
      switch (q.type) {
        case QuestType.conquerTiles:
          current = ownedCount;
          break;
        case QuestType.upgradeCastle:
          current = castleLevel;
          break;
        case QuestType.discoverShrine:
          current = shrineCount;
          break;
        case QuestType.buildStructure:
          if (q.targetBuilding != null) {
            current = state.tiles.values
                .where((t) => t.isOwned && t.building?.type == q.targetBuilding)
                .length;
          }
          break;
        case QuestType.gatherResource:
          break;
      }

      final bool isNowComplete = current >= q.targetAmount;
      return q.copyWith(
        currentAmount: current,
        isCompleted: isNowComplete,
      );
    }).toList();

    state = state.copyWith(quests: updatedQuests);
  }

  bool claimQuestReward(String questId) {
    final questIndex = state.quests.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return false;

    final quest = state.quests[questIndex];
    if (!quest.isCompleted || quest.isClaimed) {
      showToast('Görev henüz tamamlanmadı veya ödül zaten alındı.');
      return false;
    }

    ResourcesModel newRes = state.resources;
    String rewardName = 'Kaynak';

    switch (quest.rewardType) {
      case QuestRewardType.food:
        newRes = newRes.copyWith(food: newRes.food + quest.rewardAmount);
        rewardName = 'Gıda';
        break;
      case QuestRewardType.wood:
        newRes = newRes.copyWith(wood: newRes.wood + quest.rewardAmount);
        rewardName = 'Odun';
        break;
      case QuestRewardType.stone:
        newRes = newRes.copyWith(stone: newRes.stone + quest.rewardAmount);
        rewardName = 'Taş';
        break;
      case QuestRewardType.crowns:
        newRes = newRes.copyWith(crowns: newRes.crowns + quest.rewardAmount);
        rewardName = 'Taç';
        break;
    }

    final updatedQuests = List<QuestModel>.from(state.quests);
    updatedQuests[questIndex] = quest.copyWith(isClaimed: true);

    state = state.copyWith(
      resources: newRes,
      quests: updatedQuests,
      activeToast: 'Görev Ödülü Alındı: +${quest.rewardAmount} $rewardName',
    );

    TactileAudioService.instance.play(TactileSoundType.reward);
    saveGame();
    return true;
  }

  void activateFrenzy() {
    state = state.copyWith(
      frenzyMultiplier: 10,
      frenzyTimer: 60.0,
      activeToast: '10x Üretim Çılgınlığı Aktif (60 Saniye).',
    );
  }

  void setLanguage(String lang) {
    state = state.copyWith(
      settings: state.settings.copyWith(language: lang),
    );
    saveGame();
  }

  void setSfxVolume(double vol) {
    state = state.copyWith(
      settings: state.settings.copyWith(sfxVolume: vol),
    );
  }

  void toggleMute() {
    state = state.copyWith(
      settings: state.settings.copyWith(sfxMuted: !state.settings.sfxMuted),
    );
  }

  void updateNotificationSettings({
    bool? storageFullAlert,
    bool? seasonChangeAlert,
    bool? questCompletedAlert,
    bool? castleUpgradeReadyAlert,
  }) {
    final current = state.settings.notifications;
    final updated = current.copyWith(
      storageFullAlert: storageFullAlert,
      seasonChangeAlert: seasonChangeAlert,
      questCompletedAlert: questCompletedAlert,
      castleUpgradeReadyAlert: castleUpgradeReadyAlert,
    );
    state = state.copyWith(
      settings: state.settings.copyWith(notifications: updated),
    );
    saveGame();
  }

  Future<void> saveGame() async {
    _isSaveDirty = false;
    await SaveRepository.saveGame(
      resources: state.resources,
      progression: state.progression,
      season: state.season,
      settings: state.settings,
      tiles: state.tiles.values.toList(),
      toreTalents: state.toreTalents,
      titles: state.titles,
      stats: state.stats,
      quests: state.quests,
      doctrines: state.doctrines,
      activeDoctrineSlots: state.activeDoctrineSlots,
      caravanRoutes: state.caravanRoutes,
      celestialOmen: state.celestialOmen,
      yearIndex: state.yearIndex,
      discoveredKurgans: state.discoveredKurgans,
      adTracking: state.adTracking,
    );
  }

  /// Oyuncu inisiyatifinde çalışan etik ödüllü reklam talep mekanizması
  Future<bool> claimAdReward(
    AdRewardType type, {
    IAdRewardService? adService,
  }) async {
    final service = adService ?? MockAdRewardService();
    final currentTracking = state.adTracking.checkDailyReset();
    final currentCount = currentTracking.getWatchCount(type);
    final maxAllowed = EconomyCalculator.getMaxDailyWatches(type);

    if (currentCount >= maxAllowed) {
      state = state.copyWith(
        activeToast: 'Günlük azami bereket sınırına ulaşıldı.',
      );
      return false;
    }

    final success = await service.showRewardedAd(type);
    if (!success) {
      state = state.copyWith(
        activeToast: 'Kervan bağlantısı kurulamadı, daha sonra tekrar deneyin.',
      );
      return false;
    }

    // Reklam sayacını güncelle
    final updatedTracking = currentTracking.recordWatch(type);

    switch (type) {
      case AdRewardType.offlineProgressBoost:
        state = state.copyWith(
          adTracking: updatedTracking,
          activeToast: 'Kervan Bereketi: Çevrimdışı kazanç 1.5x katlandı!',
        );
        break;

      case AdRewardType.marketQuotaReset:
        state = state.copyWith(
          adTracking: updatedTracking,
          activeToast: 'Pazar Takas Kotası Sıfırlandı!',
        );
        break;

      case AdRewardType.caravanBonus:
        final bonus = EconomyCalculator.calculateCaravanAdBonus(
          castleLevel: state.progression.castleLevel,
          crowns: state.resources.crowns,
          dailyWatches: currentCount,
        );
        state = state.copyWith(
          resources: state.resources.copyWith(
            wood: state.resources.wood + (bonus['wood'] ?? 0),
            food: state.resources.food + (bonus['food'] ?? 0),
            stone: state.resources.stone + (bonus['stone'] ?? 0),
            iron: state.resources.iron + (bonus['iron'] ?? 0),
          ),
          adTracking: updatedTracking,
          activeToast:
              'Gezgin Kervan İkramı: +${bonus['wood']?.toInt()} Odun, +${bonus['food']?.toInt()} Gıda, +${bonus['stone']?.toInt()} Taş',
        );
        break;

      case AdRewardType.celestialBlessing:
        state = state.copyWith(
          shrineMultiplier: state.shrineMultiplier * 1.25,
          adTracking: updatedTracking,
          activeToast: 'Gök Tengri Bereketi: 10 dakika boyunca +%25 Kut Bereketi!',
        );
        break;

      case AdRewardType.migrationLegacy:
        state = state.copyWith(
          resources: state.resources.copyWith(
            tamgas: state.resources.tamgas + 1,
          ),
          adTracking: updatedTracking,
          activeToast: 'Kutlu Miras: +1 Kalıcı Atalar Tamgası Kazanıldı!',
        );
        break;
    }

    unawaited(TactileAudioService.instance.play(TactileSoundType.reward));
    await saveGame();
    return true;
  }

  Future<void> claimOfflineGains(OfflineGainsResult gains, {bool isBoosted = false}) async {
    final effectiveGains = isBoosted
        ? EconomyCalculator.calculateOfflineAdBoostedGains(gains)
        : gains;

    state = state.copyWith(
      resources: state.resources.copyWith(
        food: state.resources.food + effectiveGains.food,
        wood: state.resources.wood + effectiveGains.wood,
        flour: state.resources.flour + effectiveGains.flour,
        plank: state.resources.plank + effectiveGains.plank,
        bread: state.resources.bread + effectiveGains.bread,
        furniture: state.resources.furniture + effectiveGains.furniture,
        stone: state.resources.stone + effectiveGains.stone,
        iron: state.resources.iron + effectiveGains.iron,
      ),
      activeToast: isBoosted
          ? 'Kervan bereketiyle 1.5x çevrimdışı kazanç ambara aktarıldı!'
          : 'Çevrimdışı bozkır kazancı ambara aktarıldı.',
    );

    unawaited(TactileAudioService.instance.play(TactileSoundType.reward));
    await saveGame();
  }


  List<DoctrineCardModel> getActiveDoctrines() {
    final List<DoctrineCardModel> active = [];
    for (final docId in state.activeDoctrineSlots.values) {
      if (docId != null) {
        final doc = state.doctrines.where((d) => d.id == docId).firstOrNull;
        if (doc != null && doc.isUnlocked) {
          active.add(doc);
        }
      }
    }
    return active;
  }

  void unlockDoctrine(String id) {
    final doc = state.doctrines.where((d) => d.id == id).firstOrNull;
    if (doc == null || doc.isUnlocked) return;

    if (state.resources.crowns < doc.costCrowns) {
      showToast('Yetersiz Şan: Bu töre için ${doc.costCrowns} Şan gereklidir.');
      return;
    }

    final updatedDoctrines = state.doctrines.map((d) {
      if (d.id == id) return d.copyWith(isUnlocked: true);
      return d;
    }).toList();

    state = state.copyWith(
      resources: state.resources.copyWith(
        crowns: state.resources.crowns - doc.costCrowns,
      ),
      doctrines: updatedDoctrines,
      activeToast: '${doc.titleTr} töresi mecliste kabul edildi!',
    );

    TactileAudioService.instance.play(TactileSoundType.upgrade);
    saveGame();
  }

  void equipDoctrine(DoctrineSlotType slot, String? id) {
    if (id != null) {
      final doc = state.doctrines.where((d) => d.id == id).firstOrNull;
      if (doc == null || !doc.isUnlocked) return;
      if (slot != DoctrineSlotType.wildcard && doc.slotType != slot) {
        showToast('Bu töre seçilen yuvaya takılamaz.');
        return;
      }
    }

    final updatedSlots = Map<DoctrineSlotType, String?>.from(state.activeDoctrineSlots);
    updatedSlots[slot] = id;

    state = state.copyWith(
      activeDoctrineSlots: updatedSlots,
      activeToast: id != null ? 'Töre yürürlüğe girdi.' : 'Töre yuvası boşaltıldı.',
    );

    TactileAudioService.instance.play(TactileSoundType.tap);
    saveGame();
  }

  bool demolishBuilding(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null || !tile.isOwned || tile.building == null) return false;
    if (tile.building!.type == BuildingType.castle) {
      showToast('Kağan Otağı ve Merkez Karargah kaldırılamaz.');
      return false;
    }

    // BUG-004 Fix: Yıkım öncesinde binanın üzerinde birikmiş olan kaynakları otomatik olarak topla
    if (tile.building!.accumulatedResource > 0) {
      collectFromTile(coord);
    }

    final freshTile = state.tiles[coord] ?? tile;
    final b = freshTile.building ?? tile.building!;
    final double refundFood = (b.baseCost * 0.5).roundToDouble();

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = freshTile.copyWith(
      clearBuilding: true,
    );

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(
        food: state.resources.food + refundFood,
      ),
      activeToast: '${b.type.name.toUpperCase()} yıkıldı (+${refundFood.toInt()} Gıda iade edildi).',
    );

    unawaited(TactileAudioService.instance.play(TactileSoundType.tap));
    _syncQuestProgress();
    unawaited(saveGame());
    return true;
  }

  void addCaravanRoute(HexAxial startCoord, HexAxial endCoord) {
    final startTile = state.tiles[startCoord];
    final endTile = state.tiles[endCoord];
    if (startTile == null || !startTile.isOwned || endTile == null || !endTile.isOwned) {
      showToast('Kervan yolu yalnızca fethedilmiş araziler arasına kurulabilir.');
      return;
    }
    if (startCoord == endCoord) {
      showToast('Kervan yolu iki farklı arazi arasında olmalıdır.');
      return;
    }
    final int dist = startCoord.distanceTo(endCoord);
    if (dist > 8) {
      showToast('Kervan yolu çok uzun (Maksimum 8 Hex).');
      return;
    }

    final bool exists = state.caravanRoutes.any((r) =>
        (r.startCoord == startCoord && r.endCoord == endCoord) ||
        (r.startCoord == endCoord && r.endCoord == startCoord));
    if (exists) {
      showToast('Bu araziler arasında zaten bir kervan yolu mevcut.');
      return;
    }

    const double plankCost = 30.0;
    const double breadCost = 20.0;
    if (state.resources.plank < plankCost || state.resources.bread < breadCost) {
      showToast('Yetersiz Kaynak: Kervan yolu için 30 Kalas ve 20 Ekmek gerekir.');
      return;
    }

    final newRoute = CaravanRoute(
      id: 'caravan_${DateTime.now().millisecondsSinceEpoch}',
      startCoord: startCoord,
      endCoord: endCoord,
    );

    final updatedRoutes = [...state.caravanRoutes, newRoute];
    state = state.copyWith(
      caravanRoutes: updatedRoutes,
      resources: state.resources.copyWith(
        plank: state.resources.plank - plankCost,
        bread: state.resources.bread - breadCost,
      ),
      activeToast: 'İpek Yolu Kervan Hattı Kuruldu! (+%25 Takas Rezonansı)',
    );

    TactileAudioService.instance.play(TactileSoundType.build);
    saveGame();
  }

  void removeCaravanRoute(String routeId) {
    final updatedRoutes = state.caravanRoutes.where((r) => r.id != routeId).toList();
    state = state.copyWith(
      caravanRoutes: updatedRoutes,
      activeToast: 'Kervan yolu kaldırıldı.',
    );
    TactileAudioService.instance.play(TactileSoundType.tap);
    saveGame();
  }

  void toggleTranshumance() {
    final updatedTiles = <HexAxial, HexTileModel>{};
    int toggledCount = 0;
    bool anyResting = false;

    for (final entry in state.tiles.entries) {
      final tile = entry.value;
      if (tile.isOwned && (tile.biome == TileBiome.meadow || tile.building?.type == BuildingType.pasture)) {
        final bool newResting = !tile.isResting;
        updatedTiles[entry.key] = tile.copyWith(isResting: newResting);
        toggledCount++;
        if (newResting) anyResting = true;
      } else {
        updatedTiles[entry.key] = tile;
      }
    }

    if (toggledCount == 0) {
      showToast('Dinlendirilecek çayır veya otlak arazisi bulunamadı.');
      return;
    }

    state = state.copyWith(
      tiles: updatedTiles,
      activeToast: anyResting
          ? 'Yaylak Göçü: Çayırlar dinlenmeye alındı (Toprak yenileniyor, 2.5x Bereket birikiyor).'
          : 'Kışlak Dönüşü: Sürüler otlaklara döndü (Üretim yeniden başladı).',
    );

    TactileAudioService.instance.play(TactileSoundType.stoneClick);
    saveGame();
  }

  void recordRhythmTap() {
    final double now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final double last = state.lastRhythmTapTime;
    final double diffSec = (now - last) / 1000.0;

    int newCombo = 1;
    if (diffSec >= 0.35 && diffSec <= 0.70) {
      newCombo = math.min(5, state.rhythmCombo + 1);
    } else {
      newCombo = 1;
    }

    final double multiplier = EconomyCalculator.calculateRhythmComboMultiplier(newCombo);

    state = state.copyWith(
      lastRhythmTapTime: now,
      rhythmCombo: newCombo,
      rhythmMultiplier: multiplier,
    );

    TactileAudioService.instance.play(TactileSoundType.tap);
  }

  void discoverAncestralKurgan(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null || tile.ancestralKurgan == null) return;

    final kurgan = tile.ancestralKurgan!;
    if (kurgan.isDiscovered) return;

    final discoveredKurgan = kurgan.copyWith(isDiscovered: true);
    final updatedTile = tile.copyWith(ancestralKurgan: discoveredKurgan);

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = updatedTile;

    final updatedDiscovered = [...state.discoveredKurgans, discoveredKurgan];

    state = state.copyWith(
      tiles: updatedTiles,
      discoveredKurgans: updatedDiscovered,
      activeToast: 'Ata Kurganı Keşfedildi! (${kurgan.relicTitle} - +${(kurgan.bonusMultiplier * 100).toInt()}% Kalıcı Miras)',
    );

    TactileAudioService.instance.play(TactileSoundType.upgrade);
    saveGame();
  }

  void toggleMacroOverview() {
    state = state.copyWith(isMacroOverview: !state.isMacroOverview);
  }

  void toggleDioramaMode() {
    state = state.copyWith(isDioramaMode: !state.isDioramaMode);
  }

  void resetGame() {
    SaveRepository.deleteSave();

    // BUG-003 Fix: Koordinat bazlı harita ile aynı karoda üst üste kurgan çakışmasını engelle
    final Map<HexAxial, AncestralKurgan> kurganMap = {
      for (final k in state.discoveredKurgans) k.coord: k,
    };

    for (final entry in state.tiles.entries) {
      final tile = entry.value;
      if (tile.isOwned && tile.hasBuilding && tile.building!.type != BuildingType.castle) {
        final existing = kurganMap[tile.coord];
        final double newBonus = 0.05 * tile.building!.level;
        final int mergedLevel = existing != null ? math.max(existing.formerLevel, tile.building!.level) : tile.building!.level;
        final double mergedBonus = existing != null ? math.max(existing.bonusMultiplier, newBonus) : newBonus;

        kurganMap[tile.coord] = AncestralKurgan(
          id: 'kurgan_${state.progression.totalMigrations}_${tile.coord.q}_${tile.coord.r}',
          coord: tile.coord,
          formerBuildingType: tile.building!.type,
          formerLevel: mergedLevel,
          relicTitle: '${tile.building!.type.name.toUpperCase()} Kalıntısı',
          bonusMultiplier: mergedBonus,
          isDiscovered: true,
        );
      }
    }
    final List<AncestralKurgan> accumulatedKurgans = kurganMap.values.toList();

    // Prestige (Tamga) Hesaplama: (Hex Sayısı + Sunak Sayısı) / 2
    final int ownedHexes = state.progression.ownedCount;
    final int shrines = state.tiles.values.where((t) => t.isOwned && t.hasShrine).length;
    final int newTamgas = (ownedHexes + (shrines * 5)) ~/ 2;

    final int currentTamgas = state.resources.tamgas;
    final int totalTamgas = currentTamgas + newTamgas;
    final int nextMigrations = state.progression.totalMigrations + 1;

    final migrationRecord = MigrationRecordModel(
      migrationNumber: nextMigrations,
      ownedCount: ownedHexes,
      tamgasGained: newTamgas,
      zudCount: (state.stats['zudCount'] as num?)?.toInt() ?? 0,
      topSynergy: 'Bozkır Yerleşimi',
      doctrinesUsed: state.activeDoctrineSlots.values.whereType<String>().toList(),
      timestamp: DateTime.now().toIso8601String(),
    );
    final updatedHistory = [...state.progression.migrationHistory, migrationRecord];
    final int preservedSessions = state.progression.totalSessions;
    final preservedBiomes = Map<String, int>.from(state.progression.cumulativeBiomeCounts);

    state = _createInitialState();

    // Yeni oyuna Tamga ve Global Multiplier ile başla
    final double tamgaMult = EconomyCalculator.getTamgaMultiplier(totalTamgas);

    state = state.copyWith(
      resources: state.resources.copyWith(tamgas: totalTamgas),
      progression: state.progression.copyWith(
        totalMigrations: nextMigrations,
        migrationHistory: updatedHistory,
        cumulativeBiomeCounts: preservedBiomes,
        totalSessions: preservedSessions,
      ),
      discoveredKurgans: accumulatedKurgans,
      activeToast: 'Büyük Göç Tamamlandı. +$newTamgas Tamga & Geçmiş Göç Kalıntıları Miras Kaldı!',
    );

    saveGame();
  }

  /// 1. İpek Yolu Elçi Siparişini (Han Buyruğu) Teslim Et
  bool fulfillTradeOrder(String orderId) {
    final orderIndex = state.progression.activeTradeOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) return false;

    final order = state.progression.activeTradeOrders[orderIndex];
    if (order.isFulfilled) return false;

    // Kaynak yeterliliğini kontrol et
    final currentRes = state.resources;
    for (final req in order.requiredResources.entries) {
      final double available = switch (req.key.toLowerCase()) {
        'food' => currentRes.food,
        'wood' => currentRes.wood,
        'flour' => currentRes.flour,
        'plank' => currentRes.plank,
        'bread' => currentRes.bread,
        'furniture' => currentRes.furniture,
        'stone' => currentRes.stone,
        'iron' => currentRes.iron,
        'fish' => currentRes.fish,
        'kumis' => currentRes.kumis,
        'felt' => currentRes.felt,
        'damascus_steel' || 'damascussteel' => currentRes.damascusSteel,
        _ => 0.0,
      };
      if (available < req.value) {
        showToast('Yetersiz Kaynak: ${req.key.toUpperCase()} miktarı eksik (${available.toInt()} / ${req.value.toInt()}).');
        return false;
      }
    }

    // Kaynakları düş
    final updatedRes = currentRes.copyWith(
      food: currentRes.food - (order.requiredResources['food'] ?? 0.0),
      wood: currentRes.wood - (order.requiredResources['wood'] ?? 0.0),
      flour: currentRes.flour - (order.requiredResources['flour'] ?? 0.0),
      plank: currentRes.plank - (order.requiredResources['plank'] ?? 0.0),
      bread: currentRes.bread - (order.requiredResources['bread'] ?? 0.0),
      furniture: currentRes.furniture - (order.requiredResources['furniture'] ?? 0.0),
      stone: currentRes.stone - (order.requiredResources['stone'] ?? 0.0),
      iron: currentRes.iron - (order.requiredResources['iron'] ?? 0.0),
      fish: currentRes.fish - (order.requiredResources['fish'] ?? 0.0),
      kumis: currentRes.kumis - (order.requiredResources['kumis'] ?? 0.0),
      felt: currentRes.felt - (order.requiredResources['felt'] ?? 0.0),
      damascusSteel: currentRes.damascusSteel - (order.requiredResources['damascus_steel'] ?? order.requiredResources['damascussteel'] ?? 0.0),
      crowns: currentRes.crowns + order.rewardCrowns,
    );

    // Siparişi tamamlandı olarak işaretle
    final updatedOrders = List<TradeOrderModel>.from(state.progression.activeTradeOrders);
    updatedOrders[orderIndex] = order.copyWith(isFulfilled: true);

    state = state.copyWith(
      resources: updatedRes,
      progression: state.progression.copyWith(activeTradeOrders: updatedOrders),
      frenzyMultiplier: math.max(state.frenzyMultiplier, (order.rewardSpeedMultiplier).toInt()),
      frenzyTimer: state.frenzyTimer + order.buffDurationSeconds.toDouble(),
      activeToast: '${order.title} tamamlandı! (+${order.rewardCrowns} Taç & Altın Çağ Hız Buff\'ı)',
    );

    TactileAudioService.instance.play(TactileSoundType.reward);
    saveGame();
    return true;
  }

  /// 2. Orhun Bitig Taşları Töre Ağacında Bilgelik ile Kilit Aç
  bool unlockSteppeLore(String loreId) {
    if (state.progression.unlockedLoreIds.contains(loreId)) return false;

    final node = SteppeLoreNode.defaultLoreTree.where((n) => n.id == loreId).firstOrNull;
    if (node == null) return false;

    if (state.resources.wisdom < node.costWisdom) {
      showToast('Yetersiz Bilgelik: Bu töre için ${node.costWisdom.toInt()} Bitig Bilgeliği gerekir.');
      return false;
    }

    final updatedLore = [...state.progression.unlockedLoreIds, loreId];
    state = state.copyWith(
      resources: state.resources.copyWith(
        wisdom: state.resources.wisdom - node.costWisdom,
      ),
      progression: state.progression.copyWith(
        unlockedLoreIds: updatedLore,
      ),
      activeToast: 'Töre Kanunu Kabul Edildi: ${node.title} (${node.description})',
    );

    TactileAudioService.instance.play(TactileSoundType.upgrade);
    saveGame();
    return true;
  }

  /// 3. Büyük Göçte Yeni Bozkır Diyarı Seçimi
  void selectMigrationRealm(String realmId) {
    final cleanId = realmId.toLowerCase();
    state = state.copyWith(
      progression: state.progression.copyWith(activeRealmId: cleanId),
      activeToast: cleanId == 'idil'
          ? 'İdil-Yayık Nehir Havzası Seçildi: Balık ve Gıda bereketi 2x!'
          : cleanId == 'karakum'
              ? 'Karakum Vahaları Seçildi: İpek Yolu Kervanları ve Pazar bereketi 2x!'
              : 'Altay Göksel Platoları Seçildi: Taş, Maden ve Şam Çeliği bereketi 2x!',
    );

    TactileAudioService.instance.play(TactileSoundType.stoneClick);
    saveGame();
  }
}
