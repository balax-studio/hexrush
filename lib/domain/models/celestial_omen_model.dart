import 'package:flutter/foundation.dart';

enum CelestialAnimal {
  rat, // Sıçan Yılı
  ox, // Sığır Yılı
  tiger, // Pars Yılı
  rabbit, // Tavşan Yılı
  dragon, // Ejder Yılı
  snake, // Yılan Yılı
  horse, // At Yılı
  sheep, // Koyun Yılı
  monkey, // Maymun Yılı
  rooster, // Tavuk Yılı
  dog, // Köpek Yılı
  pig, // Domuz Yılı
}

@immutable
class CelestialOmen {
  final CelestialAnimal animal;
  final String titleTr;
  final String titleEn;
  final String titleEs;
  final String titleDe;
  final String descriptionTr;
  final String descriptionEn;
  final String descriptionEs;
  final String descriptionDe;
  final double woodMultiplier;
  final double meatMultiplier;
  final double goldMultiplier;
  final double ironMultiplier;
  final double workerSpeedMultiplier;
  final double migrationDiscount;

  const CelestialOmen({
    required this.animal,
    String? title,
    String? description,
    String? titleTr,
    String? titleEn,
    this.titleEs = '',
    this.titleDe = '',
    String? descriptionTr,
    String? descriptionEn,
    this.descriptionEs = '',
    this.descriptionDe = '',
    this.woodMultiplier = 1.0,
    this.meatMultiplier = 1.0,
    this.goldMultiplier = 1.0,
    this.ironMultiplier = 1.0,
    this.workerSpeedMultiplier = 1.0,
    this.migrationDiscount = 0.0,
  })  : titleTr = titleTr ?? title ?? 'At Yılı',
        titleEn = titleEn ?? title ?? 'Year of the Horse',
        descriptionTr = descriptionTr ?? description ?? 'Bozkır kervanları ve toplayıcılar %50 daha hızlı hareket eder.',
        descriptionEn = descriptionEn ?? description ?? 'Steppe caravans and foragers move 50% faster.';

  String get title => titleTr;
  String get description => descriptionTr;
  String get name => titleTr;

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

  static CelestialOmen fromYearIndex(int yearIndex) => getOmenForYear(yearIndex);

  Map<String, dynamic> toJson() {
    return {
      'animal': animal.name,
      'title': titleTr,
      'description': descriptionTr,
      'wood_multiplier': woodMultiplier,
      'meat_multiplier': meatMultiplier,
      'gold_multiplier': goldMultiplier,
      'iron_multiplier': ironMultiplier,
      'worker_speed_multiplier': workerSpeedMultiplier,
      'migration_discount': migrationDiscount,
    };
  }

  factory CelestialOmen.fromJson(Map<String, dynamic> json) {
    final animalName = json['animal'] as String? ?? 'horse';
    final matchedAnimal = CelestialAnimal.values.firstWhere(
      (a) => a.name == animalName,
      orElse: () => CelestialAnimal.horse,
    );
    return getOmenForYear(matchedAnimal.index);
  }

  static CelestialOmen getOmenForYear(int yearIndex) {
    final animal = CelestialAnimal.values[yearIndex.abs() % CelestialAnimal.values.length];
    switch (animal) {
      case CelestialAnimal.rat:
        return const CelestialOmen(
          animal: CelestialAnimal.rat,
          titleTr: 'Sıçan Yılı',
          titleEn: 'Year of the Rat',
          titleEs: 'Año de la Rata',
          titleDe: 'Jahr der Ratte',
          descriptionTr: 'Ambar stokları korunur, ekmek ve un verimi +%30 artar.',
          descriptionEn: 'Storehouses thrive; grain and bread yield +30%.',
          descriptionEs: 'Los almacenes prosperan; rendimiento de grano y pan +30%.',
          descriptionDe: 'Lagerhäuser gedeihen; Getreide- und Brotertrag +30%.',
          meatMultiplier: 1.4,
          woodMultiplier: 1.2,
        );
      case CelestialAnimal.ox:
        return const CelestialOmen(
          animal: CelestialAnimal.ox,
          titleTr: 'Sığır Yılı',
          titleEn: 'Year of the Ox',
          titleEs: 'Año del Buey',
          titleDe: 'Jahr des Büffels',
          descriptionTr: 'Toprak ağır ve dayanıklıdır; zud soğuğuna karşı direnç sağlar.',
          descriptionEn: 'Soil is resilient and provides resistance to Zud frost.',
          descriptionEs: 'El suelo es resistente y brinda protección contra el frío.',
          descriptionDe: 'Der Boden ist widerstandsfähig gegen Zud-Frost.',
          woodMultiplier: 1.3,
          ironMultiplier: 1.3,
        );
      case CelestialAnimal.tiger:
        return const CelestialOmen(
          animal: CelestialAnimal.tiger,
          titleTr: 'Pars Yılı',
          titleEn: 'Year of the Tiger',
          titleEs: 'Año del Tigre',
          titleDe: 'Jahr des Tigers',
          descriptionTr: 'Ormanlar coşar, kereste üretimi 2 katına çıkar.',
          descriptionEn: 'Forests surge; lumber yield doubles (2.0x).',
          descriptionEs: 'Los bosques prosperan; la producción de madera se duplica.',
          descriptionDe: 'Wälder sprießen; Bauholzertrag verdoppelt sich.',
          woodMultiplier: 2.0,
        );
      case CelestialAnimal.rabbit:
        return const CelestialOmen(
          animal: CelestialAnimal.rabbit,
          titleTr: 'Tavşan Yılı',
          titleEn: 'Year of the Rabbit',
          titleEs: 'Año del Conejo',
          titleDe: 'Jahr des Hasen',
          descriptionTr: 'Hızlı yerleşim; büyük göç maliyetleri %25 düşer.',
          descriptionEn: 'Swift settlement; migration costs reduced by 25%.',
          descriptionEs: 'Asentamiento rápido; los costes de migración se reducen un 25%.',
          descriptionDe: 'Schnelle Besiedlung; Migrationskosten um 25% reduziert.',
          migrationDiscount: 0.25,
          workerSpeedMultiplier: 1.2,
        );
      case CelestialAnimal.dragon:
        return const CelestialOmen(
          animal: CelestialAnimal.dragon,
          titleTr: 'Ejder Yılı',
          titleEn: 'Year of the Dragon',
          titleEs: 'Año del Dragón',
          titleDe: 'Jahr des Drachen',
          descriptionTr: 'Madenler ve volkanik ocaklar zengin filiz döker.',
          descriptionEn: 'Mines and volcanic forges yield rich ore deposits.',
          descriptionEs: 'Las minas y forjas volcánicas rinden ricos yacimientos.',
          descriptionDe: 'Minen und Vulkanschmieden liefern ergiebige Erze.',
          ironMultiplier: 1.8,
          goldMultiplier: 1.5,
        );
      case CelestialAnimal.snake:
        return const CelestialOmen(
          animal: CelestialAnimal.snake,
          titleTr: 'Yılan Yılı',
          titleEn: 'Year of the Snake',
          titleEs: 'Año de la Serpiente',
          titleDe: 'Jahr der Schlange',
          descriptionTr: 'Şifacılar ve simyacılar kadim iksirler üretir.',
          descriptionEn: 'Healers and alchemists brew ancient remedies.',
          descriptionEs: 'Sanadores y alquimistas elaboran remedios antiguos.',
          descriptionDe: 'Heiler und Alchemisten brauen alte Heilmittel.',
          goldMultiplier: 1.6,
        );
      case CelestialAnimal.horse:
        return const CelestialOmen(
          animal: CelestialAnimal.horse,
          titleTr: 'At Yılı',
          titleEn: 'Year of the Horse',
          titleEs: 'Año del Caballo',
          titleDe: 'Jahr des Pferdes',
          descriptionTr: 'Bozkır kervanları ve toplayıcılar %50 daha hızlı hareket eder.',
          descriptionEn: 'Steppe caravans and foragers move 50% faster.',
          descriptionEs: 'Caravanas y recolectores se mueven un 50% más rápido.',
          descriptionDe: 'Steppenkarawanen und Sammler bewegen sich 50% schneller.',
          workerSpeedMultiplier: 1.5,
          meatMultiplier: 1.25,
        );
      case CelestialAnimal.sheep:
        return const CelestialOmen(
          animal: CelestialAnimal.sheep,
          titleTr: 'Koyun Yılı',
          titleEn: 'Year of the Sheep',
          titleEs: 'Año de la Oveja',
          titleDe: 'Jahr des Schafes',
          descriptionTr: 'Çayırlar sakinleşir, yün ve süt bereketi artar.',
          descriptionEn: 'Pastures settle; wool and dairy fertility surge.',
          descriptionEs: 'Los pastos prosperan; aumentan la lana y lácteos.',
          descriptionDe: 'Weiden gedeihen; Wolle- und Milchertrag steigen.',
          meatMultiplier: 1.6,
        );
      case CelestialAnimal.monkey:
        return const CelestialOmen(
          animal: CelestialAnimal.monkey,
          titleTr: 'Maymun Yılı',
          titleEn: 'Year of the Monkey',
          titleEs: 'Año del Mono',
          titleDe: 'Jahr des Affen',
          descriptionTr: 'Zanaatkarlar mobilya ve yapı malzemelerini hızla işler.',
          descriptionEn: 'Craftsmen quickly process furniture and building materials.',
          descriptionEs: 'Artesanos procesan rápidamente muebles y materiales.',
          descriptionDe: 'Handwerker verarbeiten Möbel und Baumaterialien schnell.',
          woodMultiplier: 1.5,
          ironMultiplier: 1.4,
        );
      case CelestialAnimal.rooster:
        return const CelestialOmen(
          animal: CelestialAnimal.rooster,
          titleTr: 'Tavuk Yılı',
          titleEn: 'Year of the Rooster',
          titleEs: 'Año del Gallo',
          titleDe: 'Jahr des Hahns',
          descriptionTr: 'Güneş erken doğar, altın ve ticaret verimi yükselir.',
          descriptionEn: 'Sun rises early; gold and trade yields surge.',
          descriptionEs: 'El sol sale temprano; aumentan los rendimientos comerciales.',
          descriptionDe: 'Sonne geht früh auf; Gold- und Handelsertrag steigt.',
          goldMultiplier: 1.7,
        );
      case CelestialAnimal.dog:
        return const CelestialOmen(
          animal: CelestialAnimal.dog,
          titleTr: 'Köpek Yılı',
          titleEn: 'Year of the Dog',
          titleEs: 'Año del Perro',
          titleDe: 'Jahr des Hundes',
          descriptionTr: 'Oba koruma altındadır; işçiler yorulmadan çalışır.',
          descriptionEn: 'Realm is protected; workers labor tirelessly.',
          descriptionEs: 'El reino está protegido; los trabajadores laboran sin descanso.',
          descriptionDe: 'Das Reich ist geschützt; Arbeiter arbeiten unermüdlich.',
          workerSpeedMultiplier: 1.3,
        );
      case CelestialAnimal.pig:
        return const CelestialOmen(
          animal: CelestialAnimal.pig,
          titleTr: 'Domuz Yılı',
          titleEn: 'Year of the Boar',
          titleEs: 'Año del Jabalí',
          titleDe: 'Jahr des Wildschweins',
          descriptionTr: 'Kara toprak cömerttir, tüm temel kaynaklar dengeli artar.',
          descriptionEn: 'Dark soil is generous; all basic resources increase equally.',
          descriptionEs: 'La tierra oscura es generosa; los recursos aumentan por igual.',
          descriptionDe: 'Dunkle Erde ist großzügig; alle Grundressourcen steigen.',
          woodMultiplier: 1.25,
          meatMultiplier: 1.25,
          goldMultiplier: 1.25,
          ironMultiplier: 1.25,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CelestialOmen &&
          runtimeType == other.runtimeType &&
          animal == other.animal &&
          woodMultiplier == other.woodMultiplier &&
          meatMultiplier == other.meatMultiplier &&
          goldMultiplier == other.goldMultiplier &&
          ironMultiplier == other.ironMultiplier;

  @override
  int get hashCode => Object.hash(animal, woodMultiplier, meatMultiplier, goldMultiplier, ironMultiplier);
}
