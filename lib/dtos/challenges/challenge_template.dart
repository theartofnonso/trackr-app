import '../../enums/challenge_type_enums.dart';

class ChallengeTemplate {
  final String id;
  final String name;
  final String caption;
  final String description;
  final String rule;
  final int target;
  final ChallengeType type;

  ChallengeTemplate({
    required this.id,
    required this.name,
    required this.caption,
    required this.description,
    required this.rule,
    required this.target,
    required this.type
  });
}