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
  factory NewRoutineDto.fromJson(Map<String, dynamic> json) {
    return NewRoutineDto(
      exercises: List<String>.from(json['exercises']),
      workoutName: json['workout_name'],
      workoutCaption: json['workout_caption'],
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