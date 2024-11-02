import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../../dtos/appsync/challenge_log_dto.dart';

extension ChallengeLogExtension on ChallengeLog {
  ChallengeLogDto dto() {
    final json = jsonDecode(data);
    final challengeId = json["challengeId"] ?? "";
    final name = json["name"] ?? "";
    final caption = json["caption"] ?? "";
    final description = json["description"] ?? "";
    final rule = json["rule"] ?? "";
    final target = json["target"] ?? 0;
    final startDate = DateTime.parse(json["startDate"]);
    final endDate = json["endDate"] != null ? DateTime.parse(json["endDate"]) : null;
    final isCompleted = json["isCompleted"] ?? false;

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
