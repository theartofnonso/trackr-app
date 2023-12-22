import 'package:tracker_app/enums/achievement_type_enums.dart';

class AchievementDto {
  final AchievementType type;
  ({int difference, double progress}) progress;

  AchievementDto({required this.type, required this.progress});

}
