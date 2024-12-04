
class WeightsAndRepsSetIntent {
  final double weight;
  final int repetitions;

  WeightsAndRepsSetIntent({
    required this.weight,
    required this.repetitions
  });

  // Factory constructor to parse JSON into a LogSetIntent object
  factory WeightsAndRepsSetIntent.fromJson(Map<String, dynamic> json) {
    return WeightsAndRepsSetIntent(
      weight: (json['weight'] as num).toDouble(),
      repetitions: json['repetitions'] as int,
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