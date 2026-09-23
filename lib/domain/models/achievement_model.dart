import 'package:flutter/foundation.dart';

enum AchievementCategory {
  conquest,
  industry,
  winter,
  prestige,
  trade,
  mastery,
}

@immutable
class AchievementModel {
  final String id;
  final Map<String, String> titles;
  final Map<String, String> descriptions;
  final AchievementCategory category;
  final String iconCode;
  final double currentProgress;
  final double targetProgress;
  final bool isUnlocked;
  final int? unlockedAt;
  final int crownReward;
  final bool isRewardClaimed;

  const AchievementModel({
    required this.id,
    required this.titles,
    required this.descriptions,
    required this.category,
    required this.iconCode,
    this.currentProgress = 0.0,
    required this.targetProgress,
    this.isUnlocked = false,
    this.unlockedAt,
    this.crownReward = 10,
    this.isRewardClaimed = false,
  });

  String getTitle(String lang) {
    return titles[lang] ?? titles['en'] ?? titles['tr'] ?? id;
  }

  String getDescription(String lang) {
    return descriptions[lang] ?? descriptions['en'] ?? descriptions['tr'] ?? '';
  }

  double get progressRatio => targetProgress > 0
      ? (currentProgress / targetProgress).clamp(0.0, 1.0)
      : (isUnlocked ? 1.0 : 0.0);

  AchievementModel copyWith({
    String? id,
    Map<String, String>? titles,
    Map<String, String>? descriptions,
    AchievementCategory? category,
    String? iconCode,
    double? currentProgress,
    double? targetProgress,
    bool? isUnlocked,
    int? unlockedAt,
    int? crownReward,
    bool? isRewardClaimed,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      titles: titles ?? this.titles,
      descriptions: descriptions ?? this.descriptions,
      category: category ?? this.category,
      iconCode: iconCode ?? this.iconCode,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      crownReward: crownReward ?? this.crownReward,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt,
      'crownReward': crownReward,
      'isRewardClaimed': isRewardClaimed,
    };
  }

  factory AchievementModel.fromJson(
    Map<String, dynamic> json, {
    AchievementModel? template,
  }) {
    final base = template ?? AchievementCatalog.getTemplate(json['id'] as String? ?? '');
    if (base == null) {
      return AchievementModel(
        id: json['id'] as String? ?? 'unknown',
        titles: {'tr': 'Bilinmeyen Başarım', 'en': 'Unknown Achievement'},
        descriptions: {'tr': '', 'en': ''},
        category: AchievementCategory.mastery,
        iconCode: 'star',
        currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
        targetProgress: (json['targetProgress'] as num?)?.toDouble() ?? 1.0,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] as int?,
        crownReward: json['crownReward'] as int? ?? 10,
        isRewardClaimed: json['isRewardClaimed'] as bool? ?? false,
      );
    }

    return base.copyWith(
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? base.currentProgress,
      targetProgress: (json['targetProgress'] as num?)?.toDouble() ?? base.targetProgress,
      isUnlocked: json['isUnlocked'] as bool? ?? base.isUnlocked,
      unlockedAt: json['unlockedAt'] as int? ?? base.unlockedAt,
      crownReward: json['crownReward'] as int? ?? base.crownReward,
      isRewardClaimed: json['isRewardClaimed'] as bool? ?? base.isRewardClaimed,
    );
  }
}

class AchievementCatalog {
  static final List<AchievementModel> all = [
    // --- 1. ARAZİ & FETİH (CONQUEST) ---
    const AchievementModel(
      id: 'ach_first_conquest',
      titles: {
        'tr': 'İlk Otağ',
        'en': 'First Outpost',
        'es': 'Primer Puesto',
        'de': 'Erster Außenposten',
      },
      descriptions: {
        'tr': 'İlk toprak parçasını sınırlarına kat.',
        'en': 'Claim your first land tile.',
        'es': 'Reclama tu primera casilla de tierra.',
        'de': 'Erobere dein erstes Landfeld.',
      },
      category: AchievementCategory.conquest,
      iconCode: 'flag',
      targetProgress: 1,
      crownReward: 5,
    ),
    const AchievementModel(
      id: 'ach_steppe_borders',
      titles: {
        'tr': 'Bozkırın Sınırları',
        'en': 'Steppe Borders',
        'es': 'Fronteras de la Estepa',
        'de': 'Steppengrenzen',
      },
      descriptions: {
        'tr': 'Toplam 10 hex karosuna hükmet.',
        'en': 'Control a total of 10 hex tiles.',
        'es': 'Controla un total de 10 casillas hexagonales.',
        'de': 'Beherrsche insgesamt 10 Hex-Felder.',
      },
      category: AchievementCategory.conquest,
      iconCode: 'map',
      targetProgress: 10,
      crownReward: 15,
    ),
    const AchievementModel(
      id: 'ach_great_domain',
      titles: {
        'tr': 'Büyük Toy',
        'en': 'Great Domain',
        'es': 'Gran Dominio',
        'de': 'Große Domäne',
      },
      descriptions: {
        'tr': 'Toplam 25 hex karosunu egemenliğin altına al.',
        'en': 'Expand your realm to 25 hex tiles.',
        'es': 'Expande tu reino a 25 casillas hexagonales.',
        'de': 'Erweitere dein Reich auf 25 Hex-Felder.',
      },
      category: AchievementCategory.conquest,
      iconCode: 'crown',
      targetProgress: 25,
      crownReward: 30,
    ),
    const AchievementModel(
      id: 'ach_boundless',
      titles: {
        'tr': 'Ufkun Ötesi',
        'en': 'Beyond the Horizon',
        'es': 'Más Allá del Horizonte',
        'de': 'Hinter dem Horizont',
      },
      descriptions: {
        'tr': 'Toplam 50 hex karosunu fethet.',
        'en': 'Conquer a total of 50 hex tiles.',
        'es': 'Conquista un total de 50 casillas hexagonales.',
        'de': 'Erobere insgesamt 50 Hex-Felder.',
      },
      category: AchievementCategory.conquest,
      iconCode: 'globe',
      targetProgress: 50,
      crownReward: 60,
    ),
    const AchievementModel(
      id: 'ach_water_lord',
      titles: {
        'tr': 'Suya Hükmeden',
        'en': 'Ruler of Waters',
        'es': 'Señor de las Aguas',
        'de': 'Herrscher der Gewässer',
      },
      descriptions: {
        'tr': 'Göl veya nehir kenarındaki 5 su kıyısı karosunu aç.',
        'en': 'Claim 5 waterfront tiles along rivers or lakes.',
        'es': 'Reclama 5 casillas ribereñas junto a ríos o lagos.',
        'de': 'Erschließe 5 Uferfelder an Flüssen oder Seen.',
      },
      category: AchievementCategory.conquest,
      iconCode: 'water',
      targetProgress: 5,
      crownReward: 20,
    ),
    const AchievementModel(
      id: 'ach_mountain_pass',
      titles: {
        'tr': 'Dağların Kilidi',
        'en': 'Mountain Gate',
        'es': 'Paso de la Montaña',
        'de': 'Bergpass',
      },
      descriptions: {
        'tr': 'İlk dağ veya kayaç karosunu madencilik sahasına bağla.',
        'en': 'Claim your first mountain or rocky tile.',
        'es': 'Reclama tu primera casilla de montaña o roca.',
        'de': 'Erschließe dein erstes Berg- oder Felsfeld.',
      },
      category: AchievementCategory.conquest,
      iconCode: 'mountain',
      targetProgress: 1,
      crownReward: 15,
    ),

    // --- 2. SANAYİ & SEVİYE (INDUSTRY) ---
    const AchievementModel(
      id: 'ach_master_lumberjack',
      titles: {
        'tr': 'Ulu Keresteci',
        'en': 'Master Lumberjack',
        'es': 'Maestro Leñador',
        'de': 'Meisterholzfäller',
      },
      descriptions: {
        'tr': 'İlk Tier 3 Oduncu binasına ulaş.',
        'en': 'Upgrade a Lumberjack building to Tier 3.',
        'es': 'Mejora una Cabaña de Leñadores al Nivel 3.',
        'de': 'Baue eine Holzfällerhütte auf Stufe 3 aus.',
      },
      category: AchievementCategory.industry,
      iconCode: 'wood',
      targetProgress: 1,
      crownReward: 25,
    ),
    const AchievementModel(
      id: 'ach_golden_wheat',
      titles: {
        'tr': 'Altın Başak',
        'en': 'Golden Harvest',
        'es': 'Cosecha Dorada',
        'de': 'Goldene Ernte',
      },
      descriptions: {
        'tr': 'İlk Tier 3 Çiftlik veya Değirmen kompleksini kur.',
        'en': 'Upgrade a Farm or Mill complex to Tier 3.',
        'es': 'Mejora una Granja o Molino al Nivel 3.',
        'de': 'Baue einen Bauernhof oder eine Mühle auf Stufe 3 aus.',
      },
      category: AchievementCategory.industry,
      iconCode: 'food',
      targetProgress: 1,
      crownReward: 25,
    ),
    const AchievementModel(
      id: 'ach_deep_mine',
      titles: {
        'tr': 'Derin Ocak',
        'en': 'Deep Quarry',
        'es': 'Mina Profunda',
        'de': 'Tiefer Stollen',
      },
      descriptions: {
        'tr': 'İlk Tier 3 Demir Madeni seviyesine ulaş.',
        'en': 'Upgrade an Iron Mine to Tier 3.',
        'es': 'Mejora una Mina de Hierro al Nivel 3.',
        'de': 'Baue eine Eisenmine auf Stufe 3 aus.',
      },
      category: AchievementCategory.industry,
      iconCode: 'iron',
      targetProgress: 1,
      crownReward: 35,
    ),
    const AchievementModel(
      id: 'ach_grand_palace',
      titles: {
        'tr': 'Bozkırın Kalbi',
        'en': 'Heart of the Steppe',
        'es': 'Corazón de la Estepa',
        'de': 'Herz der Steppe',
      },
      descriptions: {
        'tr': 'Kağan Otağı’nı Tier 3 seviyesine yükselt.',
        'en': 'Upgrade the Grand Yurt to Tier 3.',
        'es': 'Mejora la Yurta del Gran Kan al Nivel 3.',
        'de': 'Baue die Kagan-Jurte auf Stufe 3 aus.',
      },
      category: AchievementCategory.industry,
      iconCode: 'castle',
      targetProgress: 1,
      crownReward: 50,
    ),
    const AchievementModel(
      id: 'ach_full_automation',
      titles: {
        'tr': 'Kusursuz Sanayi',
        'en': 'Flawless Industry',
        'es': 'Industria Impecable',
        'de': 'Vollendete Industrie',
      },
      descriptions: {
        'tr': 'Haritada aynı anda en az 3 adet Tier 3 binaya sahip ol.',
        'en': 'Own at least 3 Tier 3 buildings at the same time.',
        'es': 'Posee al menos 3 edificios de Nivel 3 al mismo tiempo.',
        'de': 'Besitze gleichzeitig mindestens 3 Gebäude der Stufe 3.',
      },
      category: AchievementCategory.industry,
      iconCode: 'factory',
      targetProgress: 3,
      crownReward: 40,
    ),
    const AchievementModel(
      id: 'ach_iron_surge',
      titles: {
        'tr': 'Demir Dövenler',
        'en': 'Iron Forgers',
        'es': 'Forjadores de Hierro',
        'de': 'Eisenschmiede',
      },
      descriptions: {
        'tr': 'Saniyede +30 Demir net üretim hızına ulaş.',
        'en': 'Reach +30 net Iron production per second.',
        'es': 'Alcanza +30 de producción neta de hierro por segundo.',
        'de': 'Erreiche +30 Netto-Eisenproduktion pro Sekunde.',
      },
      category: AchievementCategory.industry,
      iconCode: 'anvil',
      targetProgress: 30,
      crownReward: 30,
    ),

    // --- 3. KIŞ & AYAZ (WINTER) ---
    const AchievementModel(
      id: 'ach_first_winter',
      titles: {
        'tr': 'İlk Ayaz',
        'en': 'First Frost',
        'es': 'Primera Helada',
        'de': 'Erster Frost',
      },
      descriptions: {
        'tr': 'İlk Kış (Zud) mevsimini başarıyla atlat.',
        'en': 'Survive your first Winter season.',
        'es': 'Sobrevive a tu primera temporada de invierno.',
        'de': 'Überstehe deine erste Wintersaison.',
      },
      category: AchievementCategory.winter,
      iconCode: 'snowflake',
      targetProgress: 1,
      crownReward: 20,
    ),
    const AchievementModel(
      id: 'ach_warm_hearth',
      titles: {
        'tr': 'Sıcak Ocaklar',
        'en': 'Warm Hearths',
        'es': 'Hogares Cálidos',
        'de': 'Warme Herde',
      },
      descriptions: {
        'tr': 'Bir kış boyunca tüm binalarını kesintisiz ısıtarak bahara ulaş.',
        'en': 'Keep all buildings heated throughout winter until spring.',
        'es': 'Mantén todos los edificios calientes durante el invierno hasta la primavera.',
        'de': 'Halte alle Gebäude den gesamten Winter über beheizt bis zum Frühling.',
      },
      category: AchievementCategory.winter,
      iconCode: 'fire',
      targetProgress: 1,
      crownReward: 45,
    ),
    const AchievementModel(
      id: 'ach_winter_prep',
      titles: {
        'tr': 'Kış Hazırlığı',
        'en': 'Winter Provision',
        'es': 'Provisión Invernal',
        'de': 'Wintervorbereitung',
      },
      descriptions: {
        'tr': 'Kış mevsimine en az 500 Odun stoku ile gir.',
        'en': 'Enter Winter with at least 500 Wood in storage.',
        'es': 'Entra al invierno con al menos 500 de madera en almacén.',
        'de': 'Gehe mit mindestens 500 Holz im Lager in den Winter.',
      },
      category: AchievementCategory.winter,
      iconCode: 'wood_pile',
      targetProgress: 500,
      crownReward: 25,
    ),
    const AchievementModel(
      id: 'ach_four_seasons',
      titles: {
        'tr': 'Dört Mevsim Çarkı',
        'en': 'Wheel of Seasons',
        'es': 'Rueda de Estaciones',
        'de': 'Rad der Jahreszeiten',
      },
      descriptions: {
        'tr': '4 tam mevsim döngüsünü (İlkbahar -> Kış) tamamla.',
        'en': 'Complete 4 full season cycles.',
        'es': 'Completa 4 ciclos estacionales completos.',
        'de': 'Schließe 4 vollständige Jahreszeitenzyklen ab.',
      },
      category: AchievementCategory.winter,
      iconCode: 'sun_snow',
      targetProgress: 4,
      crownReward: 35,
    ),

    // --- 4. BÜYÜK GÖÇ & MECLİS (PRESTIGE) ---
    const AchievementModel(
      id: 'ach_first_migration',
      titles: {
        'tr': 'Büyük Göç',
        'en': 'The Great Migration',
        'es': 'La Gran Migración',
        'de': 'Die Große Wanderung',
      },
      descriptions: {
        'tr': 'İlk kez obayı toplayıp Büyük Göç gerçekleştir.',
        'en': 'Perform your very first Great Migration prestige reset.',
        'es': 'Realiza tu primera Gran Migración para reiniciar.',
        'de': 'Führe deine allererste Große Wanderung durch.',
      },
      category: AchievementCategory.prestige,
      iconCode: 'horse',
      targetProgress: 1,
      crownReward: 50,
    ),
    const AchievementModel(
      id: 'ach_ancestral_seal',
      titles: {
        'tr': 'Ata Yadigarı',
        'en': 'Ancestral Seal',
        'es': 'Sello Ancestral',
        'de': 'Ahnensiegel',
      },
      descriptions: {
        'tr': 'İlk kalıcı Tamga’nı mühürle.',
        'en': 'Forge and activate your first permanent Tamga seal.',
        'es': 'Forja y activa tu primer sello Tamga permanente.',
        'de': 'Schmiede und aktiviere dein erstes permanentes Tamga-Siegel.',
      },
      category: AchievementCategory.prestige,
      iconCode: 'seal',
      targetProgress: 1,
      crownReward: 30,
    ),
    const AchievementModel(
      id: 'ach_council_assembly',
      titles: {
        'tr': 'Bilgeler Meclisi',
        'en': 'Council of Sages',
        'es': 'Consejo de Sabios',
        'de': 'Rat der Weisen',
      },
      descriptions: {
        'tr': 'İlk doktrini aç ve bir Meclis yuvasına tak.',
        'en': 'Unlock and slot your first Steppe Doctrine.',
        'es': 'Desbloquea y equipa tu primera Doctrina de la Estepa.',
        'de': 'Schalte deine erste Steppendoktrin frei und rüste sie aus.',
      },
      category: AchievementCategory.prestige,
      iconCode: 'scroll',
      targetProgress: 1,
      crownReward: 20,
    ),
    const AchievementModel(
      id: 'ach_steppe_legend',
      titles: {
        'tr': 'Bozkır Efsanesi',
        'en': 'Legend of the Steppe',
        'es': 'Leyenda de la Estepa',
        'de': 'Legende der Steppe',
      },
      descriptions: {
        'tr': 'Toplam 3 kez Büyük Göç tamamla.',
        'en': 'Complete a total of 3 Great Migrations.',
        'es': 'Completa un total de 3 Grandes Migraciones.',
        'de': 'Vollende insgesamt 3 Große Wanderungen.',
      },
      category: AchievementCategory.prestige,
      iconCode: 'eagle',
      targetProgress: 3,
      crownReward: 100,
    ),

    // --- 5. TİCARET & PAZAR (TRADE) ---
    const AchievementModel(
      id: 'ach_silk_road_traveler',
      titles: {
        'tr': 'İpek Yolu Yolcusu',
        'en': 'Silk Road Traveler',
        'es': 'Viajero de la Ruta de la Seda',
        'de': 'Reisender der Seidenstraße',
      },
      descriptions: {
        'tr': 'İlk kervanı karşıla ve takası tamamla.',
        'en': 'Receive a trade caravan and complete an exchange.',
        'es': 'Recibe una caravana comercial y completa un intercambio.',
        'de': 'Empfange eine Handelskarawane und schließe den Tausch ab.',
      },
      category: AchievementCategory.trade,
      iconCode: 'camel',
      targetProgress: 1,
      crownReward: 15,
    ),
    const AchievementModel(
      id: 'ach_market_guild',
      titles: {
        'tr': 'Pazar Loncası',
        'en': 'Market Guild',
        'es': 'Gremio del Mercado',
        'de': 'Marktgilde',
      },
      descriptions: {
        'tr': 'Pazarda tek seferde veya toplamda 500 birim kaynak takas et.',
        'en': 'Trade a total of 500 resources at the Silk Road Market.',
        'es': 'Intercambia 500 recursos en el Mercado de la Ruta de la Seda.',
        'de': 'Tausche insgesamt 500 Ressourcen auf dem Markt.',
      },
      category: AchievementCategory.trade,
      iconCode: 'coins',
      targetProgress: 500,
      crownReward: 25,
    ),
    const AchievementModel(
      id: 'ach_crown_hoard',
      titles: {
        'tr': 'Kutlu Hazine',
        'en': 'Imperial Treasury',
        'es': 'Tesoro Imperial',
        'de': 'Kaiserliche Schatzkammer',
      },
      descriptions: {
        'tr': 'Kasanda aynı anda en az 100 Kut / Taç biriktir.',
        'en': 'Amass at least 100 Crowns of Glory in your treasury.',
        'es': 'Acumula al menos 100 Coronas en tu tesoro.',
        'de': 'Häufe mindestens 100 Kronen in deiner Schatzkammer an.',
      },
      category: AchievementCategory.trade,
      iconCode: 'chest',
      targetProgress: 100,
      crownReward: 40,
    ),

    // --- 6. TAKTİKSEL USTALIK & GİZLİ (MASTERY) ---
    const AchievementModel(
      id: 'ach_frenzy_peak',
      titles: {
        'tr': 'Bozkır Fırtınası',
        'en': 'Steppe Storm',
        'es': 'Tormenta de la Estepa',
        'de': 'Steppensturm',
      },
      descriptions: {
        'tr': '10x Toy Coşkusu (Frenzy) modunu etkinleştir.',
        'en': 'Activate 10x Realm Frenzy boost.',
        'es': 'Activa el modo Frenesí del Reino 10x.',
        'de': 'Aktiviere den 10x-Reichsfrenzy-Modus.',
      },
      category: AchievementCategory.mastery,
      iconCode: 'lightning',
      targetProgress: 1,
      crownReward: 20,
    ),
    const AchievementModel(
      id: 'ach_remodel_master',
      titles: {
        'tr': 'Stratejik Dönüşüm',
        'en': 'Tactical Remodel',
        'es': 'Reforma Táctica',
        'de': 'Taktische Umgestaltung',
      },
      descriptions: {
        'tr': 'Bir binayı yıkıp arazisine yeni bir bina inşa et.',
        'en': 'Demolish a building and replace it with a new one.',
        'es': 'Demuele un edificio y reemplázalo por uno nuevo.',
        'de': 'Reiße ein Gebäude ab und errichte ein neues.',
      },
      category: AchievementCategory.mastery,
      iconCode: 'hammer',
      targetProgress: 1,
      crownReward: 25,
    ),
    const AchievementModel(
      id: 'ach_rhythm_master',
      titles: {
        'tr': 'Bozkırın Ritmi',
        'en': 'Steppe Rhythm',
        'es': 'Ritmo de la Estepa',
        'de': 'Rhythmus der Steppe',
      },
      descriptions: {
        'tr': 'Taktil hasat ritim kombosunu 10 vuruşa ulaştır.',
        'en': 'Reach a 10x rhythm combo while collecting resources.',
        'es': 'Alcanza un combo de ritmo de 10 golpes al recolectar.',
        'de': 'Erreiche eine 10er-Rhythmuskombo beim Sammeln.',
      },
      category: AchievementCategory.mastery,
      iconCode: 'drum',
      targetProgress: 10,
      crownReward: 30,
    ),
  ];

  static AchievementModel? getTemplate(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<AchievementModel> getInitialList() {
    return all.map((a) => a.copyWith()).toList();
  }
}
