import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../data/save_repository.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/game_state_model.dart';
import '../../domain/models/hex_tile_model.dart';

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

    // Çevresindeki 6 ilk komşu (keşfedilmiş)
    final immediateTypes = [
      TileBiome.meadow,
      TileBiome.meadow,
      TileBiome.meadow,
      TileBiome.forest,
      TileBiome.forest,
      TileBiome.mountain,
    ];

    int idx = 0;
    for (final neighbor in centerCoord.neighbors) {
      map[neighbor] = HexTileModel(
        coord: neighbor,
        biome: immediateTypes[idx % immediateTypes.length],
        state: TileState.discovered,
      );
      idx++;
    }

    // Radius 3 ızgarayı oluştur (fog)
    for (int q = -radius; q <= radius; q++) {
      final int r1 = math.max(-radius, -q - radius);
      final int r2 = math.min(radius, -q + radius);
      for (int r = r1; r <= r2; r++) {
        final coord = HexAxial(q, r);
        if (!map.containsKey(coord)) {
          final biome =
              TileBiome.values[random.nextInt(TileBiome.values.length)];
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
      );

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
              '✨ Çevrimdışı Gelir: +${offline.food.toStringAsFixed(1)} 🥡 +${offline.wood.toStringAsFixed(1)} 🪵',
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

    // Sezon güncellemesi (120 saniyede bir sezon değişir)
    double newSeasonTimer = state.season.timer + 1.0;
    String newSeason = state.season.current;
    int newYear = state.season.year;
    bool newIsZud = state.season.isZud;

    if (newSeasonTimer >= 120.0) {
      newSeasonTimer = 0.0;
      if (newSeason == 'SPRING') {
        newSeason = 'SUMMER';
      } else if (newSeason == 'SUMMER') {
        newSeason = 'AUTUMN';
      } else if (newSeason == 'AUTUMN') {
        newSeason = 'WINTER';
        // Kış başlangıcında %25 olasılıkla Zud afeti
        newIsZud = math.Random().nextDouble() < 0.25;
        if (newIsZud) {
          showToast('❄️ DİKKAT: Şiddetli Zud Afeti Başladı! (%40 Kayıp)');
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

    // İşçi var mı kontrol et
    final bool hasWorkers = state.tiles.values
        .any((t) => t.isOwned && t.building?.type == BuildingType.worker);

    double addedFood = 0.0;
    double addedWood = 0.0;
    double addedFlour = 0.0;
    double addedPlank = 0.0;
    double addedBread = 0.0;
    double addedFurniture = 0.0;
    double addedStone = 0.0;
    double addedIron = 0.0;

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);

    for (final entry in state.tiles.entries) {
      final tile = entry.value;
      if (!tile.isOwned || tile.building == null) continue;

      final b = tile.building!;
      if (b.type == BuildingType.castle ||
          b.type == BuildingType.worker ||
          b.type == BuildingType.watchtower ||
          b.type == BuildingType.bridge) {
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

      final double rate = b.currentProductionRate *
          globalMult *
          seasonMult *
          synergy *
          (hasWorkers ? workerTransferMult : 1.0);

      if (hasWorkers) {
        switch (b.type) {
          case BuildingType.corn:
            addedFood += rate;
            break;
          case BuildingType.lumberjack:
            addedWood += rate;
            break;
          case BuildingType.windmill:
            if (state.resources.food >= rate * 0.5) {
              addedFood -= rate * 0.5;
              addedFlour += rate;
            }
            break;
          case BuildingType.sawmill:
            if (state.resources.wood >= rate * 0.5) {
              addedWood -= rate * 0.5;
              addedPlank += rate;
            }
            break;
          case BuildingType.bakery:
            if (state.resources.flour >= rate * 0.4 &&
                state.resources.food >= rate * 0.4) {
              addedFlour -= rate * 0.4;
              addedFood -= rate * 0.4;
              addedBread += rate;
            }
            break;
          case BuildingType.furniture:
            if (state.resources.plank >= rate * 0.4 &&
                state.resources.wood >= rate * 0.4) {
              addedPlank -= rate * 0.4;
              addedWood -= rate * 0.4;
              addedFurniture += rate;
            }
            break;
          case BuildingType.mine:
            addedStone += rate;
            if (state.progression.castleLevel >= 3) {
              addedIron += rate * 0.3;
            }
            break;
          default:
            break;
        }
        updatedTiles[entry.key] = tile.copyWith(
          isWarmed: isWarmed,
          warmTimer: warmTimer,
        );
      } else {
        final double newAccum =
            math.min(b.maxCapacity, b.accumulatedResource + rate);
        updatedTiles[entry.key] = tile.copyWith(
          building: b.copyWith(accumulatedResource: newAccum),
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
    final discount = EconomyCalculator.getExpansionDiscount(
      toreTalents: state.toreTalents,
      titles: state.titles,
    );

    double base = 5.0;
    int count = state.progression.purchasedMeadowCount;
    if (biome == TileBiome.forest) {
      base = 10.0;
      count = state.progression.purchasedForestCount;
    } else if (biome == TileBiome.sea) {
      base = 15.0;
      count = state.progression.purchasedSeaCount;
    } else if (biome == TileBiome.mountain) {
      base = 20.0;
      count = state.progression.purchasedMountainCount;
    }

    final double cost = base * math.pow(1.15, count) * (1.0 - discount);
    return math.max(1.0, cost.roundToDouble());
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
      showToast('⚠️ Yalnızca sınır komşunuz olan arazileri fethedebilirsiniz!');
      return false;
    }

    // Orman kilit kontrolü: Şato Seviye >= 2
    if (tile.biome == TileBiome.forest && state.progression.castleLevel < 2) {
      showToast(
          '🔒 Orman Kilitli! Odunculuk için Şatoyu Seviye 2\'ye yükselt.');
      return false;
    }

    final double cost = calculateExpansionCost(tile.biome);
    if (state.resources.food < cost) {
      showToast(
          '⚠️ Yetersiz Gıda! Yeni karo için ${cost.toInt()} 🥡 Gıda gerekli.');
      return false;
    }

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(state: TileState.owned);

    // Çevresindeki fog karoları açığa çıkar
    final int revealRadius = tile.biome == TileBiome.mountain ? 2 : 1;
    for (int q = -revealRadius; q <= revealRadius; q++) {
      final int r1 = math.max(-revealRadius, -q - revealRadius);
      final int r2 = math.min(revealRadius, -q + revealRadius);
      for (int r = r1; r <= r2; r++) {
        final targetCoord = coord + HexAxial(q, r);
        if (updatedTiles.containsKey(targetCoord)) {
          final t = updatedTiles[targetCoord]!;
          if (t.isFog) {
            updatedTiles[targetCoord] = t.copyWith(state: TileState.discovered);
          }
        } else {
          final randomBiome = TileBiome
              .values[math.Random().nextInt(TileBiome.values.length)];
          updatedTiles[targetCoord] = HexTileModel(
            coord: targetCoord,
            biome: randomBiome,
            state: TileState.discovered,
          );
        }
      }
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
      activeToast:
          '🏰 ${cost.toInt()} 🥡 Gıda karşılığında yeni arsa fethedildi!',
    );

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
      showToast('🔒 Bu yapı için Şato Seviye 2 gereklidir!');
      return false;
    }
    if ((type == BuildingType.windmill ||
            type == BuildingType.bakery ||
            type == BuildingType.mine ||
            type == BuildingType.bridge) &&
        castleLvl < 3) {
      showToast('🔒 Bu yapı için Şato Seviye 3 gereklidir!');
      return false;
    }
    if (type == BuildingType.furniture && castleLvl < 4) {
      showToast('🔒 Mobilyacı için Şato Seviye 4 gereklidir!');
      return false;
    }

    if (type == BuildingType.corn && tile.biome != TileBiome.meadow) {
      showToast('⚠️ Mısır Tarlası yalnızca Çayır biyomuna inşa edilebilir!');
      return false;
    }
    if (type == BuildingType.lumberjack && tile.biome != TileBiome.forest) {
      showToast('⚠️ Oduncu Kulübesi yalnızca Orman biyomuna inşa edilebilir!');
      return false;
    }
    if (type == BuildingType.bridge && tile.biome != TileBiome.sea) {
      showToast('⚠️ Köprü yalnızca Deniz biyomuna inşa edilebilir!');
      return false;
    }
    if (type == BuildingType.mine && tile.biome != TileBiome.mountain) {
      showToast('⚠️ Maden Ocağı yalnızca Dağ biyomuna inşa edilebilir!');
      return false;
    }

    final dummy = BuildingModel(type: type);
    final cost = dummy.baseCost;

    if (state.resources.food < cost) {
      showToast('⚠️ Yetersiz kaynak! Gerekli: ${cost.toInt()} 🥡');
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
      activeToast: '🏗️ ${type.name.toUpperCase()} başarıyla inşa edildi!',
    );

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
          '⚠️ Yükseltme için yetersiz kaynak! Gerekli: ${cost.toInt()} 🥡');
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
          '⭐ ${b.type.name.toUpperCase()} Seviye ${b.level + 1}\'e yükseltildi!',
    );

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

    return true;
  }

  bool warmTile(HexAxial coord) {
    final tile = state.tiles[coord];
    if (tile == null || !tile.isOwned) return false;
    if (tile.isWarmed) {
      showToast('🔥 Bu karo zaten ısıtılmış!');
      return false;
    }

    const double woodCost = 5.0;
    if (state.resources.wood < woodCost) {
      showToast('⚠️ Karoyu ısıtmak için 5 🪵 Odun gereklidir!');
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
      activeToast: '🔥 Karo 3 dakika boyunca ısıtıldı (+%50 Üretim Hızı)!',
    );

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
      showToast('⚠️ Takas için gerekli kaynaklar yetersiz!');
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
      activeToast: '⚖️ Ticaret başarılı! Kaynaklar güncellendi.',
    );

    saveGame();
    return true;
  }

  bool upgradeToreTalent(String branch, String talentKey, int costCrowns) {
    if (state.resources.crowns < costCrowns) {
      showToast('⚠️ Yetersiz Taç! Gerekli: $costCrowns 👑');
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
      activeToast: '📜 $talentKey Seviye ${currentLvl + 1} oldu!',
    );

    saveGame();
    return true;
  }

  bool claimTitle(String titleKey) {
    if (state.titles[titleKey] == true) {
      showToast('ℹ️ Bu unvana zaten sahipsiniz!');
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
      showToast('🔒 Unvan şartları henüz sağlanmadı!');
      return false;
    }

    final newTitles = Map<String, dynamic>.from(state.titles);
    newTitles[titleKey] = true;

    state = state.copyWith(
      titles: newTitles,
      activeToast: '👑 Yeni Unvan Açıldı: ${titleKey.toUpperCase()}!',
    );

    saveGame();
    return true;
  }

  bool upgradeCastle() {
    final int nextLvl = state.progression.castleLevel + 1;
    final double foodCost = 50.0 * math.pow(1.5, nextLvl - 2);
    final double woodCost = 25.0 * math.pow(1.5, nextLvl - 2);

    if (state.resources.food < foodCost || state.resources.wood < woodCost) {
      showToast(
          '⚠️ Şato yükseltme için ${foodCost.toInt()} 🥡 ve ${woodCost.toInt()} 🪵 gerekli!');
      return false;
    }

    state = state.copyWith(
      resources: state.resources.copyWith(
        food: state.resources.food - foodCost,
        wood: state.resources.wood - woodCost,
      ),
      progression: state.progression.copyWith(castleLevel: nextLvl),
      activeToast: '🏰 Krallık Şatosu Seviye $nextLvl oldu! (Küresel Hız +%25)',
    );

    saveGame();
    return true;
  }

  void activateFrenzy() {
    state = state.copyWith(
      frenzyMultiplier: 10,
      frenzyTimer: 60.0,
      activeToast: '🔥 10x Üretim Çılgınlığı Aktif! (60 Saniye)',
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
    );
  }

  void resetGame() {
    SaveRepository.deleteSave();
    state = _createInitialState();
    showToast('🔄 Oyun sıfırlandı ve yeni krallık kuruldu!');
  }
}
