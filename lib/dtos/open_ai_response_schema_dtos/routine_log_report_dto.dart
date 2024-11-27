class RoutineLogReportDto {
  final String introduction;
  final List<ExerciseReport> exerciseReports;
  final String suggestions;

  RoutineLogReportDto({
    required this.introduction,
    required this.exerciseReports,
    required this.suggestions,
  });

  factory RoutineLogReportDto.fromJson(Map<String, dynamic> json) {
    return RoutineLogReportDto(
      introduction: json['introduction'] as String,
      exerciseReports: (json['exercise_reports'] as List<dynamic>)
          .map((item) =>
          ExerciseReport.fromJson(item as Map<String, dynamic>))
          .toList(),
      suggestions: json['suggestions'] as String,
    );
  }
}

class ExerciseReport {
  final String exerciseName;
  final List<String> achievements;
  final List<String> improvements;
  final String comments;

  ExerciseReport({
    required this.exerciseName,
    required this.achievements,
    required this.improvements,
    required this.comments,
  });

  factory ExerciseReport.fromJson(Map<String, dynamic> json) {
    return ExerciseReport(
      exerciseName: json['exercise_name'] as String,
      achievements: List<String>.from(json['achievements'] as List),
      improvements: List<String>.from(json['improvements'] as List),
      comments: json['comments'] as String,
    );
  }
}