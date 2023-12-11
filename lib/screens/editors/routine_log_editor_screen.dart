import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/exercise_log_provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import '../../app_constants.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../providers/routine_log_provider.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/routine/editors/procedures_picker.dart';
import 'helper_utils.dart';

class RoutineLogEditorScreen extends StatefulWidget {
  final RoutineLog log;

  const RoutineLogEditorScreen({super.key, required this.log});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen> {
  late Function _onDisposeCallback;

  void _showProceduresPicker({required ExerciseLogDto firstProcedure}) {
    final procedures = whereOtherProceduresExcept(context: context, firstProcedure: firstProcedure);
    displayBottomSheet(
        context: context,
        child: ProceduresPicker(
          procedures: procedures,
          onSelect: (ExerciseLogDto secondProcedure) {
            _closeDialog();
            final id = "superset_id_${firstProcedure.exercise.id}_${secondProcedure.exercise.id}";
            Provider.of<ExerciseLogProvider>(context, listen: false).superSetExerciseLogs(
                firstExerciseLogId: firstProcedure.id, secondExerciseLogId: secondProcedure.id, superSetId: id);
          },
          onSelectExercisesInLibrary: () {
            _closeDialog();
            selectExercisesInLibrary(context: context);
          },
        ));
  }

  Future<void> _doCreateRoutineLog() async {
    final log = widget.log;

    final completedExerciseLogs = _completedExerciseLogsAndSets();

    return Provider.of<RoutineLogProvider>(context, listen: false).saveRoutineLog(
        context: context,
        name: log.name,
        notes: log.notes,
        procedures: completedExerciseLogs,
        startTime: log.startTime,
        routine: log.routine);
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogsProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = exerciseLogsProvider.mergeSetsIntoExerciseLogs();
    return exerciseLogs.any((log) => log.sets.any((set) => set.checked));
  }

  List<ExerciseLogDto> _completedExerciseLogsAndSets() {
    final exerciseLogsProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = exerciseLogsProvider.mergeSetsIntoExerciseLogs();
    final completedExerciseLogs = <ExerciseLogDto>[];
    for (var log in exerciseLogs) {
      final completedSets = log.sets.where((set) => set.isNotEmpty() && set.checked).toList();
      if (completedSets.isNotEmpty) {
        final completedExerciseLog = log.copyWith(sets: completedSets);
        completedExerciseLogs.add(completedExerciseLog);
      }
    }
    return completedExerciseLogs;
  }

  void _discardLog() {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Do you want to discard workout?",
        leftAction: _closeDialog,
        rightAction: () {
          _closeDialog();
          _navigateBack();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Discard',
        isRightActionDestructive: true);
  }

  void _saveLog() async {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      await _doCreateRoutineLog();
      _navigateBack();
    } else {
      showAlertDialogWithSingleAction(
          context: context, message: "You have not completed any sets", actionLabel: 'Ok', action: _closeDialog);
    }
  }

  void _cacheLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
      final procedures = procedureProvider.mergeSetsIntoExerciseLogs();
      final log = widget.log;
      Provider.of<RoutineLogProvider>(context, listen: false).cacheRoutineLog(
          name: log.name, notes: log.notes, procedures: procedures, startTime: log.startTime, routine: log.routine);
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _navigateBack() {
    SharedPrefs().cachedRoutineLog = "";
    print(SharedPrefs().cachedRoutineLog);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _cacheLog();

    final exerciseLogs = context.select((ExerciseLogProvider provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: _discardLog,
            child: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            widget.log.name,
            style: GoogleFonts.lato(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(onPressed: () => selectExercisesInLibrary(context: context), icon: const Icon(Icons.add))
          ],
        ),
        floatingActionButton: isKeyboardOpen
            ? null
            : FloatingActionButton(
                heroTag: "fab_end_routine_log_screen",
                onPressed: _saveLog,
                backgroundColor: tealBlueLighter,
                enableFeedback: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.check_box_rounded, size: 32, color: Colors.green),
              ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.direction != ScrollDirection.idle) {
              _dismissKeyboard();
            }
            return false;
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
            child: GestureDetector(
              onTap: _dismissKeyboard,
              child: Column(
                children: [
                  Consumer<ExerciseLogProvider>(
                      builder: (BuildContext context, ExerciseLogProvider provider, Widget? child) {
                    return _RoutineLogOverview(
                      sets: provider.completedSets().length,
                      timer: _RoutineTimer(startTime: widget.log.startTime.getDateTimeInUtc()),
                    );
                  }),
                  const SizedBox(height: 20),
                  Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 250),
                          itemBuilder: (BuildContext context, int index) {
                            final procedure = exerciseLogs[index];
                            final procedureId = procedure.id;
                            return ExerciseLogWidget(
                                exerciseLogDto: procedure,
                                editorType: RoutineEditorMode.log,
                                superSet:
                                    whereOtherSuperSetProcedure(firstProcedure: procedure, procedures: exerciseLogs),
                                onRemoveSuperSet: (String superSetId) =>
                                    removeProcedureSuperSets(context: context, superSetId: procedure.superSetId),
                                onRemoveLog: () => removeProcedure(context: context, procedureId: procedureId),
                                onSuperSet: () => _showProceduresPicker(firstProcedure: procedure),
                                onCache: _cacheLog,
                                onReOrderLogs: () => reOrderProcedures(context: context));
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: exerciseLogs.length)),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    _initializeProcedureData();

    _onDisposeCallback = Provider.of<ExerciseLogProvider>(context, listen: false).onClearProvider;
  }

  void _initializeProcedureData() {
    final procedureJsons = widget.log.procedures;
    final procedures = procedureJsons.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
    Provider.of<ExerciseLogProvider>(context, listen: false).loadExerciseLogs(logs: procedures);
  }

  @override
  void dispose() {
    _onDisposeCallback();
    super.dispose();
  }
}

class _RoutineTimer extends StatefulWidget {
  final DateTime startTime;

  const _RoutineTimer({required this.startTime});

  @override
  State<_RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<_RoutineTimer> {
  late Timer _timer;
  Duration _elapsedDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Text(_elapsedDuration.secondsOrMinutesOrHours(),
        style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600));
  }

  @override
  void initState() {
    super.initState();
    _elapsedDuration = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedDuration = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}

class _RoutineLogOverview extends StatelessWidget {
  final int sets;
  final Widget timer;

  const _RoutineLogOverview({required this.sets, required this.timer});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          children: [
            TableRow(children: [
              Text("Sets", style: GoogleFonts.lato(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("Duration",
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500))
            ]),
            TableRow(children: [
              Text("$sets", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              timer
            ])
          ],
        ));
  }
}
