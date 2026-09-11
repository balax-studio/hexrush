import 'building_model.dart';

enum QuestType {
  buildStructure,
  gatherResource,
  conquerTiles,
  upgradeCastle,
  discoverShrine,
  establishCaravan,
  unlockLore,
  surviveZud,
}

enum QuestRewardType {
  food,
  wood,
  stone,
  crowns,
  tamgas,
}

class QuestModel {
  final String id;
  final String titleTr;
  final String titleEn;
  final String titleEs;
  final String titleDe;
  final String descriptionTr;
  final String descriptionEn;
  final String descriptionEs;
  final String descriptionDe;
  final QuestType type;
  final BuildingType? targetBuilding;
  final String? targetResource;
  final int targetAmount;
  final int currentAmount;
  final QuestRewardType rewardType;
  final int rewardAmount;
  final bool isCompleted;
  final bool isClaimed;

  const QuestModel({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    this.titleEs = '',
    this.titleDe = '',
    required this.descriptionTr,
    required this.descriptionEn,
    this.descriptionEs = '',
    this.descriptionDe = '',
    required this.type,
    this.targetBuilding,
    this.targetResource,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.rewardType,
    required this.rewardAmount,
    this.isCompleted = false,
    this.isClaimed = false,
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

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  QuestModel copyWith({
    String? id,
    String? titleTr,
    String? titleEn,
    String? titleEs,
    String? titleDe,
    String? descriptionTr,
    String? descriptionEn,
    String? descriptionEs,
    String? descriptionDe,
    QuestType? type,
    BuildingType? targetBuilding,
    String? targetResource,
    int? targetAmount,
    int? currentAmount,
    QuestRewardType? rewardType,
    int? rewardAmount,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    final int newCurrent = currentAmount ?? this.currentAmount;
    final int newTarget = targetAmount ?? this.targetAmount;
    final bool autoCompleted = newCurrent >= newTarget;

    return QuestModel(
      id: id ?? this.id,
      titleTr: titleTr ?? this.titleTr,
      titleEn: titleEn ?? this.titleEn,
      titleEs: titleEs ?? this.titleEs,
      titleDe: titleDe ?? this.titleDe,
      descriptionTr: descriptionTr ?? this.descriptionTr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionDe: descriptionDe ?? this.descriptionDe,
      type: type ?? this.type,
      targetBuilding: targetBuilding ?? this.targetBuilding,
      targetResource: targetResource ?? this.targetResource,
      targetAmount: newTarget,
      currentAmount: newCurrent,
      rewardType: rewardType ?? this.rewardType,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      isCompleted: isCompleted ?? autoCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleTr': titleTr,
        'titleEn': titleEn,
        'titleEs': titleEs,
        'titleDe': titleDe,
        'descriptionTr': descriptionTr,
        'descriptionEn': descriptionEn,
        'descriptionEs': descriptionEs,
        'descriptionDe': descriptionDe,
        'type': type.name,
        'targetBuilding': targetBuilding?.name,
        'targetResource': targetResource,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'rewardType': rewardType.name,
        'rewardAmount': rewardAmount,
        'isCompleted': isCompleted,
        'isClaimed': isClaimed,
      };

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String? ?? 'quest_${DateTime.now().millisecondsSinceEpoch}',
      titleTr: json['titleTr'] as String? ?? 'Görev',
      titleEn: json['titleEn'] as String? ?? 'Quest',
      titleEs: json['titleEs'] as String? ?? '',
      titleDe: json['titleDe'] as String? ?? '',
      descriptionTr: json['descriptionTr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionEs: json['descriptionEs'] as String? ?? '',
      descriptionDe: json['descriptionDe'] as String? ?? '',
      type: QuestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestType.buildStructure,
      ),
      targetBuilding: json['targetBuilding'] != null
          ? BuildingType.values.firstWhere(
              (e) => e.name == json['targetBuilding'],
              orElse: () => BuildingType.corn,
            )
          : null,
      targetResource: json['targetResource'] as String?,
      targetAmount: (json['targetAmount'] as num?)?.toInt() ?? 1,
      currentAmount: (json['currentAmount'] as num?)?.toInt() ?? 0,
      rewardType: QuestRewardType.values.firstWhere(
        (e) => e.name == json['rewardType'],
        orElse: () => QuestRewardType.food,
      ),
      rewardAmount: (json['rewardAmount'] as num?)?.toInt() ?? 10,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}
