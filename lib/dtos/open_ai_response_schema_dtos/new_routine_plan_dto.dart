import 'new_routine_dto.dart';

class NewRoutinePlanDto {
  final String planName;
  final int planDurationWeeks;
  final String planDescription;
  final List<NewRoutineDto> workouts;

  NewRoutinePlanDto({
    required this.planName,
    required this.planDurationWeeks,
    required this.planDescription,
    required this.workouts,
  });

  factory NewRoutinePlanDto.fromJson(Map<String, dynamic> json) {
    return NewRoutinePlanDto(
      planName: json['plan_name'],
      planDurationWeeks: json['plan_duration_weeks'],
      planDescription: json['plan_description'],
      workouts: (json['workouts'] as List)
          .map((item) => NewRoutineDto.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_name': planName,
      'plan_duration_weeks': planDurationWeeks,
      'plan_description': planDescription,
      'workouts': workouts.map((w) => w.toJson()).toList(),
    };
  }
}