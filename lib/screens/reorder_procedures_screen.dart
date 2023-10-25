import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';

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
    return _procedures
        .mapIndexed((index, procedure) => CupertinoListTile(
              key: Key("$index"),
              title: Text(procedure.exercise.name, style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(
                CupertinoIcons.bars,
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tealBlueDark,
        middle: const Text(
          "Reorder",
          style: TextStyle(color: Colors.white),
        ),
        trailing: GestureDetector(
            onTap: _saveReOrdering,
            child: _hasReOrdered
                ? const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  )
                : const SizedBox.shrink()),
      ),
      child: ReorderableListView(
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
