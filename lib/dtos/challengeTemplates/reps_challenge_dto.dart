import 'package:tracker_app/dtos/challengeTemplates/challenge_template.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

class RepsChallengeTemplate extends ChallengeTemplate {
  final MuscleGroup muscleGroup;
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;

  RepsChallengeTemplate(
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
