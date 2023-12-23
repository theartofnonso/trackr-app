import 'package:tracker_app/enums/achievement_type_enums.dart';

class AchievementDto {
  final AchievementType type;
  ({int progressRemainder, double progressValue}) progress;

  AchievementDto({required this.type, required this.progress});

}
