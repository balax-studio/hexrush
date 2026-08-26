import 'package:flutter/foundation.dart';

/// Bozkır stratejisinde desteklenen etik ödüllü reklam türleri
enum AdRewardType {
  offlineProgressBoost, // Çevrimdışı Otağ kazancını 1.5x katlama
  marketQuotaReset, // Pazar takas kotasını sıfırlama
  caravanBonus, // Gezgin kervandan ekstra hammadde ikramı
  celestialBlessing, // Gök kehanetine 10 dakikalık +%25 kut çarpanı
  migrationLegacy, // Büyük Göç ile +1 ekstra kalıcı Tamga
}

@immutable
class AdRewardTracking {
  final Map<AdRewardType, int> dailyWatches;
  final Map<AdRewardType, DateTime> lastWatchTimes;
  final int totalAdsWatched;
  final DateTime lastResetDate;

  const AdRewardTracking({
    this.dailyWatches = const {
      AdRewardType.offlineProgressBoost: 0,
      AdRewardType.marketQuotaReset: 0,
      AdRewardType.caravanBonus: 0,
      AdRewardType.celestialBlessing: 0,
      AdRewardType.migrationLegacy: 0,
    },
    this.lastWatchTimes = const {},
    this.totalAdsWatched = 0,
    DateTime? lastResetDate,
  }) : lastResetDate = lastResetDate ?? const _DefaultEpoch();

  int getWatchCount(AdRewardType type) => dailyWatches[type] ?? 0;

  AdRewardTracking recordWatch(AdRewardType type, {DateTime? timestamp}) {
    final now = timestamp ?? DateTime.now();
    final updatedDaily = Map<AdRewardType, int>.from(dailyWatches);
    updatedDaily[type] = (updatedDaily[type] ?? 0) + 1;

    final updatedTimes = Map<AdRewardType, DateTime>.from(lastWatchTimes);
    updatedTimes[type] = now;

    return AdRewardTracking(
      dailyWatches: updatedDaily,
      lastWatchTimes: updatedTimes,
      totalAdsWatched: totalAdsWatched + 1,
      lastResetDate: lastResetDate,
    );
  }

  AdRewardTracking checkDailyReset({DateTime? currentDate}) {
    final now = currentDate ?? DateTime.now();
    final isDifferentDay = lastResetDate.year != now.year ||
        lastResetDate.month != now.month ||
        lastResetDate.day != now.day;

    if (isDifferentDay) {
      return AdRewardTracking(
        dailyWatches: {
          for (final type in AdRewardType.values) type: 0,
        },
        lastWatchTimes: lastWatchTimes,
        totalAdsWatched: totalAdsWatched,
        lastResetDate: now,
      );
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyWatches': dailyWatches.map((k, v) => MapEntry(k.name, v)),
      'lastWatchTimes': lastWatchTimes.map(
        (k, v) => MapEntry(k.name, v.toIso8601String()),
      ),
      'totalAdsWatched': totalAdsWatched,
      'lastResetDate': lastResetDate.toIso8601String(),
    };
  }

  factory AdRewardTracking.fromJson(Map<String, dynamic> json) {
    final rawWatches = json['dailyWatches'] as Map<String, dynamic>? ?? {};
    final dailyWatches = <AdRewardType, int>{};
    for (final type in AdRewardType.values) {
      dailyWatches[type] = (rawWatches[type.name] as num?)?.toInt() ?? 0;
    }

    final rawTimes = json['lastWatchTimes'] as Map<String, dynamic>? ?? {};
    final lastWatchTimes = <AdRewardType, DateTime>{};
    for (final entry in rawTimes.entries) {
      try {
        final type = AdRewardType.values.firstWhere((t) => t.name == entry.key);
        lastWatchTimes[type] = DateTime.parse(entry.value as String);
      } catch (_) {}
    }

    DateTime lastReset = DateTime.now();
    if (json['lastResetDate'] != null) {
      try {
        lastReset = DateTime.parse(json['lastResetDate'] as String);
      } catch (_) {}
    }

    return AdRewardTracking(
      dailyWatches: dailyWatches,
      lastWatchTimes: lastWatchTimes,
      totalAdsWatched: (json['totalAdsWatched'] as num?)?.toInt() ?? 0,
      lastResetDate: lastReset,
    );
  }
}

class _DefaultEpoch implements DateTime {
  const _DefaultEpoch();
  @override
  bool isAfter(DateTime other) => false;
  @override
  bool isBefore(DateTime other) => true;
  @override
  bool isAtSameMomentAs(DateTime other) => false;
  @override
  int compareTo(DateTime other) => -1;
  @override
  int get year => 2026;
  @override
  int get month => 1;
  @override
  int get day => 1;
  @override
  int get hour => 0;
  @override
  int get minute => 0;
  @override
  int get second => 0;
  @override
  int get millisecond => 0;
  @override
  int get microsecond => 0;
  @override
  String toIso8601String() => '2026-01-01T00:00:00.000';
  @override
  String toString() => toIso8601String();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
