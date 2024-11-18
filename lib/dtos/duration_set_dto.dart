
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

class DurationSetDTO extends SetDTO {
  final Duration _duration;

  const DurationSetDTO({required duration, required super.checked})
      : _duration = duration;

  Duration get duration => _duration;

  @override
  DurationSetDTO copyWith({int? duration, bool? checked}) {
    return DurationSetDTO(duration: duration ?? _duration, checked: checked ?? super.checked);
  }

  @override
  bool isEmpty() {
    return _duration == Duration.zero;
  }

  @override
  bool isNotEmpty() {
    return _duration > Duration.zero;
  }

  String durationSummary() {
    return duration.hmsAnalog();
  }

  @override
  String toString() {
    return 'DurationSetDTO{duration: $_duration, checked: ${super.checked}';
  }
}