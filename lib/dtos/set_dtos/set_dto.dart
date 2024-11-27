
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';

import '../../enums/exercise_type_enums.dart';
import 'duration_set_dto.dart';

abstract class SetDto {
  final bool _isChecked;

  const SetDto({required bool checked}) : _isChecked = checked;

  bool get checked => _isChecked;

  ExerciseType get type;

  bool isEmpty();

  bool isNotEmpty();

  SetDto copyWith({bool? checked});

  String summary();

  Map<String, dynamic> toJson() {
    if (this is WeightAndRepsSetDto) {
      final weightAndRepSet = this as WeightAndRepsSetDto;
      return {"value1": weightAndRepSet.weight, "value2": weightAndRepSet.reps, "checked": checked};
    } else if (this is RepsSetDto) {
      final repSet = this as RepsSetDto;
      return {"value1": 0, "value2": repSet.reps, "checked": checked};
    }
    final durationSet = this as DurationSetDto;
    return {"value1": 0, "value2": durationSet.duration.inMilliseconds, "checked": checked};
  }

  factory SetDto.fromJson(Map<String, dynamic> json, {required ExerciseType exerciseType}) {
    final value1 = json["value1"] as num;
    final value2 = json["value2"] as num;
    final checked = json["checked"] as bool;
    return switch (exerciseType) {
      ExerciseType.weights => WeightAndRepsSetDto(weight: value1.toDouble(), reps: value2.toInt(), checked: checked),
      ExerciseType.bodyWeight => RepsSetDto(reps: value2, checked: checked),
      ExerciseType.duration => DurationSetDto(duration: Duration(milliseconds: value2.toInt()), checked: checked),
    };
  }

  factory SetDto.newType({required ExerciseType type}) {
    return switch (type) {
      ExerciseType.weights => WeightAndRepsSetDto(weight: 0, reps: 0, checked: false),
      ExerciseType.bodyWeight => RepsSetDto(reps: 0, checked: false),
      ExerciseType.duration => DurationSetDto(duration: Duration.zero, checked: false),
    };
  }
}