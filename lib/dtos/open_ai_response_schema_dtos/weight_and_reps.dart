
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';

class WeightAndReps {
  final double weight;
  final int repetitions;

  WeightAndReps({
    required this.weight,
    required this.repetitions
  });

  // Factory constructor to parse JSON into a LogSetIntent object
  static WeightAndRepsSetDto toDto(Map<String, dynamic> json, {bool checked = false}) {
    return WeightAndRepsSetDto(
      weight: (json['weight'] as num).toDouble(),
      reps: json['repetitions'] as int, checked: checked,
    );
  }

  // Convert LogSetIntent object to JSON
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'repetitions': repetitions,
    };
  }
}