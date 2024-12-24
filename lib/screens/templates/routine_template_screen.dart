import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../dtos/viewmodels/routine_template_arguments.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../enums/routine_preview_type_enum.dart';
import '../../models/RoutineTemplate.dart';
import '../../urls.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/https_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/chart/line_chart_widget.dart';
import '../../widgets/empty_states/not_found.dart';
import '../../widgets/information_containers/information_container.dart';
import '../../widgets/monthly_insights/muscle_groups_family_frequency_widget.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';
import 'routine_day_planner.dart';

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

  void _deleteRoutine({required RoutineTemplateDto template}) async {
    try {
      await Provider.of<ExerciseAndRoutineController>(context, listen: false).removeTemplate(template: template);
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
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    if (exerciseAndRoutineController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: exerciseAndRoutineController.errorMessage);
      });
    }

    final template = _template;

    if (template == null) return const NotFound();

    final numberOfSets = template.exerciseTemplates.expand((exerciseTemplate) => exerciseTemplate.sets);
    final setsSummary = "${numberOfSets.length} ${pluralize(word: "Set", count: numberOfSets.length)}";

    final muscleGroupFamilyFrequencies = muscleGroupFamilyFrequency(exerciseLogs: template.exerciseTemplates);

    final allLogsForTemplate = exerciseAndRoutineController.whereLogsWithTemplateId(templateId: template.id);

    final allLoggedVolumesForTemplate = allLogsForTemplate.map((log) => log.volume).toList();

    final avgVolume = allLoggedVolumesForTemplate.average;

    final volumeChartPoints =
        allLoggedVolumesForTemplate.mapIndexed((index, volume) => ChartPointDto(index, volume)).toList();

    final currentAndPreviousMonthVolume = _calculateCurrentAndPreviousLogVolume(logs: allLogsForTemplate);

    final previousMonthVolume = currentAndPreviousMonthVolume.$1;
    final currentMonthVolume = currentAndPreviousMonthVolume.$2;

    final improved = currentMonthVolume > previousMonthVolume;

    final difference = improved ? currentMonthVolume - previousMonthVolume : previousMonthVolume - currentMonthVolume;

    final differenceSummary = improved
        ? "Improved by ${volumeInKOrM(difference)} ${weightLabel()}"
        : "Reduced by ${volumeInKOrM(difference)} ${weightLabel()}";

    final menuActions = [
      MenuItemButton(
          onPressed: _navigateToRoutineTemplateEditor,
          leadingIcon: FaIcon(FontAwesomeIcons.solidPenToSquare, size: 16),
          child: Text("Edit", style: GoogleFonts.ubuntu())),
      MenuItemButton(
          onPressed: () => _createTemplate(copy: true),
          leadingIcon: FaIcon(Icons.copy, size: 16),
          child: Text("Copy", style: GoogleFonts.ubuntu())),
      MenuItemButton(
        onPressed: () => _updateTemplateSchedule(template: template),
        leadingIcon: FaIcon(FontAwesomeIcons.solidClock, size: 16),
        child: Text("Schedule", style: GoogleFonts.ubuntu()),
      ),
      MenuItemButton(
          leadingIcon: FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: 16),
          onPressed: _showShareBottomSheet,
          child: Text("Share", style: GoogleFonts.ubuntu())),
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
        leadingIcon: FaIcon(
          FontAwesomeIcons.trash,
          size: 16,
          color: Colors.redAccent,
        ),
        child: Text("Delete", style: GoogleFonts.ubuntu(color: Colors.redAccent)),
      )
    ];

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            heroTag: UniqueKey,
            onPressed: template.owner == SharedPrefs().userId ? _launchRoutineLogEditor : _createTemplate,
            child: template.owner == SharedPrefs().userId
                ? const FaIcon(FontAwesomeIcons.play, size: 24)
                : const FaIcon(FontAwesomeIcons.download)),
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
            onPressed: context.pop,
          ),
          centerTitle: true,
          title: Text(template.name),
          actions: [
            template.owner == SharedPrefs().userId
                ? MenuAnchor(
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
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
            bottom: false,
            minimum: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.solidClock,
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Text(scheduledDaysSummary(template: template, showFullName: true),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  if (template.notes.isNotEmpty)
                    Center(
                      child: Text('"${template.notes}"',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                      color: isDarkMode ? Colors.black12 : Colors.grey.shade200,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: BorderSide(
                              color: isDarkMode ? sapphireLighter.withValues(alpha: 0.4) : Colors.white, width: 2)),
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
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Center(
                              child: Text(setsSummary, style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  MuscleGroupSplitChart(
                      title: "Muscle Groups Split",
                      description: "Here's a breakdown of the muscle groups in your ${template.name} workout plan.",
                      muscleGroupFamilyFrequencies: muscleGroupFamilyFrequencies,
                      minimized: false),
                  if (template.owner == SharedPrefs().userId )
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: volumeInKOrM(avgVolume),
                          style: Theme.of(context).textTheme.headlineMedium,
                          children: [
                            TextSpan(
                              text: " ",
                            ),
                            TextSpan(
                              text: weightLabel().toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "SESSION AVERAGE".toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FaIcon(
                            improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                            color: improved ? vibrantGreen : Colors.deepOrange,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          OpacityButtonWidget(
                            label: differenceSummary,
                            buttonColor: improved ? vibrantGreen : Colors.deepOrange,
                          )
                        ],
                      )
                    ],
                  ),
                  Text(
                      "Here’s a summary of your ${template.name} training intensity over the last ${allLogsForTemplate.length} sessions.",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 16),
                        LineChartWidget(
                          chartPoints: volumeChartPoints,
                          periods: [],
                          unit: ChartUnit.weight,
                        ),
                      ],
                    ),
                  ),
                  InformationContainer(
                    leadingIcon: FaIcon(FontAwesomeIcons.weightHanging),
                    title: "Training Volume",
                    color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
                    description:
                        "Volume is the total amount of work done, often calculated as sets × reps × weight. Higher volume increases muscle size (hypertrophy).",
                  ),
                  const SizedBox(height: 1),
                  ExerciseLogListView(
                    exerciseLogs: exerciseLogsToViewModels(exerciseLogs: template.exerciseTemplates),
                  ),
                  const SizedBox(
                    height: 60,
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _launchRoutineLogEditor() {
    final template = _template;
    if (template != null) {
      final arguments = RoutineLogArguments(log: template.toLog(), editorMode: RoutineEditorMode.log);
      navigateToRoutineLogEditor(context: context, arguments: arguments);
    }
  }

  void _createTemplate({bool copy = false}) async {
    final template = _template;
    if (template != null) {
      _showLoadingScreen();

      try {
        final exercises = template.exerciseTemplates.map((exerciseLog) {
          final uncheckedSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();

          /// [Exercise.duration] exercises do not have sets in templates
          /// This is because we only need to store the duration of the exercise in [RoutineEditorType.log] i.e data is logged in realtime
          final sets = withDurationOnly(type: exerciseLog.exercise.type) ? <SetDto>[] : uncheckedSets;
          return exerciseLog.copyWith(sets: sets);
        }).toList();
        final templateToCreate = RoutineTemplateDto(
            id: "",
            name: copy ? "Copy of ${template.name}" : template.name,
            notes: template.notes,
            exerciseTemplates: exercises,
            owner: "",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());

        final createdTemplate = await Provider.of<ExerciseAndRoutineController>(context, listen: false)
            .saveTemplate(templateDto: templateToCreate);
        if (mounted) {
          if (createdTemplate != null) {
            navigateToRoutineTemplatePreview(context: context, template: createdTemplate);
          }
        }
      } catch (_) {
        if (mounted) {
          showSnackbar(
              context: context,
              icon: const Icon(Icons.info_outline),
              message: "Oops, we are unable to create template");
        }
      } finally {
        _hideLoadingScreen();
      }
    }
  }

  void _loadData() {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    _template = exerciseAndRoutineController.templateWhere(id: widget.id);
    if (_template == null) {
      _loading = true;
      getAPI(endpoint: "/routine-templates/${widget.id}").then((data) {
        if (data.isNotEmpty) {
          final json = jsonDecode(data);
          final body = json["data"];
          final routineTemplate = body["getRoutineTemplate"];
          if (routineTemplate != null) {
            final template = RoutineTemplate.fromJson(routineTemplate);
            setState(() {
              _loading = false;
              _template = RoutineTemplateDto.toDto(template);
            });
          } else {
            setState(() {
              _loading = false;
            });
          }
        }
      });
    }
  }

  void _updateTemplateSchedule({required RoutineTemplateDto template}) async {
    final updatedTemplate =
        await displayBottomSheet(context: context, child: RoutineDayPlanner(template: template)) as RoutineTemplateDto?;

    if (updatedTemplate != null) {
      setState(() {
        _template = updatedTemplate;
      });
    }
  }

  void _showShareBottomSheet() {
    final template = _template;

    if (template != null) {
      final workoutLink = "$shareableRoutineUrl/${template.id}";
      final workoutText = copyRoutineAsText(
          routineType: RoutinePreviewType.log,
          name: template.name,
          notes: template.notes,
          exerciseLogs: template.exerciseTemplates);

      displayBottomSheet(
          context: context,
          isScrollControlled: true,
          child: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const FaIcon(
                  FontAwesomeIcons.link,
                  size: 18,
                ),
                horizontalTitleGap: 10,
                title: Text(
                  "Copy as Link",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                  maxLines: 1,
                ),
                subtitle: Text(workoutLink),
                onTap: () {
                  if (kReleaseMode) {
                    Posthog().capture(eventName: PostHogAnalyticsEvent.shareRoutineLogAsLink.displayName);
                  }
                  HapticFeedback.heavyImpact();
                  final data = ClipboardData(text: workoutLink);
                  Clipboard.setData(data).then((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      showSnackbar(
                          context: context,
                          icon: const FaIcon(FontAwesomeIcons.solidSquareCheck),
                          message: "Workout link copied");
                    }
                  });
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const FaIcon(
                  FontAwesomeIcons.copy,
                  size: 18,
                ),
                horizontalTitleGap: 6,
                title: Text("Copy as Text", style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text("${template.name}..."),
                onTap: () {
                  if (kReleaseMode) {
                    Posthog().capture(eventName: PostHogAnalyticsEvent.shareRoutineTemplateAsText.displayName);
                  }
                  HapticFeedback.heavyImpact();
                  final data = ClipboardData(text: workoutText);
                  Clipboard.setData(data).then((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      showSnackbar(
                          context: context,
                          icon: const FaIcon(FontAwesomeIcons.solidSquareCheck),
                          message: "Workout copied");
                    }
                  });
                },
              ),
            ]),
          ));
    }
  }

  (double, double) _calculateCurrentAndPreviousLogVolume({required List<RoutineLogDto> logs}) {

    if (logs.isEmpty) {
      // No logs => no comparison
      return (0, 0);
    }

    // 2. Identify the most recent log
    final lastLog = logs.last;
    final lastLogVolume = lastLog.volume;
    final lastLogDate = lastLog.createdAt;

    final previousLogs = logs.where((log) => log.createdAt.isBefore(lastLogDate));

    if (previousLogs.isEmpty) {
      // No earlier logs => can't compare
      return (0, 0);
    }

    final previousLogVolume = previousLogs.last.volume;

    return (previousLogVolume, lastLogVolume);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
