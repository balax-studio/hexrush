import 'package:flutter/material.dart';
import 'building_model.dart';
import 'hex_tile_model.dart';

enum HexpediaCategory {
  all,
  core,
  biomes,
  buildings,
  seasons,
  lore,
  trade,
  migration,
}

extension HexpediaCategoryExtension on HexpediaCategory {
  String getTitle(String lang) {
    switch (this) {
      case HexpediaCategory.all:
        return lang == 'tr' ? 'TÜMÜ' : (lang == 'de' ? 'ALLE' : (lang == 'es' ? 'TODO' : 'ALL'));
      case HexpediaCategory.core:
        return lang == 'tr' ? 'TEMEL MEKANİK' : (lang == 'de' ? 'GRUNDLAGEN' : (lang == 'es' ? 'BÁSICO' : 'CORE'));
      case HexpediaCategory.biomes:
        return lang == 'tr' ? 'BİYOMLAR & SİMBİYOZ' : (lang == 'de' ? 'BIOME' : (lang == 'es' ? 'BIOMAS' : 'BIOMES'));
      case HexpediaCategory.buildings:
        return lang == 'tr' ? 'YAPILAR & ZİNCİR' : (lang == 'de' ? 'GEBÄUDE' : (lang == 'es' ? 'EDIFICIOS' : 'BUILDINGS'));
      case HexpediaCategory.seasons:
        return lang == 'tr' ? 'İKLİM & ZUD' : (lang == 'de' ? 'KLIMA & ZUD' : (lang == 'es' ? 'CLIMA & ZUD' : 'SEASONS & ZUD'));
      case HexpediaCategory.lore:
        return lang == 'tr' ? 'TÖRE & BİLGELİK' : (lang == 'de' ? 'WEISHEIT' : (lang == 'es' ? 'SABIDURÍA' : 'LORE & WISDOM'));
      case HexpediaCategory.trade:
        return lang == 'tr' ? 'KERVAN & PAZAR' : (lang == 'de' ? 'HANDEL' : (lang == 'es' ? 'COMERCIO' : 'TRADE & CARAVAN'));
      case HexpediaCategory.migration:
        return lang == 'tr' ? 'GÖÇ & DİORAMA' : (lang == 'de' ? 'MIGRATION' : (lang == 'es' ? 'MIGRACIÓN' : 'MIGRATION'));
    }
  }

  IconData get icon {
    switch (this) {
      case HexpediaCategory.all:
        return Icons.auto_awesome_mosaic;
      case HexpediaCategory.core:
        return Icons.castle;
      case HexpediaCategory.biomes:
        return Icons.terrain;
      case HexpediaCategory.buildings:
        return Icons.apartment;
      case HexpediaCategory.seasons:
        return Icons.ac_unit;
      case HexpediaCategory.lore:
        return Icons.auto_stories;
      case HexpediaCategory.trade:
        return Icons.swap_calls;
      case HexpediaCategory.migration:
        return Icons.flight_takeoff;
    }
  }
}

class HexpediaEntry {
  final String id;
  final HexpediaCategory category;
  final String titleTr;
  final String titleEn;
  final String summaryTr;
  final String summaryEn;
  final String contentTr;
  final String contentEn;
  final IconData icon;
  final Color iconColor;
  final String badgeText;
  final Map<String, String> stats;
  final List<String> stepGuideTr;
  final List<String> stepGuideEn;
  final List<String> tipsTr;
  final List<String> tipsEn;
  final List<String> tags;

  const HexpediaEntry({
    required this.id,
    required this.category,
    required this.titleTr,
    required this.titleEn,
    required this.summaryTr,
    required this.summaryEn,
    required this.contentTr,
    required this.contentEn,
    required this.icon,
    this.iconColor = const Color(0xFFF59E0B),
    this.badgeText = '',
    this.stats = const {},
    this.stepGuideTr = const [],
    this.stepGuideEn = const [],
    this.tipsTr = const [],
    this.tipsEn = const [],
    this.tags = const [],
  });

  String getTitle(String lang) => lang == 'tr' ? titleTr : titleEn;
  String getSummary(String lang) => lang == 'tr' ? summaryTr : summaryEn;
  String getContent(String lang) => lang == 'tr' ? contentTr : contentEn;
  List<String> getStepGuide(String lang) => lang == 'tr' ? stepGuideTr : (stepGuideEn.isNotEmpty ? stepGuideEn : stepGuideTr);
  List<String> getTips(String lang) => lang == 'tr' ? tipsTr : (tipsEn.isNotEmpty ? tipsEn : tipsTr);
}

class HexpediaRepository {
  static List<HexpediaEntry> getAllEntries() {
    return [
      // =============================================================
      // 1. TEMEL MEKANİKLER (CORE)
      // =============================================================
      const HexpediaEntry(
        id: 'core_castle',
        category: HexpediaCategory.core,
        titleTr: 'Kağan Otağı & İlerleme',
        titleEn: "Khan's Tent & Progression",
        summaryTr: 'Kağanlığın kalbi. Otağ yükseldikçe yeni teknolojiler, binalar ve küresel hız çarpanı açılır.',
        summaryEn: "The core of the Khaganate. Upgrading the Tent unlocks new buildings, lore tiers, and speed boosts.",
        contentTr: 'Kağan Otağı, haritanın merkezindeki (0,0) ana karodur. Her seviye artışı, tüm kağanlık üretimine kalıcı %15 çarpan kazandırır ve Seviye 2\'de Töre Meclisi, Seviye 3\'te Maden ve Fırınlar, Seviye 4\'te Çöl/Tundra derin yapıları, Seviye 5\'te ise Efsanevi Obsidyen ve Göksel Ocaklar açılır.',
        contentEn: "The Khan's Tent is the central hex tile (0,0). Each level gives a permanent +15% Khaganate production boost and unlocks new building tiers up to Level 50.",
        icon: Icons.castle,
        iconColor: Color(0xFFF59E0B),
        badgeText: 'ŞATO / MERKEZ',
        stats: {
          'Maksimum Seviye': '50',
          'Küresel Bonus': '+%15 / Seviye',
          'Açılış Kademeleri': 'Sv 1: Temel, Sv 2: Töre & Arpa, Sv 5: Zanaat, Sv 15: Maden, Sv 40: Şam Çeliği',
        },
        stepGuideTr: [
          'Merkezdeki Kağan Otağı karosuna dokunun.',
          'Alt menüde gerekli Odun ve Taş miktarını kontrol edin.',
          'GELİŞTİR butonuna basarak Otağ seviyesini yükseltin.',
        ],
        stepGuideEn: [
          "Tap on the central Khan's Tent hex.",
          'Check the required Wood and Stone costs in the bottom sheet.',
          'Tap UPGRADE to level up your tent.',
        ],
        tipsTr: [
          'Otağı yükseltmeden önce iaşe ve odun stoklarınızı dengeli tutun.',
          'Her otağ seviyesi yeni pazar kurları ve töre fermanı slotları sağlar.',
        ],
        tipsEn: [
          'Keep your food and wood stockpiles balanced before upgrading.',
          'Each tent level unlocks new market exchange rates and doctrine slots.',
        ],
        tags: ['otağ', 'şato', 'merkez', 'ilerleme', 'castle', 'tent'],
      ),

      const HexpediaEntry(
        id: 'core_conquest',
        category: HexpediaCategory.core,
        titleTr: 'Karo Keşfi & Fetih (Sis Açma)',
        titleEn: 'Hex Conquest & Fog of War',
        summaryTr: 'Komşu karolara yayılarak sınırları genişletin. Fetih maliyeti fethedilen toplam karo sayısına göre artar.',
        summaryEn: 'Expand territory by conquering adjacent tiles. Cost scales with total owned tile count.',
        contentTr: 'Haritada sahip olunan arazilerin sınır komşuları "Keşfedildi" (Discovered) durumuna geçer. Sis kalktığında karonun biyom türü görünür. Fethettiğiniz her yeni karo için gereken Gıda maliyeti kademeli olarak artar (Temel: 5 Gıda * 1.35^karo).',
        contentEn: 'Adjacent hexes to owned land become discovered. Conquering tiles costs Food, scaling exponentially with each conquered tile.',
        icon: Icons.explore,
        iconColor: Color(0xFF38BDF8),
        badgeText: 'FETİH & SİS',
        stats: {
          'Gereksinim': 'Komşu karo fethi',
          'Temel Maliyet': 'Gıda (Artan oran)',
          'Gözcü Bonusu': 'Gözcü kulesi +2 sis menzili açar',
        },
        stepGuideTr: [
          'Açıkta duran ancak henüz fethedilmemiş bir komşu karoya dokunun.',
          'Gerekli Gıda miktarını alt panelden teyit edin.',
          'TOPRAĞI FETHET butonuna basarak karoyu kağanlığınıza katın.',
        ],
        stepGuideEn: [
          'Tap an adjacent discovered tile in the fog boundary.',
          'Verify required Food amount in the bottom action bar.',
          'Tap CONQUER LAND to claim the territory.',
        ],
        tipsTr: [
          'Öncelikle su kenarları ve zengin orman karolarını fethederek erken hammadde sağlayın.',
          'Töre meclisinde "İlteriş Fermanı" doktrinini takarak fetih maliyetini %20 düşürebilirsiniz.',
        ],
        tipsEn: [
          'Conquer forest and water edges first for strong early resource yields.',
          'Equip the Ilterish Decree in the Tore Council to discount conquest cost by 20%.',
        ],
        tags: ['fetih', 'sis', 'harita', 'karo', 'conquest', 'fog', 'explore'],
      ),

      const HexpediaEntry(
        id: 'core_rhythm_frenzy',
        category: HexpediaCategory.core,
        titleTr: 'Sinerji Patlaması & 10x Toy Coşkusu',
        titleEn: 'Synergy Burst & 10x Toy Frenzy',
        summaryTr: 'HUD üzerindeki 10x butonu, İpek Yolu siparişleri veya ritmik vuruşlarla tetiklenen 10x küresel üretim patlaması.',
        summaryEn: '10x global production surge triggered via the 10x HUD button, Silk Road orders, or rhythm combos.',
        contentTr: 'Sinerji Patlaması (Toy Coşkusu), kağanlığınızdaki tüm binaların ve işçilerin üretimini 10 katına (10x) çıkaran devasa bir bereket dönemidir.\n\nNasıl Tetiklenir?\n1. Üst Bardaki 10x Butonu: Dokunulduğunda doğrudan 60 saniyelik 10x üretim patlaması başlar.\n2. İpek Yolu Han Buyrukları: Şehir siparişleri teslim edildiğinde hız çarpanı ödülü olarak devreye girer.\n3. Ritmik Dokunuş (Steppe Drum): Harita zeminine 0.35s - 0.70s aralıklarla ritmik dokunarak kombo biriktirilir.\n\nBina Sinerjileri ile Birleşimi:\nSinerji Patlaması devredeyken; Zincir Sinerjileri (2.0x), Biyom Auraları (Sulama, Jeotermal) ve Ekolojik Simbiyoz çarpanları birbirini katlar.',
        contentEn: 'Synergy Burst (Toy Frenzy) grants a 10x global production multiplier across all realm structures and workers. Trigger it directly via the top HUD button, fulfilling Silk Road trade orders, or hitting rhythm combos.',
        icon: Icons.bolt,
        iconColor: Color(0xFFF97316),
        badgeText: '10X PATLAMA',
        stats: {
          'Patlama Çarpanı': '10x Üretim Hızı',
          'Temel Süre': '60 Saniye (HUD butonu)',
          'Sinerji Katlanması': 'Zincir ve Biyom sinerjileriyle katlanır',
        },
        stepGuideTr: [
          'Üst bardaki 10x simgeli Toy Coşkusu butonuna dokunun.',
          'Kırmızı geri sayım sayacını takip ederek 10 kat hızlı üretimin tadını çıkarın.',
          'Bina detay menüsüne dokunarak yeşil Toplam Sinerji & Patlama Etkisi istatistiğini inceleyin.',
        ],
        stepGuideEn: [
          'Tap the 10x Toy Frenzy button in the top HUD.',
          'Watch the red countdown timer as production surges 10x.',
          'Tap any building to inspect the unified green Total Synergy & Burst stat.',
        ],
        tipsTr: [
          'Sinerji Patlamasını kış ayı öncesinde veya ambarları doldurmak istediğinizde stratejik olarak kullanın.',
          'Birbirine bitişik üretim zincirleri (Tarla -> Değirmen -> Fırın) patlama sırasında 20x-40x verime ulaşır.',
        ],
        tipsEn: [
          'Use Synergy Burst strategically before winter or to fuel expensive castle upgrades.',
          'Adjacent chain partners (Farm -> Mill -> Bakery) reach 20x-40x throughput during bursts.',
        ],
        tags: ['sinerji', 'patlama', 'toy', 'frenzy', 'kombo', 'hız', '10x', 'zincir'],
      ),

      // =============================================================
      // 2. BİYOMLAR & SİMBİYOZ (BIOMES)
      // =============================================================
      const HexpediaEntry(
        id: 'biome_varieties',
        category: HexpediaCategory.biomes,
        titleTr: '11 Bozkır Biyomu & Doğal Zenginlikler',
        titleEn: '11 Steppe Biomes & Natural Yields',
        summaryTr: 'Çayırdan Altay Tundrasına, Yanardağdan Kristal Yarığına kadar 11 farklı coğrafi arazi tipi.',
        summaryEn: 'From Meadows to Altay Tundra, Volcanoes to Crystal Chasms: 11 distinct biomes.',
        contentTr: 'HexRush arazisi 11 farklı biyomdan oluşur:\n1. Çayır (Meadow): Buğday, arpa, mera ve at sürüleri.\n2. Orman (Forest): Kereste, huş katranı ve reçine.\n3. Dağ (Mountain): Taş kütleleri ve demir filizleri.\n4. Deniz / Göl (Sea): Balıkçılık ve su köprüsü.\n5. Karakum Çölü (Desert): Vaha sarnıcı, kervansaray ve rasathane.\n6. Altay Tundrası (Tundra): Geyik otağı ve jeotermal kaplıca.\n7. Yanardağ (Volcano): Obsidyen ocağı ve buhar menfezi.\n8. Bozkır Sazlığı (Wetland): Şifacı otağı, parşömen ve sazlık.\n9. Göksel Krater (Celestial Crater): Göksel örs ve meteorik maden.\n10. Atalar Kurganı (Kurgan Valley): Ata mirası balbalları ve totemler.\n11. Kristal Yarığı (Crystal Chasm): Kristal rezonatör ve prizmatik rezonans.',
        contentEn: 'Features 11 biomes: Meadow, Forest, Mountain, Sea, Desert, Tundra, Volcano, Wetland, Celestial Crater, Kurgan Valley, and Crystal Chasm, each with unique buildings and yields.',
        icon: Icons.landscape,
        iconColor: Color(0xFF10B981),
        badgeText: '11 COĞRAFYA',
        stats: {
          'Toplam Biyom': '11 Farklı Arazi',
          'Özel Yapılar': 'Her biyoma özgü 3+ yapı',
          'Mevsim Hassasiyeti': 'Çöl yazın coşar, Tundra kışa dirençlidir',
        },
        tipsTr: [
          'Her biyomun kendine has binaları vardır; örneğin Vaha Sarnıcı yalnızca Çöl karolarına kurulabilir.',
        ],
        tipsEn: [
          'Specific buildings require native biomes, such as Oasis Cisterns in Deserts.',
        ],
        tags: ['biyom', 'arazi', 'orman', 'çöl', 'tundra', 'dağ', 'deniz', 'volkan', 'kristal', 'kurgan', 'krater', 'sazlık'],
      ),

      const HexpediaEntry(
        id: 'biome_symbiosis',
        category: HexpediaCategory.biomes,
        titleTr: 'Ekolojik Simbiyoz (Hibrid Arazi Mutasyonu)',
        titleEn: 'Ecological Symbiosis Engine',
        summaryTr: 'Komşu biyomların birbirini etkilemesiyle ortaya çıkan 4 gizli hibrid arazi mutasyonu.',
        summaryEn: '4 hidden hybrid land mutations created by matching neighboring biomes.',
        contentTr: 'Farklı biyomlar yan yana fethedildiğinde doğa rezonansa girer ve merkez karoda Simbiyoz mutasyonu oluşur:\n\n1. Vahşi Koruluk (Wild Glade): Çayır etrafında en az 2 Orman ve 1 Sazlık olduğunda oluşur. Şifalı polen ve +%40 iaşe/odun verir.\n2. Kanyon Vahası (Canyon Oasis): Çöl ve Dağ karoları en az 2\'şer komşu olduğunda oluşur. Tuz, baharat ve +%50 kervan altını sağlar.\n3. Kristal Pınar (Crystal Spring): Deniz/Göl ile Dağ komşu olduğunda açılır. Saf kaynak suyu ve +%40 maden hızı verir.\n4. Jeotermal Gayzer (Volcanic Geothermal): Yanardağ ile Tundra/Sazlık komşu olduğunda patlar. Doğal buhar ısısıyla donmayı engeller ve +%60 hız aurası yayar.',
        contentEn: 'Neighboring biomes trigger organic mutations: Wild Glade (Meadow+Forest+Wetland), Canyon Oasis (Desert+Mountain), Crystal Spring (Sea+Mountain), and Volcanic Geothermal (Volcano+Tundra).',
        icon: Icons.hub,
        iconColor: Color(0xFF06B6D4),
        badgeText: '4 HİBRİD REZONANS',
        stats: {
          'Vahşi Koruluk': '+%40 İaşe & Huş Bonusu',
          'Kanyon Vahası': '+%50 Kervan & Altın',
          'Kristal Pınar': '+%40 Taş & Maden',
          'Jeotermal Gayzer': 'Sonsuz Isınma & +%60 Hız',
        },
        stepGuideTr: [
          'Harita üzerinde bir Çayır karosu seçin.',
          'Etrafındaki 6 komşu karodan en az 2\'sini Orman, 1\'ini Sazlık yapacak şekilde fethedin.',
          'Merkez karoda otomatik olarak "VAHŞİ KORULUK" rozetinin yandığını görün.',
        ],
        stepGuideEn: [
          'Select a Meadow hex on the map.',
          'Conquer neighboring tiles to place at least 2 Forests and 1 Wetland around it.',
          'The central tile will automatically mutate into a "WILD GLADE".',
        ],
        tipsTr: [
          'Fetih yaparken rastgele yayılmak yerine Simbiyoz formüllerine göre kümelenme yapın.',
        ],
        tipsEn: [
          'Plan your conquests to fulfill Symbiosis requirements for massive passive production boosts.',
        ],
        tags: ['simbiyoz', 'ekoloji', 'hibrid', 'mutasyon', 'koruluk', 'vaha', 'gayzer'],
      ),

      const HexpediaEntry(
        id: 'biome_transhumance',
        category: HexpediaCategory.biomes,
        titleTr: 'Toprak Sağlığı & Yaylak Nadası',
        titleEn: 'Soil Health & Transhumance Resting',
        summaryTr: 'Aşırı ekilen tarla ve otlakların yorulması; nadasa bırakılarak bereket patlaması kazanılması.',
        summaryEn: 'Over-farmed soils exhaust over time; rest them for massive respiration yield bursts.',
        contentTr: 'Sürekli üretim yapan tarım ve mera karolarında Toprak Sağlığı (%100\'den %20\'ye) kademeli olarak aşınır. Verim düştüğünde karoyu seçip "Nadasa Bırak" (Rest Pasture) moduna aldığınızda üretim durur ancak toprak hızla dinlenir. Nadas tamamlandığında 60 saniyelik 2.5x Nefes Patlaması (Respiration Burst) başlar.',
        contentEn: 'Constantly farmed tiles lose soil health over time. Resting them stops production temporarily to regenerate soil, triggering a 2.5x Respiration Burst upon resuming.',
        icon: Icons.spa,
        iconColor: Color(0xFF22C55E),
        badgeText: 'NADAS & YAYLAK',
        stats: {
          'Aşınma Süresi': '120 Saniye aktif üretim',
          'Dinlenme Süresi': '30 Saniye nadas',
          'Patlama Bonusu': '60sn boyunca 2.5x Bereket',
        },
        stepGuideTr: [
          'Verimi düşmüş bir tarla veya mera karosuna dokunun.',
          'Alt paneldeki Toprak Sağlığı çubuğunu inceleyin.',
          'Nadasa alarak toprağın dinlenmesini sağlayın; dolduğunda tekrar üretime açın.',
        ],
        stepGuideEn: [
          'Tap an exhausted farm or pasture hex.',
          'Check the Soil Health gauge in the action sheet.',
          'Switch to Rest mode to regenerate soil and trigger the Respiration Burst.',
        ],
        tipsTr: [
          'Tarlalarınızı mevsim dönüşlerinde sırayla nadasa bırakarak kış öncesi stok patlaması yaratın.',
        ],
        tipsEn: [
          'Rotate resting across farms during autumn to prepare for winter stockpiles.',
        ],
        tags: ['nadas', 'toprak', 'yaylak', 'bereket', 'dinlenme', 'transhumance'],
      ),

      // =============================================================
      // 3. YAPILAR & ÜRETİM ZİNCİRİ (BUILDINGS - TÜM 36 YAPI)
      // =============================================================
      const HexpediaEntry(
        id: 'buildings_chains_overview',
        category: HexpediaCategory.buildings,
        titleTr: 'Üretim Zincirleri & 3-Tier Mimari',
        titleEn: 'Production Chains & 3-Tier Architecture',
        summaryTr: 'Hammaddeden işlenmiş mamullere ve efsanevi silahlara uzanan derin üretim piramidi.',
        summaryEn: 'Deep production pipeline from raw resources to refined goods and mythical arms.',
        contentTr: 'HexRush ekonomisi 3 katmanlı girdi-çıktı mantığıyla işler:\n\n• Tier 1 (Hammadde): Buğday, Arpa, Odun, Taş, Demir filizi, Balık.\n• Tier 2 (İşlenmiş Mamul): Yel Değirmeni buğdayı Un yapar, Hızar Otağı odunu Kalas/Kereste yapar, Fırın ekmek pişirir, Marangoz mobilya üretir.\n• Tier 3 (Bozkır Zanaat): Kımız Otağı (Kımız şifası), Keçe Atölyesi (Zırh keçesi), Şam Ocağı (Demir+Obsidyen = Şam Çeliği), Tahıl Mahzeni (Kapasite deposu).',
        contentEn: 'Tier 1 gathers raw crops, timber, stone, and ores. Tier 2 refines them into Flour, Planks, Bread, and Furniture. Tier 3 crafts Kumis, Felt armor, Damascus Steel, and Granary storage.',
        icon: Icons.precision_manufacturing,
        iconColor: Color(0xFFFBBF24),
        badgeText: '3 TİER ZİNCİR',
        stats: {
          'Toplam Yapı': '36 Benzersiz Yapı',
          'Dönüşüm Oranları': '2 Odun -> 1 Kalas | 2 Buğday -> 1 Un -> 1 Ekmek',
          'Otomasyon': 'İşçi Kulübesi ile otomatik taşıma',
        },
        tipsTr: [
          'Un ve Kalas üretmeden Fırın veya Marangoz kurmayın; girdi eksikliğinde binalar boşta kalır.',
        ],
        tipsEn: [
          'Ensure continuous Flour and Plank supplies before building Bakeries or Furniture workshops.',
        ],
        tags: ['üretim', 'zincir', 'bina', 'un', 'ekmek', 'kalas', 'çelik', 'kımız', 'keçe', 'mimari'],
      ),

      // 1. Buğday Tarlası
      const HexpediaEntry(
        id: 'bld_corn',
        category: HexpediaCategory.buildings,
        titleTr: 'Buğday Tarlası (Tarım)',
        titleEn: 'Wheat Farm (Agriculture)',
        summaryTr: 'Temel gıda kaynağı. Hasat edilen buğday doğrudan tüketilebilir veya Değirmende una dönüştürülür.',
        summaryEn: 'Primary food source. Harvested wheat can be consumed directly or milled into flour.',
        contentTr: 'Buğday Tarlası, kağanlığın en temel besin direğidir. Çayır arazilerine kurulur. Saniyede 0.42 Gıda üretir. Üretilen buğday doğrudan ambarı besler veya Yel Değirmenine sevk edilerek una çevrilir. Yaz mevsiminde üretimi %50 artar.',
        contentEn: 'Wheat Farm is the bedrock of sustenance. Built on Meadow hexes, producing 0.42 Food/sec. Boosted by 50% in summer.',
        icon: Icons.grass,
        iconColor: Color(0xFFEAB308),
        badgeText: 'SV.1 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 1',
          'Maliyet': '10 Gıda',
          'Temel Verim': '0.42 Gıda / sn',
          'Yerleşim': 'Çayır Karosu',
        },
        tipsTr: ['Yel Değirmeni ile bitişik inşa edildiğinde +%25 komşuluk zincir sinerjisi kazanır.'],
        tipsEn: ['Place adjacent to a Windmill for +25% chain synergy.'],
        tags: ['buğday', 'tarla', 'gıda', 'tarım', 'corn', 'wheat', 'farm', 'food'],
      ),

      // 2. Arpa Tarlası
      const HexpediaEntry(
        id: 'bld_barley',
        category: HexpediaCategory.buildings,
        titleTr: 'Arpa Tarlası (Bozkır Tahılı)',
        titleEn: 'Barley Field (Steppe Grain)',
        summaryTr: 'Soğuğa dayanıklı bozkır tahılı. Kımız mayalamada ve sürü yemlemesinde kullanılır.',
        summaryEn: 'Cold-resilient steppe grain used in Kumis brewing and livestock feed.',
        contentTr: 'Arpa Tarlası, kuraklığa ve dona karşı buğdaydan daha dayanıklıdır. Çayır karolarına kurulur. Saniyede 0.40 birim ürün verir. Kutsal Kımız Otağı için temel fermantasyon girdisidir.',
        contentEn: 'Barley is more resilient against frost. Built on Meadow hexes, yielding 0.40/sec. Crucial for Kumis brewing.',
        icon: Icons.grain,
        iconColor: Color(0xFFFDE047),
        badgeText: 'SV.2 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 2',
          'Maliyet': '12 Gıda',
          'Temel Verim': '0.40 Arpa / sn',
          'Yerleşim': 'Çayır Karosu',
        },
        tipsTr: ['Kımız Otağı açılmadan önce arpa stoklamak hızlı kımız üretimini garanti eder.'],
        tipsEn: ['Stockpile barley before unlocking Kumis Yurts.'],
        tags: ['arpa', 'tahıl', 'kımız', 'gıda', 'barley', 'grain'],
      ),

      // 3. Bozkır Otlağı / Mera
      const HexpediaEntry(
        id: 'bld_pasture',
        category: HexpediaCategory.buildings,
        titleTr: 'Bozkır Otlağı / Mera (Hayvancılık)',
        titleEn: 'Steppe Pasture (Livestock)',
        summaryTr: 'At ve koyun sürülerinin otlatıldığı mera. Yüksek iaşe, kısrak sütü ve yün sağlar.',
        summaryEn: 'Grazing pasture for horses and sheep. Yields food, mare milk, and wool.',
        contentTr: 'Bozkır Otlağı, göçebe yaşamın atardamarıdır. Saniyede 0.48 Gıda üretir. Keçe Çadır Atölyesi ve Kımız Otağı için hammadde akışı sağlar. Zamanla otlar tükendiğinde yaylak nadasına bırakılarak dinlendirilebilir.',
        contentEn: 'Steppe Pasture houses horses and herds, producing 0.48 Food/sec. Supplies wool and milk.',
        icon: Icons.pets,
        iconColor: Color(0xFF10B981),
        badgeText: 'SV.2 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 2',
          'Maliyet': '28 Gıda & Odun',
          'Temel Verim': '0.48 İaşe / sn',
          'Yerleşim': 'Çayır Karosu',
        },
        tipsTr: ['Tohum tabanlı organik hayvan çeşitliliği (Doru, Yağız atlar ve koyunlar) barındırır.'],
        tipsEn: ['Features organic procedural horses and sheep herds.'],
        tags: ['otlak', 'mera', 'at', 'koyun', 'sürü', 'hayvancılık', 'pasture'],
      ),

      // 4. Meyve Bahçesi
      const HexpediaEntry(
        id: 'bld_orchard',
        category: HexpediaCategory.buildings,
        titleTr: 'Meyve Bahçesi (Bozkır Bağı)',
        titleEn: 'Fruit Orchard (Steppe Grove)',
        summaryTr: 'Elma ve yabani meyve ağaçları. Hızlı gıda hasadı ve pazar takası değeri sağlar.',
        summaryEn: 'Apple and wild berry groves delivering high nutritional yield and market value.',
        contentTr: 'Meyve Bahçesi, çayır ve orman sınırlarına kurularak saniyede 0.52 yüksek besin üretir. Bahar aylarında çiçek açar ve yaz aylarında çifte hasat verir.',
        contentEn: 'Fruit Orchards yield 0.52 Food/sec. Blooms in spring and yields double harvest in summer.',
        icon: Icons.park,
        iconColor: Color(0xFFEC4899),
        badgeText: 'SV.10 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 10',
          'Maliyet': '30 Gıda & Odun',
          'Temel Verim': '0.52 Gıda / sn',
          'Yerleşim': 'Çayır & Orman Kenarı',
        },
        tipsTr: ['Orman karosu yanına dikildiğinde Vahşi Koruluk simbiyozunu tetikler.'],
        tipsEn: ['Place next to forests to trigger the Wild Glade symbiosis.'],
        tags: ['meyve', 'bahçe', 'elma', 'gıda', 'orchard', 'fruit'],
      ),

      // 5. Taş Ocağı
      const HexpediaEntry(
        id: 'bld_quarry',
        category: HexpediaCategory.buildings,
        titleTr: 'Taş Ocağı (Madencilik)',
        titleEn: 'Stone Quarry (Excavation)',
        summaryTr: 'Dağ ve kayalıklardan inşaat taşı çıkarır. Otağ geliştirme ve kale surları için zorunludur.',
        summaryEn: 'Extracts building stone from mountains and rocky outcrops.',
        contentTr: 'Taş Ocağı, Dağ karolarına inşa edilir. Saniyede 0.35 Taş üretir. Kağan Otağının seviye atlamasında ve taş köprülerin inşasında ana kaynak taşıdır.',
        contentEn: 'Stone Quarry operates on Mountain tiles, producing 0.35 Stone/sec for castle upgrades.',
        icon: Icons.terrain,
        iconColor: Color(0xFF94A3B8),
        badgeText: 'SV.1 | DAĞ',
        stats: {
          'Gereken Otağ': 'Seviye 1',
          'Maliyet': '25 Gıda & Odun',
          'Temel Verim': '0.35 Taş / sn',
          'Yerleşim': 'Dağ Karosu',
        },
        tipsTr: ['Dağ karolarındaki Taş Ocakları kış Zud ayazından en az etkilenen tesislerdir.'],
        tipsEn: ['Quarries suffer least from winter freezing penalties.'],
        tags: ['taş', 'ocak', 'maden', 'dağ', 'quarry', 'stone', 'mountain'],
      ),

      // 6. Reçine & Katran Kampı
      const HexpediaEntry(
        id: 'bld_resin_camp',
        category: HexpediaCategory.buildings,
        titleTr: 'Reçine & Katran Kampı (Huş Ormanı)',
        titleEn: 'Resin & Tar Camp (Birch Woods)',
        summaryTr: 'Ağaç gövdelerinden huş katranı ve reçine toplar. Zırh yalıtımı ve çadır izolasyonunda kullanılır.',
        summaryEn: 'Harvests birch tar and tree resin for tent insulation and weapon crafting.',
        contentTr: 'Reçine Kampı, yaşlı orman karolarına kurulur. Saniyede 0.32 reçine üretir. Kış aylarında çadırların su ve soğuk geçirmesini önleyen keçe zırh üretiminde vazgeçilmezdir.',
        contentEn: 'Gathers resin and tar at 0.32/sec in Forest hexes. Essential for winter felt tent sealing.',
        icon: Icons.water_drop,
        iconColor: Color(0xFFD97706),
        badgeText: 'SV.10 | ORMAN',
        stats: {
          'Gereken Otağ': 'Seviye 10',
          'Maliyet': '35 Gıda & Odun',
          'Temel Verim': '0.32 Reçine / sn',
          'Yerleşim': 'Orman Karosu',
        },
        tipsTr: ['Oduncu kulübesi ile komşu kurulduğunda reçine toplama verimi %30 artar.'],
        tipsEn: ['Neighbor with a Lumberjack Hut for +30% resin throughput.'],
        tags: ['reçine', 'katran', 'orman', 'huş', 'resin', 'tar', 'forest'],
      ),

      // 7. Yel Değirmeni
      const HexpediaEntry(
        id: 'bld_windmill',
        category: HexpediaCategory.buildings,
        titleTr: 'Yel Değirmeni (Un Değirmeni)',
        titleEn: 'Windmill (Flour Mill)',
        summaryTr: 'Buğdayı öğüterek un yapar. Ekmek fırınlarının çalışması için birincil şarttır.',
        summaryEn: 'Grinds raw wheat into flour to supply bakeries.',
        contentTr: 'Yel Değirmeni, 2 Buğday tüketerek 1 Un üretir (Temel hız: 0.25 Un/sn). Kinetik dönen çarklarıyla buğdayı beyaz una çevirir. Fırınların kesintisiz ekmek üretmesi için düzenli un akışı şarttır.',
        contentEn: 'Consumes 2 Wheat to produce 1 Flour (0.25 Flour/sec). Powers the bread supply chain.',
        icon: Icons.air,
        iconColor: Color(0xFFFDE68A),
        badgeText: 'SV.5 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 5',
          'Maliyet': '25 Gıda & Taş',
          'Temel Verim': '0.25 Un / sn (2 Gıda -> 1 Un)',
          'Yerleşim': 'Çayır Karosu',
        },
        tipsTr: ['Buğday Tarlası ile Fırın arasına köprü gibi yerleştirilmelidir.'],
        tipsEn: ['Position between Wheat Farms and Bakeries for optimal logistic flow.'],
        tags: ['değirmen', 'un', 'buğday', 'öğütme', 'windmill', 'flour', 'mill'],
      ),

      // 8. Tandır & Ekmek Fırını
      const HexpediaEntry(
        id: 'bld_bakery',
        category: HexpediaCategory.buildings,
        titleTr: 'Tandır & Ekmek Fırını (Gıda Rafinerisi)',
        titleEn: 'Bakery & Tandoor (Food Refinery)',
        summaryTr: 'Un ve odun tüketerek besin değeri çok yüksek somun ekmekler pişirir.',
        summaryEn: 'Bakes nutritious bread loaves using flour and firewood.',
        contentTr: 'Ekmek Fırını, un ve odunu birleştirerek saniyede 0.25 Ekmek pişirir. Ekmek, kağanlık nüfusunu doyurmanın yanı sıra İpek Yolu kervan bağlantıları kurmanın zorunlu maliyetidir (20 Ekmek / rota).',
        contentEn: 'Bakes bread at 0.25/sec from flour and wood. Bread is required to fund caravan route links.',
        icon: Icons.bakery_dining,
        iconColor: Color(0xFFF59E0B),
        badgeText: 'SV.15 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 15',
          'Maliyet': '50 Odun & Taş',
          'Temel Verim': '0.25 Ekmek / sn',
          'Girdi': '1 Un + 1 Odun -> 1 Ekmek',
        },
        tipsTr: ['Kervan rotası bağlamadan önce en az 50 ekmek stoklayın.'],
        tipsEn: ['Save at least 50 bread before establishing trade routes.'],
        tags: ['fırın', 'tandır', 'ekmek', 'un', 'gıda', 'bakery', 'bread'],
      ),

      // 9. Oduncu Kulübesi
      const HexpediaEntry(
        id: 'bld_lumberjack',
        category: HexpediaCategory.buildings,
        titleTr: 'Oduncu Kulübesi (Kereste Tedariği)',
        titleEn: 'Lumberjack Hut (Timber Logging)',
        summaryTr: 'Ormandan ham odun keser. Kışın binaları ısıtmak ve inşaat yapmak için hayati kaynaktır.',
        summaryEn: 'Harvests raw timber from forests. Essential for winter heating and construction.',
        contentTr: 'Oduncu Kulübesi, Orman karolarına kurulur ve saniyede 0.35 Odun keser. Odun, hem kış ayazında donan binaları ısıtmak hem de Hızar Otağında kalas biçmek için vazgeçilmez yakıttır.',
        contentEn: 'Built on Forest hexes, harvesting 0.35 Wood/sec for construction and winter heating.',
        icon: Icons.carpenter,
        iconColor: Color(0xFF84CC16),
        badgeText: 'SV.1 | ORMAN',
        stats: {
          'Gereken Otağ': 'Seviye 1',
          'Maliyet': '15 Gıda',
          'Temel Verim': '0.35 Odun / sn',
          'Yerleşim': 'Orman Karosu',
        },
        tipsTr: ['Sonbahar aylarında odun üretimini artırarak kış için stok yapın.'],
        tipsEn: ['Stockpile wood during autumn to survive winter heating demands.'],
        tags: ['odun', 'oduncu', 'orman', 'kereste', 'yakıt', 'lumberjack', 'wood', 'forest'],
      ),

      // 10. Hızar Otağı / Kereste Fabrikası
      const HexpediaEntry(
        id: 'bld_sawmill',
        category: HexpediaCategory.buildings,
        titleTr: 'Hızar Otağı / Kereste Fabrikası',
        titleEn: 'Sawmill (Plank Workshop)',
        summaryTr: 'Ham kütükleri biçerek pürüzsüz kalas ve kereste üretir. İleri yapılar için şarttır.',
        summaryEn: 'Processes raw logs into refined timber planks for advanced structures.',
        contentTr: 'Hızar Otağı, 2 Odun harcayarak 1 Kalas/Kereste üretir (0.20 Kalas/sn). Kalaslar; mobilya atölyeleri, kervan hatları, köprüler ve Kağan Otağının yüksek kademeleri için zorunlu inşaat malzemesidir.',
        contentEn: 'Refines 2 Wood into 1 Plank (0.20 Plank/sec). Powers bridges, furniture, and advanced tents.',
        icon: Icons.format_paint,
        iconColor: Color(0xFFD97706),
        badgeText: 'SV.5 | ORMAN',
        stats: {
          'Gereken Otağ': 'Seviye 5',
          'Maliyet': '30 Odun & Taş',
          'Temel Verim': '0.20 Kalas / sn',
          'Girdi': '2 Odun -> 1 Kalas',
        },
        tipsTr: ['Oduncu Kulübesinin hemen yanına kurularak lojistik taşıma süresi kısaltılmalıdır.'],
        tipsEn: ['Place right next to Lumberjack Huts to minimize hauling lag.'],
        tags: ['hızar', 'kalas', 'kereste', 'odun', 'sawmill', 'plank', 'timber'],
      ),

      // 11. Marangoz & Mobilya Atölyesi
      const HexpediaEntry(
        id: 'bld_furniture',
        category: HexpediaCategory.buildings,
        titleTr: 'Marangoz & Mobilya Atölyesi',
        titleEn: 'Furniture & Carpentry Workshop',
        summaryTr: 'Kalasları işleyerek otağ mobilyası ve değerli ticaret eşyaları üretir.',
        summaryEn: 'Crafts yurt furniture and luxury trade goods from refined planks.',
        contentTr: 'Marangoz Atölyesi, kalasları işleyerek saniyede 0.20 Mobilya üretir. Mobilyalar; Pazar yerinde yüksek altın değeriyle satılır ve Soğd elçilerinin en çok talep ettiği prestijli ticaret mamulüdür.',
        contentEn: 'Produces 0.20 Furniture/sec from planks. Highly prized by Silk Road trade envoys.',
        icon: Icons.chair,
        iconColor: Color(0xFFFB923C),
        badgeText: 'SV.20 | ORMAN',
        stats: {
          'Gereken Otağ': 'Seviye 20',
          'Maliyet': '60 Kalas & Taş',
          'Temel Verim': '0.20 Mobilya / sn',
          'Girdi': '2 Kalas -> 1 Mobilya',
        },
        tipsTr: ['Pazar yerinde mobilya satmak, altın kasasını en hızlı dolduran yöntemdir.'],
        tipsEn: ['Trading furniture in the market generates the fastest gold revenue.'],
        tags: ['marangoz', 'mobilya', 'zanaat', 'ticaret', 'furniture', 'carpentry'],
      ),

      // 12. İşçi Kulübesi & Lojistik
      const HexpediaEntry(
        id: 'bld_worker',
        category: HexpediaCategory.buildings,
        titleTr: 'İşçi Kulübesi & Lojistik Ağı',
        titleEn: 'Worker Hut & Logistics Hub',
        summaryTr: '4 Hex yarıçapındaki tarlaları ve madenleri otomatik toplayıp merkeze taşıyan işçiler çıkarır.',
        summaryEn: 'Spawns logistical workers that patrol a 4-hex radius, collecting yields automatically.',
        contentTr: 'İşçi Kulübesi, oyunun en kritik otomasyon yapısıdır. Manuel hasat ihtiyacını ortadan kaldırır. Çevresindeki tüm üretim binalarını düzenli ziyaret ederek kaynakları ambarınıza taşır. Seviye atladıkça taşıma kapasitesi ve hızı artar.',
        contentEn: 'Automates resource gathering in a 4-hex radius. Workers transport yields to storage continuously.',
        icon: Icons.engineering,
        iconColor: Color(0xFFE2E8F0),
        badgeText: 'SV.1 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 1',
          'Maliyet': '35 Gıda & Odun',
          'Menzil': '4 Hex Çapı',
          'Kapasite': 'Seviye başı +1.68 Yük',
        },
        tipsTr: ['Her 8-10 üretim yapısı için en az 1 adet Seviye 2+ İşçi Kulübesi inşa edin.'],
        tipsEn: ['Place at least one Level 2+ Worker Hut for every 8-10 production buildings.'],
        tags: ['işçi', 'lojistik', 'otomasyon', 'taşıma', 'kulübe', 'worker', 'logistics'],
      ),

      // 13. Gözcü Kulesi
      const HexpediaEntry(
        id: 'bld_watchtower',
        category: HexpediaCategory.buildings,
        titleTr: 'Gözcü Kulesi (Sınır Karakolu)',
        titleEn: 'Watchtower (Border Outpost)',
        summaryTr: 'Sınır görüşünü açar, sis perdesini 2 karo öteye kadar aydınlatır.',
        summaryEn: 'Expands border vision, clearing fog of war up to 2 hexes further.',
        contentTr: 'Gözcü Kulesi, yüksek bir ahşap gözetleme kulesidir. Kurulduğu karonun etrafındaki karanlık sis alanını anında 2 halka daha uzağa açarak yeni biyomları ve kutsal tapınakları erkenden keşfetmenizi sağlar.',
        contentEn: 'Clears fog of war in an expanded 2-hex radius, revealing new biomes and shrines early.',
        icon: Icons.visibility,
        iconColor: Color(0xFF38BDF8),
        badgeText: 'SV.10 | DAĞ/ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 10',
          'Maliyet': '40 Odun & Taş',
          'Sis Açma Menzili': '+2 Hex Çevre Görüşü',
          'Yerleşim': 'Tüm Biyomlar',
        },
        tipsTr: ['Dağ zirvelerine dikilen Gözcü Kuleleri harita keşfini muazzam hızlandırır.'],
        tipsEn: ['Place on mountain ridges for maximum tactical exploration visibility.'],
        tags: ['gözcü', 'kule', 'sis', 'keşif', 'görüş', 'watchtower', 'vision', 'fog'],
      ),

      // 14. Demir Madeni
      const HexpediaEntry(
        id: 'bld_mine',
        category: HexpediaCategory.buildings,
        titleTr: 'Demir Madeni (Cevher Ocağı)',
        titleEn: 'Iron Mine (Ore Smelting)',
        summaryTr: 'Dağ derinliklerinden demir filizi çıkarır. Silah, zırh ve Şam Çeliği için temel kaynaktır.',
        summaryEn: 'Excavates raw iron ore from mountains. Crucial for arms and Damascus Steel.',
        contentTr: 'Demir Madeni, zengin Dağ arazilerine kurulur. Saniyede 0.30 Demir cevheri çıkarır. Demir, askeri doktrinler, Şam Ocağı ve Kağan Otağının yüksek seviyeleri için stratejik bir madendir.',
        contentEn: 'Mines 0.30 Iron/sec on Mountain tiles. Required for Damascus Forges and military doctrines.',
        icon: Icons.hardware,
        iconColor: Color(0xFF64748B),
        badgeText: 'SV.15 | DAĞ',
        stats: {
          'Gereken Otağ': 'Seviye 15',
          'Maliyet': '55 Gıda, Odun & Taş',
          'Temel Verim': '0.30 Demir / sn',
          'Yerleşim': 'Dağ Karosu',
        },
        tipsTr: ['Ejder Yılı göksel kehaneti aktifken demir madenleri 1.8x hızla cevher fışkırtır.'],
        tipsEn: ['Year of the Dragon boosts iron mine throughput by 1.8x.'],
        tags: ['demir', 'maden', 'cevher', 'dağ', 'mine', 'iron', 'ore'],
      ),

      // 15. Ahşap Su Köprüsü
      const HexpediaEntry(
        id: 'bld_bridge',
        category: HexpediaCategory.buildings,
        titleTr: 'Ahşap Su Köprüsü (Geçit)',
        titleEn: 'Timber Bridge (Waterway Crossing)',
        summaryTr: 'Deniz ve göl karoları üzerine kurularak su üstünden kara yolu ve lojistik bağlantısı sağlar.',
        summaryEn: 'Constructed over water tiles to link islands and enable overland logistics.',
        contentTr: 'Su Köprüsü, göl veya deniz karolarının üzerine inşa edilir. Su engelini aşarak işçilerin ve kervanların su üstünden doğrudan karşı kıyıya geçebilmesini sağlar; harita kopukluklarını birleştirir.',
        contentEn: 'Built over Sea hexes, connecting disconnected landmasses for uninterrupted logistics.',
        icon: Icons.alt_route,
        iconColor: Color(0xFFA855F7),
        badgeText: 'SV.20 | DENİZ',
        stats: {
          'Gereken Otağ': 'Seviye 20',
          'Maliyet': '20 Kalas & Taş',
          'İşlev': 'Su üstü kara geçidi sağlama',
          'Yerleşim': 'Deniz/Göl Karosu',
        },
        tipsTr: ['Uzak adaları ana karaya bağlamak için en stratejik yapıdır.'],
        tipsEn: ['Strategic structure for linking isolated islands to the central capital.'],
        tags: ['köprü', 'su', 'geçit', 'deniz', 'bridge', 'water', 'sea'],
      ),

      // 16. Balıkçı İskelesi
      const HexpediaEntry(
        id: 'bld_fisherman',
        category: HexpediaCategory.buildings,
        titleTr: 'Balıkçı İskelesi (Kıyı Avcılığı)',
        titleEn: 'Fishing Dock (Coastal Harvest)',
        summaryTr: 'Deniz ve göl kıyılarında bol balık avlar. Kış ayazında donmayan alternatif gıda kaynağıdır.',
        summaryEn: 'Catches fish on coastal sea hexes. A winter-resistant food lifeline.',
        contentTr: 'Balıkçı İskelesi, Deniz/Göl karolarına kurulur. Saniyede 0.35 Balık üretir. Balık, kışın tarlalar dondurucu zud nedeniyle yavaşladığında obanın aç kalmasını önleyen en güvenilir besin kaynağıdır.',
        contentEn: 'Built on Sea tiles, fishing 0.35 Fish/sec. Sustains realm food stockpiles during winter freezes.',
        icon: Icons.phishing,
        iconColor: Color(0xFF06B6D4),
        badgeText: 'SV.15 | DENİZ',
        stats: {
          'Gereken Otağ': 'Seviye 15',
          'Maliyet': '30 Odun & Kalas',
          'Temel Verim': '0.35 Balık / sn',
          'Yerleşim': 'Deniz/Göl Karosu',
        },
        tipsTr: ['İdil Nehri Sefer Diyarı seçildiğinde balık verimi 2 katına (2x) çıkar.'],
        tipsEn: ['Migrating to Idil River basin doubles fish production output.'],
        tags: ['balık', 'balıkçı', 'iskele', 'deniz', 'göl', 'gıda', 'fisherman', 'fish', 'sea'],
      ),

      // 17. Balıkçı Kulübesi & Kıyı Lojistiği
      const HexpediaEntry(
        id: 'bld_fisherman_hut',
        category: HexpediaCategory.buildings,
        titleTr: 'Balıkçı Kulübesi & Kıyı Lojistiği',
        titleEn: 'Fisherman Hut & Coastal Logistics',
        summaryTr: 'Kıyı ve deniz karolarındaki avları otomatik toplayan özelleşmiş deniz lojistik merkezidir.',
        summaryEn: 'Specialized coastal logistics hut automating fish harvest transport.',
        contentTr: 'Balıkçı Kulübesi, deniz kıyısına kurularak saniyede 1.40 taşıma kapasitesiyle çevredeki tüm balıkçı iskelelerini otomatik ziyaret eder ve balıkları ambarlara taşır.',
        contentEn: 'Provides 1.40 carrying capacity to automatically haul catches from nearby fishing docks.',
        icon: Icons.houseboat,
        iconColor: Color(0xFF38BDF8),
        badgeText: 'SV.35 | DENİZ',
        stats: {
          'Gereken Otağ': 'Seviye 35',
          'Maliyet': '45 Kalas & Taş',
          'Taşıma Kapasitesi': '1.40 Yük / sn',
          'Yerleşim': 'Deniz/Kıyı Karosu',
        },
        tipsTr: ['Birden fazla balıkçı iskelesinin ortasına kurarak kıyı ekonomisini tam otomatik hale getirin.'],
        tipsEn: ['Center between multiple docks for full coastal automation.'],
        tags: ['balıkçı', 'kulübe', 'kıyı', 'lojistik', 'fishermanhut'],
      ),

      // 18. Vaha Sarnıcı
      const HexpediaEntry(
        id: 'bld_oasis_cistern',
        category: HexpediaCategory.buildings,
        titleTr: 'Vaha Sarnıcı (Çöl Pınarı)',
        titleEn: 'Oasis Cistern (Desert Spring)',
        summaryTr: 'Karakum çölünde yeraltı sularını toplayarak komşu karolara sulama ve bereket aurası yayar.',
        summaryEn: 'Collects underground desert aquifers, radiating irrigation buffs to neighbors.',
        contentTr: 'Vaha Sarnıcı, Çöl karolarına kurulur. Saniyede 0.30 su ve yaşam enerjisi üretir. Etrafındaki 6 komşu karoya doğal nem ve sulama aurası vererek tarım ve kervan verimini %40 artırır.',
        contentEn: 'Built on Desert tiles, generating 0.30/sec and radiating irrigation buffs to adjacent hexes.',
        icon: Icons.opacity,
        iconColor: Color(0xFF38BDF8),
        badgeText: 'SV.25 | ÇÖL',
        stats: {
          'Gereken Otağ': 'Seviye 25',
          'Maliyet': '45 Taş & Kalas',
          'Temel Verim': '0.30 Su / sn',
          'Komşuluk Aurası': '+%40 Komşu Bereket Bonusu',
        },
        tipsTr: ['Dağ karosu yanına kurulduğunda "Kanyon Vahası" simbiyoz mutasyonunu tetikler.'],
        tipsEn: ['Pair with mountains to mutate into a Canyon Oasis.'],
        tags: ['vaha', 'sarnıç', 'çöl', 'su', 'sulama', 'oasis', 'cistern', 'desert'],
      ),

      // 19. İpek Yolu Kervansarayı
      const HexpediaEntry(
        id: 'bld_caravanserai',
        category: HexpediaCategory.buildings,
        titleTr: 'İpek Yolu Kervansarayı (Han)',
        titleEn: 'Silk Road Caravanserai (Inn)',
        summaryTr: 'Çöl ticaret yolları üzerinde dinlenen tüccarlardan Altın, Taç ve egzotik gelir sağlar.',
        summaryEn: 'Houses traveling merchants to generate Gold, Crowns, and exotic revenue.',
        contentTr: 'Kervansaray, Çöl karolarına inşa edilir. Saniyede 0.18 altın ve refah üretir. Kervan rotalarının kesişim noktasına kurulduğunda ticaret rezonansını katlayarak büyük miktarda Taç ve Kut kazandırır.',
        contentEn: 'Generates 0.18 Gold/sec. Amplifies trade resonance when connected to multiple caravan routes.',
        icon: Icons.hotel,
        iconColor: Color(0xFFF59E0B),
        badgeText: 'SV.25 | ÇÖL',
        stats: {
          'Gereken Otağ': 'Seviye 25',
          'Maliyet': '80 Kalas & Taş',
          'Temel Verim': '0.18 Altın & Taç / sn',
          'Yerleşim': 'Çöl Karosu',
        },
        tipsTr: ['Karakum Diyarında kervansaray gelirleri 2 katına (2x) çıkar.'],
        tipsEn: ['Caravanserai revenue is doubled in the Karakum Realm.'],
        tags: ['kervansaray', 'han', 'ipekyolu', 'ticaret', 'altın', 'taç', 'caravanserai', 'desert'],
      ),

      // 20. Çöl Rasathanesi / Usturlap
      const HexpediaEntry(
        id: 'bld_astrolabe',
        category: HexpediaCategory.buildings,
        titleTr: 'Çöl Rasathanesi / Usturlap',
        titleEn: 'Desert Astrolabe & Observatory',
        summaryTr: 'Berrak çöl göklerini izleyerek yıldız haritaları çıkarır; toy coşkusu ve bilgelik hız çarpanı verir.',
        summaryEn: 'Tracks celestial stars over clear desert skies, boosting frenzy and lore.',
        contentTr: 'Çöl Rasathanesi, gökbilimcilerin yıldızları gözlemlediği kadim bir yapıdır. Saniyede 0.15 kozmik ilim üretir ve Toy Coşkusu patlamalarının süresini ve gücünü kalıcı olarak artırır.',
        contentEn: 'Produces 0.15 Cosmic Lore/sec and permanently extends Toy Frenzy burst durations.',
        icon: Icons.auto_awesome,
        iconColor: Color(0xFFFDE047),
        badgeText: 'SV.45 | ÇÖL',
        stats: {
          'Gereken Otağ': 'Seviye 45',
          'Maliyet': '120 Taş & Kalas',
          'Temel Verim': '0.15 İlim / sn',
          'Özel Güç': 'Toy Patlaması süresi artışı',
        },
        tipsTr: ['Göksel kehanetlerle birleştiğinde tüm kağanlık hızını devasa oranda katlar.'],
        tipsEn: ['Combines with celestial omens for extreme realm-wide production acceleration.'],
        tags: ['usturlap', 'rasathane', 'yıldız', 'gök', 'çöl', 'astrolabe', 'observatory'],
      ),

      // 21. Ren Geyiği Barınağı
      const HexpediaEntry(
        id: 'bld_reindeer_sanctuary',
        category: HexpediaCategory.buildings,
        titleTr: 'Ren Geyiği Barınağı (Tundra Sürüsü)',
        titleEn: 'Reindeer Sanctuary (Tundra Herds)',
        summaryTr: 'Altay tundrasında geyik sütü, kalın kürk ve soğuğa karşı dirençli iaşe sağlar.',
        summaryEn: 'Herds reindeer in the Altay tundra, yielding milk, thick pelts, and food.',
        contentTr: 'Ren Geyiği Barınağı, donmuş Tundra karolarına kurulur. Saniyede 0.32 dayanıklı gıda ve kürk üretir. Kış aylarında donma cezası almaz; dondurucu zud ayazında dahi tam kapasite çalışır.',
        contentEn: 'Produces 0.32 Food/sec on Tundra hexes. Immune to winter freezing penalties.',
        icon: Icons.cruelty_free,
        iconColor: Color(0xFF93C5FD),
        badgeText: 'SV.25 | TUNDRA',
        stats: {
          'Gereken Otağ': 'Seviye 25',
          'Maliyet': '60 Kalas & Taş',
          'Temel Verim': '0.32 İaşe / sn',
          'Zud Direnci': '%100 Donma Koruması',
        },
        tipsTr: ['Kışın sıfır kayıpla çalışan en güvenli tundra gıda kaynağıdır.'],
        tipsEn: ['Operates at 100% efficiency even in the harshest winter blizzards.'],
        tags: ['geyik', 'tundra', 'kürk', 'soğuk', 'iaşe', 'reindeer', 'sanctuary'],
      ),

      // 22. Jeotermal Kaplıca
      const HexpediaEntry(
        id: 'bld_geothermal_bath',
        category: HexpediaCategory.buildings,
        titleTr: 'Jeotermal Kaplıca (Sıcak Pınar)',
        titleEn: 'Geothermal Bath (Hot Spring)',
        summaryTr: 'Yeraltı magma sıcaklığını yüzeye çıkararak çevresindeki 6 karoyu kışın donmaktan korur.',
        summaryEn: 'Channels geothermal warmth, shielding 6 adjacent tiles from winter frost.',
        contentTr: 'Jeotermal Kaplıca, Tundra karolarına inşa edilir. Saniyede 0.20 termal enerji üretir. En büyük özelliği: 6 komşu karoya sürekli ısı yayarak kışın bu karolardaki binaların asla donmamasını sağlar (Odunsuz Isınma).',
        contentEn: 'Yields 0.20 Warmth/sec and radiates passive heating to 6 adjacent hexes, preventing freezes.',
        icon: Icons.hot_tub,
        iconColor: Color(0xFFF97316),
        badgeText: 'SV.35 | TUNDRA',
        stats: {
          'Gereken Otağ': 'Seviye 35',
          'Maliyet': '90 Taş & Odun',
          'Temel Verim': '0.20 Enerji / sn',
          'Isıtma Aurası': '6 Komşu Karoda Sonsuz Isınma',
        },
        tipsTr: ['Fabrika ve tarlalarınızı Jeotermal Kaplıcanın etrafına dizerek kış odun tüketimini sıfırlayın.'],
        tipsEn: ['Cluster mills and farms around the bath to eliminate winter heating costs.'],
        tags: ['jeotermal', 'kaplıca', 'ısı', 'zud', 'tundra', 'geothermal', 'bath', 'heat'],
      ),

      // 23. Permafrost Kazı Alanı
      const HexpediaEntry(
        id: 'bld_permafrost_dig',
        category: HexpediaCategory.buildings,
        titleTr: 'Permafrost Kazı Alanı (Kadim Fosil)',
        titleEn: 'Permafrost Dig (Ancient Fossils)',
        summaryTr: 'Bin yıllık donmuş toprak altından mamut dişi, kehribar ve kadim mineraller çıkartır.',
        summaryEn: 'Excavates mammoth ivory, amber, and primeval minerals from frozen strata.',
        contentTr: 'Permafrost Kazısı, derin Tundra arazilerine kurulur. Saniyede 0.22 antik maden üretir. Kazılan fosiller ve kehribarlar hem yüksek ticaret değeri taşır hem de Töre Bilgisi kazandırır.',
        contentEn: 'Excavates 0.22 Ancient Ore/sec on Tundra hexes, yielding rare trade relics.',
        icon: Icons.landscape,
        iconColor: Color(0xFF60A5FA),
        badgeText: 'SV.35 | TUNDRA',
        stats: {
          'Gereken Otağ': 'Seviye 35',
          'Maliyet': '130 Taş & Kalas',
          'Temel Verim': '0.22 Antik Kehribar / sn',
          'Yerleşim': 'Tundra Karosu',
        },
        tipsTr: ['Permafrost madenleri Pazar yerinde normal taştan 4 kat daha değerliye bozdurulur.'],
        tipsEn: ['Permafrost fossils barter for 4x higher value in the market.'],
        tags: ['permafrost', 'kazı', 'kehribar', 'fosil', 'tundra', 'dig'],
      ),

      // 24. Volkanik Buhar Menfezi
      const HexpediaEntry(
        id: 'bld_steam_vent',
        category: HexpediaCategory.buildings,
        titleTr: 'Volkanik Buhar Menfezi (Termal Basınç)',
        titleEn: 'Volcanic Steam Vent (Thermal Pressure)',
        summaryTr: 'Yanardağ çatlaklarından yüksek basınçlı buhar toplar; komşu ocakların üretimini hızlandırır.',
        summaryEn: 'Harnesses high-pressure steam from volcanic fissures to supercharge smelters.',
        contentTr: 'Buhar Menfezi, Yanardağ karolarına kurulur. Saniyede 0.28 buhar gücü üretir. Çevresindeki maden ve dökümhanelere basınç aktararak demir ve çelik üretim hızını %50 artırır.',
        contentEn: 'Generates 0.28 Steam/sec on Volcano tiles, boosting neighboring forge speeds by 50%.',
        icon: Icons.air,
        iconColor: Color(0xFFFB7185),
        badgeText: 'SV.40 | VOLKAN',
        stats: {
          'Gereken Otağ': 'Seviye 40',
          'Maliyet': '85 Taş & Demir',
          'Temel Verim': '0.28 Buhar / sn',
          'Basınç Aurası': '+%50 Komşu Döküm Hızı',
        },
        tipsTr: ['Obsidyen ve Şam Ocaklarının yanına kurularak döküm süresi yarıya indirilir.'],
        tipsEn: ['Place next to Obsidian Forges to halve smelting durations.'],
        tags: ['buhar', 'menfez', 'volkan', 'termal', 'enerji', 'steam', 'vent', 'volcano'],
      ),

      // 25. Obsidyen Döküm Ocağı
      const HexpediaEntry(
        id: 'bld_obsidian_forge',
        category: HexpediaCategory.buildings,
        titleTr: 'Obsidyen Döküm Ocağı (Lav Dökümü)',
        titleEn: 'Obsidian Forge (Lava Smelting)',
        summaryTr: 'Volkanik cam ve lav ısısıyla aşırı sert obsidyen külçeler döker. Şam Çeliğinin ana maddesidir.',
        summaryEn: 'Smelts volcanic glass into ultra-hard obsidian ingots for Damascus Steel.',
        contentTr: 'Obsidyen Ocağı, Yanardağ arazilerine kurulur. Saniyede 0.25 Obsidyen döker. Obsidyen külçeleri, Şam Çeliği üretiminde demir ile birleştirilerek kırılmaz kılıç ve zırh yapımında kullanılır.',
        contentEn: 'Produces 0.25 Obsidian/sec on Volcano hexes. Blended with iron to forge Damascus Steel.',
        icon: Icons.whatshot,
        iconColor: Color(0xFFDC2626),
        badgeText: 'SV.40 | VOLKAN',
        stats: {
          'Gereken Otağ': 'Seviye 40',
          'Maliyet': '150 Taş, Demir & Kalas',
          'Temel Verim': '0.25 Obsidyen / sn',
          'Yerleşim': 'Yanardağ Karosu',
        },
        tipsTr: ['Şam Ocağı kurmadan önce en az 50 birim obsidyen biriktirilmesi tavsiye edilir.'],
        tipsEn: ['Stockpile at least 50 obsidian before lighting Damascus Forges.'],
        tags: ['obsidyen', 'volkan', 'döküm', 'lav', 'çelik', 'obsidian', 'forge', 'volcano'],
      ),

      // 26. Şifacı Otağı
      const HexpediaEntry(
        id: 'bld_herbalist_yurt',
        category: HexpediaCategory.buildings,
        titleTr: 'Şifacı Otağı (Bozkır Eczası)',
        titleEn: 'Herbalist Yurt (Steppe Apothecary)',
        summaryTr: 'Sazlıklardan şifalı kök ve otlar toplayarak iksir üretir; halkın verimliliğini artırır.',
        summaryEn: 'Gathers medicinal herbs from wetlands to brew tonics, boosting worker efficiency.',
        contentTr: 'Şifacı Otağı, Bozkır Sazlığı karolarına kurulur. Saniyede 0.35 şifa ve bitkisel iksir üretir. Salgın hastalık ve sert kış aylarında halkın direncini korur; işçilerin taşıma hızına %20 bonus verir.',
        contentEn: 'Built on Wetland tiles, brewing 0.35 Herbal Tonics/sec to boost worker speeds by 20%.',
        icon: Icons.healing,
        iconColor: Color(0xFF34D399),
        badgeText: 'SV.10 | SAZLIK',
        stats: {
          'Gereken Otağ': 'Seviye 10',
          'Maliyet': '40 Gıda & Odun',
          'Temel Verim': '0.35 Şifa / sn',
          'İşçi Bonusu': '+%20 Taşıma Hızı',
        },
        tipsTr: ['Sazlık karosu bulunmayan haritalarda nehir kenarlarına yakın kurulmalıdır.'],
        tipsEn: ['Build near riverbeds if wetland tiles are sparse.'],
        tags: ['şifacı', 'ot', 'iksir', 'sazlık', 'sağlık', 'herbalist', 'yurt', 'wetland'],
      ),

      // 27. Parşömen & Yazıcı Atölyesi
      const HexpediaEntry(
        id: 'bld_scribe_workshop',
        category: HexpediaCategory.buildings,
        titleTr: 'Parşömen & Yazıcı Atölyesi',
        titleEn: 'Scribe & Parchment Workshop',
        summaryTr: 'Sazlık kamışlarından yazı parşömeni üretir; töre fermanlarının ve antlaşmaların yazılmasını sağlar.',
        summaryEn: 'Produces parchment scrolls from wetland reeds for decrees and treaties.',
        contentTr: 'Yazıcı Atölyesi, Sazlık karolarına inşa edilir. Saniyede 0.22 Parşömen üretir. Üretilen parşömenler; Töre Meclisinde yeni ferman yuvaları açmak ve kervan antlaşmaları imzalamak için kullanılır.',
        contentEn: 'Yields 0.22 Parchment/sec from reeds. Unlocks Tore Council decree slots and treaties.',
        icon: Icons.history_edu,
        iconColor: Color(0xFFA7F3D0),
        badgeText: 'SV.30 | SAZLIK',
        stats: {
          'Gereken Otağ': 'Seviye 30',
          'Maliyet': '75 Odun & Taş',
          'Temel Verim': '0.22 Parşömen / sn',
          'Yerleşim': 'Bozkır Sazlığı Karosu',
        },
        tipsTr: ['Rünik Bengü Taşı ile yan yana yerleştirildiğinde bilgelik üretimi %40 artar.'],
        tipsEn: ['Pair with Runic Steles for a +40% lore generation surge.'],
        tags: ['parşömen', 'yazıcı', 'katip', 'sazlık', 'töre', 'scribe', 'parchment'],
      ),

      // 28. Göksel Örs & Meteor Ocağı
      const HexpediaEntry(
        id: 'bld_celestial_anvil',
        category: HexpediaCategory.buildings,
        titleTr: 'Göksel Örs & Meteor Ocağı',
        titleEn: 'Celestial Anvil & Meteor Forge',
        summaryTr: 'Göksel kraterden düşen meteor taşlarıyla kutsal Tamgalar ve efsanevi silahlar döver.',
        summaryEn: 'Forges sacred Tamga relics and mythical arms from crater meteorites.',
        contentTr: 'Göksel Örs, Göksel Krater biyomuna kurulabilen nihai zanaat yapısıdır. Saniyede 0.16 göksel alaşım döker. Büyük Göçte kazanılacak Tamga sayısına doğrudan +2 ilave Tamga katkısı sağlar.',
        contentEn: 'Built on Celestial Craters, forging 0.16 Meteorite/sec and granting +2 bonus Tamgas on reset.',
        icon: Icons.auto_awesome_motion,
        iconColor: Color(0xFF818CF8),
        badgeText: 'SV.50 | KRATER',
        stats: {
          'Gereken Otağ': 'Seviye 50',
          'Maliyet': '200 Taş, Demir & Şam Çeliği',
          'Temel Verim': '0.16 Meteor Madeni / sn',
          'Prestij Bonusu': 'Göçte +2 Kalıcı Atalar Tamgası',
        },
        tipsTr: ['Büyük Göç yapmadan önce mutlaka bir Göksel Örs kurarak fazladan Tamga kazanın.'],
        tipsEn: ['Build before migrating to bank extra permanent prestige tokens.'],
        tags: ['göksel', 'örs', 'meteor', 'krater', 'tamga', 'celestial', 'anvil', 'crater'],
      ),

      // 29. Atalar Totemi
      const HexpediaEntry(
        id: 'bld_ancestral_totem',
        category: HexpediaCategory.buildings,
        titleTr: 'Atalar Totemi (Bengü Balbal)',
        titleEn: 'Ancestral Totem (Eternal Balbal)',
        summaryTr: 'Kurgan vadisinde ataların ruhunu çağırarak tüm kağanlığa devasa %25 küresel üretim aurası yayar.',
        summaryEn: 'Invokes ancestor spirits in Kurgan Valleys, radiating a +25% global realm buff.',
        contentTr: 'Atalar Totemi, Atalar Kurganı vadisine dikilir. Saniyede 0.20 ata kutsaması yayar. Kağanlığın tüm binalarına ve işçilerine mesafeden bağımsız kalıcı +%25 küresel üretim bonusu verir.',
        contentEn: 'Erected on Kurgan Valleys, radiating a global +25% production aura across the entire realm.',
        icon: Icons.account_balance,
        iconColor: Color(0xFFFFD700),
        badgeText: 'SV.50 | KURGAN',
        stats: {
          'Gereken Otağ': 'Seviye 50',
          'Maliyet': '250 Taş & Kalas',
          'Küresel Bonus': 'Tüm Haritada +%25 Hız Aurası',
          'Yerleşim': 'Atalar Kurganı Karosu',
        },
        tipsTr: ['Toy Coşkusu ile birleştiğinde üretim hızını akıl almaz seviyelere taşır.'],
        tipsEn: ['Stacks multiplicatively with Toy Frenzy bursts.'],
        tags: ['totem', 'balbal', 'kurgan', 'ata', 'kutsama', 'ancestral', 'totem'],
      ),

      // 30. Prizmatik Rezonatör
      const HexpediaEntry(
        id: 'bld_prismatic_resonator',
        category: HexpediaCategory.buildings,
        titleTr: 'Prizmatik Rezonatör (Kristal Odak)',
        titleEn: 'Prismatic Resonator (Crystal Focus)',
        summaryTr: 'Kristal yarığındaki ışık dalgalarını rezonansa sokarak komşu binaların hızını 3x katlar.',
        summaryEn: 'Harmonizes crystal wavelengths to triple (3x) adjacent structure speeds.',
        contentTr: 'Prizmatik Rezonatör, Kristal Yarığı karolarına kurulur. Saniyede 0.24 prizmatik ışık üretir. Doğrudan temas ettiği 6 komşu karodaki tüm binaların üretim hızını 3 katına (3.0x) fırlatır.',
        contentEn: 'Built on Crystal Chasms, generating 0.24 Crystal/sec and granting a 3.0x speed boost to 6 neighbors.',
        icon: Icons.flare,
        iconColor: Color(0xFFC084FC),
        badgeText: 'SV.50 | KRİSTAL',
        stats: {
          'Gereken Otağ': 'Seviye 50',
          'Maliyet': '220 Kristal & Taş',
          'Temel Verim': '0.24 Rezonans / sn',
          'Komşuluk Bonusu': '6 Komşu Karoda 3.0x Hız Artışı',
        },
        tipsTr: ['Etrafına en pahalı Şam Ocaklarını ve Kımız Otağlarını dizerek maksimum verim alın.'],
        tipsEn: ['Surround with Damascus Forges and Kumis Yurts for extreme compounding yields.'],
        tags: ['prizmatik', 'rezonatör', 'kristal', 'ışık', 'hız', 'prismatic', 'resonator', 'crystal'],
      ),

      // 31. Ulu Tahıl Mahzeni
      const HexpediaEntry(
        id: 'bld_granary_vault',
        category: HexpediaCategory.buildings,
        titleTr: 'Ulu Tahıl Mahzeni (Kapasite Deposu)',
        titleEn: 'Granary Vault (Capacity Storage)',
        summaryTr: 'Dev ambar depolama kapasitesi ve 2.50 taşıma tamponu sağlar; kış kıtlığını tamamen önler.',
        summaryEn: 'Massive resource stockpile buffer with 2.50 hauling capacity to prevent winter starvation.',
        contentTr: 'Ulu Tahıl Mahzeni, üretim yapmaz ancak ambar kapasitenizi katlar ve 2.50 yüksek lojistik taşıma kapasitesi sunar. Tarlalardan taşan gıdayı bünyesinde toplayarak kışın zud ayazında obanın kıtlığa düşmesini engeller.',
        contentEn: 'Pure logistical vault offering huge storage reserves and 2.50 hauling capacity.',
        icon: Icons.inventory_2,
        iconColor: Color(0xFFF59E0B),
        badgeText: 'SV.2 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 2',
          'Maliyet': '40 Odun & Taş',
          'Taşıma Kapasitesi': '2.50 Yük / sn',
          'Depo Bonusu': '+1,000 Birim Ambar Kapasitesi',
        },
        tipsTr: ['Kış öncesinde tarlaların ortasına kurularak hasadın zayi olması önlenir.'],
        tipsEn: ['Place centrally among farms to safeguard autumn harvests.'],
        tags: ['mahzen', 'ambar', 'depo', 'tahıl', 'kapasite', 'granary', 'vault', 'storage'],
      ),

      // 32. Kutsal Kımız Otağı
      const HexpediaEntry(
        id: 'bld_kumis_yurt',
        category: HexpediaCategory.buildings,
        titleTr: 'Kutsal Kımız Otağı (Bozkır İksiri)',
        titleEn: 'Kumis Yurt (Sacred Ferment)',
        summaryTr: 'Kısrak sütü ve arpayı tulumlarda mayalayarak güç veren kımız üretir.',
        summaryEn: 'Ferments mare milk and barley in leather casks to brew sacred Kumis.',
        contentTr: 'Kımız Otağı, mera ve arpa tarlalarından gelen girdileri deri tulumlarda çalkalayarak saniyede 0.25 Kımız üretir. Kımız, hem halkın moralini ve hızını artırır hem de Ulu İpek Yolu zaferi için zorunlu kutsal içecektir (100 Kımız gerekir).',
        contentEn: 'Brews 0.25 Kumis/sec from milk and barley. Essential for the Silk Road Victory milestone.',
        icon: Icons.liquor,
        iconColor: Color(0xFF10B981),
        badgeText: 'SV.30 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 30',
          'Maliyet': '70 Kalas & Taş',
          'Temel Verim': '0.25 Kımız / sn',
          'Girdi': '1 Gıda + 1 Arpa -> 1 Kımız',
        },
        tipsTr: ['Bozkır Otlağı ve Arpa tarlası ile komşu kurulduğunda fermantasyon hızı %50 artar.'],
        tipsEn: ['Position next to pastures and barley fields for +50% brewing throughput.'],
        tags: ['kımız', 'otağ', 'kısrak', 'içecek', 'fermantasyon', 'zafer', 'kumis', 'yurt'],
      ),

      // 33. Keçe Çadır & Zırh Atölyesi
      const HexpediaEntry(
        id: 'bld_felt_tent_workshop',
        category: HexpediaCategory.buildings,
        titleTr: 'Keçe Çadır & Zırh Atölyesi',
        titleEn: 'Felt Tent & Armor Workshop',
        summaryTr: 'Koyun yününü döverek su geçirmez keçe çadır örtüleri ve zırh astarı üretir.',
        summaryEn: 'Fulls sheep wool into waterproof felt tent wraps and battle armor linings.',
        contentTr: 'Keçe Atölyesi, meradan gelen yünü tokmaklarla döverek saniyede 0.22 Keçe üretir. Keçe; kış aylarında donan binaları ısıtmak için yakıt alternatifi (5 Keçe = 45sn donma koruması) olarak kullanılır ve İpek Yolu zaferinin temel şartıdır.',
        contentEn: 'Produces 0.22 Felt/sec. Felt serves as efficient winter heating fuel and a victory requirement.',
        icon: Icons.shield,
        iconColor: Color(0xFFFB923C),
        badgeText: 'SV.20 | ÇAYIR',
        stats: {
          'Gereken Otağ': 'Seviye 20',
          'Maliyet': '65 Kalas & Taş',
          'Temel Verim': '0.22 Keçe / sn',
          'Zud Yakıtı': '5 Keçe ile 45sn Kesintisiz Isınma',
        },
        tipsTr: ['Kış gelmeden önce ambarınızda en az 30 keçe stoku bulundurun.'],
        tipsEn: ['Maintain at least 30 felt before winter to easily insulate frozen structures.'],
        tags: ['keçe', 'çadır', 'zırh', 'yün', 'ısınma', 'zud', 'felt', 'workshop'],
      ),

      // 34. Şam Çeliği Dökümhanesi
      const HexpediaEntry(
        id: 'bld_damascus_forge',
        category: HexpediaCategory.buildings,
        titleTr: 'Şam Çeliği Dökümhanesi (Kadim Çelik)',
        titleEn: 'Damascus Steel Forge (Legendary Metallurgy)',
        summaryTr: 'Demir filizi ile volkanik obsidyeni harmanlayarak kırılmaz Şam Çeliği üretir.',
        summaryEn: 'Smelts iron ore and volcanic obsidian into unbreakable Damascus Steel.',
        contentTr: 'Şam Ocağı, saniyede 0.18 Şam Çeliği döker. 1 Demir ve 1 Obsidyen harcar. Şam Çeliği, Orhun Bengü Taşları kültürel zaferinin (100 Şam Çeliği gerekir) ve kağanlığın en üst seviye imparatorluk yapılarının ana alaşımıdır.',
        contentEn: 'Forges 0.18 Damascus Steel/sec from 1 Iron and 1 Obsidian. Mandatory for Cultural Victory.',
        icon: Icons.colorize,
        iconColor: Color(0xFFEF4444),
        badgeText: 'SV.40 | DAĞ/VOLKAN',
        stats: {
          'Gereken Otağ': 'Seviye 40',
          'Maliyet': '120 Taş, Kalas & Demir',
          'Temel Verim': '0.18 Şam Çeliği / sn',
          'Girdi': '1 Demir + 1 Obsidyen -> 1 Şam Çeliği',
        },
        tipsTr: ['Demir Madeni ile Obsidyen Ocağının tam ortasına inşa edilmelidir.'],
        tipsEn: ['Center between Iron Mines and Obsidian Forges to streamline input flow.'],
        tags: ['şam', 'çelik', 'döküm', 'demir', 'obsidyen', 'kılıç', 'zafer', 'damascus', 'forge', 'steel'],
      ),

      // 35. Runik Bengü Taşı
      const HexpediaEntry(
        id: 'bld_runic_stele',
        category: HexpediaCategory.buildings,
        titleTr: 'Runik Bengü Taşı (Bilgelik Yazıtı)',
        titleEn: 'Runic Stele (Wisdom Monolith)',
        summaryTr: 'Bozkırın ebedi yazıtlarını kazıyarak saniyelik Bilgelik (Lore/Wisdom) puanı üretir.',
        summaryEn: 'Inscribes eternal steppe runes to generate passive Wisdom points.',
        contentTr: 'Runik Bengü Taşı, saniyede 0.15 Bilgelik (Wisdom) puanı üretir. Üretilen bilgelik; sağ araç çubuğundaki Orhun Bitig Ağacında 4 uzmanlık dalını (Lojistik, İklim, Toprak, Dökümcülük) açmak ve Kültürel Zaferi tamamlamak için harcanır.',
        contentEn: 'Generates 0.15 Wisdom/sec to unlock nodes in the Orhun Lore Tree and fulfill Cultural Victory.',
        icon: Icons.history,
        iconColor: Color(0xFF06B6D4),
        badgeText: 'SV.5 | TÜM BİYOMLAR',
        stats: {
          'Gereken Otağ': 'Seviye 5',
          'Maliyet': '80 Taş & Kalas',
          'Temel Verim': '0.15 Bilgelik / sn',
          'Kullanım Alanı': 'Orhun Bitig Yetenek Ağacı',
        },
        tipsTr: ['Oyunun başında 2-3 adet dikilerek Bilgelik puanının hızla birikmesi sağlanmalıdır.'],
        tipsEn: ['Erect 2-3 early on to rapidly unlock essential lore tree perks.'],
        tags: ['runik', 'bengü', 'taş', 'yazıt', 'bilgelik', 'orhun', 'runic', 'stele', 'wisdom', 'lore'],
      ),

      // 36. Kağan Otağı (Detaylı Yapı Girişi)
      const HexpediaEntry(
        id: 'bld_castle_detail',
        category: HexpediaCategory.buildings,
        titleTr: 'Kağan Otağı (Başkent Sarayı)',
        titleEn: "Khan's Grand Yurt (Imperial Palace)",
        summaryTr: 'İmparatorluğun kalbi. Seviyesi arttıkça tüm yapılara kademeli küresel üretim bonusu verir.',
        summaryEn: 'Heart of the empire. Leveling up grants tiered global multipliers to all structures.',
        contentTr: 'Kağan Otağı, merkez karoda yer alır. Seviye 1\'den 50\'ye kadar kademeli olarak yükseltilebilir. Seviye 5, 15, 30 ve 50 basamaklarında mimari görünümü evrilir (Deri Çadırdan Altın Kubbeli Saraya). Her seviye küresel üretimi %1-%6 oranında artırır.',
        contentEn: 'The imperial palace evolves at levels 5, 15, 30, and 50, providing cumulative production boosts.',
        icon: Icons.fort,
        iconColor: Color(0xFFF59E0B),
        badgeText: 'BAŞKENT | MERKEZ',
        stats: {
          'Maksimum Seviye': '50 Kademeli Evrim',
          'Görsel Evrim': 'Sv. 5, 15, 30, 50',
          'Küresel Bonus': '+%1-%6 / Seviye Artışı',
        },
        tipsTr: ['Otağ seviyesi arttıkça Büyük Göçte kazanılan Taç miktarı da doğrudan artar.'],
        tipsEn: ['Higher tent levels directly grant more Crown points during Great Migrations.'],
        tags: ['otağ', 'saray', 'kağan', 'şato', 'merkez', 'başşehri', 'castle', 'tent', 'palace'],
      ),

      // =============================================================
      // 4. İKLİM, ZUD & GÖKSEL KEHANETLER (SEASONS)
      // =============================================================
      const HexpediaEntry(
        id: 'seasons_zud_mechanic',
        category: HexpediaCategory.seasons,
        titleTr: '4 Mevsim Döngüsü, Kış & Zud Afeti',
        titleEn: '4 Seasons, Winter & Severe Zud Frost',
        summaryTr: 'Baharın ekiminden yazın hasadına; kışın dondurucu zud ayazında binaları ısıtma taktiği.',
        summaryEn: 'From spring planting to summer harvests, protect buildings with heat during harsh winter Zud.',
        contentTr: 'Her mevsim 60 saniye sürer (1 Yıl = 4 Mevsim = 240sn):\n\n• Bahar: Ekim mevsimi; tarla maliyetleri düşer, fidanlar coşar.\n• Yaz: Hasat zirvesi; tüm tarım ve balıkçılık +%50 daha hızlı üretir.\n• Sonbahar: Stok ve pazar bereketi; ticaret gelirleri artar.\n• Kış & Zud Afeti: Dondurucu ayaz başlar. Zud vurduğunda ısıtılmayan binalar donar (%0 verim). Karoya dokunup "ISIT" butonuna basarak Odun ve Keçe ile binayı donmaktan koruyabilirsiniz.',
        contentEn: 'Seasons cycle every 60s. Winter brings severe Zud frost where unheated buildings freeze (0% yield). Heat them using Wood and Felt to sustain output.',
        icon: Icons.ac_unit,
        iconColor: Color(0xFF67E8F9),
        badgeText: 'İKLİM & ZUD',
        stats: {
          'Mevsim Süresi': '60 Saniye',
          'Zud Donma Oranı': 'Isıtılmayan binalarda %100 verim kaybı',
          'Isıtma Yakıtı': '15 Odun veya 5 Keçe (45sn koruma)',
        },
        stepGuideTr: [
          'Kış mevsiminde veya Zud uyarısı geldiğinde donan binanıza dokunun.',
          'Alt menüde kırmızı yanan "BİNAYI ISIT" butonuna basın.',
          'Odun veya keçe harcayarak binanın donmasını engelleyin.',
        ],
        stepGuideEn: [
          'During winter/Zud alert, tap on any frozen building.',
          'Tap the glowing HEAT BUILDING action button in the sheet.',
          'Spend wood/felt to keep the building warm and operational.',
        ],
        tipsTr: [
          'Sonbahar aylarında odun harcamayı kısıp kış için en az 200 odun stoku yapın.',
        ],
        tipsEn: [
          'Save at least 200 wood during autumn to survive winter heating demands.',
        ],
        tags: ['mevsim', 'kış', 'zud', 'ısınma', 'bahar', 'yaz', 'donma', 'seasons', 'winter'],
      ),

      const HexpediaEntry(
        id: 'seasons_celestial_omens',
        category: HexpediaCategory.seasons,
        titleTr: '12 Hayvanlı Göksel Takvim & Kehanetler',
        titleEn: '12-Year Celestial Animal Calendar',
        summaryTr: 'Her yeni yılda göklerden inen 12 kadim hayvan ruhunun küresel lütufları.',
        summaryEn: 'Each game year bestows a global omen from the 12 celestial animal spirits.',
        contentTr: 'Her 4 mevsim tamamlandığında yeni bir Göksel Yıl başlar:\n\n• Pars Yılı: Ormanlar coşar, kereste üretimi 2 katına çıkar.\n• At Yılı: Kervanlar ve işçiler %50 daha hızlı hareket eder.\n• Ejder Yılı: Madenler ve volkanik ocaklar zengin filiz döker (1.8x Demir).\n• Sığır Yılı: Zud ayazına karşı doğal direnç ve taş bereketi.\n• Koyun Yılı: Sürü bereketi, +%60 kımız ve et iaşesi.\n• Tavşan Yılı: Büyük Göç maliyetleri %25 ucuzlar.\n• Sıçan Yılı: Ambar stokları %50 genişler.\n• Yılan Yılı: Şifacılar kadim iksirler üretir, altın takası coşar.',
        contentEn: 'Every completed year cycles through 12 celestial animal omens offering huge global multipliers like Tiger (2x wood), Horse (+50% worker speed), and Dragon (1.8x iron).',
        icon: Icons.brightness_auto,
        iconColor: Color(0xFFFDE047),
        badgeText: '12 YIL DÖNGÜSÜ',
        stats: {
          'Döngü': '12 Kadim Hayvan',
          'Süre': 'Her 1 Oyun Yılı (240sn)',
          'Etki': 'Tüm kağanlık geneli pasif çarpan',
        },
        tipsTr: [
          'Üst bardaki Göksel Rozete tıklayarak o yılın aktif kutsamasını ve kalan süresini görebilirsiniz.',
        ],
        tipsEn: [
          'Tap the top celestial omen badge to inspect the active yearly blessing and remaining time.',
        ],
        tags: ['kehanet', 'göksel', 'takvim', '12hayvan', 'pars', 'at', 'ejder', 'omen'],
      ),

      // =============================================================
      // 5. TÖRE MECLİSİ & BİLGELİK (LORE)
      // =============================================================
      const HexpediaEntry(
        id: 'lore_tore_doctrines',
        category: HexpediaCategory.lore,
        titleTr: 'Töre Meclisi & Doktrin Kartları',
        titleEn: 'Töre Council & Doctrine Cards',
        summaryTr: 'Kağanlığın yasalarını belirleyen Ekonomik, Askeri, Göçebe ve Joker doktrin fermanları.',
        summaryEn: 'Equip Economic, Military, Nomadic, and Wildcard doctrine decrees in the Töre Council.',
        contentTr: 'Kağan Otağı Seviye 2 olduğunda açılan Töre Meclisi, 4 farklı yuvaya doktrin kartı takmanızı sağlar:\n\n1. Ekonomik Yuva: Sulama Fermanı (+%25 tarla bereketi), Maden İmtiyazı (+%30 demir).\n2. Askeri Yuva: Bozkır Akıncısı (Fetih maliyetinde -%20 indirim), Sınır Karakolu.\n3. Göçebe Yuvası: Kış Otağı (Zud yakıtında -%40 tasarruf), Yaylak Sürüsü.\n4. Joker Yuva: Kutlu Balbal (Tamga ve tapınak gelirlerine +%50 çarpan).\n\nDoktrinler Kut/Şan puanı ile açılır ve istenildiği an mecliste değiştirilebilir.',
        contentEn: 'Unlocked at Tent Level 2, the Töre Council lets you slot decrees into Economic, Military, Nomadic, and Wildcard slots using Crown points.',
        icon: Icons.gavel,
        iconColor: Color(0xFFC084FC),
        badgeText: 'MECLİS & YASA',
        stats: {
          'Yuva Sayısı': '4 Aktif Slot',
          'Açılış Kaynağı': 'Kut / Şan (Crowns)',
          'Esneklik': 'İstendiği an takıp çıkarılabilir',
        },
        stepGuideTr: [
          'Üst menüdeki "TÖRE" butonuna dokunarak Meclis ekranını açın.',
          'Açmak istediğiniz ferman kartını seçip KUT puanı ile kilidini açın.',
          'Uygun yuvaya (Ekonomik/Askeri/Göçebe) dokunarak fermanı yürürlüğe koyun.',
        ],
        stepGuideEn: [
          'Tap the TORE button in the top bar to open the Council.',
          'Select a doctrine card and unlock it with Crowns.',
          'Assign it to the matching slot to activate its passive realm bonus.',
        ],
        tipsTr: [
          'Kış gelmeden önce Göçebe yuvasına "Kış Otağı" doktrinini takarak odun tüketimini yarıya indirin.',
        ],
        tipsEn: [
          'Slot the Winter Tent doctrine before winter arrives to halve wood heating costs.',
        ],
        tags: ['töre', 'meclis', 'doktrin', 'ferman', 'yasa', 'kut', 'şan', 'tore'],
      ),

      const HexpediaEntry(
        id: 'lore_steppe_tree',
        category: HexpediaCategory.lore,
        titleTr: 'Orhun Bitig Ağacı & Bilgelik Taşı',
        titleEn: 'Orhun Lore Tree & Wisdom Stele',
        summaryTr: 'Rünik Yazıt Taşı dikerek kazanılan Bilgelik (Wisdom) puanlarıyla 4 kadim uzmanlık dalını geliştirin.',
        summaryEn: 'Construct Runic Steles to generate Wisdom and unlock 4 ancient talent branches.',
        contentTr: 'Bozkır Rünik Yazıtları dikildiğinde zamanla Bilgelik (Wisdom) puanı üretir. Sağ araç çubuğundaki Kitap simgesiyle açılan Orhun Bitig Ağacı 4 daldan oluşur:\n\n1. Akıncı Lojistiği: İşçi menzili (+1 Hex) ve kervan hızı (+%25).\n2. İklim & Keçe Zanaatı: Çadır yalıtımı ve Zud dondurma süresi geciktirme.\n3. Toprak Sırrı: Nadas dinlenme süresini yarıya indirme ve +%50 bereket.\n4. Bozkır Dökümcülüğü: Şam Çeliği filizlenme şansı ve maden patlamaları.',
        contentEn: 'Runic Steles generate Wisdom points. Spend them in the Orhun Lore Tree across 4 branches: Logistics, Weathercraft, Soil Mastery, and Metallurgy.',
        icon: Icons.menu_book,
        iconColor: Color(0xFF06B6D4),
        badgeText: '4 BİLGELİK DALI',
        stats: {
          'Kaynak': 'Bilgelik Puanı (Wisdom)',
          'Üretici Bina': 'Rünik Yazıt Taşı (Runic Stele)',
          'Kalıcılık': 'Göçlerde de korunan kadim bilgi',
        },
        stepGuideTr: [
          'Arazinize bir "Rünik Yazıt Taşı" inşa edin ve Bilgelik puanı biriktirin.',
          'Sağdaki mavi Bitig Ağacı butonuna dokunun.',
          'Geliştirmek istediğiniz düğümü seçip "BİLGİYİ UYANDIR" butonuna basın.',
        ],
        stepGuideEn: [
          'Build a Runic Stele to generate Wisdom points.',
          'Tap the blue Lore Tree button on the right tactical toolbar.',
          'Select a talent node and tap UNLOCK LORE.',
        ],
        tipsTr: [
          'Öncelikle Lojistik dalındaki "Çevik Atlı Posta" düğümünü açarak işçi menzilinizi artırın.',
        ],
        tipsEn: [
          'Prioritize unlocking Agile Courier in the Logistics branch for larger worker collection radius.',
        ],
        tags: ['bitig', 'ağaç', 'orhun', 'bilgelik', 'yazıt', 'yetenek', 'wisdom', 'lore'],
      ),

      // =============================================================
      // 6. TİCARET, KERVANLAR & PAZAR (TRADE & CARAVANS)
      // =============================================================
      const HexpediaEntry(
        id: 'trade_caravan_routes',
        category: HexpediaCategory.trade,
        titleTr: 'İpek Yolu Kervan Hatları Nasıl Kurulur?',
        titleEn: 'How to Connect Silk Road Caravan Routes',
        summaryTr: 'İki fethedilmiş karo arasında kervan bağı kurarak %25 takas rezonansı ve canlı deve katarı başlatma.',
        summaryEn: 'Step-by-step guide to connecting caravan links between tiles for a +25% trade synergy.',
        contentTr: 'Kervan Hatları, kağanlığınızın uzak arazileri arasında ticaret rezonansı kurmanızı sağlar. Bir hat kurulduğunda iki karo arasında 2.5D izometrik voksel deve/at katarı seyahat etmeye başlar ve her iki karonun üretimine +%25 karşılıklı Takas Rezonansı bonusu eklenir.',
        contentEn: 'Caravan routes link two owned hexes within 8 hexes, spawning animated voxel caravans and granting +25% Trade Resonance bonus to both tiles.',
        icon: Icons.swap_calls,
        iconColor: Color(0xFFF59E0B),
        badgeText: 'ADIM ADIM REHBER',
        stats: {
          'Maksimum Menzil': '8 Hex Mesafesi',
          'Kurulum Maliyeti': '30 Kalas & 20 Ekmek',
          'Sinerji Bonusu': '+%25 Üretim Rezonansı',
          'Görsel': 'Canlı Voksel Kervan Konvoyu',
        },
        stepGuideTr: [
          '1. ADIM: Başlangıç noktası yapmak istediğiniz fethedilmiş bir karoya dokunun (Alt Menü açılır).',
          '2. ADIM: Alt menüdeki yeşil/gri "KERVAN BAĞLA" butonuna dokunun.',
          '3. ADIM: Açılan İpek Yolu sayfasında, 8 Hex menzilinizdeki aday varış karoları listelenir.',
          '4. ADIM: Bağlantı kurmak istediğiniz hedef karonun yanındaki "BAĞLANTI KUR" butonuna basın (30 Kalas, 20 Ekmek harcanır).',
          '5. ADIM: İki karo arasında voksel kervan konvoyu hareket etmeye başlar ve her iki arazi +%25 rezonans kazanır!',
        ],
        stepGuideEn: [
          'STEP 1: Tap any owned hex tile on the map to open the Tile Action Sheet.',
          'STEP 2: Tap the "CONNECT CARAVAN" button in the bottom sheet.',
          'STEP 3: In the Silk Road sheet, browse candidate destination tiles within 8 hexes.',
          'STEP 4: Tap "ESTABLISH ROUTE" on your chosen target (costs 30 Planks & 20 Bread).',
          'STEP 5: Animated voxel convoys begin traveling between tiles, granting +25% bonus to both!',
        ],
        tipsTr: [
          'Özellikle Vaha ile Maden veya Orman ile Şato arasına kervan kurarak maksimum sinerji yakalayın.',
          'Bir karodan birden fazla farklı noktaya kervan hattı uzatabilirsiniz.',
        ],
        tipsEn: [
          'Connect Oasis and Mine or Forest and Castle for thematic trade synergy.',
          'You can branch multiple caravan routes from a single prominent hub tile.',
        ],
        tags: ['kervan', 'bağlama', 'ipekyolu', 'rota', 'ticaret', 'deve', 'caravan', 'trade'],
      ),

      const HexpediaEntry(
        id: 'trade_market_orders',
        category: HexpediaCategory.trade,
        titleTr: 'Pazar Yeri & Soğd Elçi Siparişleri',
        titleEn: 'Market Barter & Sogdian Trade Orders',
        summaryTr: 'Fazla kaynakları altına çevirme ve elçilerin özel siparişlerini tamamlayarak Kut/Şan kazanma.',
        summaryEn: 'Trade excess resources for gold and fulfill timed Sogdian envoy orders for Crown rewards.',
        contentTr: 'Üst menüdeki Pazar (Market) ekranından ihtiyaç duymadığınız odun, gıda ve taş kütlelerini Altın ve Şan karşılığı takas edebilirsiniz. Sağ araç çubuğundaki Kervan siparişleri ekranında ise Soğd ve Bizans elçilerinin belirli kaynak talepleri (örn. 50 Ekmek, 20 Mobilya) yer alır. Sipariş tamamlandığında 10 dakikalık %25 küresel hız takviyesi ve Kut kazanılır.',
        contentEn: 'Exchange resources for Gold in the Market, or fulfill timed envoy contracts on the right toolbar to earn Crowns and 10-minute speed buffs.',
        icon: Icons.storefront,
        iconColor: Color(0xFFFBBF24),
        badgeText: 'TAKVİYE & KUT',
        stats: {
          'Pazar Takası': 'Anlık kaynak dengeleme',
          'Elçi Ödülü': '+5-15 Kut / Şan',
          'Geçici Güçlendirme': '10 Dakika boyunca +%25 Hız',
        },
        stepGuideTr: [
          'Sağdaki sarı Kamyonet/Kervan butonuna dokunarak aktif Elçi Siparişlerini açın.',
          'İstenen kaynakları ambarınızda biriktirin.',
          '"SİPARİŞİ TESLİM ET" butonuna basarak Kut ödülünü ve 10 dakikalık hız takviyesini alın.',
        ],
        stepGuideEn: [
          'Tap the yellow Trade Orders button on the right toolbar.',
          'Stockpile the requested goods in your treasury.',
          'Tap DELIVER ORDER to claim Crowns and a 10-minute production boost.',
        ],
        tipsTr: [
          'Büyük Göç öncesinde elçi siparişlerini tamamlayarak bolca Kut puanı biriktirin.',
        ],
        tipsEn: [
          'Complete envoy orders before migrating to stockpile valuable Crown points.',
        ],
        tags: ['pazar', 'elçi', 'sipariş', 'takas', 'kut', 'şan', 'market', 'orders'],
      ),

      // =============================================================
      // 7. BÜYÜK GÖÇ & DİORAMA (MIGRATION & PRESTIGE)
      // =============================================================
      const HexpediaEntry(
        id: 'migration_prestige_tamga',
        category: HexpediaCategory.migration,
        titleTr: 'Büyük Göç & Kadim Tamga (Prestij Sistemi)',
        titleEn: 'Great Migration & Tamga Prestige',
        summaryTr: 'Diyarı terk edip kümülatif Tamgalar ve ata mirası anıtlarıyla yeni topraklara göç etme.',
        summaryEn: 'Migrate to new realms, retaining cumulative Tamgas and Ancestral Kurgan relic echoes.',
        contentTr: 'Kağanlığınız yeterince büyüdüğünde (en az 12 fethedilmiş karo), sağdaki Harita butonuna basarak "Büyük Göç" başlatabilirsiniz. Göç ettiğinizde kaynaklar sıfırlanır ancak:\n\n1. Kümülatif Tamgalar (Prestige Tokens) kazanırsınız (her Tamga tüm üretime kalıcı +%4-5 çarpan verir).\n2. Eski diyardaki en görkemli binalarınız yeni haritada "Atalar Kurganı" olarak belirir; uyandırıldığında devasa aura bonusu verir.\n3. Yeni diyarlara (İdil Boyu, Karakum Çölü) yerleşme hakkı açılır.',
        contentEn: 'Once reaching 12+ tiles, initiate the Great Migration. You earn permanent Tamga tokens (+4-5% global boost each) and leave behind Ancestral Kurgans.',
        icon: Icons.flight_takeoff,
        iconColor: Color(0xFF818CF8),
        badgeText: 'PRESTİJ SİSTEMİ',
        stats: {
          'Asgari Şart': '12 Fethedilmiş Karo & Sv.5 Otağ',
          'Tamga Bonusu': '+%4 Kalıcı Çarpan / Tamga',
          'Ata Kurganı': 'Eski binaların anıt kalıntısı',
        },
        stepGuideTr: [
          'Sağdaki mor Diyar Seçimi butonuna dokunun.',
          'Kazanacağınız Tamga miktarını ve Kurgan mirasını inceleyin.',
          'GÖÇÜ BAŞLAT butonuna basarak yeni topraklarda daha güçlü bir başlangıç yapın.',
        ],
        stepGuideEn: [
          'Tap the purple Realm Migration button on the right toolbar.',
          'Review your earned Tamga count and Kurgan relics.',
          'Tap INITIATE MIGRATION to start fresh with permanent prestige multipliers.',
        ],
        tipsTr: [
          'Göç etmeden önce Kağan Otağını ve ana binalarınızı mümkün olan en yüksek seviyeye çıkarın; böylece Atalar Kurganınız çok daha güçlü miras bonusu verir.',
        ],
        tipsEn: [
          'Level up your buildings before migrating to create higher tier Ancestral Kurgans in the next realm.',
        ],
        tags: ['göç', 'tamga', 'prestij', 'kurgan', 'ata', 'miras', 'migration', 'prestige'],
      ),

      const HexpediaEntry(
        id: 'migration_diorama_lens',
        category: HexpediaCategory.migration,
        titleTr: 'Diorama Modu & Mühürlü Fotoğraf Çekimi',
        titleEn: 'Diorama Lens & Sealed Photo Snapshots',
        summaryTr: 'HUD arayüzünü gizleyerek minyatür tilt-shift merceğinde kağanlığı izleme ve hatıra mühürleri basma.',
        summaryEn: 'Hide the HUD for a cinematic tilt-shift diorama lens and capture sealed photo stamps.',
        contentTr: 'Sağ araç çubuğundaki Kamera simgesine dokunduğunuzda Diorama Snapshot penceresi açılır. "DİORAMA MERCEĞİNE GEÇ" butonuna bastığınızda tüm arayüz gizlenir, ekranın üst ve altına sinematik optik derinlik (tilt-shift blur) uygulanır. Kağanlığınızı yaşayan bir minyatür maket gibi izleyebilir, "MÜHÜRLÜ FOTOĞRAF" alarak başarılarınızı kaydedebilirsiniz.',
        contentEn: 'Tap the Camera icon to enter Diorama Mode. Hides all HUD elements and applies a tilt-shift miniature lens to view your living khaganate in cinematic beauty.',
        icon: Icons.camera_alt,
        iconColor: Color(0xFFF43F5E),
        badgeText: 'SİNEMATİK',
        stats: {
          'Lens Tipi': 'Minyatür Tilt-Shift & Vinyet',
          'HUD Durumu': 'Tamamen gizlenir',
          'Mühür': 'Tarih ve Tamgalı hatıra kartı',
        },
        stepGuideTr: [
          'Sağdaki Kamera butonuna dokunun.',
          '"DİORAMA MERCEĞİNİ AÇ" seçeneğine basın.',
          'Haritayı istediğiniz açıya kaydırıp minyatür yaşayan bozkırın keyfini çıkarın; çıkmak için sağ üstteki X butonuna basın.',
        ],
        stepGuideEn: [
          'Tap the Camera button on the right toolbar.',
          'Select OPEN DIORAMA LENS.',
          'Pan and zoom around your miniature realm; tap the top-right exit button when done.',
        ],
        tipsTr: [
          'Toy Coşkusu aktifken veya Zud fırtınası ortasında Diorama moduna geçerek görsel şöleni izleyin.',
        ],
        tipsEn: [
          'Switch to Diorama Mode during a 10x Toy Frenzy or snowstorm for breathtaking visuals.',
        ],
        tags: ['diorama', 'kamera', 'fotoğraf', 'lens', 'sinematik', 'tiltshift', 'camera'],
      ),
    ];
  }

  static List<HexpediaEntry> getByCategory(HexpediaCategory category) {
    final all = getAllEntries();
    if (category == HexpediaCategory.all) return all;
    return all.where((e) => e.category == category).toList();
  }

  /// Türkçe karakter toleranslı metin normalizasyonu (ç->c, ğ->g, ı->i, ö->o, ş->s, ü->u)
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('i̇', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }

  static List<HexpediaEntry> search(String query, {HexpediaCategory category = HexpediaCategory.all}) {
    final list = getByCategory(category);
    if (query.trim().isEmpty) return list;

    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return list;

    final queryWords = normalizedQuery.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    return list.where((e) {
      final normTitleTr = normalize(e.titleTr);
      final normTitleEn = normalize(e.titleEn);
      final normSummaryTr = normalize(e.summaryTr);
      final normSummaryEn = normalize(e.summaryEn);
      final normContentTr = normalize(e.contentTr);
      final normContentEn = normalize(e.contentEn);
      final normBadge = normalize(e.badgeText);
      final normTags = e.tags.map(normalize).toList();

      final combined = '$normTitleTr $normTitleEn $normSummaryTr $normSummaryEn $normContentTr $normContentEn $normBadge ${normTags.join(' ')}';

      return queryWords.every((word) => combined.contains(word));
    }).toList();
  }
}
