import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import 'general_utils.dart';

SetDto heaviestSetPerLog({required ExerciseLogDto exerciseLog}) {
  SetDto heaviestSet = const SetDto(0, 0, false);
  double heaviestVolume = heaviestSet.value1.toDouble() * heaviestSet.value2.toInt();

  for (SetDto set in exerciseLog.sets) {
    final volume = set.value1.toDouble() * set.value2.toInt();
    if (volume > heaviestVolume) {
      heaviestSet = set;
      heaviestVolume = volume;
    }
  }
  return heaviestSet;
}

double oneRepMaxPerLog({required ExerciseLogDto exerciseLog}) {
  final heaviestSet = heaviestSetPerLog(exerciseLog: exerciseLog);

  final max = (heaviestSet.value1 * (1 + 0.0333 * heaviestSet.value2));

  final maxWeight = isDefaultWeightUnit() ? max : toLbs(max);

  return maxWeight;
}