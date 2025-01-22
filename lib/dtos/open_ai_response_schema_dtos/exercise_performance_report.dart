class ExercisePerformanceReport {
  final List<ExerciseReport> exerciseReports;
  final List<String> suggestions;

  ExercisePerformanceReport({
    required this.exerciseReports,
    required this.suggestions,
  });

  factory ExercisePerformanceReport.fromJson(Map<String, dynamic> json) {
    return ExercisePerformanceReport(
      exerciseReports:
          (json['exercise_reports'] as List).map((e) => ExerciseReport.fromJson(e as Map<String, dynamic>)).toList(),
      suggestions: (json['suggestions'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_reports': exerciseReports.map((e) => e.toJson()).toList(),
      'suggestions': suggestions,
    };
  }
}

class ExerciseReport {
  final String exerciseId;
  final String comments;

  ExerciseReport({
    required this.exerciseId,
    required this.comments,
  });

  factory ExerciseReport.fromJson(Map<String, dynamic> json) {
    return ExerciseReport(
      exerciseId: json['exercise_id'] as String,
      comments: json['comments'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'comments': comments,
    };
  }
}
