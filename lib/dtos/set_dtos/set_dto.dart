import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';

import '../../enums/exercise_type_enums.dart';
import 'duration_set_dto.dart';

abstract class SetDto {
  final bool _isChecked;
  final bool _isWorkingSet;
  final DateTime _dateTime;

  const SetDto({bool checked = false, isWorkingSet = false, required dateTime})
      : _isChecked = checked,
        _isWorkingSet = isWorkingSet,
        _dateTime = dateTime;

  bool get checked => _isChecked;

  bool get isWorkingSet => _isWorkingSet;

  DateTime get dateTime => _dateTime;

  ExerciseType get type;

  bool isEmpty();

  bool isNotEmpty();

  SetDto copyWith({bool? checked});

  String summary();

  Map<String, dynamic> toJson() {
    // This method should be overridden by concrete implementations
    // to avoid type checking overhead
    throw UnimplementedError(
        'toJson must be implemented by concrete SetDto classes');
  }

  factory SetDto.fromJson(Map<String, dynamic> json,
      {required ExerciseType exerciseType, required DateTime datetime}) {
    final value1 = json["value1"] as num;
    final value2 = json["value2"] as num;
    final checked = json["checked"] as bool;
    return switch (exerciseType) {
      ExerciseType.weights => WeightAndRepsSetDto(
          weight: value1.toDouble(),
          reps: value2.toInt(),
          checked: checked,
          dateTime: datetime),
      ExerciseType.bodyWeight =>
        RepsSetDto(reps: value2.toInt(), checked: checked, dateTime: datetime),
      ExerciseType.duration => DurationSetDto(
          duration: Duration(milliseconds: value2.toInt()),
          checked: checked,
          dateTime: datetime),
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
