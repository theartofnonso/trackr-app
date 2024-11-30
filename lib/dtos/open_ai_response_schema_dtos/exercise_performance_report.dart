class ExercisePerformanceReport {
  final String introduction;
  final List<ExerciseReport> exerciseReports;
  final String suggestions;

  ExercisePerformanceReport({
    required this.introduction,
    required this.exerciseReports,
    required this.suggestions,
  });

  factory ExercisePerformanceReport.fromJson(Map<String, dynamic> json) {
    return ExercisePerformanceReport(
      introduction: json['introduction'] as String,
      exerciseReports:
          (json['exercise_reports'] as List).map((e) => ExerciseReport.fromJson(e as Map<String, dynamic>)).toList(),
      suggestions: json['suggestions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'introduction': introduction,
      'exercise_reports': exerciseReports.map((e) => e.toJson()).toList(),
      'suggestions': suggestions,
    };
  }
}

class ExerciseReport {
  final String exerciseName;
  final Performance currentPerformance;
  final List<Performance> previousPerformance;
  final String achievements;
  final String comments;

  ExerciseReport({
    required this.exerciseName,
    required this.currentPerformance,
    required this.previousPerformance,
    required this.achievements,
    required this.comments,
  });

  factory ExerciseReport.fromJson(Map<String, dynamic> json) {
    return ExerciseReport(
      exerciseName: json['exercise_name'] as String,
      currentPerformance: Performance.fromJson(json['current_performance'] as Map<String, dynamic>),
      previousPerformance:
          (json['previous_performance'] as List).map((e) => Performance.fromJson(e as Map<String, dynamic>)).toList(),
      achievements: json['achievements'] as String,
      comments: json['comments'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_name': exerciseName,
      'current_performance': currentPerformance.toJson(),
      'previous_performance': previousPerformance.map((e) => e.toJson()).toList(),
      'achievements': achievements,
      'comments': comments,
    };
  }
}

class Performance {
  final String date;
  final List<Set> sets;
  final double totalVolume;

  Performance({
    required this.date,
    required this.sets,
    required this.totalVolume,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      date: json['date'] as String,
      sets: (json['sets'] as List).map((e) => Set.fromJson(e as Map<String, dynamic>)).toList(),
      totalVolume: json['total_volume'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sets': sets.map((e) => e.toJson()).toList(),
      'total_volume': totalVolume,
    };
  }
}

class Set {
  final double weight;
  final int repetitions;

  Set({
    required this.weight,
    required this.repetitions,
  });

  factory Set.fromJson(Map<String, dynamic> json) {
    return Set(
        weight: (json['weight'] is int)
            ? (json['weight'] as int).toDouble()
            : (json['weight'] is double)
            ? json['weight'] as double
            : double.tryParse(json['weight'].toString()) ?? 0.0,
        repetitions: int.tryParse((json['repetitions'].toString())) ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'repetitions': repetitions,
    };
  }
}
