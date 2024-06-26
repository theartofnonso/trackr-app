import 'package:tracker_app/dtos/progress_dto.dart';
import 'package:tracker_app/enums/achievement_type_enums.dart';

class AchievementDto {
  final AchievementType type;
  final ProgressDto progress;

  AchievementDto({required this.type, required this.progress});

  @override
  String toString() {
    return 'AchievementDto{type: $type, progress: $progress}';
  }
}
