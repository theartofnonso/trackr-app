
import '../../dtos/appsync/challenge_log_dto.dart';
import '../dtos/streaks/challenge_template.dart';

extension ChallengeTemplateExtension on ChallengeTemplate {

  ChallengeLogDto createChallenge({required DateTime startDate}) {
    return ChallengeLogDto(
        id: "",
        challengeId: id,
        name: name,
        caption: caption,
        description: description,
        rule: rule,
        target: 0,
        startDate: startDate,
        isCompleted: false);
  }
}
