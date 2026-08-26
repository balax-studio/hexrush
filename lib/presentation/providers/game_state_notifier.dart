import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../core/hex/hex_math.dart';
import '../../data/save_repository.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/doctrine_model.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/game_state_model.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/hex_tile_model.dart';
import '../../domain/models/quest_model.dart';

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
          // Radius 1: Ağırlıklı Çayır ve Orman (%80 Çayır, %20 Orman)
          biome = random.nextDouble() < 0.80 ? TileBiome.meadow : TileBiome.forest;
        } else if (dist == 2) {
          // Radius 2: Çayır (%65), Orman (%25), Çöl (%10)
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
      progression: const ProgressionModel(castleLevel: 1, ownedCount: 1),
      quests: _generateInitialQuests(),
      doctrines: DoctrineCardModel.getInitialDoctrines(),
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
        final tilesMap = {for (final t in save.tiles) t.coord: t};
        state = state.copyWith(
          tiles: tilesMap,
          resources: save.resources,
          progression: save.progression.copyWith(
            totalSessions: save.progression.totalSessions + 1,
          ),
          season: save.season,
          settings: save.settings,
          toreTalents: save.toreTalents,
          titles: save.titles,
          stats: save.stats,
          quests: save.quests.isNotEmpty ? save.quests : _generateInitialQuests(),
          doctrines: save.doctrines.isNotEmpty ? save.doctrines : DoctrineCardModel.getInitialDoctrines(),
          activeDoctrineSlots: save.activeDoctrineSlots.isNotEmpty ? save.activeDoctrineSlots : state.activeDoctrineSlots,
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
      }
    }

    // Frenzy zamanlayıcı
    final double newFrenzyTimer = math.max(0.0, state.frenzyTimer - 1.0);
    final int newFrenzyMultiplier = newFrenzyTimer > 0 ? state.frenzyMultiplier : 1;

    // Toplam İşçi Taşıma Kapasitesi: Şatodan gelen 1.0 taban kapasite + İşçi Çadırları (Softlock Önleme)
    double totalWorkerCapacity = 1.0;
    for (final t in state.tiles.values) {
      if (t.isOwned && t.building != null) {
        totalWorkerCapacity += t.building!.currentCarryingCapacity;
      }
    }
    // Yeteneklerden gelen hız bonusunu kapasiteye uygula
    totalWorkerCapacity *= workerTransferMult;

    double addedFood = 0.0;
    double addedWood = 0.0;
    double addedFish = 0.0;
    double addedFlour = 0.0;
    double addedPlank = 0.0;
    double addedBread = 0.0;
    double addedFurniture = 0.0;
    double addedStone = 0.0;
    double addedIron = 0.0;

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

      final double rate = EconomyCalculator.calculateBuildingProduction(
        type: b.type,
        level: b.level,
        baseRate: b.baseProductionRate,
        globalMultiplier: globalMult * docMult,
        seasonMultiplier: seasonMult,
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

        // Taşıma Kapasitesi Kontrolü
        final double carriedAmount = math.min(rate, totalWorkerCapacity);
        totalWorkerCapacity -= carriedAmount;
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
          default:
            break;
        }

        // Taşınamayanları binada biriktir
        final double newAccum = math.min(b.maxCapacity, b.accumulatedResource + storedAmount);
        updatedTiles[entry.key] = tile.copyWith(
          building: b.copyWith(accumulatedResource: newAccum),
          isWarmed: isWarmed,
          warmTimer: warmTimer,
        );
      } else {
        // Üretim yapılamadı (kaynak yok), sadece ısıtma timerı güncellensin
        updatedTiles[entry.key] = tile.copyWith(
          isWarmed: isWarmed,
          warmTimer: warmTimer,
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
        ];
      case TileBiome.forest:
        return const [
          BuildingType.lumberjack,
          BuildingType.resinCamp,
          BuildingType.sawmill,
          BuildingType.furniture,
          BuildingType.worker,
        ];
      case TileBiome.mountain:
        return const [
          BuildingType.mine,
          BuildingType.quarry,
          BuildingType.watchtower,
        ];
      case TileBiome.sea:
        return const [
          BuildingType.bridge,
          BuildingType.fisherman,
          BuildingType.fishermanHut,
        ];
      case TileBiome.desert:
        return const [
          BuildingType.oasisCistern,
          BuildingType.caravanserai,
          BuildingType.astrolabe,
        ];
      case TileBiome.tundra:
        return const [
          BuildingType.reindeerSanctuary,
          BuildingType.geothermalBath,
          BuildingType.permafrostDig,
        ];
      case TileBiome.volcano:
        return const [
          BuildingType.steamVent,
          BuildingType.obsidianForge,
        ];
      case TileBiome.wetland:
        return const [
          BuildingType.herbalistYurt,
          BuildingType.scribeWorkshop,
        ];
      case TileBiome.celestialCrater:
        return const [
          BuildingType.celestialAnvil,
        ];
      case TileBiome.kurganValley:
        return const [
          BuildingType.ancestralTotem,
        ];
      case TileBiome.crystalChasm:
        return const [
          BuildingType.prismaticResonator,
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

    state = state.copyWith(
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
    );
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

    final b = tile.building!;
    final double refundFood = (b.baseCost * 0.5).roundToDouble();

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(
      clearBuilding: true,
    );

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(
        food: state.resources.food + refundFood,
      ),
      activeToast: '${b.type.name.toUpperCase()} yıkıldı (+${refundFood.toInt()} Gıda iade edildi).',
    );

    TactileAudioService.instance.play(TactileSoundType.tap);
    _syncQuestProgress();
    saveGame();
    return true;
  }

  void resetGame() {
    SaveRepository.deleteSave();

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
      activeToast: 'Göç Tamamlandı. +$newTamgas Tamga Kazanıldı (Yeni Çarpan: x${tamgaMult.toStringAsFixed(1)}).',
    );

    saveGame();
  }
}
