import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';

import '../../enums/milestone_type_enums.dart';

abstract class Milestone {
  final String id;
  final String name;
  final String caption;
  final String description;
  final String rule;
  final int target;
  final (double, List<RoutineLogDto>) progress;
  final MilestoneType type;

  Milestone({
    required this.id,
    required this.name,
    required this.caption,
    required this.description,
    required this.rule,
    required this.target,
    required this.progress,
    required this.type
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Milestone && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}