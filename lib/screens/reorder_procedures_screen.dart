import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../providers/exercises_provider.dart';

class ReOrderProceduresScreen extends StatefulWidget {
  final List<ProcedureDto> procedures;

  const ReOrderProceduresScreen({super.key, required this.procedures});

  @override
  State<ReOrderProceduresScreen> createState() => _ReOrderProceduresScreenState();
}

class _ReOrderProceduresScreenState extends State<ReOrderProceduresScreen> {
  bool _hasReOrdered = false;
  late List<ProcedureDto> _procedures;

  void _reOrderProcedures({required int oldIndex, required int newIndex}) {
    setState(() {
      _hasReOrdered = true;

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ProcedureDto item = _procedures.removeAt(oldIndex);
      _procedures.insert(newIndex, item);
    });
  }

  List<Widget> _proceduresToWidgets() {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    return _procedures
        .mapIndexed((index, procedure) => ListTile(
              key: Key("$index"),
              title: Text(exerciseProvider.whereExercise(exerciseId: procedure.exerciseId).name, style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(
                Icons.list,
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
        backgroundColor: tealBlueDark,
        title: const Text(
          "Reorder",
          style: TextStyle(color: Colors.white),
        ),
        actions: [_hasReOrdered ? CTextButton(onPressed: _saveReOrdering, label: "Save") : const SizedBox.shrink()],
      ),
      body: ReorderableListView(
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
