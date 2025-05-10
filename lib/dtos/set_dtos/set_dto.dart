import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';

import '../../enums/exercise_type_enums.dart';
import 'duration_set_dto.dart';

abstract class SetDto {
  final bool _isChecked;
  final int _rpeRating;
  final bool _isWorkingSet;
  final DateTime _dateTime;

  const SetDto({bool checked = false, int rpeRating = 4, isWorkingSet = false, required dateTime})
      : _isChecked = checked,
        _rpeRating = rpeRating,
        _isWorkingSet = isWorkingSet,
        _dateTime = dateTime;

  bool get checked => _isChecked;

  int get rpeRating => _rpeRating;

  bool get isWorkingSet => _isWorkingSet;

  DateTime get dateTime => _dateTime;

  ExerciseType get type;

  bool isEmpty();

  bool isNotEmpty();

  SetDto copyWith({bool? checked, int? rpeRating});

  String summary();

  Map<String, dynamic> toJson() {
    if (this is WeightAndRepsSetDto) {
      final weightAndRepSet = this as WeightAndRepsSetDto;
      return {
        "value1": weightAndRepSet.weight,
        "value2": weightAndRepSet.reps,
        "checked": _isChecked,
        "rpeRating": rpeRating
      };
    } else if (this is RepsSetDto) {
      final repSet = this as RepsSetDto;
      return {"value1": 0, "value2": repSet.reps, "checked": _isChecked, "rpeRating": _rpeRating};
    } else {
      final durationSet = this as DurationSetDto;
      return {
        "value1": 0,
        "value2": durationSet.duration.inMilliseconds,
        "checked": _isChecked,
        "rpeRating": _rpeRating
      };
    }
  }

  factory SetDto.fromJson(Map<String, dynamic> json, {required ExerciseType exerciseType, required DateTime datetime}) {
    final value1 = json["value1"] as num;
    final value2 = json["value2"] as num;
    final checked = json["checked"] as bool;
    final rpeRating = json["rpeRating"] as int? ?? 5;
    return switch (exerciseType) {
      ExerciseType.weights =>
          WeightAndRepsSetDto(weight: value1.toDouble(), reps: value2.toInt(), checked: checked, rpeRating: rpeRating, dateTime: datetime),
      ExerciseType.bodyWeight => RepsSetDto(reps: value2.toInt(), checked: checked, rpeRating: rpeRating, dateTime: datetime),
      ExerciseType.duration =>
          DurationSetDto(duration: Duration(milliseconds: value2.toInt()), checked: checked, rpeRating: rpeRating, dateTime: datetime),
    };
  }

  factory SetDto.newType({required ExerciseType type}) {
    return switch (type) {
      ExerciseType.weights => WeightAndRepsSetDto.defaultSet(),
      ExerciseType.bodyWeight => RepsSetDto.defaultSet(),
      ExerciseType.duration => DurationSetDto.defaultSet(),
    };
  }
}
