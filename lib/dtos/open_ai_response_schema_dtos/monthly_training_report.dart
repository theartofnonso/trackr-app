class MonthlyTrainingReport {
  final String introduction;
  final String exercisesSummary;
  final String musclesTrainedSummary;
  final String caloriesBurnedSummary;
  final String personalBestsSummary;
  final String workoutDurationSummary;
  final String activitiesSummary;
  final String consistencySummary;
  final String recommendations;

  MonthlyTrainingReport({
    required this.introduction,
    required this.exercisesSummary,
    required this.musclesTrainedSummary,
    required this.caloriesBurnedSummary,
    required this.personalBestsSummary,
    required this.workoutDurationSummary,
    required this.activitiesSummary,
    required this.consistencySummary,
    required this.recommendations,
  });

  /// Factory constructor to create an instance from JSON
  factory MonthlyTrainingReport.fromJson(Map<String, dynamic> json) {
    return MonthlyTrainingReport(
      introduction: json['introduction'] as String,
      exercisesSummary: json['exercises_summary'] as String,
      musclesTrainedSummary: json['muscles_trained_summary'] as String,
      caloriesBurnedSummary: json['calories_burned_summary'] as String,
      personalBestsSummary: json['personal_bests_summary'] as String,
      workoutDurationSummary: json['workout_duration_summary'] as String,
      activitiesSummary: json['activities_summary'] as String,
      consistencySummary: json['consistency_summary'] as String,
      recommendations: json['recommendations'] as String,
    );
  }

  /// Method to convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'introduction': introduction,
      'exercises_summary': exercisesSummary,
      'muscles_trained_summary': musclesTrainedSummary,
      'calories_burned_summary': caloriesBurnedSummary,
      'personal_bests_summary': personalBestsSummary,
      'workout_duration_summary': workoutDurationSummary,
      'activities_summary': activitiesSummary,
      'consistency_summary': consistencySummary,
      'recommendations': recommendations,
    };
  }
}