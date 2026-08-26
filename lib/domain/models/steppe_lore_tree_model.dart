enum SteppeLoreBranch {
  logistics, // Akıncı Lojistiği & Kervanlar
  weatherCraft, // Keçe & Kışlık Isınma
  soilMastery, // Toprak Sırrı & Yaylak Nadası
  metallurgy, // Bozkır Dökümcülüğü & Şam Çeliği
}

class SteppeLoreNode {
  final String id;
  final SteppeLoreBranch branch;
  final int tier; // 1, 2, 3
  final String title;
  final String description;
  final double costWisdom;
  final double effectMultiplier;
  final bool isUnlocked;

  const SteppeLoreNode({
    required this.id,
    required this.branch,
    required this.tier,
    required this.title,
    required this.description,
    required this.costWisdom,
    required this.effectMultiplier,
    this.isUnlocked = false,
  });

  SteppeLoreNode copyWith({
    String? id,
    SteppeLoreBranch? branch,
    int? tier,
    String? title,
    String? description,
    double? costWisdom,
    double? effectMultiplier,
    bool? isUnlocked,
  }) {
    return SteppeLoreNode(
      id: id ?? this.id,
      branch: branch ?? this.branch,
      tier: tier ?? this.tier,
      title: title ?? this.title,
      description: description ?? this.description,
      costWisdom: costWisdom ?? this.costWisdom,
      effectMultiplier: effectMultiplier ?? this.effectMultiplier,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch': branch.name,
      'tier': tier,
      'title': title,
      'description': description,
      'costWisdom': costWisdom,
      'effectMultiplier': effectMultiplier,
      'isUnlocked': isUnlocked,
    };
  }

  factory SteppeLoreNode.fromJson(Map<String, dynamic> json) {
    return SteppeLoreNode(
      id: json['id'] as String,
      branch: SteppeLoreBranch.values.firstWhere(
        (b) => b.name == json['branch'],
        orElse: () => SteppeLoreBranch.logistics,
      ),
      tier: json['tier'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      costWisdom: (json['costWisdom'] as num?)?.toDouble() ?? 50.0,
      effectMultiplier: (json['effectMultiplier'] as num?)?.toDouble() ?? 1.25,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  static List<SteppeLoreNode> get defaultLoreTree => const [
        // 1. Akıncı Lojistiği (Logistics)
        SteppeLoreNode(
          id: 'lore_logistics_1',
          branch: SteppeLoreBranch.logistics,
          tier: 1,
          title: 'Çevik Atlı Posta',
          description: 'İşçi taşıma menzilini +1 Hex genişletir ve kervan hızını +%25 artırır.',
          costWisdom: 30.0,
          effectMultiplier: 1.25,
        ),
        SteppeLoreNode(
          id: 'lore_logistics_2',
          branch: SteppeLoreBranch.logistics,
          tier: 2,
          title: 'İpek Yolu Ağı',
          description: 'Kervan yollarının ticaret sinerjisini +%50 artırır.',
          costWisdom: 80.0,
          effectMultiplier: 1.50,
        ),
        SteppeLoreNode(
          id: 'lore_logistics_3',
          branch: SteppeLoreBranch.logistics,
          tier: 3,
          title: 'Kağanlık Kurye Teşkilatı',
          description: 'Tüm haritada işçi taşıma kapasitesini 2 katına çıkarır.',
          costWisdom: 200.0,
          effectMultiplier: 2.0,
        ),

        // 2. Keçe & Kışlık Isınma (WeatherCraft)
        SteppeLoreNode(
          id: 'lore_weather_1',
          branch: SteppeLoreBranch.weatherCraft,
          tier: 1,
          title: 'Kalın Keçe Dokuma',
          description: 'Kışın donan karoların ısıtma odun maliyetini %30 azaltır.',
          costWisdom: 30.0,
          effectMultiplier: 0.70,
        ),
        SteppeLoreNode(
          id: 'lore_weather_2',
          branch: SteppeLoreBranch.weatherCraft,
          tier: 2,
          title: 'Ocak Başı Ateşi',
          description: 'Isıtılan karoların kışın üretim çarpanını +%40 artırır.',
          costWisdom: 80.0,
          effectMultiplier: 1.40,
        ),
        SteppeLoreNode(
          id: 'lore_weather_3',
          branch: SteppeLoreBranch.weatherCraft,
          tier: 3,
          title: 'Zud Direnci',
          description: 'Zud fırtınasının negatif üretim cezasını yarı yarıya düşürür.',
          costWisdom: 200.0,
          effectMultiplier: 0.50,
        ),

        // 3. Toprak Sırrı & Yaylak Nadası (SoilMastery)
        SteppeLoreNode(
          id: 'lore_soil_1',
          branch: SteppeLoreBranch.soilMastery,
          tier: 1,
          title: 'Yaylak-Kışlak Göçü',
          description: 'Nadasa bırakılan çayırlarda toprak sağlığı yenilenme hızını 2x yapar.',
          costWisdom: 30.0,
          effectMultiplier: 2.0,
        ),
        SteppeLoreNode(
          id: 'lore_soil_2',
          branch: SteppeLoreBranch.soilMastery,
          tier: 2,
          title: 'Kutlu Tohum Islahı',
          description: 'Tüm tarla ve meyve bahçelerinde temel hasat verimini +%35 artırır.',
          costWisdom: 80.0,
          effectMultiplier: 1.35,
        ),
        SteppeLoreNode(
          id: 'lore_soil_3',
          branch: SteppeLoreBranch.soilMastery,
          tier: 3,
          title: 'Toprak Nefesi Patlaması',
          description: 'Dinlenmiş toprağın nefes patlaması (respiration burst) çarpanını 3 katına çıkarır.',
          costWisdom: 200.0,
          effectMultiplier: 3.0,
        ),

        // 4. Bozkır Dökümcülüğü & Şam Çeliği (Metallurgy)
        SteppeLoreNode(
          id: 'lore_metal_1',
          branch: SteppeLoreBranch.metallurgy,
          tier: 1,
          title: 'Körük Ocağı Islahı',
          description: 'Madenlerden cevher ve demir çıkarma hızını +%30 artırır.',
          costWisdom: 30.0,
          effectMultiplier: 1.30,
        ),
        SteppeLoreNode(
          id: 'lore_metal_2',
          branch: SteppeLoreBranch.metallurgy,
          tier: 2,
          title: 'Şam Çeliği Sırrı',
          description: 'Şam Çeliği dökümhanesi verimini +%50 artırır.',
          costWisdom: 80.0,
          effectMultiplier: 1.50,
        ),
        SteppeLoreNode(
          id: 'lore_metal_3',
          branch: SteppeLoreBranch.metallurgy,
          tier: 3,
          title: 'Mete Han Yay & Kılıçları',
          description: 'Tüm maden ve zanaat yapılarının küresel verimini 2 katına çıkarır.',
          costWisdom: 200.0,
          effectMultiplier: 2.0,
        ),
      ];
}
