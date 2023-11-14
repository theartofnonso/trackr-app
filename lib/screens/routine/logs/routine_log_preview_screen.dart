import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/duration_num_pair.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/screens/editor/routine_editor_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/procedure_dto.dart';
import '../../../dtos/double_num_pair.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../widgets/buttons/text_button_widget.dart';
import '../../../widgets/helper_widgets/dialog_helper.dart';
import '../../../widgets/helper_widgets/routine_helper.dart';
import '../../exercise/exercise_history_screen.dart';

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

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Provider.of<ExerciseProvider>(context, listen: true);
    final log = Provider.of<RoutineLogProvider>(context, listen: true).whereRoutineLog(id: widget.routineLogId);

    if (log == null) {
      return const SizedBox.shrink();
    }

    List<ProcedureDto> procedures = log.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).map((procedure) {
      final exerciseFromLibrary = Provider.of<ExerciseProvider>(context, listen: false).whereExerciseOrNull(exerciseId: procedure.exercise.id);
      if(exerciseFromLibrary != null) {
        return procedure.copyWith(exercise: exerciseFromLibrary);
      }
      return procedure;
    }).toList();

    final numberOfCompletedSets = _calculateCompletedSets(procedures: procedures);
    final completedSetsSummary = "$numberOfCompletedSets set(s)";

    final totalVolume = _totalVolume(procedures: procedures);
    final volume = isDefaultWeightUnit() ? totalVolume : toLbs(totalVolume);
    final totalVolumeSummary = "$volume ${weightLabel()}";

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title:
              Text(log.name, style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
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
              menuChildren: _menuActionButtons(context: context, log: log),
            )
          ],
        ),
        body: Stack(children: [
          SafeArea(
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
                                style: GoogleFonts.lato(
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
                            style: GoogleFonts.lato(
                                color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 1),
                        Text(log.endTime.getDateTimeInUtc().formattedTime(),
                            style: GoogleFonts.lato(
                                color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                        color: tealBlueLight, // Set the background color
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Table(
                        border: TableBorder.symmetric(inside: const BorderSide(color: tealBlueLighter, width: 2)),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(children: [
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(completedSetsSummary,
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(totalVolumeSummary,
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(_logDuration(log: log),
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            )
                          ]),
                        ],
                      ),
                    ),
                    Column(
                      children: [..._muscleGroupFamilySplit(procedures: procedures)],
                    ),
                    ..._proceduresToWidgets(procedures: procedures)
                  ],
                ),
              ),
            ),
          ),
          _loading
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: tealBlueDark.withOpacity(0.7),
                      child: const Center(child: Text("Deleting log"))))
              : const SizedBox.shrink()
        ]));
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

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  List<Widget> _proceduresToWidgets({required List<ProcedureDto> procedures}) {
    return procedures
        .map((procedure) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ProcedureWidget(
                procedureDto: procedure,
                otherSuperSetProcedureDto: whereOtherSuperSetProcedure(
                    firstProcedure: procedure, procedures: procedures),
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

  int _calculateCompletedSets({required List<ProcedureDto> procedures}) {
    List<SetDto> completedSets = [];
    for (var procedure in procedures) {
      completedSets.addAll(procedure.sets);
    }
    return completedSets.length;
  }

  double _totalVolume({required List<ProcedureDto> procedures}) {
    double totalWeight = 0;
    for (var procedure in procedures) {
      final exerciseTypeString = procedure.exercise.type;
      final exerciseType = ExerciseType.fromString(exerciseTypeString);
      for (var set in procedure.sets) {
        final weightPerSet = switch (exerciseType) {
          ExerciseType.weightAndReps || ExerciseType.weightedBodyWeight => (set as DoubleNumPair).value1 * (set).value2,
          ExerciseType.bodyWeightAndReps ||
          ExerciseType.assistedBodyWeight ||
          ExerciseType.duration ||
          ExerciseType.distanceAndDuration ||
          ExerciseType.weightAndDistance =>
            0,
        };
        totalWeight += weightPerSet;
      }
    }
    return totalWeight;
  }

  Map<String, double> _calculateBodySplitPercentage(List<MuscleGroupFamily> muscleGroups) {
    final Map<MuscleGroupFamily, int> frequencyMap = {};

    // Count the occurrences of each muscleGroup
    for (MuscleGroupFamily muscleGroupFamily in muscleGroups) {
      frequencyMap[muscleGroupFamily] = (frequencyMap[muscleGroupFamily] ?? 0) + 1;
    }

    final int totalItems = muscleGroups.length;
    final Map<String, double> percentageMap = {};

    // Calculate the percentage for each muscleGroup
    frequencyMap.forEach((item, count) {
      final double percentage = ((count / totalItems) * 100.0) / 100;
      percentageMap[item.name] = percentage;
    });

    final sortedMap = percentageMap.entries.toList();
    sortedMap.sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedMap);
  }

  List<Widget> _muscleGroupFamilySplit({required List<ProcedureDto> procedures}) {
    final parts = procedures.map((procedure) {
      final primaryMuscleGroupFamily = MuscleGroup.fromString(procedure.exercise.primaryMuscle).family;
      final secondaryMuscleGroupsFamily = procedure.exercise.secondaryMuscles.map((muscleGroupString) => MuscleGroup.fromString(muscleGroupString).family);
      return [primaryMuscleGroupFamily, ...secondaryMuscleGroupsFamily];
    }).expand((element) => element).toList();
    final splitMap = _calculateBodySplitPercentage(parts);
    final splitList = <Widget>[];
    splitMap.forEach((key, value) {
      final widget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$key ${(value * 100).toInt()}%",
            style: GoogleFonts.lato(fontWeight: FontWeight.w400),
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
  List<Widget> _menuActionButtons({required BuildContext context, required RoutineLog log}) {
    return [
      MenuItemButton(
        onPressed: () {
          _navigateToRoutineEditor(context: context, log: log);
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          final decodedProcedures = log.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json)));
          final procedures = decodedProcedures.map((procedure) {
            final exerciseTypeString = procedure.exercise.type;
            final exerciseType = ExerciseType.fromString(exerciseTypeString);
            final newSets = procedure.sets
                .map((set) => switch (exerciseType) {
                      ExerciseType.weightAndReps ||
                      ExerciseType.weightedBodyWeight ||
                      ExerciseType.assistedBodyWeight ||
                      ExerciseType.bodyWeightAndReps ||
                      ExerciseType.weightAndDistance =>
                        (set as DoubleNumPair).copyWith(checked: false),
                      ExerciseType.duration ||
                      ExerciseType.distanceAndDuration =>
                        (set as DurationNumPair).copyWith(checked: false)
                    })
                .toList();
            return procedure.copyWith(sets: newSets);
          }).toList();

          Provider.of<RoutineProvider>(context, listen: false)
              .saveRoutine(name: log.name, notes: log.notes, procedures: procedures);
        },
        leadingIcon: const Icon(Icons.save_alt_rounded),
        child: const Text("Save as workout"),
      ),
      MenuItemButton(
        onPressed: () {
          final alertDialogActions = <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            CTextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _toggleLoadingState();
                  try {
                    await Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: widget.routineLogId);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (_) {
                    if (mounted) {
                      showSnackbar(
                          context: context,
                          icon: const Icon(Icons.info_outline),
                          message: "Oops, we are unable delete this log");
                    }
                  } finally {
                    _toggleLoadingState();
                  }
                },
                label: 'Delete'),
          ];
          showAlertDialog(context: context, message: "Delete log?", actions: alertDialogActions);
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: Text("Delete", style: GoogleFonts.lato(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineEditor({required BuildContext context, required RoutineLog log}) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => RoutineEditorScreen(routineLog: log, mode: RoutineEditorType.edit)));
  }
}
