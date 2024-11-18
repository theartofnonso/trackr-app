
import 'package:tracker_app/dtos/set_dto.dart';

class RepsSetDTO extends SetDTO {
  final int _reps;

  const RepsSetDTO({required reps, required super.checked})
      : _reps = reps;

  int get reps => _reps;

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

  String repsSummary() {
    return "x$reps";
  }

  @override
  String toString() {
    return 'RepsSetDTO{reps: $_reps, checked: ${super.checked}';
  }
}