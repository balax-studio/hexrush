class TimedProductionBuff {
  final double multiplier;
  final double remainingSeconds;

  const TimedProductionBuff({
    required this.multiplier,
    required this.remainingSeconds,
  });

  TimedProductionBuff copyWith({double? remainingSeconds}) {
    return TimedProductionBuff(
      multiplier: multiplier,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'multiplier': multiplier,
    'remaining_seconds': remainingSeconds,
  };

  factory TimedProductionBuff.fromJson(Map<String, dynamic> json) {
    return TimedProductionBuff(
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      remainingSeconds: (json['remaining_seconds'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
