
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../enums/exercise_type_enums.dart';

class DurationSetDto extends SetDto {
  final Duration _duration;

  const DurationSetDto({required duration, super.checked = false, super.rpeRating = 4, super.isWorkingSet})
      : _duration = duration;

  Duration get duration => _duration;

  @override
  ExerciseType get type => ExerciseType.duration;

  @override
  DurationSetDto copyWith({Duration? duration, bool? checked, ExerciseType? type, int? rpeRating}) {
    return DurationSetDto(duration: duration ?? _duration, checked: checked ?? super.checked, rpeRating: super.rpeRating);
  }

  @override
  bool isEmpty() {
    return _duration == Duration.zero;
  }

  @override
  bool isNotEmpty() {
    return _duration > Duration.zero;
  }

  @override
  String summary() {
    return duration.hmsAnalog();
  }

  @override
  String toString() {
    return 'DurationSetDTO{duration: $_duration, checked: ${super.checked}, type: $type, rpeRating: ${super.rpeRating}}';
  }
}