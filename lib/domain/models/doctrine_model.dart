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
  final String titleEs;
  final String titleDe;
  final String descriptionTr;
  final String descriptionEn;
  final String descriptionEs;
  final String descriptionDe;
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
    this.titleEs = '',
    this.titleDe = '',
    required this.descriptionTr,
    required this.descriptionEn,
    this.descriptionEs = '',
    this.descriptionDe = '',
    required this.slotType,
    required this.effectType,
    required this.effectValue,
    required this.unlockCastleLevel,
    this.costCrowns = 0,
    this.isUnlocked = false,
  });

  String getTitle(String lang) {
    if (lang == 'tr') return titleTr;
    if (lang == 'es') return titleEs.isNotEmpty ? titleEs : titleEn;
    if (lang == 'de') return titleDe.isNotEmpty ? titleDe : titleEn;
    return titleEn;
  }

  String getDescription(String lang) {
    if (lang == 'tr') return descriptionTr;
    if (lang == 'es') return descriptionEs.isNotEmpty ? descriptionEs : descriptionEn;
    if (lang == 'de') return descriptionDe.isNotEmpty ? descriptionDe : descriptionEn;
    return descriptionEn;
  }

  DoctrineCardModel copyWith({
    String? id,
    String? titleTr,
    String? titleEn,
    String? titleEs,
    String? titleDe,
    String? descriptionTr,
    String? descriptionEn,
    String? descriptionEs,
    String? descriptionDe,
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
      titleEs: titleEs ?? this.titleEs,
      titleDe: titleDe ?? this.titleDe,
      descriptionTr: descriptionTr ?? this.descriptionTr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionDe: descriptionDe ?? this.descriptionDe,
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
      'titleEs': titleEs,
      'titleDe': titleDe,
      'descriptionTr': descriptionTr,
      'descriptionEn': descriptionEn,
      'descriptionEs': descriptionEs,
      'descriptionDe': descriptionDe,
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
      titleTr: json['titleTr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      titleEs: json['titleEs'] as String? ?? '',
      titleDe: json['titleDe'] as String? ?? '',
      descriptionTr: json['descriptionTr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionEs: json['descriptionEs'] as String? ?? '',
      descriptionDe: json['descriptionDe'] as String? ?? '',
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
        titleEs: 'Decreto de Regadío',
        titleDe: 'Bewässerungsdekret',
        descriptionTr: 'Tüm tarla ve değirmenlerin taban üretimini +%25 artırır.',
        descriptionEn: 'Increases base production of farms and windmills by +25%.',
        descriptionEs: 'Aumenta la producción base de granjas y molinos un +25%.',
        descriptionDe: 'Erhöht die Basisproduktion von Höfen und Mühlen um +25%.',
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
        titleEs: 'Forraje Nómada',
        titleDe: 'Nomadische Versorgung',
        descriptionTr: 'Sahip olunan her boş çayır saniyede +0.5 Gıda üretir.',
        descriptionEn: 'Every owned empty meadow generates +0.5 Food per second.',
        descriptionEs: 'Cada prado vacío poseído genera +0.5 de comida por segundo.',
        descriptionDe: 'Jede eigene freie Wiese erzeugt +0,5 Nahrung pro Sekunde.',
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
        titleEs: 'Incursor de la Estepa',
        titleDe: 'Steppenreiter',
        descriptionTr: 'Karo fetih maliyetlerinde %20 indirim sağlar.',
        descriptionEn: 'Reduces tile conquest costs by 20%.',
        descriptionEs: 'Reduce los costos de conquista de casillas un 20%.',
        descriptionDe: 'Verringert die Kosten für die Eroberung von Feldern um 20%.',
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
        titleEs: 'Hogar del Herrero',
        titleDe: 'Schmiedefeuer',
        descriptionTr: 'Madenlerden demir çıkarma oranını +%50 artırır.',
        descriptionEn: 'Increases iron extraction ratio from mines by +50%.',
        descriptionEs: 'Aumenta la extracción de hierro en las minas un +50%.',
        descriptionDe: 'Erhöht die Eisenausbeute in Minen um +50%.',
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
        titleEs: 'Refugio de Invierno',
        titleDe: 'Winterjurte',
        descriptionTr: 'Kışın binaları ısıtmak 5 Odun yerine 2 Odun tüketir.',
        descriptionEn: 'Heating buildings in winter costs 2 Wood instead of 5.',
        descriptionEs: 'Calentar edificios en invierno cuesta 2 de madera en lugar de 5.',
        descriptionDe: 'Das Beheizen von Gebäuden im Winter kostet 2 Holz statt 5.',
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
        titleEs: 'Logística de Yurtas',
        titleDe: 'Jurten-Logistik',
        descriptionTr: 'İşçi taşıma kapasitesini ve hızını +%50 artırır.',
        descriptionEn: 'Increases worker carry capacity and speed by +50%.',
        descriptionEs: 'Aumenta la capacidad de carga y velocidad de los trabajadores un +50%.',
        descriptionDe: 'Erhöht die Tragekapazität und Geschwindigkeit der Arbeiter um +50%.',
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
        titleEs: 'Privilegio de la Ruta de la Seda',
        titleDe: 'Seidenstraßen-Privileg',
        descriptionTr: 'Pazar ve Çöl komşuluğundaki tüm yapılara +%35 gelir.',
        descriptionEn: '+35% revenue to all buildings adjacent to Market and Desert.',
        descriptionEs: '+35% de ingresos para edificios adyacentes al Mercado o Desierto.',
        descriptionDe: '+35% Ertrag für alle Gebäude neben Markt oder Wüste.',
        slotType: DoctrineSlotType.wildcard,
        effectType: DoctrineEffectType.desertTradeBonus,
        effectValue: 0.35,
        unlockCastleLevel: 12,
        costCrowns: 3,
      ),
      DoctrineCardModel(
        id: 'doc_kut_inanci',
        titleTr: 'Kut İnancı',
        titleEn: 'Sacred Kut Faith',
        titleEs: 'Fe Sagrada Kut',
        titleDe: 'Heiliger Kut-Glaube',
        descriptionTr: 'Kutlu Tapınak kutsamalarını ve Tamga çarpanını +%30 güçlendirir.',
        descriptionEn: 'Boosts sacred shrine blessings and Tamga multiplier by +30%.',
        descriptionEs: 'Potencia las bendiciones de altares y multiplicadores Tamga un +30%.',
        descriptionDe: 'Verstärkt Heiligtum-Segen und Tamga-Multiplikatoren um +30%.',
        slotType: DoctrineSlotType.wildcard,
        effectType: DoctrineEffectType.tamgaAndShrineBonus,
        effectValue: 0.30,
        unlockCastleLevel: 12,
        costCrowns: 3,
      ),
    ];
  }
}
