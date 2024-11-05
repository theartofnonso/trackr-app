import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/challengeTemplates/milestone_dto.dart';
import 'package:tracker_app/enums/milestone_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

class RepsMilestone extends Milestone {
  RepsMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required super.type});

  static String _milestoneName({required MuscleGroup muscleGroup}) {
    return switch (muscleGroup) {
      MuscleGroup.abs => "Abs of Steel",
      MuscleGroup.biceps => "Guns and Glory",
      MuscleGroup.back => "Back Attack",
      MuscleGroup.calves => "Calves Do Grow",
      MuscleGroup.chest => "Abs of Steel",
      MuscleGroup.forearms => "Popeye's Pride",
      MuscleGroup.glutes => "Dump Truck",
      MuscleGroup.hamstrings => "Hammies Award",
      MuscleGroup.lats => "Wing Commander",
      MuscleGroup.neck => "Abs of Steel",
      MuscleGroup.shoulders => "Abs of Steel",
      MuscleGroup.traps => "Trap King",
      MuscleGroup.triceps => "Tri Titan",
      MuscleGroup.quadriceps => "Quadzilla",
      _ => "No Milestone"
    };
  }

  static List<Milestone> loadMilestones() {
    final muscleGroups = [
      MuscleGroup.abs,
      MuscleGroup.biceps,
      MuscleGroup.back,
      MuscleGroup.calves,
      MuscleGroup.chest,
      MuscleGroup.forearms,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.lats,
      MuscleGroup.neck,
      MuscleGroup.shoulders,
      MuscleGroup.traps,
      MuscleGroup.triceps,
      MuscleGroup.quadriceps
    ];
    return muscleGroups.mapIndexed((index, muscleGroup) {
      final description =
          'Focus on building strength and endurance in your ${muscleGroup.name} by committing to this challenge. Consistency and dedication will be key as you target your goals each week.';
      final caption = "Accumulate 10k reps of ${muscleGroup.name} training";
      final rule = "Accumulate reps targeting your ${muscleGroup.name} in every training session.";
      final milestoneName = _milestoneName(muscleGroup: muscleGroup).toUpperCase();
      return RepsMilestone(
          id: "Reps_Milestone_${milestoneName}_$index",
          name: milestoneName,
          caption: caption,
          description: description,
          rule: rule,
          target: 10000,
          type: MilestoneType.reps);
    }).toList();
  }
}
