import '../../dtos/appsync/challenge_log_dto.dart';
import '../dtos/challenges/challenge_template.dart';

extension ChallengeTemplateExtension on ChallengeTemplate {
  ChallengeLogDto createChallenge({required DateTime startDate}) {
    return ChallengeLogDto(
        id: "",
        challengeId: id,
        name: name,
        caption: caption,
        description: description,
        rule: rule,
        progress: 0,
        startDate: startDate,
        isCompleted: false,
        type: type);
  }
}
