import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/challenges/challenge_template.dart';

class WeightChallengeDto extends ChallengeTemplate {
  final DateTime startDate;
  DateTime? endDate;
  final bool isCompleted;
  final ExerciseDto? exerciseDto;

  WeightChallengeDto(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required this.exerciseDto,
      required this.startDate,
      this.endDate,
      required this.isCompleted,
      required super.type});
}
