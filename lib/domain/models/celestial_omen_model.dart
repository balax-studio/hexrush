import 'package:flutter/foundation.dart';

enum CelestialAnimal {
  rat, // Sıçan Yılı (Akıl ve Stok)
  ox, // Sığır Yılı (Bereket ve Dayanıklılık)
  tiger, // Pars Yılı (Cesaret ve Kereste)
  rabbit, // Tavşan Yılı (Hız ve Nüfus)
  dragon, // Ejder Yılı (Mistik Kristal ve Maden)
  snake, // Yılan Yılı (Gizem ve Şifa)
  horse, // At Yılı (Bozkır Rüzgarı ve Kervan Hızı)
  sheep, // Koyun Yılı (Huzur ve Yün)
  monkey, // Maymun Yılı (Zanaat ve Alet)
  rooster, // Tavuk Yılı (Güneş ve Hasat)
  dog, // Köpek Yılı (Sadakat ve Koruma)
  pig, // Domuz Yılı (Toprak ve Bolluk)
}

@immutable
class CelestialOmen {
  final CelestialAnimal animal;
  final String title;
  final String description;
  final double woodMultiplier;
  final double meatMultiplier;
  final double goldMultiplier;
  final double ironMultiplier;
  final double workerSpeedMultiplier;
  final double migrationDiscount;

  const CelestialOmen({
    required this.animal,
    required this.title,
    required this.description,
    this.woodMultiplier = 1.0,
    this.meatMultiplier = 1.0,
    this.goldMultiplier = 1.0,
    this.ironMultiplier = 1.0,
    this.workerSpeedMultiplier = 1.0,
    this.migrationDiscount = 0.0,
  });

  String get name => title;

  static CelestialOmen fromYearIndex(int yearIndex) => getOmenForYear(yearIndex);

  static CelestialOmen getOmenForYear(int yearIndex) {
    final animal = CelestialAnimal.values[yearIndex.abs() % CelestialAnimal.values.length];
    switch (animal) {
      case CelestialAnimal.tiger:
        return const CelestialOmen(
          animal: CelestialAnimal.tiger,
          title: 'Pars Yılı',
          description: 'Ormanlar coşar, kereste üretimi 2 katına çıkar.',
          woodMultiplier: 2.0,
        );
      case CelestialAnimal.horse:
        return const CelestialOmen(
          animal: CelestialAnimal.horse,
          title: 'At Yılı',
          description: 'Bozkır kervanları ve toplayıcılar %50 daha hızlı hareket eder.',
          workerSpeedMultiplier: 1.5,
          meatMultiplier: 1.25,
        );
      case CelestialAnimal.dragon:
        return const CelestialOmen(
          animal: CelestialAnimal.dragon,
          title: 'Ejder Yılı',
          description: 'Madenler ve volkanik ocaklar zengin filiz döker.',
          ironMultiplier: 1.8,
          goldMultiplier: 1.5,
        );
      case CelestialAnimal.sheep:
        return const CelestialOmen(
          animal: CelestialAnimal.sheep,
          title: 'Koyun Yılı',
          description: 'Çayırlar sakinleşir, yün ve süt bereketi artar.',
          meatMultiplier: 1.6,
        );
      case CelestialAnimal.ox:
        return const CelestialOmen(
          animal: CelestialAnimal.ox,
          title: 'Sığır Yılı',
          description: 'Toprak ağır ve dayanıklıdır; zud soğuğuna karşı direnç sağlar.',
          woodMultiplier: 1.3,
          ironMultiplier: 1.3,
        );
      case CelestialAnimal.snake:
        return const CelestialOmen(
          animal: CelestialAnimal.snake,
          title: 'Yılan Yılı',
          description: 'Şifacılar ve simyacılar kadim iksirler üretir.',
          goldMultiplier: 1.6,
        );
      case CelestialAnimal.rabbit:
        return const CelestialOmen(
          animal: CelestialAnimal.rabbit,
          title: 'Tavşan Yılı',
          description: 'Hızlı yerleşim; büyük göç maliyetleri %25 düşer.',
          migrationDiscount: 0.25,
          workerSpeedMultiplier: 1.2,
        );
      case CelestialAnimal.rat:
        return const CelestialOmen(
          animal: CelestialAnimal.rat,
          title: 'Sıçan Yılı',
          description: 'Ambarlar bereketle dolar, tahıl ve un verimi artar.',
          meatMultiplier: 1.4,
          woodMultiplier: 1.2,
        );
      case CelestialAnimal.monkey:
        return const CelestialOmen(
          animal: CelestialAnimal.monkey,
          title: 'Maymun Yılı',
          description: 'Zanaatkarlar mobilya ve yapı malzemelerini hızla işler.',
          woodMultiplier: 1.5,
          ironMultiplier: 1.4,
        );
      case CelestialAnimal.rooster:
        return const CelestialOmen(
          animal: CelestialAnimal.rooster,
          title: 'Tavuk Yılı',
          description: 'Güneş erken doğar, altın ve ticaret verimi yükselir.',
          goldMultiplier: 1.7,
        );
      case CelestialAnimal.dog:
        return const CelestialOmen(
          animal: CelestialAnimal.dog,
          title: 'Köpek Yılı',
          description: 'Oba koruma altındadır; işçiler yorulmadan çalışır.',
          workerSpeedMultiplier: 1.3,
        );
      case CelestialAnimal.pig:
        return const CelestialOmen(
          animal: CelestialAnimal.pig,
          title: 'Domuz Yılı',
          description: 'Kara toprak cömerttir, tüm temel kaynaklar dengeli artar.',
          woodMultiplier: 1.25,
          meatMultiplier: 1.25,
          goldMultiplier: 1.25,
          ironMultiplier: 1.25,
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'animal': animal.name,
      'title': title,
      'description': description,
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

    return CelestialOmen(
      animal: matchedAnimal,
      title: json['title'] as String? ?? 'At Yılı',
      description: json['description'] as String? ?? '',
      woodMultiplier: (json['wood_multiplier'] as num?)?.toDouble() ?? 1.0,
      meatMultiplier: (json['meat_multiplier'] as num?)?.toDouble() ?? 1.0,
      goldMultiplier: (json['gold_multiplier'] as num?)?.toDouble() ?? 1.0,
      ironMultiplier: (json['iron_multiplier'] as num?)?.toDouble() ?? 1.0,
      workerSpeedMultiplier: (json['worker_speed_multiplier'] as num?)?.toDouble() ?? 1.0,
      migrationDiscount: (json['migration_discount'] as num?)?.toDouble() ?? 0.0,
    );
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
