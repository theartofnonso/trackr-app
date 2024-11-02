class ChallengeLogDto {
  final String id;
  final String challengeId;
  final String name;
  final String caption;
  final String description;
  final String rule;
  int target = 1;
  final DateTime startDate;
  DateTime? endDate;
  bool isCompleted;

  ChallengeLogDto(
      {required this.id,
      required this.name,
      required this.challengeId,
      required this.caption,
      required this.description,
      required this.rule,
      this.target = 1,
      required this.startDate,
      this.endDate,
      this.isCompleted = false});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'name': name,
      'caption': caption,
      'description': description,
      'rule': rule,
      'target': target,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  ChallengeLogDto copyWith({
    String? id,
    String? challengeId,
    String? name,
    String? caption,
    String? description,
    String? rule,
    int? target,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
  }) {
    return ChallengeLogDto(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      name: name ?? this.name,
      caption: caption ?? this.caption,
      description: description ?? this.caption,
      rule: rule ?? this.rule,
      target: target ?? this.target,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.startDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'ChallengeLogDto{id: $id, challengeId: $challengeId, name: $name, caption: $caption, description: $description, rule: $rule, target: $target, startDate: $startDate, endDate: $endDate, isCompleted: $isCompleted}';
  }
}
