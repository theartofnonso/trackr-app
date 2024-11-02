import '../../../dtos/appsync/challenge_log_dto.dart';
import '../../dtos/challengeTemplates/challenge_template.dart';

extension ChallengeTemplateExtension on ChallengeTemplate {
  ChallengeLogDto createChallenge({required DateTime startDate}) {
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
        type: type);
  }
}
