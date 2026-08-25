enum DoctrineSlotType {
  economic,
  military,
  nomadic,
  wildcard,
}

enum DoctrineEffectType {
  cropBonus,
  mineIronBoost,
  conquestDiscount,
  winterWarmDiscount,
  workerCapacityBoost,
  desertTradeBonus,
  tamgaAndShrineBonus,
  meadowGrazeYield,
}

class DoctrineCardModel {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final DoctrineSlotType slotType;
  final DoctrineEffectType effectType;
  final double effectValue;
  final int unlockCastleLevel;
  final int costCrowns;
  final bool isUnlocked;

  const DoctrineCardModel({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.slotType,
    required this.effectType,
    required this.effectValue,
    required this.unlockCastleLevel,
    this.costCrowns = 0,
    this.isUnlocked = false,
  });

  DoctrineCardModel copyWith({
    String? id,
    String? titleTr,
    String? titleEn,
    String? descriptionTr,
    String? descriptionEn,
    DoctrineSlotType? slotType,
    DoctrineEffectType? effectType,
    double? effectValue,
    int? unlockCastleLevel,
    int? costCrowns,
    bool? isUnlocked,
  }) {
    return DoctrineCardModel(
      id: id ?? this.id,
      titleTr: titleTr ?? this.titleTr,
      titleEn: titleEn ?? this.titleEn,
      descriptionTr: descriptionTr ?? this.descriptionTr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      slotType: slotType ?? this.slotType,
      effectType: effectType ?? this.effectType,
      effectValue: effectValue ?? this.effectValue,
      unlockCastleLevel: unlockCastleLevel ?? this.unlockCastleLevel,
      costCrowns: costCrowns ?? this.costCrowns,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleTr': titleTr,
      'titleEn': titleEn,
      'descriptionTr': descriptionTr,
      'descriptionEn': descriptionEn,
      'slotType': slotType.name,
      'effectType': effectType.name,
      'effectValue': effectValue,
      'unlockCastleLevel': unlockCastleLevel,
      'costCrowns': costCrowns,
      'isUnlocked': isUnlocked,
    };
  }

  factory DoctrineCardModel.fromJson(Map<String, dynamic> json) {
    return DoctrineCardModel(
      id: json['id'] as String,
      titleTr: json['titleTr'] as String,
      titleEn: json['titleEn'] as String,
      descriptionTr: json['descriptionTr'] as String,
      descriptionEn: json['descriptionEn'] as String,
      slotType: DoctrineSlotType.values.firstWhere(
        (e) => e.name == json['slotType'],
        orElse: () => DoctrineSlotType.economic,
      ),
      effectType: DoctrineEffectType.values.firstWhere(
        (e) => e.name == json['effectType'],
        orElse: () => DoctrineEffectType.cropBonus,
      ),
      effectValue: (json['effectValue'] as num?)?.toDouble() ?? 1.0,
      unlockCastleLevel: json['unlockCastleLevel'] as int? ?? 1,
      costCrowns: json['costCrowns'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  static List<DoctrineCardModel> getInitialDoctrines() {
    return const [
      DoctrineCardModel(
        id: 'doc_sulama_fermani',
        titleTr: 'Sulama Fermanı',
        titleEn: 'Irrigation Decree',
        descriptionTr: 'Tüm tarla ve değirmenlerin taban üretimini +%25 artırır.',
        descriptionEn: 'Increases base production of farms and windmills by +25%.',
        slotType: DoctrineSlotType.economic,
        effectType: DoctrineEffectType.cropBonus,
        effectValue: 0.25,
        unlockCastleLevel: 1,
        costCrowns: 0,
        isUnlocked: true,
      ),
      DoctrineCardModel(
        id: 'doc_gocer_iasesi',
        titleTr: 'Göçer İaşesi',
        titleEn: 'Nomadic Foraging',
        descriptionTr: 'Sahip olunan her boş çayır saniyede +0.5 Gıda üretir.',
        descriptionEn: 'Every owned empty meadow generates +0.5 Food per second.',
        slotType: DoctrineSlotType.economic,
        effectType: DoctrineEffectType.meadowGrazeYield,
        effectValue: 0.5,
        unlockCastleLevel: 2,
        costCrowns: 1,
      ),
      DoctrineCardModel(
        id: 'doc_bozkir_akincisi',
        titleTr: 'Bozkır Akıncısı',
        titleEn: 'Steppe Raider',
        descriptionTr: 'Karo fetih maliyetlerinde %20 indirim sağlar.',
        descriptionEn: 'Reduces tile conquest costs by 20%.',
        slotType: DoctrineSlotType.military,
        effectType: DoctrineEffectType.conquestDiscount,
        effectValue: 0.20,
        unlockCastleLevel: 1,
        costCrowns: 0,
        isUnlocked: true,
      ),
      DoctrineCardModel(
        id: 'doc_demirci_ocagi',
        titleTr: 'Demirci Ocağı',
        titleEn: 'Blacksmith Hearth',
        descriptionTr: 'Madenlerden demir çıkarma oranını +%50 artırır.',
        descriptionEn: 'Increases iron extraction ratio from mines by +50%.',
        slotType: DoctrineSlotType.military,
        effectType: DoctrineEffectType.mineIronBoost,
        effectValue: 0.50,
        unlockCastleLevel: 2,
        costCrowns: 2,
      ),
      DoctrineCardModel(
        id: 'doc_kis_otagi',
        titleTr: 'Kış Otağı',
        titleEn: 'Winter Yurt Lodge',
        descriptionTr: 'Kışın binaları ısıtmak 5 Odun yerine 2 Odun tüketir.',
        descriptionEn: 'Heating buildings in winter costs 2 Wood instead of 5.',
        slotType: DoctrineSlotType.nomadic,
        effectType: DoctrineEffectType.winterWarmDiscount,
        effectValue: 3.0, // 5 - 3 = 2 odun
        unlockCastleLevel: 1,
        costCrowns: 0,
        isUnlocked: true,
      ),
      DoctrineCardModel(
        id: 'doc_yurt_duzeni',
        titleTr: 'Yurt Düzeni',
        titleEn: 'Yurt Logistics',
        descriptionTr: 'İşçi taşıma kapasitesini ve hızını +%50 artırır.',
        descriptionEn: 'Increases worker carry capacity and speed by +50%.',
        slotType: DoctrineSlotType.nomadic,
        effectType: DoctrineEffectType.workerCapacityBoost,
        effectValue: 0.50,
        unlockCastleLevel: 2,
        costCrowns: 1,
      ),
      DoctrineCardModel(
        id: 'doc_ipek_yolu_imtiyazi',
        titleTr: 'İpek Yolu İmtiyazı',
        titleEn: 'Silk Road Privilege',
        descriptionTr: 'Pazar ve Çöl komşuluğundaki tüm yapılara +%35 gelir.',
        descriptionEn: '+35% revenue to all buildings adjacent to Market and Desert.',
        slotType: DoctrineSlotType.wildcard,
        effectType: DoctrineEffectType.desertTradeBonus,
        effectValue: 0.35,
        unlockCastleLevel: 3,
        costCrowns: 3,
      ),
      DoctrineCardModel(
        id: 'doc_kut_inanci',
        titleTr: 'Kut İnancı',
        titleEn: 'Sacred Kut Faith',
        descriptionTr: 'Sunak kutsamalarını ve Tamga çarpanını +%30 güçlendirir.',
        descriptionEn: 'Boosts shrine blessings and Tamga multiplier by +30%.',
        slotType: DoctrineSlotType.wildcard,
        effectType: DoctrineEffectType.tamgaAndShrineBonus,
        effectValue: 0.30,
        unlockCastleLevel: 3,
        costCrowns: 3,
      ),
    ];
  }
}
