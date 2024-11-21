
import 'package:tracker_app/dtos/sets_dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';

class RepsSetDTO extends SetDTO {
  final int _reps;

  const RepsSetDTO({required reps, required super.checked})
      : _reps = reps;

  int get reps => _reps;
  @override
  SetType get type => SetType.reps;

  @override
  RepsSetDTO copyWith({int? reps, bool? checked}) {
    return RepsSetDTO(reps: reps ?? _reps, checked: checked ?? super.checked);
  }

  @override
  bool isEmpty() {
    return _reps == 0;
  }

  @override
  bool isNotEmpty() {
    return _reps > 0;
  }

  @override
  String summary() {
    return "x$reps";
  }

  @override
  String toString() {
    return 'RepsSetDTO{reps: $_reps, checked: ${super.checked}, type: $type';
  }
}