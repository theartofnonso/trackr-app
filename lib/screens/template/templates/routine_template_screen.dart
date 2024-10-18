import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/routine_template_extension.dart';
import 'package:tracker_app/screens/template/templates/trkr_coach_context_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../../colors.dart';
import '../../../controllers/routine_template_controller.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../dtos/viewmodels/routine_log_arguments.dart';
import '../../../dtos/viewmodels/routine_template_arguments.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../enums/routine_preview_type_enum.dart';
import '../../../models/RoutineTemplate.dart';
import '../../../urls.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/https_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/routine_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/ai_widgets/trkr_information_container.dart';
import '../../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../../widgets/chart/muscle_group_family_chart.dart';
import '../../../widgets/routine/preview/exercise_log_listview.dart';
import '../../not_found.dart';
import '../../preferences/routine_schedule_planner/routine_schedule_planner_home.dart';

class RoutineTemplateScreen extends StatefulWidget {
  static const routeName = '/routine_template_screen';

  final String id;

  const RoutineTemplateScreen({super.key, required this.id});

  @override
  State<RoutineTemplateScreen> createState() => _RoutineTemplateScreenState();
}

class _RoutineTemplateScreenState extends State<RoutineTemplateScreen> {
  RoutineTemplateDto? _template;

  bool _loading = false;

  bool _minimized = true;

  void _deleteRoutine({required RoutineTemplateDto template}) async {
    try {
      await Provider.of<RoutineTemplateController>(context, listen: false).removeTemplate(template: template);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to remove workout");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  void _navigateToRoutineTemplateEditor() async {
    final template = _template;
    if (template != null) {
      final arguments = RoutineTemplateArguments(template: template);
      final updatedTemplate = await navigateToRoutineTemplateEditor(context: context, arguments: arguments);
      if (updatedTemplate != null) {
        setState(() {
          _template = updatedTemplate;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = _template;

    if (template == null) {
      if (_loading) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: sapphireDark80,
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                onPressed: context.pop,
              ),
              title: Text("Workout",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
            ),
            body: const TRKRLoadingScreen());
      }
      return const NotFound();
    }

    final numberOfSets = template.exerciseTemplates.expand((exerciseTemplate) => exerciseTemplate.sets);
    final setsSummary = "${numberOfSets.length} ${pluralize(word: "Set", count: numberOfSets.length)}";

    final exerciseController = Provider.of<ExerciseController>(context, listen: true);

    final exercisesFromLibrary = template.exerciseTemplates.map((exerciseTemplate) {
      final foundExercise = exerciseController.exercises
          .firstWhereOrNull((exerciseInLibrary) => exerciseInLibrary.id == exerciseTemplate.id);
      return foundExercise != null ? exerciseTemplate.copyWith(exercise: foundExercise) : exerciseTemplate;
    }).toList();

    final muscleGroupFamilyFrequencies = muscleGroupFamilyFrequency(exerciseLogs: exercisesFromLibrary);

    final menuActions = [
      MenuItemButton(onPressed: _navigateToRoutineTemplateEditor, child: Text("Edit", style: GoogleFonts.ubuntu())),
      MenuItemButton(
        onPressed: () {
          displayBottomSheet(
              height: 400,
              context: context,
              child: RoutineSchedulePlannerHome(template: template),
              isScrollControlled: true);
        },
        child: Text("Schedule", style: GoogleFonts.ubuntu(color: Colors.white)),
      ),
      MenuItemButton(onPressed: _showBottomSheet, child: Text("Share", style: GoogleFonts.ubuntu())),
      MenuItemButton(
        onPressed: () {
          showBottomSheetWithMultiActions(
              context: context,
              title: "Delete workout?",
              description: "Are you sure you want to delete this workout?",
              leftAction: Navigator.of(context).pop,
              rightAction: () {
                context.pop();
                _toggleLoadingState();
                _deleteRoutine(template: template);
              },
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.ubuntu(color: Colors.red)),
      )
    ];

    return Scaffold(
        floatingActionButton: template.owner == SharedPrefs().userId
            ? FloatingActionButton(
                heroTag: UniqueKey,
                onPressed: () {
                  final arguments = RoutineLogArguments(log: template.log(), editorMode: RoutineEditorMode.log);
                  navigateToRoutineLogEditor(context: context, arguments: arguments);
                },
                backgroundColor: sapphireDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const FaIcon(FontAwesomeIcons.play, color: Colors.white, size: 24))
            : null,
        backgroundColor: sapphireDark,
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: context.pop,
          ),
          centerTitle: true,
          title: Text(template.name,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
          actions: [
            template.owner == SharedPrefs().userId
                ? MenuAnchor(
                    style: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(sapphireDark80),
                      surfaceTintColor: WidgetStateProperty.all(sapphireDark),
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
                    menuChildren: menuActions,
                  )
                : const SizedBox.shrink()
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
          child: Stack(children: [
            SafeArea(
              minimum: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (template.notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 10),
                        child: Text('"${template.notes}"',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white70,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600)),
                      ),
                    if (template.notes.isEmpty)
                      const SizedBox(
                        height: 10,
                      ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                        color: sapphireDark.withOpacity(0.4), // Set the background color
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Table(
                        border: const TableBorder.symmetric(inside: BorderSide(color: sapphireLighter, width: 2)),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(children: [
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(
                                    "${template.exerciseTemplates.length} ${pluralize(word: "Exercise", count: template.exerciseTemplates.length)}",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(setsSummary,
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _onTap,
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text("Muscle Groups Split".toUpperCase(),
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (muscleGroupFamilyFrequencies.length > 3)
                                FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp,
                                    color: Colors.white70, size: 16),
                            ]),
                            const SizedBox(height: 10),
                            Text("Here's a breakdown of the muscle groups in your ${template.name} workout plan.",
                                style: GoogleFonts.ubuntu(
                                    color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            MuscleGroupFamilyChart(frequencyData: muscleGroupFamilyFrequencies, minimized: _minimized),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TRKRInformationContainer(
                        ctaLabel: "Ask for a review",
                        description:
                            "Achieving your fitness goals is easier with a structured plan. Ask the TRKR Coach to optimize your workouts and help you succeed!",
                        onTap: () => navigateWithSlideTransition(
                            context: context,
                            child: const TRKRCoachContextScreen())),
                    const SizedBox(height: 12),
                    ExerciseLogListView(
                      exerciseLogs: exerciseLogsToViewModels(exerciseLogs: template.exerciseTemplates),
                      previewType: RoutinePreviewType.template,
                    ),
                  ],
                ),
              ),
            ),
            if (_loading) const TRKRLoadingScreen()
          ]),
        ));
  }

  void _onTap() {
    setState(() {
      _minimized = !_minimized;
    });
  }

  void _loadData() {
    final routineTemplateController = Provider.of<RoutineTemplateController>(context, listen: false);
    _template = routineTemplateController.templateWhere(id: widget.id);
    if (_template == null) {
      _loading = true;
      getAPI(endpoint: "/routine-template", queryParameters: {"id": widget.id}).then((data) {
        if (data != null) {
          final json = jsonDecode(data);
          final body = json["data"];
          final routineTemplate = body["getRoutineTemplate"];
          final routineTemplateDto = RoutineTemplate.fromJson(routineTemplate);
          setState(() {
            _loading = false;
            _template = routineTemplateDto.dto();
          });
        }
      });
    }
  }

  void _showBottomSheet() {
    final workoutLink = "$shareableRoutineUrl/${_template?.id}";
    final workoutText = _copyAsText();

    displayBottomSheet(
        context: context,
        isScrollControlled: true,
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.link, size: 14, color: Colors.white70),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(workoutLink,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      )),
                ),
                const SizedBox(width: 6),
                OpacityButtonWidget(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    final data = ClipboardData(text: workoutLink);
                    Clipboard.setData(data).then((_) {
                      if (mounted) {
                        context.pop();
                        showSnackbar(context: context, icon: const Icon(Icons.check), message: "Workout link copied");
                      }
                    });
                  },
                  label: "Copy",
                  buttonColor: vibrantGreen,
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sapphireDark80,
                border: Border.all(
                  color: sapphireDark80, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
              ),
              child: Text("${workoutText.substring(0, workoutText.length >= 150 ? 150 : workoutText.length)}...",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ubuntu(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  )),
            ),
            OpacityButtonWidget(
              onPressed: () {
                HapticFeedback.heavyImpact();
                final data = ClipboardData(text: workoutText);
                Clipboard.setData(data).then((_) {
                  if (mounted) {
                    context.pop();
                    showSnackbar(context: context, icon: const Icon(Icons.check), message: "Workout copied");
                  }
                });
              },
              label: "Copy as text",
              buttonColor: vibrantGreen,
            )
          ]),
        ));
  }

  String _copyAsText() {
    final template = _template;
    if (template != null) {
      StringBuffer workoutText = StringBuffer();

      workoutText.writeln(template.name);
      if (template.notes.isNotEmpty) {
        workoutText.writeln("Notes: ${template.notes}");
      }

      for (var exerciseLog in template.exerciseTemplates) {
        var exercise = exerciseLog.exercise;
        workoutText.writeln("\n- Exercise: ${exercise.name}");
        workoutText.writeln("  Muscle Group: ${exercise.primaryMuscleGroup.name}");

        for (var i = 0; i < exerciseLog.sets.length; i++) {
          switch (exerciseLog.exercise.type) {
            case ExerciseType.weights:
              workoutText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].weightsSummary()}");
              break;
            case ExerciseType.bodyWeight:
              workoutText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].bodyWeightSummary()}");
              break;
            case ExerciseType.duration:
              workoutText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].durationSummary()}");
              break;
          }
        }
      }
      return workoutText.toString();
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
