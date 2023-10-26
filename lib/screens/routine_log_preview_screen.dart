import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../dtos/set_dto.dart';
import '../models/BodyPart.dart';
import '../providers/routine_log_provider.dart';

class RoutineLogPreviewScreen extends StatefulWidget {
  final String routineLogId;

  const RoutineLogPreviewScreen({super.key, required this.routineLogId});

  @override
  State<RoutineLogPreviewScreen> createState() => _RoutineLogPreviewScreenState();
}

class _RoutineLogPreviewScreenState extends State<RoutineLogPreviewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  Widget build(BuildContext context) {
    final logDto = Provider.of<RoutineLogProvider>(context, listen: true).whereRoutineLog(id: widget.routineLogId);

    if (logDto != null) {
      final completedSets = _calculateCompletedSets(procedures: logDto.procedures);
      final completedSetsSummary =
          completedSets.length > 1 ? "${completedSets.length} sets" : "${completedSets.length} set";

      final totalWeight = _totalWeight(sets: completedSets);
      final totalWeightSummary = "$totalWeight kg";

      return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToRoutineEditor(context: context, logDto: logDto),
            backgroundColor: tealBlueLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.edit),
          ),
          backgroundColor: tealBlueDark,
          appBar: AppBar(
            backgroundColor: tealBlueDark,
            actions: [
              MenuAnchor(
                style: MenuStyle(
                  backgroundColor: MaterialStateProperty.all(tealBlueLighter),
                ),
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Show menu',
                  );
                },
                menuChildren: _menuActionButtons(context: context, logDto: logDto),
              )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(logDto.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  logDto.notes.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(logDto.notes,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              )),
                        )
                      : const SizedBox.shrink(),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 1),
                      Text(logDto.createdAt.formattedDayAndMonthAndYear(),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(
                        CupertinoIcons.time,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 1),
                      Text(logDto.createdAt.formattedTime(),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                        color: tealBlueLight, // Set the background color
                      ),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(completedSetsSummary,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
                            ),
                          ),
                          const VerticalDivider(
                            color: tealBlueLighter,
                            thickness: 2,
                            indent: 12,
                            endIndent: 12,
                            width: 20,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(totalWeightSummary,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
                            ),
                          ),
                          const VerticalDivider(
                            color: tealBlueLighter,
                            thickness: 2,
                            indent: 12,
                            endIndent: 12,
                            width: 20,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(_logDuration(logDto: logDto),
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [..._bodyPartSplit(procedures: logDto.procedures)],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) =>
                            _procedureToWidget(procedure: logDto.procedures[index], otherProcedures: logDto.procedures),
                        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 18),
                        itemCount: logDto.procedures.length),
                  ),
                ],
              ),
            ),
          ));
    }

    return const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
    // Create an animation controller with a duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Create a tween for the color animation
    _colorAnimation = ColorTween(
      begin: tealBlueLight,
      end: Colors.white,
    ).animate(_controller);

    // Start the animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _logDuration({required RoutineLogDto logDto}) {
    String interval = "";
    final startTime = logDto.startTime;
    final endTime = logDto.endTime;
    if (startTime != null && endTime != null) {
      final difference = endTime.difference(startTime);
      interval = difference.secondsOrMinutesOrHours();
    }
    return interval;
  }

  List<SetDto> _calculateCompletedSets({required List<ProcedureDto> procedures}) {
    List<SetDto> completedSets = [];
    for (var procedure in procedures) {
      final sets = procedure.sets.where((set) => set.checked).toList();
      completedSets.addAll(sets);
    }
    return completedSets;
  }

  int _totalWeight({required List<SetDto> sets}) {
    int totalWeight = 0;
    for (var set in sets) {
      final weightPerSet = set.rep * set.weight;
      totalWeight += weightPerSet;
    }
    return totalWeight;
  }

  Map<String, double> _calculateBodySplitPercentage(List<BodyPart> itemList) {
    final Map<BodyPart, int> frequencyMap = {};

    // Count the occurrences of each item
    for (var item in itemList) {
      frequencyMap[item] = (frequencyMap[item] ?? 0) + 1;
    }

    final int totalItems = itemList.length;
    final Map<String, double> percentageMap = {};

    // Calculate the percentage for each item
    frequencyMap.forEach((item, count) {
      final double percentage = ((count / totalItems) * 100.0) / 100;
      percentageMap[item.name] = percentage;
    });

    return percentageMap;
  }

  List<Widget> _bodyPartSplit({required List<ProcedureDto> procedures}) {
    final parts = procedures.map((procedure) => procedure.exercise.bodyPart).toList();
    final splitMap = _calculateBodySplitPercentage(parts);
    final splitList = <Widget>[];
    splitMap.forEach((key, value) {
      final widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$key ${(value * 100).toInt()}%",
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return LinearProgressIndicator(
                    value: value,
                    valueColor: _colorAnimation,
                    backgroundColor: tealBlueLight,
                    minHeight: 15,
                    borderRadius: BorderRadius.circular(2));
              }),
          const SizedBox(height: 12)
        ],
      );
      splitList.add(widget);
    });
    return splitList;
  }

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required RoutineLogDto logDto}) {
    return [
      MenuItemButton(
        onPressed: () {
          _navigateToRoutineEditor(context: context, logDto: logDto);
        },
        // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(tealBlueLight),),
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).pop({"id": widget.routineLogId});
        },
        // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(tealBlueLight),),
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineEditor({required BuildContext context, required RoutineLogDto logDto}) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineEditorScreen(routineDto: logDto, mode: RoutineEditorMode.editing, type: RoutineEditingType.log)));
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  ProcedureWidget _procedureToWidget({required ProcedureDto procedure, required List<ProcedureDto> otherProcedures}) {
    return ProcedureWidget(
      procedureDto: procedure,
      otherSuperSetProcedureDto: _whereOtherProcedure(firstProcedure: procedure, procedures: otherProcedures),
    );
  }

  ProcedureDto? _whereOtherProcedure({required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
    return procedures.firstWhereOrNull((procedure) =>
        procedure.superSetId == firstProcedure.superSetId && procedure.exercise.id != firstProcedure.exercise.id);
  }
}
