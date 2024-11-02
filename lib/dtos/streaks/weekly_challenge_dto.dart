import 'package:tracker_app/dtos/streaks/challenge_template.dart';

class WeeklyChallengeDto extends ChallengeTemplate {
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;

  WeeklyChallengeDto(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required this.startDate,
      this.endDate,
      required this.isCompleted});
}
