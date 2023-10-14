import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_constants.dart';
import '../dtos/exercise_in_workout_dto.dart';
import '../dtos/workout_dto.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout/preview/exercise_in_workout_preview.dart';

class WorkoutPreviewScreen extends StatelessWidget {
  final String workoutId;
  final void Function() onUpdateWorkout;
  final void Function() onRemoveWorkout;

  const WorkoutPreviewScreen({super.key, required this.workoutId, required this.onUpdateWorkout, required this.onRemoveWorkout});

  /// Show [CupertinoActionSheet]
  void _showWorkoutPreviewActionSheet({required BuildContext context}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onUpdateWorkout();
            },
            child: Text('Edit Workout', style: textStyle),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemoveWorkout();
            },
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  List<ExerciseInWorkoutPreview> _exercisesToWidgets({required WorkoutDto workoutDto, required List<ExerciseInWorkoutDto> exercisesInWorkout}) {
    return exercisesInWorkout.map((exerciseInWorkout) {
      return ExerciseInWorkoutPreview(
        exerciseInWorkoutDto: exerciseInWorkout,
        superSetExerciseInWorkoutDto: _whereOtherSuperSet(workoutDto: workoutDto, firstExercise: exerciseInWorkout),
      );
    }).toList();
  }

  ExerciseInWorkoutDto? _whereOtherSuperSet({required WorkoutDto workoutDto, required ExerciseInWorkoutDto firstExercise}) {
    return workoutDto.exercises.firstWhereOrNull((exerciseInWorkout) =>
        exerciseInWorkout.superSetId == firstExercise.superSetId &&
        exerciseInWorkout.exercise.id != firstExercise.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final workouts = Provider.of<WorkoutProvider>(context, listen: true).workouts;
    final workout = workouts.firstWhere((workout) => workout.id == workoutId);
    return CupertinoPageScaffold(
        backgroundColor: tealBlueDark,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: tealBlueDark,
          trailing: GestureDetector(
              onTap: () => _showWorkoutPreviewActionSheet(context: context),
              child: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: CupertinoColors.white,
                size: 24,
              )),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoListSection.insetGrouped(
                    hasLeading: false,
                    margin: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    children: [
                      CupertinoListTile(
                        backgroundColor: tealBlueLight,
                        title: Text(workout.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white.withOpacity(0.8),
                                fontSize: 18)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      CupertinoListTile.notched(
                        backgroundColor: tealBlueLight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(workout.notes,
                            style: TextStyle(
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white.withOpacity(0.8),
                              fontSize: 16,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._exercisesToWidgets(workoutDto: workout, exercisesInWorkout: workout.exercises),
                ],
              ),
            ),
          ),
        ));
  }
}
