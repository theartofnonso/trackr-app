
class ChallengeLogDto {
  final String id;
  final String challengeId;
  final String name;
  final String caption;
  final String description;
  final String rule;
  final int target;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final String image;

  ChallengeLogDto(
      {required this.id,
      required this.name,
        required this.challengeId,
      required this.caption,
      required this.description,
      required this.rule,
      required this.target,
      required this.startDate,
      required this.endDate,
      required this.isCompleted,
      required this.image});

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
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
      'image': ''
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
    String? image,
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
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'ChallengeLogDto{id: $id, challengeId: $challengeId, name: $name, caption: $caption, description: $description, rule: $rule, target: $target, startDate: $startDate, endDate: $endDate, isCompleted: $isCompleted, image: $image}';
  }
}
