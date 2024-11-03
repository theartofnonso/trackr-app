
import 'package:tracker_app/enums/muscle_group_enums.dart';

extension MuscleGroupFamilyExtension on MuscleGroupFamily {
  String illustration() {
    return switch (this) {
      MuscleGroupFamily.core => "abs",
      MuscleGroupFamily.back => "back",
      MuscleGroupFamily.chest => "chest",
      MuscleGroupFamily.shoulders => "front_shoulder",
      MuscleGroupFamily.fullBody => "fullbody",
      MuscleGroupFamily.neck => "neck",
      _ => "",
    };
  }
}
