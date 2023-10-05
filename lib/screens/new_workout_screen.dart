import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'exercise_library_screen.dart';

const double _kItemExtent = 38.0;

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  Future<void> _showListOfExercises(BuildContext context) async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return const ExerciseLibraryScreen();
      },
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  final _subTitleTextStyle =
      TextStyle(color: CupertinoColors.white.withOpacity(0.7));

  void _showActionSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showDialog(_repsPicker, 216);
            },
            child: const Text('Add Reps'),
          ),
        ],
      ),
    );
  }

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
    children: List<Widget>.generate(100, (int index) {
      return Center(
          child: Text(
        "$index",
        style: TextStyle(color: CupertinoColors.white),
      ));
    }),
  );

  void _showDialog(Widget child, double height) {
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
              child: const Text(
                "Save",
                style: TextStyle(color: CupertinoColors.white),
              )),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CupertinoListSection.insetGrouped(
                backgroundColor: Colors.transparent,
                header: const CupertinoListTile(
                  padding: EdgeInsets.zero,
                  title: Text("Bench Press",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  trailing: Icon(CupertinoIcons.ellipsis_vertical),
                ),
                footer: GestureDetector(
                    onTap: () => _showListOfExercises(context),
                    child: const Center(
                        child: Text(
                      "Add new set",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
                children: [
                  CupertinoListTile.notched(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    onTap: _showActionSheet,
                    backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
                    leading: CircleAvatar(
                      child: const Text(
                        "1",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text("10 Reps"),
                    trailing: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("kg"),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: 30,
                          child: CupertinoTextField(
                            decoration:
                                BoxDecoration(color: Colors.transparent),
                            padding: EdgeInsets.zero,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            maxLines: 1,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            style: TextStyle(fontWeight: FontWeight.w600),
                            placeholder: "10",
                            placeholderStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white),
                          ),
                        )
                      ],
                    ),
                    subtitle: Text(
                      "Previous: 30kg for 10 reps",
                      style: _subTitleTextStyle,
                    ),
                  ),
                  CupertinoListTile.notched(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
                    leading: CircleAvatar(
                      child: Text(
                        "2",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text("10 Reps"),
                    trailing: CTextField(),
                    subtitle: Text("Previous: 30kg for 10 reps",
                        style: _subTitleTextStyle),
                  ),
                  CupertinoListTile.notched(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
                    leading: CircleAvatar(
                      child: Text(
                        "3",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text("10 Reps"),
                    trailing: CTextField(),
                    subtitle: Text(
                      "Previous: 30kg for 10 reps",
                      style: _subTitleTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class CTextField extends StatelessWidget {
  const CTextField({super.key});

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
            placeholder: "10",
            placeholderStyle: TextStyle(
                fontWeight: FontWeight.w600, color: CupertinoColors.white),
          ),
        )
      ],
    );
  }
}
