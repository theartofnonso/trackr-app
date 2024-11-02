import 'package:tracker_app/dtos/challenges/challenge_template.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

class RepsChallengeDto extends ChallengeTemplate {
  final MuscleGroup muscleGroup;
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;

  RepsChallengeDto(
      {required super.id,
      required super.name,
      required super.caption,
      this.muscleGroup = MuscleGroup.none,
      required super.description,
      required super.rule,
      required super.target,
      required this.startDate,
      this.endDate,
      required this.isCompleted,
      required super.type});
}
