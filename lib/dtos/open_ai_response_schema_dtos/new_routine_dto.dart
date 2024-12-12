class NewRoutineDto {
  final List<String> exercises;
  final String workoutName;
  final String workoutCaption;

  NewRoutineDto({
    required this.exercises,
    required this.workoutName,
    required this.workoutCaption,
  });

  // Factory method to create a Workout instance from JSON
  factory NewRoutineDto.fromJson(Map<String, Object> json) {
    return NewRoutineDto(
      exercises: List<String>.from(json['exercises'] as List<String>),
      workoutName: json['workout_name'] as String,
      workoutCaption: json['workout_caption'] as String,
    );
  }

  // Method to convert Workout instance back to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'exercises': exercises,
      'workout_name': workoutName,
      'workout_caption': workoutCaption,
    };
  }
}