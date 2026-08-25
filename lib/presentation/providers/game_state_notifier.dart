import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../data/save_repository.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/game_state_model.dart';
import '../../domain/models/hex_tile_model.dart';
import '../../domain/models/quest_model.dart';

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  Timer? _gameLoopTimer;
  Timer? _autoSaveTimer;

  GameStateNotifier() : super(_createInitialState()) {
    initialize();
  }

  static List<QuestModel> _generateInitialQuests() {
    return const [
      QuestModel(
        id: 'q_corn_1',
        titleTr: 'Bozkırın Ekmeği',
        titleEn: 'Bread of the Steppe',
        descriptionTr: 'Krallığı beslemek için 1 adet Buğday Tarlası inşa et.',
        descriptionEn: 'Build 1 Corn Farm to feed your realm.',
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
        descriptionTr: 'Şatonu Seviye 2\'ye yükselt.',
        descriptionEn: 'Upgrade your Castle to Level 2.',
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
    const int radius = 3;
    final random = math.Random(42);

    // Merkez karo: (0, 0) Çayır + Şato
    const centerCoord = HexAxial(0, 0);
    map[centerCoord] = const HexTileModel(
      coord: centerCoord,
      biome: TileBiome.meadow,
      state: TileState.owned,
      building: BuildingModel(type: BuildingType.castle, level: 1),
    );

    // Çevresindeki 4 radius ızgarayı oluştur (Başlangıç keşfi)
    final initialRange = centerCoord.getRange(4);
    for (final coord in initialRange) {
      if (!map.containsKey(coord)) {
        final biome = TileBiome.values[random.nextInt(TileBiome.values.length)];
        map[coord] = HexTileModel(
          coord: coord,
          biome: biome,
          state: TileState.discovered,
        );
      }
    }

    // Radius 8 (veya daha büyük) ızgarayı oluştur (fog)
    const int gridRadius = 8;
    for (int q = -gridRadius; q <= gridRadius; q++) {
      final int r1 = math.max(-gridRadius, -q - gridRadius);
      final int r2 = math.min(gridRadius, -q + gridRadius);
      for (int r = r1; r <= r2; r++) {
        final coord = HexAxial(q, r);
        if (!map.containsKey(coord)) {
          final biome = TileBiome.values[random.nextInt(TileBiome.values.length)];
          map[coord] = HexTileModel(
            coord: coord,
            biome: biome,
            state: TileState.fog,
          );
        }
      }
    }

    return GameState(
      tiles: map,
      resources: const ResourcesModel(food: 50.0, wood: 20.0),
      progression: const ProgressionModel(castleLevel: 1, ownedCount: 1),
      quests: _generateInitialQuests(),
    );
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    final save = await SaveRepository.loadGame();
    if (!mounted) return;

    if (save != null && save.tiles.isNotEmpty) {
      final tilesMap = {for (final t in save.tiles) t.coord: t};
      state = state.copyWith(
        tiles: tilesMap,
        resources: save.resources,
        progression: save.progression,
        season: save.season,
        settings: save.settings,
        toreTalents: save.toreTalents,
        titles: save.titles,
        stats: save.stats,
        quests: save.quests.isNotEmpty ? save.quests : _generateInitialQuests(),
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
      if (mounted) saveGame();
    });
  }

  void _tick() {
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
    double newFrenzyTimer = math.max(0.0, state.frenzyTimer - 1.0);
    int newFrenzyMultiplier = newFrenzyTimer > 0 ? state.frenzyMultiplier : 1;

    // Toplam İşçi Taşıma Kapasitesi Hesapla
    double totalWorkerCapacity = 0.0;
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
          b.type == BuildingType.fishermanHut) {
        continue;
      }

      // Komşuluk sinerjisi hesapla
      double synergy = 1.0;
      for (final nCoord in tile.coord.neighbors) {
        final nTile = state.tiles[nCoord];
        if (nTile != null && nTile.isOwned && nTile.building != null) {
          if (b.type == BuildingType.windmill &&
              nTile.building!.type == BuildingType.corn) {
            synergy = 2.0;
          }
          if (b.type == BuildingType.sawmill &&
              nTile.building!.type == BuildingType.lumberjack) {
            synergy = 2.0;
          }
          if (b.type == BuildingType.bakery &&
              nTile.building!.type == BuildingType.windmill) {
            synergy = 2.0;
          }
          if (b.type == BuildingType.furniture &&
              nTile.building!.type == BuildingType.sawmill) {
            synergy = 2.0;
          }
        }
      }

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

      final double rate = EconomyCalculator.calculateBuildingProduction(
        type: b.type,
        level: b.level,
        baseRate: b.baseProductionRate,
        globalMultiplier: globalMult,
        seasonMultiplier: seasonMult,
        synergyMultiplier: synergy,
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
        if (currentFood >= rate * 0.5) consumeFood = rate * 0.5;
        else canProduce = false;
      } else if (b.type == BuildingType.sawmill) {
        if (currentWood >= rate * 0.5) consumeWood = rate * 0.5;
        else canProduce = false;
      } else if (b.type == BuildingType.bakery) {
        if (currentFlour >= rate * 0.4 && currentFood >= rate * 0.4) {
          consumeFlour = rate * 0.4;
          consumeFood = rate * 0.4;
        } else canProduce = false;
      } else if (b.type == BuildingType.furniture) {
        if (currentPlank >= rate * 0.4 && currentWood >= rate * 0.4) {
          consumePlank = rate * 0.4;
          consumeWood = rate * 0.4;
        } else canProduce = false;
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
        double carriedAmount = math.min(rate, totalWorkerCapacity);
        totalWorkerCapacity -= carriedAmount;
        double storedAmount = rate - carriedAmount;

        // Taşınanları ekle
        switch (b.type) {
          case BuildingType.corn:
            addedFood += carriedAmount;
            currentFood += carriedAmount;
            break;
          case BuildingType.lumberjack:
            addedWood += carriedAmount;
            currentWood += carriedAmount;
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
              addedIron += carriedAmount * 0.3;
            }
            break;
          case BuildingType.fisherman:
            addedFish += carriedAmount;
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
    if (state.selectedCoord == coord) {
      state = state.copyWith(clearSelection: true);
    } else {
      state = state.copyWith(selectedCoord: coord);
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

  double calculateExpansionCost(TileBiome biome) {
    final Map<String, int> biomeCounts = {
      'meadow': state.progression.purchasedMeadowCount,
      'forest': state.progression.purchasedForestCount,
      'sea': state.progression.purchasedSeaCount,
      'mountain': state.progression.purchasedMountainCount,
    };

    return EconomyCalculator.getExpansionCost(
      biome: biome,
      ownedCount: state.progression.ownedCount,
      biomeCounts: biomeCounts,
      toreTalents: state.toreTalents,
      titles: state.titles,
    );
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

    // Orman ve Çöl kilit kontrolü: Şato Seviye >= 2
    if ((tile.biome == TileBiome.forest || tile.biome == TileBiome.desert) && state.progression.castleLevel < 2) {
      showToast(
          'Arazi Kilitli: Çöl ve Orman keşfi için Şato Seviye 2 gereklidir.');
      return false;
    }
    // Dağ ve Sazlık kilit kontrolü: Şato Seviye >= 3
    if ((tile.biome == TileBiome.mountain || tile.biome == TileBiome.wetland) && state.progression.castleLevel < 3) {
      showToast(
          'Arazi Kilitli: Dağ ve Sazlık keşfi için Şato Seviye 3 gereklidir.');
      return false;
    }
    // Deniz ve Tundra kilit kontrolü: Şato Seviye >= 4
    if ((tile.biome == TileBiome.sea || tile.biome == TileBiome.tundra) && state.progression.castleLevel < 4) {
      showToast(
          'Arazi Kilitli: Deniz ve Tundra keşfi için Şato Seviye 4 gereklidir.');
      return false;
    }
    // Volkan kilit kontrolü: Şato Seviye >= 5
    if (tile.biome == TileBiome.volcano && state.progression.castleLevel < 5) {
      showToast(
          'Volkan Kilitli: Obsidiyen arazileri için Şato Seviye 5 gereklidir.');
      return false;
    }

    final double cost = calculateExpansionCost(tile.biome);
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
    if (tile.biome == TileBiome.meadow) mCount++;
    if (tile.biome == TileBiome.forest) fCount++;
    if (tile.biome == TileBiome.sea) sCount++;
    if (tile.biome == TileBiome.mountain) mtCount++;

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(food: state.resources.food - cost),
      progression: state.progression.copyWith(
        ownedCount: state.progression.ownedCount + 1,
        purchasedMeadowCount: mCount,
        purchasedForestCount: fCount,
        purchasedSeaCount: sCount,
        purchasedMountainCount: mtCount,
      ),
      shrineMultiplier: newShrineMult,
      activeToast: tile.hasShrine
          ? 'Sunak gücüyle beraber yeni arsa fethedildi.'
          : '${cost.toInt()} Gıda karşılığında yeni arsa fethedildi.',
    );

    TactileAudioService.instance.play(TactileSoundType.conquer);
    _syncQuestProgress();
    saveGame();
    return true;
  }

  bool buildStructure(HexAxial coord, BuildingType type) {
    final tile = state.tiles[coord];
    if (tile == null || !tile.isOwned || tile.hasBuilding) return false;

    // Şato Seviyesi Kilit Kontrolleri
    final int castleLvl = state.progression.castleLevel;
    if ((type == BuildingType.lumberjack ||
            type == BuildingType.sawmill ||
            type == BuildingType.watchtower) &&
        castleLvl < 2) {
      showToast('Kilitli: Bu yapı için Şato Seviye 2 gereklidir.');
      return false;
    }
    if ((type == BuildingType.windmill ||
            type == BuildingType.bakery ||
            type == BuildingType.mine ||
            type == BuildingType.bridge ||
            type == BuildingType.fisherman ||
            type == BuildingType.fishermanHut) &&
        castleLvl < 3) {
      showToast('Kilitli: Bu yapı için Şato Seviye 3 gereklidir.');
      return false;
    }
    if (type == BuildingType.furniture && castleLvl < 4) {
      showToast('Kilitli: Mobilyacı için Şato Seviye 4 gereklidir.');
      return false;
    }

    if (type == BuildingType.corn && tile.biome != TileBiome.meadow) {
      showToast('Mısır Tarlası yalnızca Çayır biyomuna inşa edilebilir.');
      return false;
    }
    if (type == BuildingType.lumberjack && tile.biome != TileBiome.forest) {
      showToast('Oduncu Kulübesi yalnızca Orman biyomuna inşa edilebilir.');
      return false;
    }
    if (type == BuildingType.bridge) {
      if (tile.biome != TileBiome.sea && tile.biome != TileBiome.wetland) {
        showToast('Köprü yalnızca Deniz veya Sazlık biyomuna inşa edilebilir.');
        return false;
      }
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
    if (type == BuildingType.mine &&
        tile.biome != TileBiome.mountain &&
        tile.biome != TileBiome.volcano &&
        tile.biome != TileBiome.tundra) {
      showToast('Maden Ocağı yalnızca Dağ, Tundra veya Volkan biyomuna inşa edilebilir.');
      return false;
    }
    if (type == BuildingType.fisherman &&
        tile.biome != TileBiome.sea &&
        tile.biome != TileBiome.wetland) {
      showToast('Balıkçı yalnızca Deniz veya Sazlık biyomuna inşa edilebilir.');
      return false;
    }
    if (type == BuildingType.fishermanHut) {
      if (tile.biome != TileBiome.sea && tile.biome != TileBiome.wetland) {
        showToast('Balıkçı Barınağı yalnızca Deniz veya Sazlık biyomuna inşa edilebilir.');
        return false;
      }
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

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(building: BuildingModel(type: type));

    // Gözcü Kulesi ise etrafındaki 2 kademe sisi aç
    if (type == BuildingType.watchtower) {
      const int towerRadius = 2;
      for (int q = -towerRadius; q <= towerRadius; q++) {
        final int r1 = math.max(-towerRadius, -q - towerRadius);
        final int r2 = math.min(towerRadius, -q + towerRadius);
        for (int r = r1; r <= r2; r++) {
          final targetCoord = coord + HexAxial(q, r);
          if (updatedTiles.containsKey(targetCoord)) {
            final t = updatedTiles[targetCoord]!;
            if (t.isFog) {
              updatedTiles[targetCoord] =
                  t.copyWith(state: TileState.discovered);
            }
          }
        }
      }
    }

    state = state.copyWith(
      tiles: updatedTiles,
      resources: state.resources.copyWith(food: state.resources.food - cost),
      activeToast: '${type.name.toUpperCase()} inşa edildi.',
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
    final double accum = b.accumulatedResource;
    if (accum <= 0.0) return false;

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(
      building: b.copyWith(accumulatedResource: 0.0),
    );

    ResourcesModel res = state.resources;
    if (b.type == BuildingType.corn) {
      res = res.copyWith(food: res.food + accum);
    } else if (b.type == BuildingType.lumberjack) {
      res = res.copyWith(wood: res.wood + accum);
    } else if (b.type == BuildingType.fisherman) {
      res = res.copyWith(fish: res.fish + accum);
    } else if (b.type == BuildingType.windmill) {
      res = res.copyWith(flour: res.flour + accum);
    } else if (b.type == BuildingType.sawmill) {
      res = res.copyWith(plank: res.plank + accum);
    } else if (b.type == BuildingType.bakery) {
      res = res.copyWith(bread: res.bread + accum);
    } else if (b.type == BuildingType.furniture) {
      res = res.copyWith(furniture: res.furniture + accum);
    } else if (b.type == BuildingType.mine) {
      res = res.copyWith(stone: res.stone + accum);
    }

    state = state.copyWith(
      tiles: updatedTiles,
      resources: res,
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

    const double woodCost = 5.0;
    if (state.resources.wood < woodCost) {
      showToast('Karoyu ısıtmak için 5 Odun gereklidir.');
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
      activeToast: 'Karo 3 dakika boyunca ısıtıldı (Üretim Hızı: +%50).',
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

    state = state.copyWith(
      titles: newTitles,
      activeToast: 'Yeni Unvan Açıldı: ${titleKey.toUpperCase()}',
    );

    TactileAudioService.instance.play(TactileSoundType.reward);
    saveGame();
    return true;
  }

  bool upgradeCastle() {
    final int nextLvl = state.progression.castleLevel + 1;
    final double foodCost = 50.0 * math.pow(1.5, nextLvl - 2);
    // İlk bir kaç seviye (Lvl 2 ve 3) odun istemesin
    final double woodCost = nextLvl <= 3 ? 0.0 : 25.0 * math.pow(1.5, nextLvl - 4);

    if (state.resources.food < foodCost || state.resources.wood < woodCost) {
      String costMsg = 'Şato yükseltme için ${foodCost.toInt()} Gıda';
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
      activeToast: 'Krallık Şatosu Seviye $nextLvl oldu (Küresel Hız: +%25).',
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

  Future<void> saveGame() async {
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
    );
  }

  void resetGame() {
    SaveRepository.deleteSave();

    // Prestige (Tamga) Hesaplama: (Hex Sayısı + Sunak Sayısı) / 2
    final int ownedHexes = state.progression.ownedCount;
    final int shrines = state.tiles.values.where((t) => t.isOwned && t.hasShrine).length;
    final int newTamgas = (ownedHexes + (shrines * 5)) ~/ 2;

    final int currentTamgas = state.resources.tamgas;
    final int totalTamgas = currentTamgas + newTamgas;

    state = _createInitialState();

    // Yeni oyuna Tamga ve Global Multiplier ile başla
    final double tamgaMult = EconomyCalculator.getTamgaMultiplier(totalTamgas);

    state = state.copyWith(
      resources: state.resources.copyWith(tamgas: totalTamgas),
      activeToast: 'Göç Tamamlandı. +$newTamgas Tamga Kazanıldı (Yeni Çarpan: x${tamgaMult.toStringAsFixed(1)}).',
    );

    saveGame();
  }
}
