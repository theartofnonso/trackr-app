import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import 'exercise_library_screen.dart';

const double _kItemExtent = 38.0;

final _repsPicker = CupertinoPicker(
  backgroundColor: Colors.transparent,
  magnification: 1.22,
  squeeze: 1.2,
  useMagnifier: true,
  itemExtent: _kItemExtent,
  // This sets the initial item.
  scrollController: FixedExtentScrollController(
    initialItem: 0,
  ),
  // This is called when selected item is changed.
  onSelectedItemChanged: (int selectedItem) {
    // setState(() {
    //   _selectedFruit = selectedItem;
    // });
  },
  children: List<Widget>.generate(101, (int index) {
    return Center(
        child: Text(
      "$index",
      style: TextStyle(color: CupertinoColors.white),
    ));
  }),
);

void _showExerciseActionSheet(
    {required BuildContext context, required String exercise}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showDialog(child: _repsPicker, height: 216, context: context);
          },
          child: const Text('Add new set', style: const TextStyle(fontSize: 18)),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showDialog(child: _repsPicker, height: 216, context: context);
          },
          child: const Text('Add warm-up set', style: const TextStyle(fontSize: 18)),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showDialog(child: _repsPicker, height: 216, context: context);
          },
          child: Text('Super set $exercise with ...', style: const TextStyle(fontSize: 18),),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            _showDialog(child: _repsPicker, height: 216, context: context);
          },
          child: Text('Remove $exercise', style: const TextStyle(fontSize: 18)),
        ),
      ],
    ),
  );
}

void _showSetsActionSheet({required BuildContext context}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showDialog(child: _repsPicker, height: 216, context: context);
          },
          child: const Text('Add Reps'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            _showDialog(child: _repsPicker, height: 216, context: context);
          },
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}

void _showDialog(
    {required BuildContext context,
    required Widget child,
    required double height}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => Container(
      height: height,
      padding: const EdgeInsets.only(top: 6.0),
      // The Bottom margin is provided to align the popup above the system navigation bar.
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      // Provide a background color for the popup.
      color: Colors.transparent,
      // Use a SafeArea widget to avoid system overlaps.
      child: SafeArea(
        top: false,
        child: child,
      ),
    ),
  );
}

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {

  final List<Exercise> _selectedExercises = [];

  Future<void> _showListOfExercises(BuildContext context) async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(preSelectedExercises: _selectedExercises);
      },
    );
    if(selectedExercises != null) {
      setState(() {
        _selectedExercises.addAll(selectedExercises);
      });
    }
  }

  List<WorkoutListSection> _exercisesTo() {
    return _selectedExercises.map((exercise) => WorkoutListSection(exercise: exercise)).toList();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'New Workout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: GestureDetector(
              onTap: _navigateBack,
              child: const Icon(
                CupertinoIcons.check_mark_circled,
                size: 24,
              )),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._exercisesTo(),
                GestureDetector(
                    onTap: () => _showListOfExercises(context),
                    child: const Center(
                        child: Text(
                      "Add new exercise",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
              ],
            ),
          ),
        ));
  }
}

class WorkoutListSection extends StatelessWidget {
  final Exercise exercise;

  const WorkoutListSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      header: Column(
        children: [
          CupertinoListTile(
            padding: EdgeInsets.zero,
            title: Text(exercise.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            trailing: GestureDetector(
                onTap: () => _showExerciseActionSheet(
                    exercise: exercise.name, context: context),
                child: const Icon(CupertinoIcons.ellipsis_vertical)),
          ),
          const SizedBox(
            height: 8,
          ),
          CupertinoTextField(
            expands: true,
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.number,
            maxLength: 240,
            maxLines: null,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white.withOpacity(0.8)),
            placeholder: "Enter notes for ${exercise.name}",
            placeholderStyle: const TextStyle(
                color: CupertinoColors.inactiveGray, fontSize: 16),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
      children: const [
        WorkoutListTile(
            key: Key("_asda"),
            previousWorkoutSummary: '',
            repsCount: 10,
            leading: 'W',
            weight: 0,
            leadingColor: CupertinoColors.activeOrange),
        WorkoutListTile(
            key: Key("_acca"),
            previousWorkoutSummary: '',
            repsCount: 10,
            leading: 'W',
            weight: 0,
            leadingColor: CupertinoColors.activeOrange),
        WorkoutListTile(
            key: Key("_aada"),
            previousWorkoutSummary: '',
            repsCount: 10,
            leading: 'W',
            weight: 0,
            leadingColor: CupertinoColors.activeOrange),
        WorkoutListTile(
            key: Key("_asasfa"),
            previousWorkoutSummary: '',
            repsCount: 10,
            leading: '1',
            weight: 0,
            leadingColor: CupertinoColors.activeBlue),
        WorkoutListTile(
            key: Key("_aadascca"),
            previousWorkoutSummary: '',
            repsCount: 10,
            leading: '2',
            weight: 0,
            leadingColor: CupertinoColors.activeBlue),
        WorkoutListTile(
            key: Key("_aaasdfada"),
            previousWorkoutSummary: '',
            repsCount: 10,
            leading: '3',
            weight: 0,
            leadingColor: CupertinoColors.activeBlue),
      ],
    );
  }
}

class WorkoutListTile extends StatelessWidget {
  const WorkoutListTile({
    super.key,
    required this.previousWorkoutSummary,
    required this.repsCount,
    required this.leading,
    required this.weight,
    required this.leadingColor,
  });

  final String leading;
  final int repsCount;
  final String previousWorkoutSummary;
  final int weight;

  final Color leadingColor;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: super.key!,
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.destructiveRed,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              CupertinoIcons.delete_solid,
              color: CupertinoColors.white,
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ),
      child: CupertinoListTile.notched(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
        leading: CircleAvatar(
          backgroundColor: leadingColor,
          child: Text(
            leading,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: CupertinoColors.white),
          ),
        ),
        title: Text("$repsCount Reps"),
        trailing: const CTextField(
          value: 10,
        ),
        subtitle: Text("Past: ${previousWorkoutSummary.isNotEmpty ? previousWorkoutSummary : "No past data"}",
            style: TextStyle(color: CupertinoColors.white.withOpacity(0.7))),
      ),
    );
  }
}

class CTextField extends StatelessWidget {
  final int value;

  const CTextField({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("kg"),
        SizedBox(
          height: 8,
        ),
        SizedBox(
          width: 30,
          child: CupertinoTextField(
            decoration: BoxDecoration(color: Colors.transparent),
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.number,
            maxLength: 3,
            maxLines: 1,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: TextStyle(fontWeight: FontWeight.w600),
            placeholder: "0",
            placeholderStyle: TextStyle(
                fontWeight: FontWeight.w600, color: CupertinoColors.white),
          ),
        )
      ],
    );
  }
}
