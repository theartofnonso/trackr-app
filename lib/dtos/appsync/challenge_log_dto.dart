import '../../enums/challenge_type_enums.dart';

class ChallengeLogDto {
  final String id;
  final String templateId;
  final String name;
  final String caption;
  final String description;
  final String rule;
  int progress = 0;
  final DateTime startDate;
  DateTime? endDate;
  bool isCompleted;
  final ChallengeType type;

  ChallengeLogDto(
      {required this.id,
      required this.name,
      required this.templateId,
      required this.caption,
      required this.description,
      required this.rule,
      this.progress = 1,
      required this.startDate,
      this.endDate,
      this.isCompleted = false,
      required this.type});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'name': name,
      'caption': caption,
      'description': description,
      'rule': rule,
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'type': type.name,
    };
  }

  ChallengeLogDto copyWith({
    String? id,
    String? templateId,
    String? name,
    String? caption,
    String? description,
    String? rule,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    ChallengeType? type,
  }) {
    return ChallengeLogDto(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        name: name ?? this.name,
        caption: caption ?? this.caption,
        description: description ?? this.caption,
        rule: rule ?? this.rule,
        progress: progress ?? this.progress,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.startDate,
        isCompleted: isCompleted ?? this.isCompleted,
        type: type ?? this.type);
  }

  @override
  String toString() {
    return 'ChallengeLogDto{id: $id, templateId: $templateId, name: $name, caption: $caption, description: $description, rule: $rule, progress: $progress, startDate: $startDate, endDate: $endDate, isCompleted: $isCompleted, type: $type}';
  }
}
