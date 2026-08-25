import 'building_model.dart';

enum QuestType {
  buildStructure,
  gatherResource,
  conquerTiles,
  upgradeCastle,
  discoverShrine,
}

enum QuestRewardType {
  food,
  wood,
  stone,
  crowns,
}

class QuestModel {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
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
    required this.descriptionTr,
    required this.descriptionEn,
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

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  QuestModel copyWith({
    String? id,
    String? titleTr,
    String? titleEn,
    String? descriptionTr,
    String? descriptionEn,
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
      descriptionTr: descriptionTr ?? this.descriptionTr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
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
        'descriptionTr': descriptionTr,
        'descriptionEn': descriptionEn,
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
      id: json['id'] as String,
      titleTr: json['titleTr'] as String,
      titleEn: json['titleEn'] as String,
      descriptionTr: json['descriptionTr'] as String,
      descriptionEn: json['descriptionEn'] as String,
      type: QuestType.values.byName(json['type'] as String),
      targetBuilding: json['targetBuilding'] != null
          ? BuildingType.values.byName(json['targetBuilding'] as String)
          : null,
      targetResource: json['targetResource'] as String?,
      targetAmount: (json['targetAmount'] as num).toInt(),
      currentAmount: (json['currentAmount'] as num?)?.toInt() ?? 0,
      rewardType: QuestRewardType.values.byName(json['rewardType'] as String),
      rewardAmount: (json['rewardAmount'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}
