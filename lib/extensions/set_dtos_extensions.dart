import '../dtos/set_dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../utils/sets_utils.dart';

extension WorkingSetsX on List<SetDto> {
  List<SetDto> workingSets(ExerciseType t) {
    switch (t) {
      case ExerciseType.weights:   return markHighestWeightSets(this);
      case ExerciseType.bodyWeight:return markHighestRepsSets(this);
      case ExerciseType.duration:  return markHighestDurationSets(this);
    }
  }
}