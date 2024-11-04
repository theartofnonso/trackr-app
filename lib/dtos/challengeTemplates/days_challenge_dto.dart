import 'milestone_dto.dart';

class DaysChallengeTemplate extends Milestone {
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;

  DaysChallengeTemplate(
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
