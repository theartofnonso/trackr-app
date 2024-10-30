import 'package:tracker_app/dtos/streaks/reps/reps_challenge_dto.dart';

class ArmsRepsChallengeDto extends RepsChallengeDto {
  ArmsRepsChallengeDto( {required super.id,
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