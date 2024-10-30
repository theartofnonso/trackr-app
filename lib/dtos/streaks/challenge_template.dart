class ChallengeTemplate {
  final String id;
  final String name;
  final String caption;
  final String description;
  final String rule;
  final int target;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final String image;

  ChallengeTemplate({
    required this.id,
    required this.name,
    required this.caption,
    required this.description,
    required this.rule,
    required this.target,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
    required this.image
  });
}