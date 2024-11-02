import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../../dtos/appsync/challenge_log_dto.dart';

extension ChallengeLogExtension on ChallengeLog {
  ChallengeLogDto dto() {
    final dataJson = jsonDecode(data);
    final challengeId = dataJson["challengeId"] ?? "";
    final name = dataJson["name"] ?? "";
    final caption = dataJson["caption"] ?? "";
    final description = dataJson["description"] ?? "";
    final rule = dataJson["rule"] ?? "";
    final target = dataJson["target"] ?? 0;
    final startDate = DateTime.parse(dataJson["startDate"]);
    final endDate = DateTime.parse(dataJson["endDate"]);
    final isCompleted = dataJson["isCompleted"] ?? false;

    return ChallengeLogDto(
        id: id,
        challengeId: challengeId,
        name: name,
        caption: caption,
        description: description,
        rule: rule,
        target: target,
        startDate: startDate,
        endDate: endDate,
        isCompleted: isCompleted);
  }
}
