import '../../enums/challenge_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import 'exercise_dto.dart';

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
  final double weight;
  final MuscleGroup muscleGroup;
  final ExerciseDto? exercise;
  final ChallengeType type;

  ChallengeLogDto(
      {required this.id,
      required this.name,
      required this.templateId,
      required this.caption,
      required this.description,
      required this.rule,
      this.progress = 0,
      required this.startDate,
      this.endDate,
      this.isCompleted = false,
      this.weight = 0,
      required this.muscleGroup,
      required this.exercise,
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
      'weight': weight,
      'muscleGroup': muscleGroup.name,
      'exercise': exercise?.toJson(),
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
    double? weight,
    MuscleGroup? muscleGroup,
    ExerciseDto? exercise,
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
        weight: weight ?? this.weight,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        exercise: exercise ?? this.exercise,
        type: type ?? this.type);
  }

  @override
  String toString() {
    return 'ChallengeLogDto{id: $id, templateId: $templateId, name: $name, caption: $caption, description: $description, rule: $rule, progress: $progress, startDate: $startDate, endDate: $endDate, isCompleted: $isCompleted, weight: $weight, muscleGroup: $muscleGroup, exercise: $exercise, type: $type}';
  }
}
