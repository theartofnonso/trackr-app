import 'package:tracker_app/dtos/sets_dtos/reps_set_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/weight_and_reps_set_dto.dart';

import '../../enums/exercise/set_type_enums.dart';
import 'duration_set_dto.dart';

abstract class SetDTO {
  final bool _isChecked;

  const SetDTO({required bool checked}) : _isChecked = checked;

  bool get checked => _isChecked;

  SetType get type;

  bool isEmpty();

  bool isNotEmpty();

  SetDTO copyWith({bool? checked});

  String summary();

  Map<String, dynamic> toJson() {
    if (this is WeightAndRepsSetDTO) {
      final weightAndRepSet = this as WeightAndRepsSetDTO;
      return {"value1": weightAndRepSet.weight, "value2": weightAndRepSet.reps, "checked": checked};
    } else if (this is RepsSetDTO) {
      final repSet = this as RepsSetDTO;
      return {"value1": 0, "value2": repSet.reps, "checked": checked};
    }
    final durationSet = this as DurationSetDTO;
    return {"value1": 0, "value2": durationSet.duration.inMilliseconds, "checked": checked};
  }

  factory SetDTO.fromJson(Map<String, dynamic> json, {required SetType metric}) {
    final value1 = json["value1"] as num;
    final value2 = json["value2"] as num;
    final checked = json["checked"] as bool;
    return switch (metric) {
      SetType.weightsAndReps => WeightAndRepsSetDTO(weight: value1.toDouble(), reps: value2.toInt(), checked: checked),
      SetType.reps => RepsSetDTO(reps: value2, checked: checked),
      SetType.duration => DurationSetDTO(duration: Duration(milliseconds: value2.toInt()), checked: checked),
    };
  }

  factory SetDTO.newType({required SetType type}) {
    return switch (type) {
      SetType.weightsAndReps => WeightAndRepsSetDTO(weight: 0, reps: 0, checked: false),
      SetType.reps => RepsSetDTO(reps: 0, checked: false),
      SetType.duration => DurationSetDTO(duration: Duration.zero, checked: false),
    };
  }
}
