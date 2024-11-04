import 'package:tracker_app/dtos/challengeTemplates/milestone_dto.dart';

class WeeklyChallengeTemplate extends Milestone {
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;

  WeeklyChallengeTemplate(
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
