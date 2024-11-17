
import 'package:tracker_app/enums/muscle_group_enums.dart';

extension MuscleGroupExtension on MuscleGroup {
  String illustration() {
    return switch (this) {
      MuscleGroup.abductors => "abductors",
      MuscleGroup.adductors => "adductors",
      MuscleGroup.abs => "abs",
      MuscleGroup.back => "back",
      MuscleGroup.biceps => "biceps",
      MuscleGroup.calves => "calves",
      MuscleGroup.chest => "chest",
      MuscleGroup.shoulders => "frontshoulder",
      MuscleGroup.glutes => "glutes",
      MuscleGroup.hamstrings => "hamstrings",
      MuscleGroup.triceps => "triceps",
      MuscleGroup.quadriceps => "quadriceps",
    };
  }
}
