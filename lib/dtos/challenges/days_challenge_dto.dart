import 'challenge_template.dart';

class DaysChallengeDto extends ChallengeTemplate {
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;

  DaysChallengeDto(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required this.startDate,
      this.endDate,
      required this.isCompleted,
      required super.type});
}
