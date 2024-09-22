import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/routine_template_extension.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/information_container_lite.dart';

import '../../../../dtos/exercise_log_dto.dart';
import '../../../colors.dart';
import '../../../controllers/routine_template_controller.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../../dtos/viewmodels/routine_log_arguments.dart';
import '../../../dtos/viewmodels/routine_template_arguments.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../enums/routine_preview_type_enum.dart';
import '../../../urls.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/routine_utils.dart';
import '../../../widgets/backgrounds/overlay_background.dart';
import '../../../widgets/routine/preview/exercise_log_listview.dart';
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

  bool _isOwner = false;

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

  @override
  Widget build(BuildContext context) {
    RoutineTemplateDto? template =
        Provider.of<RoutineTemplateController>(context, listen: true).templateWhere(id: widget.id);

    if (template == null) {
      Provider.of<RoutineTemplateController>(context, listen: false).fetchTemplate(id: widget.id);
      return const _EmptyState();
    }

    final menuActions = [
      MenuItemButton(
          onPressed: () {
            final arguments = RoutineTemplateArguments(template: template);
            navigateToRoutineTemplateEditor(context: context, arguments: arguments);
          },
          child: Text("Edit", style: GoogleFonts.montserrat())),
      MenuItemButton(
        onPressed: () {
          displayBottomSheet(
              height: 400,
              context: context,
              child: RoutineSchedulePlannerHome(template: template),
              isScrollControlled: true);
        },
        child: Text("Schedule", style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      MenuItemButton(onPressed: _showBottomSheet, child: Text("Share", style: GoogleFonts.montserrat())),
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
        child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
      )
    ];

    return Scaffold(
        floatingActionButton: _isOwner
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
            onPressed: () => context.pop(),
          ),
          title: Text(template.name,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
          actions: [
            _isOwner
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
                      Column(
                        children: [
                          Text(template.notes,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ExerciseLogListView(
                      exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: template.exerciseTemplates),
                      previewType: RoutinePreviewType.template,
                    ),
                  ],
                ),
              ),
            ),
            if (_loading) const OverlayBackground()
          ]),
        ));
  }

  void _loadData() {
    final routineTemplateController = Provider.of<RoutineTemplateController>(context, listen: false);
    _template = routineTemplateController.templateWhere(id: widget.id);
    if (_template == null) {
      _loading = true;
      routineTemplateController.fetchTemplate(id: widget.id).then((data) {
        setState(() {
          _loading = false;
          _template = data?.dto();
        });
      });
    } else {
      _isOwner = _template != null;
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
                      style: GoogleFonts.montserrat(
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
                  style: GoogleFonts.montserrat(
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
      if(template.notes.isNotEmpty) {
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

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs.map((exerciseLog) {
      return ExerciseLogViewModel(
          exerciseLog: exerciseLog,
          superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
    }).toList();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text("Workout",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
      ),
      body: Container(
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
        child: SafeArea(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                  text: TextSpan(
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                      children: [
                    TextSpan(
                        text: "Not F",
                        style:
                            GoogleFonts.montserrat(fontSize: 48, color: Colors.white70, fontWeight: FontWeight.w900)),
                    const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 48, color: Colors.white70),
                        ),
                        alignment: PlaceholderAlignment.middle),
                    TextSpan(
                        text: "und",
                        style:
                            GoogleFonts.montserrat(fontSize: 48, color: Colors.white70, fontWeight: FontWeight.w900)),
                  ])),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: InformationContainerLite(
                    content: "We can't find this workout, Please check the link and try again.", color: Colors.orange),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
