import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/reps_set_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/weight_and_reps_set_dto.dart';
import 'package:tracker_app/enums/exercise/set_type_enums.dart';
import 'package:tracker_app/enums/milestone_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../utils/exercise_logs_utils.dart';
import '../appsync/routine_log_dto.dart';

class RepsMilestone extends Milestone {
  final MuscleGroup muscleGroup;

  RepsMilestone(
      {required super.id,
      required super.name,
      required super.caption,
      required super.description,
      required super.rule,
      required super.target,
      required super.progress,
      required super.type,
      required this.muscleGroup});

  static String _milestoneName({required MuscleGroup muscleGroup}) {
    return switch (muscleGroup) {
      MuscleGroup.abs => "Abs of Steel",
      MuscleGroup.biceps => "Guns and Glory",
      MuscleGroup.back => "Back Attack",
      MuscleGroup.calves => "Calves Do Grow",
      MuscleGroup.chest => "Pectacular",
      MuscleGroup.glutes => "Dump Truck",
      MuscleGroup.hamstrings => "Hammies Award",
      MuscleGroup.shoulders => "Jonny Bravo",
      MuscleGroup.triceps => "Tri Titan",
      MuscleGroup.quadriceps => "Quadzilla",
      _ => "No Milestone"
    };
  }

  static List<Milestone> loadMilestones({required List<RoutineLogDto> logs}) {
    final muscleGroups = [
      MuscleGroup.abs,
      MuscleGroup.biceps,
      MuscleGroup.back,
      MuscleGroup.calves,
      MuscleGroup.chest,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
      MuscleGroup.quadriceps
    ];
    return muscleGroups.mapIndexed((index, muscleGroup) {
      final description =
          'Focus on building strength and endurance in your ${muscleGroup.name} by committing to this challenge. Consistency and dedication will be key as you target your goals each week.';
      final caption = "Accumulate ${1}k reps of ${muscleGroup.name} training";
      final rule = "Accumulate ${1}k reps targeting your ${muscleGroup.name} in every training session.";
      final milestoneName = _milestoneName(muscleGroup: muscleGroup).toUpperCase();
      return RepsMilestone(
          id: "Reps_Milestone_${milestoneName}_$index",
          name: milestoneName,
          caption: caption,
          description: description,
          rule: rule,
          target: 1000,
          progress: _calculateProgress(logs: logs, muscleGroup: muscleGroup, target: 1000),
          muscleGroup: muscleGroup,
          type: MilestoneType.reps);
    }).toList();
  }

  static (double, List<RoutineLogDto>) _calculateProgress(
      {required List<RoutineLogDto> logs, required MuscleGroup muscleGroup, required int target}) {
    if (logs.isEmpty) return (0, []);

    int sumOfReps = 0;

    List<RoutineLogDto> qualifyingLogs = [];

    for (final log in logs) {
      if (sumOfReps < target) {
        final completedExerciseLogs = completedExercises(exerciseLogs: log.exerciseLogs);

        final exerciseLogs = completedExerciseLogs
            .where((exerciseLog) =>
                exerciseLog.exerciseVariant.getSetTypeConfiguration() !=
                SetType.duration)
            .where((exerciseLog) {
          final primaryMuscleGroups = exerciseLog.exerciseVariant.primaryMuscleGroups;
          final secondaryMuscleGroups = exerciseLog.exerciseVariant.secondaryMuscleGroups;
          final muscleGroups = [...primaryMuscleGroups, ...secondaryMuscleGroups];
          return muscleGroups.contains(muscleGroup);
        });

        if (exerciseLogs.isNotEmpty) {
          final reps = exerciseLogs
              .expand((exerciseLog) => exerciseLog.sets)
              .map((set) {
                if(set is RepsSetDTO) {
                  return set.reps;
                } else if(set is WeightAndRepsSetDTO) {
                  return set.reps;
                }
                return 0;
          })
              .reduce((value, element) => value + element)
              .toInt();

          qualifyingLogs.add(log);
          sumOfReps += reps;
        }
      }
    }

    final progress = (sumOfReps >= target ? 1 : sumOfReps / target).toDouble();

    return (progress, qualifyingLogs);
  }
}
