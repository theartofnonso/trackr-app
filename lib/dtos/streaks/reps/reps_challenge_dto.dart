import 'package:tracker_app/dtos/streaks/challenge_template.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

class RepsChallengeDto extends ChallengeTemplate {
  final MuscleGroup? muscleGroup;

  RepsChallengeDto(
      {required super.id,
      required super.name,
      required super.caption,
      this.muscleGroup,
      required super.description,
      required super.rule,
      required super.target,
      required super.startDate,
      required super.endDate,
      required super.isCompleted,
      required super.image});
}
