
import '../../dtos/appsync/challenge_log_dto.dart';
import '../dtos/streaks/challenge_template.dart';

extension ChallengeTemplateExtension on ChallengeTemplate {
  ChallengeLogDto copyAsChallengeLog() {
    return ChallengeLogDto(
        id: "",
        challengeId: id,
        name: name,
        caption: caption,
        description: description,
        rule: rule,
        target: target,
        startDate: startDate,
        endDate: endDate,
        isCompleted: isCompleted,
        image: image);
  }
}
