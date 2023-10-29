import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../providers/exercises_provider.dart';
import '../providers/routine_log_provider.dart';
import '../providers/weight_unit_provider.dart';
import '../widgets/helper_widgets/routine_helper.dart';
import 'exercise_history_screen.dart';

class RoutineLogPreviewScreen extends StatefulWidget {
  final String routineLogId;
  final String previousRouteName;

  const RoutineLogPreviewScreen({super.key, required this.routineLogId, this.previousRouteName = ""});

  @override
  State<RoutineLogPreviewScreen> createState() => _RoutineLogPreviewScreenState();
}

class _RoutineLogPreviewScreenState extends State<RoutineLogPreviewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  Widget build(BuildContext context) {
    final weightProvider = Provider.of<WeightUnitProvider>(context, listen: false);
    final log = Provider.of<RoutineLogProvider>(context, listen: true).whereRoutineLog(id: widget.routineLogId);

    if (log != null) {
      final completedSets = _calculateCompletedSets(procedureJsons: log.procedures);
      final completedSetsSummary = completedSets.length > 1 ? "${completedSets.length} sets" : "${completedSets.length} set";

      final totalWeight = _totalWeight(sets: completedSets);
      final conversion = weightProvider.isLbs ? weightProvider.toLbs(totalWeight) : totalWeight;
      final totalWeightSummary = "$conversion kg";

      return Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: "fab_routine_log_preview_screen",
            onPressed: () => _navigateToRoutineEditor(context: context, log: log),
            backgroundColor: tealBlueLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.edit),
          ),
          backgroundColor: tealBlueDark,
          appBar: AppBar(
            backgroundColor: tealBlueDark,
            title:
                Text(log.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
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
                menuChildren: _menuActionButtons(context: context, logDto: log),
              )
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    log.notes.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(log.notes,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                )),
                          )
                        : const SizedBox.shrink(),
                    Row(
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 1),
                        Text(log.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear(),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 1),
                        Text(log.endTime.getDateTimeInUtc().formattedTime(),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
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
                                child: Text(_logDuration(log: log),
                                    style: const TextStyle(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [..._bodyPartSplit(procedureJsons: log.procedures)],
                    ),
                    ..._proceduresToWidgets(routineLog: log)
                  ],
                ),
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
      end: Colors.blueAccent,
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

  List<Widget> _proceduresToWidgets({required RoutineLog routineLog}) {
    final procedures = routineLog.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
    return routineLog.procedures
        .map((procedure) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ProcedureWidget(
                procedureDto: ProcedureDto.fromJson(jsonDecode(procedure)),
                otherSuperSetProcedureDto: whereOtherSuperSetProcedure(
                    firstProcedure: ProcedureDto.fromJson(jsonDecode(procedure)), procedures: procedures),
                readOnly: widget.previousRouteName == exerciseRouteName,
              ),
            ))
        .toList();
  }

  String _logDuration({required RoutineLog log}) {
    String interval = "";
    final startTime = log.startTime.getDateTimeInUtc();
    final endTime = log.endTime.getDateTimeInUtc();
    final difference = endTime.difference(startTime);
    interval = difference.secondsOrMinutesOrHours();
    return interval;
  }

  List<SetDto> _calculateCompletedSets({required List<String> procedureJsons}) {
    final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
    List<SetDto> completedSets = [];
    for (var procedure in procedures) {
      completedSets.addAll(procedure.sets);
    }
    return completedSets;
  }

  double _totalWeight({required List<SetDto> sets}) {
    double totalWeight = 0;
    for (var set in sets) {
      final weightPerSet = set.reps * set.weight;
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

  List<Widget> _bodyPartSplit({required List<String> procedureJsons}) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
    final parts = procedures.map((procedure) => exerciseProvider.whereExercise(exerciseId: procedure.exerciseId).bodyPart).toList();
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
  List<Widget> _menuActionButtons({required BuildContext context, required RoutineLog logDto}) {
    return [
      MenuItemButton(
        onPressed: () {
          _navigateToRoutineEditor(context: context, log: logDto);
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).pop({"id": widget.routineLogId});
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineEditor({required BuildContext context, required RoutineLog log}) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineEditorScreen(routineLog: log, mode: RoutineEditorMode.editing, type: RoutineEditingType.log)));
  }
}
