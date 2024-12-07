
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';

class Reps {
  final int repetitions;

  Reps({required this.repetitions});

  static RepsSetDto toDto(Map<String, dynamic> json, {bool checked = false}) {
    return RepsSetDto(reps: json['repetitions'] as int, checked: checked);
  }

  // Convert LogSetIntent object to JSON
  Map<String, dynamic> toJson() {
    return {'repetitions': repetitions};
  }
}