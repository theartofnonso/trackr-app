class RoutineLogsReportDto {
  final String introduction;
  final List<ExerciseReport> exerciseReports;
  final String suggestions;

  RoutineLogsReportDto({
    required this.introduction,
    required this.exerciseReports,
    required this.suggestions,
  });

  factory RoutineLogsReportDto.fromJson(Map<String, dynamic> json) {
    return RoutineLogsReportDto(
      introduction: json['introduction'] as String,
      exerciseReports: (json['exercise_reports'] as List<dynamic>)
          .map((item) => ExerciseReport.fromJson(item as Map<String, dynamic>))
          .toList(),
      suggestions: json['suggestions'] as String,
    );
  }
}

class ExerciseReport {
  final String exerciseName;
  final String heaviestWeight;
  final String heaviestVolume;
  final List<String> dropsInPerformance;
  final String comments;

  ExerciseReport({
    required this.exerciseName,
    required this.heaviestWeight,
    required this.heaviestVolume,
    required this.dropsInPerformance,
    required this.comments,
  });

  factory ExerciseReport.fromJson(Map<String, dynamic> json) {
    return ExerciseReport(
      exerciseName: json['exercise_name'] as String,
      heaviestWeight: json['heaviest_weight'] as String,
      heaviestVolume: json['heaviest_volume'] as String,
      dropsInPerformance: (json['drops_in_performance'] as List<dynamic>).map((item) => item as String).toList(),
      comments: json['comments'] as String,
    );
  }
}