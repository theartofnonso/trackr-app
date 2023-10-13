import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../dtos/workout_dto.dart';

class WorkoutPreviewScreen extends StatelessWidget {
  final WorkoutDto workoutDto;

  const WorkoutPreviewScreen({super.key, required this.workoutDto});

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
            },
            child: Text('Edit Workout', style: textStyle),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: tealBlueDark,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: tealBlueDark,
          trailing: GestureDetector(
              onTap: () => _showWorkoutPreviewActionSheet(context: context),
              child: const Padding(
                padding: EdgeInsets.only(right: 9.0),
                child: Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: CupertinoColors.white,
                ),
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
                      CupertinoListTile(title: Text(workoutDto.name))
                      // CupertinoListTile(
                      //   backgroundColor: tealBlueLight,
                      //   title: CupertinoTextField.borderless(
                      //     controller: _workoutNameController,
                      //     expands: true,
                      //     padding: const EdgeInsets.only(left: 20),
                      //     textCapitalization: TextCapitalization.sentences,
                      //     keyboardType: TextInputType.text,
                      //     maxLength: 240,
                      //     maxLines: null,
                      //     maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         color: CupertinoColors.white.withOpacity(0.8),
                      //         fontSize: 18),
                      //     placeholder: "New workout",
                      //     placeholderStyle: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 18),
                      //   ),
                      //   padding: EdgeInsets.zero,
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  //..._exercisesToListSection(exercisesInWorkout: _exercisesInWorkout),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ));
  }
}
