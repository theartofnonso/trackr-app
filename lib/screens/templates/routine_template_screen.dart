import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/screens/editors/workout_video_generator_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../dtos/viewmodels/routine_template_arguments.dart';
import '../../enums/chart_unit_enum.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../enums/routine_preview_type_enum.dart';
import '../../models/RoutineTemplate.dart';
import '../../urls.dart';
import '../../utils/data_trend_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/https_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
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

  RecoveryResult? _selectedMuscleAndRecovery;

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
      final copyOfTemplate = template.copyWith();
      final arguments = RoutineTemplateArguments(template: copyOfTemplate);
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

    final allLogsForTemplate = exerciseAndRoutineController
        .whereLogsWithTemplateId(templateId: template.id)
        .map((log) => routineWithLoggedExercises(log: log))
        .toList();

    final allLoggedVolumesForTemplate = allLogsForTemplate.map((log) => log.volume).toList();

    final avgVolume = allLoggedVolumesForTemplate.isNotEmpty ? allLoggedVolumesForTemplate.average : 0.0;

    final volumeChartPoints =
        allLoggedVolumesForTemplate.mapIndexed((index, volume) => ChartPointDto(index, volume)).toList();

    final trendSummary = _analyzeWeeklyTrends(volumes: allLoggedVolumesForTemplate);

    final listOfMuscleAndRecovery = template.exerciseTemplates
        .map((exerciseTemplate) => exerciseTemplate.exercise.primaryMuscleGroup)
        .toSet()
        .map((muscleGroup) {
      final pastExerciseLogs =
          (Provider.of<ExerciseAndRoutineController>(context, listen: false).exerciseLogsByMuscleGroup[muscleGroup] ??
              []);
      final lastExerciseLog = pastExerciseLogs.isNotEmpty ? pastExerciseLogs.last : null;
      final lastTrainingTime = lastExerciseLog?.createdAt;
      final recovery = lastTrainingTime != null
          ? _calculateMuscleRecovery(lastTrainingTime: lastTrainingTime, muscleGroup: muscleGroup)
          : RecoveryResult(
              recoveryPercentage: 0,
              muscleGroup: muscleGroup,
              lastTrainingTime: DateTime.now(),
              description:
                  "No recovery data available for $muscleGroup. Please log a $muscleGroup session to see updated recovery.");
      return recovery;
    });

    final selectedMuscleAndRecovery =
        _selectedMuscleAndRecovery ?? (listOfMuscleAndRecovery.isNotEmpty ? listOfMuscleAndRecovery.first : null);

    final muscleGroupsIllustrations = listOfMuscleAndRecovery.map((muscleAndRecovery) {
      final muscleGroup = muscleAndRecovery.muscleGroup;
      final recovery = muscleAndRecovery.recoveryPercentage;

      return Badge(
        backgroundColor: recoveryColor(recovery),
        alignment: Alignment.topRight,
        smallSize: 12,
        isLabelVisible: muscleGroup == selectedMuscleAndRecovery?.muscleGroup,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedMuscleAndRecovery = muscleAndRecovery;
            });
          },
          child: Stack(alignment: Alignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: recovery,
                  strokeWidth: 6,
                  backgroundColor: isDarkMode ? Colors.black12 : Colors.grey.shade200,
                  strokeCap: StrokeCap.butt,
                  valueColor: AlwaysStoppedAnimation<Color>(recoveryColor(recovery)),
                ),
              ),
            ),
            Image.asset(
              recoveryMuscleIllustration(recoveryPercentage: recovery, muscleGroup: muscleGroup),
              fit: BoxFit.contain,
              height: 50, // Adjust the height as needed
            )
          ]),
        ),
      );
    }).toList();

    final menuActions = [
      MenuItemButton(
          onPressed: _navigateToRoutineTemplateEditor,
          leadingIcon: FaIcon(FontAwesomeIcons.solidPenToSquare, size: 16),
          child: Text("Edit", style: GoogleFonts.ubuntu())),
      MenuItemButton(
        onPressed: _navigateToWorkoutVideoGenerator,
        leadingIcon: FaIcon(FontAwesomeIcons.link, size: 16),
        child: Text("Video", style: GoogleFonts.ubuntu()),
      ),
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
            minimum: const EdgeInsets.only(top: 10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      spacing: 20,
                      children: [
                        Column(
                          spacing: 6,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.calendarDay,
                                      color: Colors.deepOrange,
                                      size: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    scheduledDaysSummary(template: template, showFullName: true),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.solidNoteSticky,
                                      color: Colors.yellow,
                                      size: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    template.notes.isNotEmpty ? "${template.notes}." : "No notes",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                                    color: isDarkMode ? sapphireLighter.withValues(alpha: 0.4) : Colors.white,
                                    width: 2)),
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
                            description:
                                "Here's a breakdown of the muscle groups in your ${template.name} workout plan.",
                            muscleGroupFamilyFrequencies: muscleGroupFamilyFrequencies,
                            minimized: false),
                      ],
                    ),
                  ),
                  if (template.owner == SharedPrefs().userId)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                children: [
                                  trendSummary.trend == Trend.none
                                      ? const SizedBox.shrink()
                                      : getTrendIcon(trend: trendSummary.trend),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: volumeInKOrM(avgVolume),
                                          style: Theme.of(context).textTheme.headlineSmall,
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
                                        "Session AVERAGE".toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Text(trendSummary.summary,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
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
                          Text(
                              "Here’s a summary of your ${template.name} training intensity over the last ${allLogsForTemplate.length} ${pluralize(word: "session", count: allLogsForTemplate.length)}.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                          const SizedBox(height: 12),
                          InformationContainer(
                            leadingIcon: FaIcon(FontAwesomeIcons.weightHanging),
                            title: "Training Volume",
                            color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
                            description:
                                "Volume is the total amount of work done, often calculated as sets × reps × weight. Higher volume increases muscle size (hypertrophy).",
                          ),
                        ],
                      ),
                    ),
                  if (template.owner == SharedPrefs().userId)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Muscle Recovery".toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          Text(
                              "Delayed Onset Muscle Soreness (DOMS) refers to the muscle pain or stiffness experienced after intense physical activity. It typically develops 24 to 48 hours after exercise and can last for several days.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                        ],
                      ),
                    ),
                  if (template.owner == SharedPrefs().userId && listOfMuscleAndRecovery.isNotEmpty)
                    Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 20, children: [
                              SizedBox(width: 2),
                              ...muscleGroupsIllustrations,
                              SizedBox(width: 2),
                            ])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(selectedMuscleAndRecovery?.description ?? "",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white : Colors.black)),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      spacing: 20,
                      children: [
                        ExerciseLogListView(
                          exerciseLogs: exerciseLogsToViewModels(exerciseLogs: template.exerciseTemplates),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                      ],
                    ),
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
      final arguments = RoutineLogArguments(
          log: template.toLog(), editorMode: RoutineEditorMode.log, workoutVideo: template.workoutVideoUrl);
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
          return exerciseLog.copyWith(sets: uncheckedSets);
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
    final copyOfTemplate = template.copyWith();
    final updatedTemplate =
        await displayBottomSheet(context: context, child: RoutineDayPlanner(template: copyOfTemplate))
            as RoutineTemplateDto?;

    if (updatedTemplate != null) {
      setState(() {
        _template = updatedTemplate;
      });
    }
  }

  void _navigateToWorkoutVideoGenerator() async {
    final template = _template;
    if (template != null) {
      final workoutVideoUrl = await navigateWithSlideTransition(
          context: context,
          child: WorkoutVideoGeneratorScreen(
            workoutVideoUrl: template.workoutVideoUrl,
          ));
      if (mounted) {
        final templateToUpdate = template.copyWith(workoutVideoUrl: workoutVideoUrl);
        await Provider.of<ExerciseAndRoutineController>(context, listen: false)
            .updateTemplate(template: templateToUpdate);

        setState(() {
          _template = templateToUpdate;
        });
      }
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
                  Posthog().capture(eventName: PostHogAnalyticsEvent.shareRoutineTemplateAsLink.displayName);
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
                  Posthog().capture(eventName: PostHogAnalyticsEvent.shareRoutineTemplateAsText.displayName);
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  TrendSummary _analyzeWeeklyTrends({required List<double> volumes}) {
    // 1. Handle edge cases
    if (volumes.isEmpty) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No training data available yet. Log some sessions to start tracking your progress!");
    }

    if (volumes.length == 1) {
      return TrendSummary(
          trend: Trend.none,
          summary: "You've logged your first week's volume (${volumes.first})."
              " Great job! Keep logging more data to see trends over time.");
    }

    // 2. Identify the last week's volume and the average of all previous weeks
    final lastWeekVolume = volumes.last;

    if (lastWeekVolume == 0) {
      return TrendSummary(
          trend: Trend.none,
          summary: "No training data available for this week. Log some workouts to continue tracking your progress!");
    }

    final previousVolumes = volumes.sublist(0, volumes.length - 1);
    final averageOfPrevious = previousVolumes.reduce((a, b) => a + b) / previousVolumes.length;

    // 3. Compare last week's volume to the average of previous volumes
    final difference = lastWeekVolume - averageOfPrevious;

    // Special check for no difference
    final differenceIsZero = difference == 0;

    // If the average is zero, treat it as a special case for percentage change
    final bool averageIsZero = averageOfPrevious == 0;
    final double percentageChange = averageIsZero ? 100.0 : (difference / averageOfPrevious) * 100;

    // 4. Decide the trend
    const threshold = 5; // Adjust this threshold for "stable" as needed
    late final Trend trend;
    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    // 5. Generate a friendly, concise message based on the trend
    final variation = "${percentageChange.abs().toStringAsFixed(1)}%";

    switch (trend) {
      case Trend.up:
        return TrendSummary(
            trend: Trend.up,
            summary: "This session's volume is $variation higher than your average. "
                "Awesome job building momentum!");
      case Trend.down:
        return TrendSummary(
            trend: Trend.down,
            summary: "This session's volume is $variation lower than your average. "
                "Consider extra rest, checking your technique, or planning a deload.");
      case Trend.stable:
        final summary = differenceIsZero
            ? "You've matched your average exactly! Stay consistent to see long-term progress."
            : "Your volume changed by about $variation compared to your average. "
                "A great chance to refine your form and maintain consistency.";
        return TrendSummary(trend: Trend.stable, summary: summary);
      case Trend.none:
        return TrendSummary(trend: Trend.none, summary: "Unable to identify trends");
    }
  }
}

class RecoveryResult {
  final double recoveryPercentage;
  final MuscleGroup muscleGroup;
  final DateTime lastTrainingTime;
  final String description;

  RecoveryResult(
      {required this.recoveryPercentage,
      required this.muscleGroup,
      required this.lastTrainingTime,
      required this.description});

  @override
  String toString() {
    return 'RecoveryResult{recoveryPercentage: $recoveryPercentage, muscleGroup: $muscleGroup, lastTrainingTime: $lastTrainingTime, desciption: $description}';
  }
}

/// Calculates muscle recovery percentage based on time since last training.
/// - 0% means no recovery (extremely fresh DOMS).
/// - 100% means fully recovered.
/// - If more than 7 days have passed and soreness remains, we flag overtraining.
///
/// You can adjust these time thresholds or percentages as needed.
RecoveryResult _calculateMuscleRecovery({required DateTime lastTrainingTime, required MuscleGroup muscleGroup}) {
  // Calculate hours since last training.
  final hoursSinceTraining = DateTime.now().difference(lastTrainingTime).inHours;

  // A simple piecewise approach to approximate "percent recovered."
  // Tweak as needed for your app’s logic.
  double recoveryPercentage;

  String description;

  if (hoursSinceTraining < 24) {
    // Within first 24 hours after training — DOMS just starting
    recoveryPercentage = -0.01;
    description =
        "Your $muscleGroup was just trained. Be sure to allow enough recovery time—DOMS can appear within the next day or two";
  } else if (hoursSinceTraining < 48) {
    // 24–48 hours: muscle soreness typically peaks
    // We assume minimal recovery, e.g. up to ~30%
    final ratio = (hoursSinceTraining - 24) / 24;
    recoveryPercentage = 0.3 * ratio;
    description = "Your $muscleGroup is only ${(recoveryPercentage * 100).floor()}% recovered. DOMS is likely high. "
        "It's best to rest or do very light activity today.";
  } else if (hoursSinceTraining < 72) {
    // 48–72 hours: soreness usually starts to fade
    // Move recovery from ~30% to ~70%
    final ratio = (hoursSinceTraining - 48) / 24;
    recoveryPercentage = 0.3 + 0.4 * ratio; // ~30% -> 70%
    description =
        "Your $muscleGroup is about ${(recoveryPercentage * 100).floor()}% recovered. Moderate soreness may still be present. "
        "Light to moderate training can be considered, but monitor how you feel.";
  } else if (hoursSinceTraining < 96) {
    // 72–96 hours: typically nearing full recovery
    // Move recovery from ~70% to ~90%
    final ratio = (hoursSinceTraining - 72) / 24;
    recoveryPercentage = 0.7 + 0.2 * ratio; // ~70% -> 90%
    description = "Your $muscleGroup is ${(recoveryPercentage * 100).floor()}% recovered. Soreness should be minimal. "
        "Feel free to train, but keep an eye on any lingering tightness.";
  } else if (hoursSinceTraining < 168) {
    // 4–7 days: often fully recovered or very close
    // We treat this range as ~90% -> 100% recovery
    final ratio = (hoursSinceTraining - 96) / 72;
    recoveryPercentage = 0.9 + 0.1 * ratio; // ~90% -> 100%
    description = "Your $muscleGroup is ${(recoveryPercentage * 100).floor()}% recovered. Soreness should be minimal. "
        "Feel free to train, but keep an eye on any lingering tightness.";
  } else {
    // 7+ days of soreness likely indicates overtraining or incomplete recovery
    // You could set this to 100% and rely on [isOvertrained] for the warning,
    // or set it to 0% to indicate "inconsistent with normal recovery."
    // Below, we assume 100% physically, but isOvertrained = true means possible problem.
    recoveryPercentage = 1.0;
    description = "Your $muscleGroup is fully recovered at 100%. You're good to train!";
  }

  // Clamp between 0.0 and 1.0 in case of minor rounding
  recoveryPercentage = recoveryPercentage.clamp(0.0, 1.0);

  return RecoveryResult(
      recoveryPercentage: recoveryPercentage,
      muscleGroup: muscleGroup,
      lastTrainingTime: lastTrainingTime,
      description: description);
}
