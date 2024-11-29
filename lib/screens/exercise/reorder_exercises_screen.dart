import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../../dtos/exercise_log_dto.dart';

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

  /// Navigate to previous screen
  void _saveReOrdering() {
    Navigator.of(context).pop(_exercises);
  }

  @override
  Widget build(BuildContext context) {
    final widgets = _exercises
        .mapIndexed((index, exercise) => ListTile(
              key: Key("$index"),
              title: Text(exercise.exercise.name, style: GoogleFonts.ubuntu()),
              trailing: const Icon(
                Icons.drag_handle,
                color: Colors.white,
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
        actions: [
          _hasReOrdered
              ? IconButton(
                  icon: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: Colors.white, size: 28),
                  onPressed: _saveReOrdering,
                )
              : const SizedBox.shrink(),
          const SizedBox(width: 12)
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: ReorderableListView(
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: true,
            children: widgets,
            onReorder: (int oldIndex, int newIndex) => _reOrderProcedures(oldIndex: oldIndex, newIndex: newIndex)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.exercises);
  }
}
