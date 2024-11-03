import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/challengeTemplates/challenge_template.dart';

class WeightChallengeTemplate extends ChallengeTemplate {
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;
  final ExerciseDto? exercise;

  WeightChallengeTemplate(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required this.exercise,
      required this.startDate,
      this.endDate,
      required this.isCompleted,
      required super.type});
}
