import 'dart:convert';

import 'package:tracker_app/dtos/reps_set_dto.dart';
import 'package:tracker_app/dtos/weight_and_reps_set_dto.dart';

import '../enums/exercise/exercise_metrics_enums.dart';
import 'duration_set_dto.dart';

abstract class SetDTO {
  final bool _isChecked;

  const SetDTO({required bool checked}) : _isChecked = checked;

  bool get checked => _isChecked;

  bool isEmpty();

  bool isNotEmpty();

  SetDTO copyWith({bool? checked});

  String toJson() {
    if (this is WeightAndRepsSetDTO) {
      final weightAndRepSet = this as WeightAndRepsSetDTO;
      return jsonEncode({"value1": weightAndRepSet.weight, "value2": weightAndRepSet.reps, "checked": checked});
    } else if (this is RepsSetDTO) {
      final repSet = this as RepsSetDTO;
      return jsonEncode({"value1": 0, "value2": repSet.reps, "checked": checked});
    }
    final durationSet = this as DurationSetDTO;
    return jsonEncode({"value1": 0, "value2": durationSet.duration.inMilliseconds, "checked": checked});
  }

  factory SetDTO.fromJson(Map<String, dynamic> json, {required ExerciseMetric metric}) {
    final value1 = json["value1"] as num;
    final value2 = json["value2"] as num;
    final checked = json["checked"] as bool;
    return switch (metric) {
      ExerciseMetric.weights => WeightAndRepsSetDTO(weight: value1.toDouble(), reps: value2.toInt(), checked: checked),
      ExerciseMetric.reps => RepsSetDTO(reps: value2, checked: checked),
      ExerciseMetric.duration => DurationSetDTO(duration: Duration(milliseconds: value2.toInt()), checked: checked),
    };
  }

  factory SetDTO.newType({required ExerciseMetric metric}) {
    return switch (metric) {
      ExerciseMetric.weights => WeightAndRepsSetDTO(weight: 0, reps: 0, checked: false),
      ExerciseMetric.reps => RepsSetDTO(reps: 0, checked: false),
      ExerciseMetric.duration => DurationSetDTO(duration: Duration.zero, checked: false),
    };
  }

  factory SetDTO.set({required ExerciseMetric metric, required SetDTO set}) {
    return switch (metric) {
      ExerciseMetric.weights => set as WeightAndRepsSetDTO,
      ExerciseMetric.reps => set as RepsSetDTO,
      ExerciseMetric.duration => set as DurationSetDTO,
    };
  }
}
