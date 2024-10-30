import 'package:tracker_app/dtos/streaks/challenge_template.dart';

class WeightChallengeDto extends ChallengeTemplate {
  WeightChallengeDto(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required super.startDate,
      required super.endDate,
      required super.isCompleted,
      required super.image});
}
