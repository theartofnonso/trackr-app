import 'package:tracker_app/dtos/challengeTemplates/challenge_template.dart';

class WeeklyChallengeTemplate extends ChallengeTemplate {
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
