import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../dtos/exercise_log_dto.dart';

class ReOrderExercisesScreen extends StatefulWidget {
  final List<ExerciseLogDto> exercises;

  const ReOrderExercisesScreen({super.key, required this.exercises});

  @override
  State<ReOrderExercisesScreen> createState() => _ReOrderExercisesScreenState();
}

class _ReOrderExercisesScreenState extends State<ReOrderExercisesScreen> {
  bool _hasReOrdered = false;
  late List<ExerciseLogDto> _exercises;

  void _reOrderProcedures({required int oldIndex, required int newIndex}) {
    setState(() {
      _hasReOrdered = true;

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ExerciseLogDto item = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, item);
    });
  }

  List<Widget> _exercisesToWidgets() {
    return _exercises
        .mapIndexed((index, exercise) => ListTile(
              key: Key("$index"),
              title: Text(exercise.exercise.name, style: GoogleFonts.lato()),
              trailing: const Icon(
                Icons.drag_handle,
                color: Colors.white,
              ),
            ))
        .toList();
  }

  /// Navigate to previous screen
  void _saveReOrdering() {
    Navigator.of(context).pop(_exercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Reorder",
          style: GoogleFonts.lato(color: Colors.white),
        ),
        actions: [_hasReOrdered ? CTextButton(onPressed: _saveReOrdering, label: "Save", buttonColor: Colors.transparent,) : const SizedBox.shrink()],
      ),
      body: ReorderableListView(
          buildDefaultDragHandles: true,
          children: _exercisesToWidgets(),
          onReorder: (int oldIndex, int newIndex) => _reOrderProcedures(oldIndex: oldIndex, newIndex: newIndex)),
    );
  }

  @override
  void initState() {
    super.initState();
    _exercises = widget.exercises;
  }
}
