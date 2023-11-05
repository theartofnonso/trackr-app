import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../../app_constants.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../dtos/procedure_dto.dart';
import '../../enums.dart';
import '../../providers/routine_log_provider.dart';
import '../../providers/routine_provider.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/chart/line_chart_widget.dart';
import '../../widgets/helper_widgets/dialog_helper.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../exercise_history_screen.dart';

enum RoutineSummaryType { volume, reps, duration }

class RoutinePreviewScreen extends StatefulWidget {
  final String routineId;

  const RoutinePreviewScreen({super.key, required this.routineId});

  @override
  State<RoutinePreviewScreen> createState() => _RoutinePreviewScreenState();
}

class _RoutinePreviewScreenState extends State<RoutinePreviewScreen> {
  List<RoutineLog> _logs = [];

  List<RoutineLog> _filteredLogs = [];

  List<String> _dateTimes = [];

  List<ChartPointDto> _chartPoints = [];

  late ChartUnit _chartUnit;

  RoutineSummaryType _summaryType = RoutineSummaryType.volume;

  HistoricalTimePeriod _selectedHistoricalDate = HistoricalTimePeriod.allTime;

  void _volume() {
    final values = _filteredLogs.map((log) => volumePerLog(context: context, log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = RoutineSummaryType.volume;
      _chartUnit = weightUnit();
    });
  }

  void _totalReps() {
    final values = _filteredLogs.map((log) => repsPerLog(log: log)).toList();
    setState(() {
      _chartPoints = values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble())).toList();
      _summaryType = RoutineSummaryType.reps;
      _chartUnit = ChartUnit.reps;
    });
  }

  void _totalDuration() {
    final values = _filteredLogs.map((log) => durationPerLog(log: log)).toList();
    setState(() {
      _chartPoints =
          values.mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.inMinutes.toDouble())).toList();
      _summaryType = RoutineSummaryType.duration;
      _chartUnit = ChartUnit.min;
    });
  }

  void _recomputeChart() {
    switch (_selectedHistoricalDate) {
      case HistoricalTimePeriod.lastThreeMonths:
        _filteredLogs =
            Provider.of<RoutineLogProvider>(context, listen: false).routineLogsSince(90, logs: _logs).toList();
      case HistoricalTimePeriod.lastOneYear:
        _filteredLogs =
            Provider.of<RoutineLogProvider>(context, listen: false).routineLogsSince(365, logs: _logs).toList();
      case HistoricalTimePeriod.allTime:
        _filteredLogs = _logs.toList();
    }

    _dateTimes = _logs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();

    switch (_summaryType) {
      case RoutineSummaryType.volume:
        _volume();
      case RoutineSummaryType.reps:
        _totalReps();
      case RoutineSummaryType.duration:
        _totalDuration();
    }
  }

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required Routine routine}) {
    return [
      MenuItemButton(
        onPressed: () {
          _navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.editing);
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          final alertDialogActions = <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            CTextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop({"id": widget.routineId});
                },
                label: 'Delete'),
          ];
          showAlertDialog(context: context, message: "Delete workout?", actions: alertDialogActions);
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineEditor(
      {required BuildContext context, Routine? routine, RoutineEditorMode mode = RoutineEditorMode.editing}) {
    if (mode == RoutineEditorMode.editing) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RoutineEditorScreen(routine: routine, mode: mode, type: RoutineEditingType.template)));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => RoutineEditorScreen(routine: routine, mode: mode)));
    }
  }

  void _loadChart() {
    Provider.of<RoutineProvider>(context, listen: false).routinesLogsWhere(id: widget.routineId).then((logs) async {
      _logs = logs.reversed.toList();
      _filteredLogs = _logs;
      _dateTimes = logs.map((log) => dateTimePerLog(log: log).formattedDayAndMonth()).toList();
      _volume();
    });
  }

  Color? _buttonColor({required RoutineSummaryType type}) {
    return _summaryType == type ? Colors.blueAccent : tealBlueLight;
  }

  @override
  Widget build(BuildContext context) {
    final routine = Provider.of<RoutineProvider>(context, listen: true).routineWhere(id: widget.routineId);

    if(routine == null) {
      return const SizedBox.shrink();
    }

    final procedures = routine.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();

    final cachedRoutineLogDto = Provider.of<RoutineLogProvider>(context, listen: true).cachedLog;

    final chartPoints = _chartPoints;

    return Scaffold(
        floatingActionButton: cachedRoutineLogDto == null
            ? FloatingActionButton(
                heroTag: "fab_routine_preview_screen",
                onPressed: () {
                  _navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.routine);
                },
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.play_arrow))
            : null,
        backgroundColor: tealBlueDark,
        appBar: AppBar(
          backgroundColor: tealBlueDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(routine.name,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
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
              menuChildren: _menuActionButtons(context: context, routine: routine),
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  routine.notes.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(routine.notes,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              )),
                        )
                      : const SizedBox.shrink(),
                  chartPoints.isNotEmpty
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0, right: 20, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  DropdownButton<String>(
                                    isDense: true,
                                    value: _selectedHistoricalDate.label,
                                    underline: Container(
                                      color: Colors.transparent,
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedHistoricalDate = switch (value) {
                                            "Last 3 months" => HistoricalTimePeriod.lastThreeMonths,
                                            "Last 1 year" => HistoricalTimePeriod.lastOneYear,
                                            "All Time" => HistoricalTimePeriod.allTime,
                                            _ => HistoricalTimePeriod.allTime
                                          };
                                          _recomputeChart();
                                        });
                                      }
                                    },
                                    items: HistoricalTimePeriod.values
                                        .map<DropdownMenuItem<String>>((HistoricalTimePeriod historicalTimePeriod) {
                                      return DropdownMenuItem<String>(
                                        value: historicalTimePeriod.label,
                                        child: Text(historicalTimePeriod.label, style: const TextStyle(fontSize: 12)),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  LineChartWidget(
                                    chartPoints: _chartPoints,
                                    dateTimes: _dateTimes,
                                    unit: _chartUnit,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CTextButton(
                                    onPressed: _volume,
                                    label: "Volume",
                                    buttonColor: _buttonColor(type: RoutineSummaryType.volume)),
                                const SizedBox(width: 5),
                                CTextButton(
                                    onPressed: _totalReps,
                                    label: "Reps",
                                    buttonColor: _buttonColor(type: RoutineSummaryType.reps)),
                                const SizedBox(width: 5),
                                CTextButton(
                                    onPressed: _totalDuration,
                                    label: "Duration",
                                    buttonColor: _buttonColor(type: RoutineSummaryType.duration)),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 5),
                  ..._proceduresToWidgets(procedures: procedures)
                ],
              ),
            ),
          ),
        ));
  }

  List<Widget> _proceduresToWidgets({required List<ProcedureDto> procedures}) {
    return procedures
        .map((procedure) => Column(
              children: [
                ProcedureWidget(
                  procedureDto: procedure,
                  otherSuperSetProcedureDto:
                      whereOtherSuperSetProcedure(firstProcedure: procedure, procedures: procedures),
                ),
                const SizedBox(height: 18)
              ],
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadChart();
  }
}
