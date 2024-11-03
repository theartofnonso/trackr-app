import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../../dtos/appsync/challenge_log_dto.dart';
import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/challengeTemplates/challenge_template.dart';

extension ChallengeTemplateExtension on ChallengeTemplate {
  ChallengeLogDto createChallenge(
      {required DateTime startDate, required MuscleGroup muscleGroup, ExerciseDto? exercise, double weight = 0}) {
    return ChallengeLogDto(
        id: "",
        templateId: id,
        name: name,
        caption: caption,
        description: description,
        rule: rule,
        progress: 0,
        startDate: startDate,
        isCompleted: false,
        type: type,
        muscleGroup: muscleGroup,
        exercise: exercise,
        weight: weight);
  }
}
