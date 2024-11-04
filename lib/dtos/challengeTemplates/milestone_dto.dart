import '../../enums/milestone_type_enums.dart';

class Milestone {
  final String id;
  final String name;
  final String caption;
  final String description;
  final String rule;
  final int target;
  final MilestoneType type;

  Milestone({
    required this.id,
    required this.name,
    required this.caption,
    required this.description,
    required this.rule,
    required this.target,
    required this.type
  });
}