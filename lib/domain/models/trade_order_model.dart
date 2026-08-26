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

  const TradeOrderModel({
    required this.id,
    required this.title,
    required this.requesterName,
    required this.requiredResources,
    required this.rewardCrowns,
    this.rewardSpeedMultiplier = 1.25,
    this.buffDurationSeconds = 600, // 10 dakika
    this.isFulfilled = false,
    required this.createdAt,
  });

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
      rewardCrowns: json['rewardCrowns'] as int? ?? 5,
      rewardSpeedMultiplier: (json['rewardSpeedMultiplier'] as num?)?.toDouble() ?? 1.25,
      buffDurationSeconds: json['buffDurationSeconds'] as int? ?? 600,
      isFulfilled: json['isFulfilled'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
