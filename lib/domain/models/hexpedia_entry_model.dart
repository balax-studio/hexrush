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
      // -------------------------------------------------------------
      // 1. TEMEL MEKANİKLER (CORE)
      // -------------------------------------------------------------
      const HexpediaEntry(
        id: 'core_castle',
        category: HexpediaCategory.core,
        titleTr: 'Kağan Otağı & İlerleme',
        titleEn: "Khan's Tent & Progression",
        summaryTr: 'Kağanlığın kalbi. Otağ yükseldikçe yeni teknolojiler, binalar ve küresel hız çarpanı açılır.',
        summaryEn: "The core of the Khaganate. Upgrading the Tent unlocks new buildings, lore tiers, and speed boosts.",
        contentTr: 'Kağan Otağı, haritanın merkezindeki (0,0) ana karodur. Her seviye artışı, tüm kağanlık üretimine kalıcı %15 çarpan kazandırır ve Seviye 2\'de Töre Meclisi, Seviye 3\'te Maden ve Fırınlar, Seviye 4\'te Çöl/Tundra derin yapıları, Seviye 5\'te ise Efsanevi Obsidyen ve Göksel Ocaklar açılır.',
        contentEn: "The Khan's Tent is the central hex tile (0,0). Each level gives a permanent +15% Khaganate production boost and unlocks new building tiers up to Level 5.",
        icon: Icons.castle,
        iconColor: Color(0xFFF59E0B),
        badgeText: 'ŞATO / MERKEZ',
        stats: {
          'Maksimum Seviye': '5',
          'Küresel Bonus': '+%15 / Seviye',
          'Açılış Seviyeleri': 'Sv 1: Temel, Sv 2: Töre, Sv 3: Rafineri, Sv 4: İklim, Sv 5: Göksel',
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
        titleTr: 'Ritmik Dokunuş & Toy Coşkusu',
        titleEn: 'Rhythm Tap & 10x Frenzy',
        summaryTr: 'Bozkır davulunun ritmine uyarak haritaya dokunun. Kombo biriktirerek 10x Toy Coşkusunu tetikleyin.',
        summaryEn: 'Tap to the rhythm of the steppe drum. Build combos to unleash 10x Toy Frenzy.',
        contentTr: 'Haritanın boş alanlarına veya karolara 0.4s - 1.2s aralıklarla ritmik dokunduğunuzda Ritim Kombosu artar. Kombo 15 seviyesine ulaştığında "Toy Coşkusu" butonu parlar. Aktif edildiğinde tüm binalar ve işçiler 20 saniye boyunca 10 kat hızla çalışır.',
        contentEn: 'Tapping at steady rhythmic intervals increases your Rhythm Combo. Hitting 15 combo primes Toy Frenzy for a 20-second 10x production surge.',
        icon: Icons.bolt,
        iconColor: Color(0xFFF97316),
        badgeText: 'RİTİM / 10X',
        stats: {
          'Toy Süresi': '20 Saniye',
          'Üretim Çarpanı': '10x Hız',
          'Ritim Penceresi': '0.4s - 1.2s aralık',
        },
        stepGuideTr: [
          'Harita zeminine saniyede yaklaşık 1-2 dokunuşla ritmik olarak dokunun.',
          'Üst bardaki ritim çubuğunun ve kombo sayacının dolmasını izleyin.',
          'Toy Coşkusu butonu aktif olduğunda basarak 10x üretim patlamasını başlatın.',
        ],
        stepGuideEn: [
          'Tap rhythmically on the map at roughly 1-2 taps per second.',
          'Watch the top bar rhythm gauge and combo counter fill up.',
          'When primed, tap Toy Frenzy to trigger 10x speed boost for 20s.',
        ],
        tipsTr: [
          'Toy Coşkusu patlamasını kış aylarında veya büyük inşaat yükseltmelerinde kullanarak zaman kazanın.',
        ],
        tipsEn: [
          'Trigger Toy Frenzy during harsh winters or heavy building upgrade cycles.',
        ],
        tags: ['ritim', 'toy', 'frenzy', 'kombo', 'hız', 'dokunuş'],
      ),

      // -------------------------------------------------------------
      // 2. BİYOMLAR & SİMBİYOZ (BIOMES)
      // -------------------------------------------------------------
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
        tags: ['biyom', 'arazi', 'orman', 'çöl', 'tundra', 'dağ', 'deniz', 'volkan'],
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

      // -------------------------------------------------------------
      // 3. YAPILAR & ÜRETİM ZİNCİRİ (BUILDINGS)
      // -------------------------------------------------------------
      const HexpediaEntry(
        id: 'buildings_chains',
        category: HexpediaCategory.buildings,
        titleTr: '3 Seviyeli Üretim Zinciri Mimarisi',
        titleEn: '3-Tier Production Chains',
        summaryTr: 'Hammaddeden işlenmiş mamullere ve efsanevi silahlara uzanan derin üretim piramidi.',
        summaryEn: 'Deep production pipeline from raw resources to refined goods and mythical arms.',
        contentTr: 'HexRush ekonomisi 3 katmanlı girdi-çıktı mantığıyla işler:\n\n• Tier 1 (Hammadde): Buğday, Arpa, Odun, Taş, Demir filizi, Balık.\n• Tier 2 (İşlenmiş Mamul): Yel Değirmeni buğdayı Un yapar, Hızar Otağı odunu Kalas/Kereste yapar, Fırın ekmek pişirir, Marangoz mobilya üretir.\n• Tier 3 (Bozkır Zanaat): Kımız Otağı (Kımız şifası), Keçe Atölyesi (Zırh keçesi), Şam Ocağı (Demir+Obsidyen = Şam Çeliği), Tahıl Mahzeni (Kapasite deposu).',
        contentEn: 'Tier 1 gathers raw crops, timber, stone, and ores. Tier 2 refines them into Flour, Planks, Bread, and Furniture. Tier 3 crafts Kumis, Felt armor, Damascus Steel, and Granary storage.',
        icon: Icons.precision_manufacturing,
        iconColor: Color(0xFFFBBF24),
        badgeText: '3 TİER ZİNCİR',
        stats: {
          'Toplam Yapı': '35+ Benzersiz Bina',
          'Dönüşüm Oranları': '2 Odun -> 1 Kalas | 2 Buğday -> 1 Un -> 1 Ekmek',
          'Otomasyon': 'İşçi Kulübesi ile otomatik taşıma',
        },
        tipsTr: [
          'Un ve Kalas üretmeden Fırın veya Marangoz kurmayın; girdi eksikliğinde binalar boşta kalır.',
        ],
        tipsEn: [
          'Ensure continuous Flour and Plank supplies before building Bakeries or Furniture workshops.',
        ],
        tags: ['üretim', 'zincir', 'bina', 'un', 'ekmek', 'kalas', 'çelik', 'kımız', 'keçe'],
      ),

      const HexpediaEntry(
        id: 'buildings_worker_logistics',
        category: HexpediaCategory.buildings,
        titleTr: 'İşçi Kulübesi & Lojistik Ağı',
        titleEn: 'Worker Huts & Automated Logistics',
        summaryTr: 'Karolar arasında üretilen hammaddeleri otomatik toplayıp işleme tesislerine taşıyan işçiler.',
        summaryEn: 'Workers automatically gather raw yields and transport them to processing facilities.',
        contentTr: 'Manuel olarak "TOPLA" butonuna basmak yerine İşçi Kulübesi kurduğunuzda, kulübeden çıkan işçiler 4 Hex yarıçapındaki tüm tarlaları, oduncuları ve madenleri otomatik ziyaret eder. Taşınan yükler Kağanlık ambarına anında aktarılır.',
        contentEn: 'Worker Huts spawn automated logistical workers that patrol a 4-hex radius, collecting yields from farms and lumber camps automatically.',
        icon: Icons.engineering,
        iconColor: Color(0xFFE2E8F0),
        badgeText: 'OTOMASYON',
        stats: {
          'Toplama Menzili': '4 Hex Çapı',
          'Taşıma Kapasitesi': 'Seviye başına +5 Yük',
          'Hızlandırma': 'At Yılı kehanetiyle %50 hız artışı',
        },
        stepGuideTr: [
          'Üretim tesislerinizin ortasında merkezi bir karo seçin.',
          'İNŞA ET menüsünden "İşçi Kulübesi" yapısını seçip kurun.',
          'İşçilerin otomatik olarak tarlaları gezip kaynak toplamasını izleyin.',
        ],
        stepGuideEn: [
          'Pick a central tile surrounded by production facilities.',
          'Build a Worker Hut from the construction menu.',
          'Watch workers patrol and automatically haul resources to your treasury.',
        ],
        tipsTr: [
          'Her 8-10 üretim binası için en az 1 adet Seviye 2+ İşçi Kulübesi bulundurun.',
        ],
        tipsEn: [
          'Place at least one Level 2+ Worker Hut for every 8-10 production buildings.',
        ],
        tags: ['işçi', 'lojistik', 'otomasyon', 'taşıma', 'kulübe', 'worker'],
      ),

      // -------------------------------------------------------------
      // 4. İKLİM, ZUD & GÖKSEL KEHANETLER (SEASONS)
      // -------------------------------------------------------------
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
          'Odun harcayarak binanın donmasını engelleyin ve turuncu aurasını koruyun.',
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
        tags: ['mevsim', 'kış', 'zud', 'ısınma', 'bahar', 'yaz', 'donma', 'seasons'],
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

      // -------------------------------------------------------------
      // 5. TÖRE MECLİSİ & BİLGELİK (LORE)
      // -------------------------------------------------------------
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

      // -------------------------------------------------------------
      // 6. TİCARET, KERVANLAR & PAZAR (TRADE & CARAVANS)
      // -------------------------------------------------------------
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

      // -------------------------------------------------------------
      // 7. BÜYÜK GÖÇ & DİORAMA (MIGRATION & PRESTIGE)
      // -------------------------------------------------------------
      const HexpediaEntry(
        id: 'migration_prestige_tamga',
        category: HexpediaCategory.migration,
        titleTr: 'Büyük Göç & Kadim Tamga (Prestij Sistemi)',
        titleEn: 'Great Migration & Tamga Prestige',
        summaryTr: 'Diyarı terk edip kümülatif Tamgalar ve ata mirası anıtlarıyla yeni topraklara göç etme.',
        summaryEn: 'Migrate to new realms, retaining cumulative Tamgas and Ancestral Kurgan relic echoes.',
        contentTr: 'Kağanlığınız yeterince büyüdüğünde (en az 12 fethedilmiş karo), sağdaki Harita butonuna basarak "Büyük Göç" başlatabilirsiniz. Göç ettiğinizde kaynaklar sıfırlanır ancak:\n\n1. Kümülatif Tamgalar (Prestige Tokens) kazanırsınız (her Tamga tüm üretime kalıcı +%5 çarpan verir).\n2. Eski diyardaki en görkemli binalarınız yeni haritada "Atalar Kurganı" olarak belirir; uyandırıldığında devasa aura bonusu verir.\n3. Yeni diyarlara (İdil Boyu, Karakum Çölü) yerleşme hakkı açılır.',
        contentEn: 'Once reaching 12+ tiles, initiate the Great Migration. You earn permanent Tamga tokens (+5% global boost each) and leave behind Ancestral Kurgans.',
        icon: Icons.flight_takeoff,
        iconColor: Color(0xFF818CF8),
        badgeText: 'PRESTİJ SİSTEMİ',
        stats: {
          'Asgari Şart': '12 Fethedilmiş Karo',
          'Tamga Bonusu': '+%5 Kalıcı Çarpan / Tamga',
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

  static List<HexpediaEntry> search(String query, {HexpediaCategory category = HexpediaCategory.all}) {
    final list = getByCategory(category);
    if (query.trim().isEmpty) return list;

    final q = query.toLowerCase().trim();
    return list.where((e) {
      final matchTr = e.titleTr.toLowerCase().contains(q) ||
          e.summaryTr.toLowerCase().contains(q) ||
          e.contentTr.toLowerCase().contains(q) ||
          e.tags.any((t) => t.toLowerCase().contains(q));
      final matchEn = e.titleEn.toLowerCase().contains(q) ||
          e.summaryEn.toLowerCase().contains(q) ||
          e.contentEn.toLowerCase().contains(q);
      return matchTr || matchEn;
    }).toList();
  }
}
