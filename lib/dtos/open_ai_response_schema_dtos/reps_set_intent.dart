
class RepsSetIntent {
  final int repetitions;

  RepsSetIntent({required this.repetitions});

  // Factory constructor to parse JSON into a LogSetIntent object
  factory RepsSetIntent.fromJson(Map<String, dynamic> json) {
    return RepsSetIntent(repetitions: json['repetitions'] as int);
  }

  // Convert LogSetIntent object to JSON
  Map<String, dynamic> toJson() {
    return {'repetitions': repetitions};
  }
}