import 'package:collection/collection.dart';
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
    if (selectedExercises != null) {
      setState(() {
        _selectedExercises.addAll(selectedExercises);
      });
    }
  }

  List<SetListSection> _exercisesToProcedureListSection() {
    return _selectedExercises
        .map((exercise) => SetListSection(exercise: exercise))
        .toList();
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
                ..._exercisesToProcedureListSection(),
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

class SetListSection extends StatefulWidget {
  final Exercise exercise;

  const SetListSection({super.key, required this.exercise});

  @override
  State<SetListSection> createState() => _SetListSectionState();
}

class _SetListSectionState extends State<SetListSection> {
  List<SetListItem> _warmupSetItems = [];
  List<SetListItem> _setItems = [];
  final List<TextEditingController> _warmupSetRepsController = [];
  final List<TextEditingController> _warmupSetWeightController = [];
  final List<TextEditingController> _setRepsController = [];
  final List<TextEditingController> _setWeightController = [];

  void _onRemoveSetListItem(int index) {
    if (_setItems.length > 1) {
      setState(() {
        _setItems.removeAt(index);
        _setItems = _setItems.mapIndexed((index, item) {
          return SetListItem(
            index: index,
            leadingColor: item.leadingColor,
            onRemove: item.onRemove,
            repsController: item.repsController,
            weightController: item.weightController,
            isWarmup: item.isWarmup,
          );
        }).toList();

        _setRepsController.removeAt(index);
        _setWeightController.removeAt(index);
      });
    }
  }

  void _onRemoveWarmupSetListItem(int index) {
    setState(() {
      _warmupSetItems.removeAt(index);
      _warmupSetItems = _warmupSetItems.mapIndexed((index, item) {
        return SetListItem(
          index: index,
          leadingColor: item.leadingColor,
          onRemove: item.onRemove,
          repsController: item.repsController,
          weightController: item.weightController,
          isWarmup: item.isWarmup,
        );
      }).toList();

      _warmupSetRepsController.removeAt(index);
      _warmupSetWeightController.removeAt(index);
    });
  }

  void _showExerciseActionSheet(
      {required BuildContext context, required String exercise}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _createNewSetListItem();
              });
            },
            child: const Text('Add new set', style: TextStyle(fontSize: 18)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _createNewWarmupSetListItem();
              });
            },
            child:
                const Text('Add warm-up set', style: TextStyle(fontSize: 18)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showDialog(child: _repsPicker, height: 216, context: context);
            },
            child: Text(
              'Super set $exercise with ...',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child:
                Text('Remove $exercise', style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _createNewSetListItem() {
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final setItem = SetListItem(
      index: _setItems.length,
      leadingColor: CupertinoColors.activeBlue,
      onRemove: (int index) => _onRemoveSetListItem(index),
      repsController: repsController,
      weightController: setsController,
      isWarmup: false,
    );
    _setItems.add(setItem);
    _setRepsController.add(repsController);
    _setWeightController.add(setsController);
  }

  void _createNewWarmupSetListItem() {
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final setItem = SetListItem(
      index: _warmupSetItems.length,
      isWarmup: true,
      leadingColor: CupertinoColors.activeOrange,
      onRemove: (int index) => _onRemoveWarmupSetListItem(index),
      repsController: repsController,
      weightController: setsController,
    );
    _warmupSetItems.add(setItem);
    _warmupSetRepsController.add(repsController);
    _warmupSetWeightController.add(setsController);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: Colors.transparent,
      header: Column(
        children: [
          CupertinoListTile(
            padding: EdgeInsets.zero,
            title: Text(widget.exercise.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            trailing: GestureDetector(
                onTap: () => _showExerciseActionSheet(
                    exercise: widget.exercise.name, context: context),
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
            placeholder: "Enter notes for ${widget.exercise.name}",
            placeholderStyle: const TextStyle(
                color: CupertinoColors.inactiveGray, fontSize: 16),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
      children: [..._warmupSetItems, ..._setItems],
    );
  }

  @override
  void initState() {
    super.initState();
    _createNewSetListItem();
  }
}

class SetListItem extends StatelessWidget {
  const SetListItem({
    super.key,
    required this.index,
    required this.leadingColor,
    required this.onRemove,
    required this.repsController,
    required this.weightController,
    required this.isWarmup,
    this.previousWorkoutSummary,
  });

  final int index;
  final String? previousWorkoutSummary;
  final bool isWarmup;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final void Function(int index) onRemove;

  final Color leadingColor;

  void _showSetsActionSheet({required BuildContext context}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemove(index);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSetsActionSheet(context: context),
      child: CupertinoListTile.notched(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
        leading: CircleAvatar(
          backgroundColor: leadingColor,
          child: Text(
            isWarmup ? "W${index + 1}" : "${index + 1}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
                fontSize: isWarmup ? 12 : null),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(
              width: 18,
            ),
            SetListItemTextField(
              label: 'Reps',
              textEditingController: repsController,
            ),
            const SizedBox(
              width: 34,
            ),
            SetListItemTextField(
              label: 'kg',
              textEditingController: weightController,
            ),
            const SizedBox(
              width: 34,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Past"),
                const SizedBox(
                  height: 8,
                ),
                Text(previousWorkoutSummary ?? "No past data",
                    style: TextStyle(
                        color: CupertinoColors.white.withOpacity(0.7)))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SetListItemTextField extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;

  const SetListItemTextField(
      {super.key, required this.label, required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: CupertinoColors.opaqueSeparator),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: 30,
          child: CupertinoTextField(
            controller: textEditingController,
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.number,
            maxLength: 3,
            maxLines: 1,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: const TextStyle(fontWeight: FontWeight.bold),
            placeholder: "0",
            placeholderStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: CupertinoColors.white),
          ),
        )
      ],
    );
  }
}
