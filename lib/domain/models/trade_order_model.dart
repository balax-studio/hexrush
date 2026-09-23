import 'dart:math' as math;

class TradeOrderModel {
  final String id;
  final String title;
  final String requesterName;
  final Map<String, double> requiredResources;
  final int rewardCrowns;
  final double rewardSpeedMultiplier;
  final int buffDurationSeconds;
  final bool isFulfilled;
  final String createdAt;
  final int unlockTimestamp; // Kilidin kalkacağı epoch milisaniyesi (30 dk bekleme)
  final int slotIndex;
  final int dailyCycleIndex; // O günkü kaçıncı başarılan sipariş katı (her biri 10x maliyet)

  const TradeOrderModel({
    required this.id,
    required this.title,
    required this.requesterName,
    required this.requiredResources,
    this.rewardCrowns = 0,
    this.rewardSpeedMultiplier = 1.35,
    this.buffDurationSeconds = 1800, // 30 dakika (3x artırılmış)
    this.isFulfilled = false,
    required this.createdAt,
    this.unlockTimestamp = 0,
    this.slotIndex = 0,
    this.dailyCycleIndex = 0,
  });

  bool isLocked([int? currentNowMs]) {
    final now = currentNowMs ?? DateTime.now().millisecondsSinceEpoch;
    return isFulfilled && unlockTimestamp > now;
  }

  int getRemainingSeconds([int? currentNowMs]) {
    if (!isFulfilled || unlockTimestamp <= 0) return 0;
    final now = currentNowMs ?? DateTime.now().millisecondsSinceEpoch;
    return math.max(0, (unlockTimestamp - now) ~/ 1000);
  }

  TradeOrderModel copyWith({
    String? id,
    String? title,
    String? requesterName,
    Map<String, double>? requiredResources,
    int? rewardCrowns,
    double? rewardSpeedMultiplier,
    int? buffDurationSeconds,
    bool? isFulfilled,
    String? createdAt,
    int? unlockTimestamp,
    int? slotIndex,
    int? dailyCycleIndex,
  }) {
    return TradeOrderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      requesterName: requesterName ?? this.requesterName,
      requiredResources: requiredResources ?? this.requiredResources,
      rewardCrowns: rewardCrowns ?? this.rewardCrowns,
      rewardSpeedMultiplier: rewardSpeedMultiplier ?? this.rewardSpeedMultiplier,
      buffDurationSeconds: buffDurationSeconds ?? this.buffDurationSeconds,
      isFulfilled: isFulfilled ?? this.isFulfilled,
      createdAt: createdAt ?? this.createdAt,
      unlockTimestamp: unlockTimestamp ?? this.unlockTimestamp,
      slotIndex: slotIndex ?? this.slotIndex,
      dailyCycleIndex: dailyCycleIndex ?? this.dailyCycleIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'requesterName': requesterName,
      'requiredResources': requiredResources,
      'rewardCrowns': rewardCrowns,
      'rewardSpeedMultiplier': rewardSpeedMultiplier,
      'buffDurationSeconds': buffDurationSeconds,
      'isFulfilled': isFulfilled,
      'createdAt': createdAt,
      'unlockTimestamp': unlockTimestamp,
      'slotIndex': slotIndex,
      'dailyCycleIndex': dailyCycleIndex,
    };
  }

  factory TradeOrderModel.fromJson(Map<String, dynamic> json) {
    return TradeOrderModel(
      id: json['id'] as String? ?? 'order_default',
      title: json['title'] as String? ?? 'İpek Yolu Kervan Siparişi',
      requesterName: json['requesterName'] as String? ?? 'Soğd Tüccarı',
      requiredResources: (json['requiredResources'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      rewardCrowns: json['rewardCrowns'] as int? ?? 0,
      rewardSpeedMultiplier: (json['rewardSpeedMultiplier'] as num?)?.toDouble() ?? 1.35,
      buffDurationSeconds: json['buffDurationSeconds'] as int? ?? 1800,
      isFulfilled: json['isFulfilled'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      unlockTimestamp: json['unlockTimestamp'] as int? ?? 0,
      slotIndex: json['slotIndex'] as int? ?? 0,
      dailyCycleIndex: json['dailyCycleIndex'] as int? ?? 0,
    );
  }
}
