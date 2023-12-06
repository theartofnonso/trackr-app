import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../dtos/exercise_log_dto.dart';

class ReOrderProceduresScreen extends StatefulWidget {
  final List<ExerciseLogDto> procedures;

  const ReOrderProceduresScreen({super.key, required this.procedures});

  @override
  State<ReOrderProceduresScreen> createState() => _ReOrderProceduresScreenState();
}

class _ReOrderProceduresScreenState extends State<ReOrderProceduresScreen> {
  bool _hasReOrdered = false;
  late List<ExerciseLogDto> _procedures;

  void _reOrderProcedures({required int oldIndex, required int newIndex}) {
    setState(() {
      _hasReOrdered = true;

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ExerciseLogDto item = _procedures.removeAt(oldIndex);
      _procedures.insert(newIndex, item);
    });
  }

  List<Widget> _proceduresToWidgets() {
    return _procedures
        .mapIndexed((index, procedure) => ListTile(
              key: Key("$index"),
              title: Text(procedure.exercise.name, style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(
                Icons.reorder_rounded,
                color: Colors.white,
              ),
            ))
        .toList();
  }

  /// Navigate to previous screen
  void _saveReOrdering() {
    Navigator.of(context).pop(_procedures);
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
          children: _proceduresToWidgets(),
          onReorder: (int oldIndex, int newIndex) => _reOrderProcedures(oldIndex: oldIndex, newIndex: newIndex)),
    );
  }

  @override
  void initState() {
    super.initState();
    _procedures = widget.procedures;
  }
}
