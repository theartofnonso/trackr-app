import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';
import 'package:tracker_app/enums/chart_unit_enum.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/open_ai_response_schema_dtos/monthly_training_report.dart';
import '../../enums/activity_type_enums.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/chart/line_chart_widget.dart';
import '../../widgets/chart/muscle_group_family_frequency_chart.dart';
import '../../widgets/dividers/label_container_divider.dart';
import '../../widgets/shareables/pbs_shareable.dart';

class MonthlyTrainingReportScreen extends StatelessWidget {
  final DateTime dateTime;
  final MonthlyTrainingReport monthlyTrainingReport;
  final List<RoutineLogDto> routineLogs;
  final List<ActivityLogDto> activityLogs;

  const MonthlyTrainingReportScreen(
      {super.key,
      required this.dateTime,
      required this.monthlyTrainingReport,
      required this.routineLogs,
      required this.activityLogs});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final activitiesChildren = activityLogs.map((activityLog) => activityLog.name).toSet().mapIndexed((index, activity) {
      final activityType = ActivityType.fromJson(activity);

      final image = activityType.image;

      return _ActivityChip(image: image, activityType: activityType, nameOrSummary: activityLogs[index].nameOrSummary,);
    }).toList();

    final exercises = routineLogs
        .map((routineLog) => loggedExercises(exerciseLogs: routineLog.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .map((exerciseLog) => exerciseLog.exercise.name)
        .toSet();

    final exercisesScrollViewHalf = exercises.length > 10 ? exercises.length ~/ 2 : exercises.length;

    final exercisesChildren = exercises.map((exerciseName) => _Chip(label: exerciseName)).toList();

    final exerciseLogsWithCompletedSets = routineLogs
        .map((routineLog) => loggedExercises(exerciseLogs: routineLog.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();

    final muscleGroupFamilyFrequencies =
        muscleGroupFamilyFrequency(exerciseLogs: exerciseLogsWithCompletedSets, includeSecondaryMuscleGroups: false);

    final exerciseAndRoutineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pbs = routineLogs
        .expand((routineLog) => routineLog.exerciseLogs)
        .map((exerciseLog) {
          final pastExerciseLogs = exerciseAndRoutineLogController.whereExerciseLogsBefore(
              exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

          return calculatePBs(
              pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
        })
        .expand((pbs) => pbs)
        .map((pb) =>
            SizedBox(width: 400, height: 400, child: PBsShareable(set: pb.set, pbDto: pb, globalKey: GlobalKey())))
        .toList();

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final calories = routineLogs.map((log) => calculateCalories(
        duration: log.duration(),
        bodyWeight: (routineUserController.user?.weight)?.toDouble() ?? 0.0,
        activity: log.activityType));

    final chartPoints = calories.mapIndexed((index, calories) => ChartPointDto(index, calories)).toList();

    final dateTimes = routineLogs.map((log) => log.createdAt.formattedMonth()).toList();

    final durations = routineLogs.map((log) => log.duration().inMilliseconds).toList();

    final minDuration = Duration(milliseconds: durations.min);
    final avgDuration = Duration(milliseconds: durations.average.ceil());
    final maxDuration = Duration(milliseconds: durations.max);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
          title: Text("${dateTime.formattedFullMonth()} Review".toUpperCase(), textAlign: TextAlign.center),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
              bottom: false,
              minimum: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Calendar(dateTime: dateTime),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TRKRCoachWidget(),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(monthlyTrainingReport.introduction,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16, height: 1.8)))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                          labelAlignment: LabelAlignment.left,
                          label: "Exercises".toUpperCase(),
                          description: monthlyTrainingReport.exercisesSummary,
                          labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                         descriptionStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 2),
                          dividerColor: sapphireLighter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: exercisesScrollViewHalf == exercisesChildren.length
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Wrap(spacing: 6, runSpacing: 6, children: [
                                      ...exercisesChildren.sublist(0, exercisesScrollViewHalf),
                                    ]))
                                : Column(
                                    children: [
                                      SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Wrap(spacing: 6, runSpacing: 6, children: [
                                            ...exercisesChildren.sublist(0, exercisesScrollViewHalf),
                                          ])),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Wrap(spacing: 6, children: [
                                            ...exercisesChildren.sublist(exercisesScrollViewHalf),
                                          ])),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Muscle Groups Trained".toUpperCase(),
                            description: monthlyTrainingReport.musclesTrainedSummary,
                            labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                           descriptionStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 2),
                            dividerColor: sapphireLighter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: MuscleGroupFamilyFrequencyChart(
                                  frequencyData: muscleGroupFamilyFrequencies, minimized: false),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                          labelAlignment: LabelAlignment.left,
                          label: "Personal Bests".toUpperCase(),
                          description: monthlyTrainingReport.personalBestsSummary,
                          labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                         descriptionStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 2),
                          dividerColor: sapphireLighter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: pbs)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                          labelAlignment: LabelAlignment.left,
                          label: "Calories Burned".toUpperCase(),
                          description: monthlyTrainingReport.caloriesBurnedSummary,
                          labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                         descriptionStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 2),
                          dividerColor: sapphireLighter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                            child: LineChartWidget(
                              chartPoints: chartPoints,
                              periods: dateTimes,
                              unit: ChartUnit.number,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                          labelAlignment: LabelAlignment.left,
                          label: "Training Duration".toUpperCase(),
                          description: monthlyTrainingReport.workoutDurationSummary,
                          labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                          descriptionStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 2),
                          dividerColor: sapphireLighter,
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _RowItem(
                                  subTitle: "Min",
                                  title: minDuration.hmDigital(),
                                  titleColor: _getTitleColour(isDarkMode: isDarkMode),
                                  subTitleColor: _getSubTitleColour(isDarkMode: isDarkMode),
                                ),
                                Expanded(
                                    child: Divider(
                                  color: _getSubTitleColour(isDarkMode: isDarkMode),
                                  height: 0.5,
                                )),
                                _RowItem(
                                  subTitle: "Avg",
                                  title: avgDuration.hmDigital(),
                                  titleColor: _getTitleColour(isDarkMode: isDarkMode),
                                  subTitleColor: _getSubTitleColour(isDarkMode: isDarkMode),
                                ),
                                Expanded(
                                    child: Divider(
                                  color: _getSubTitleColour(isDarkMode: isDarkMode),
                                  height: 0.5,
                                )),
                                _RowItem(
                                  subTitle: "Max",
                                  title: maxDuration.hmDigital(),
                                  titleColor: _getTitleColour(isDarkMode: isDarkMode),
                                  subTitleColor: _getSubTitleColour(isDarkMode: isDarkMode),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                          labelAlignment: LabelAlignment.left,
                          label: "Other Activities".toUpperCase(),
                          description: monthlyTrainingReport.activitiesSummary,
                          labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                         descriptionStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 2),
                          dividerColor: sapphireLighter,
                          child: activitiesChildren.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: activitiesChildren,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TRKRCoachWidget(),
                            const SizedBox(width: 10),
                            Expanded(
                                child: MarkdownBody(
                              data: monthlyTrainingReport.recommendations,
                              styleSheet: MarkdownStyleSheet(
                                h1: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.8),
                                h2: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.8),
                                h3: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.8),
                                h4: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.8),
                                h5: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.8),
                                h6: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.8),
                                p: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.8),
                              ),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ))),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )),
        ));
  }

  Color _getTitleColour({required bool isDarkMode}) {
    return isDarkMode ? Colors.white : Colors.black;
  }

  Color _getSubTitleColour({required bool isDarkMode}) {
    return isDarkMode ? Colors.white70 : Colors.grey.shade600;
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.image,
    required this.activityType, required this.nameOrSummary,
  });

  final String? image;
  final ActivityType activityType;
  final String nameOrSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.greenAccent, // Dark background color
          borderRadius: BorderRadius.circular(5.0), // Rounded corners
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.start,
          children: [
            image != null
                ? Image.asset(
                    'icons/$image.png',
                    fit: BoxFit.contain,
                    height: 12,
                    color: Colors.black, // Adjust the height as needed
                  )
                : FaIcon(
                    activityType.icon,
                    color: Colors.black,
                    size: 12,
                  ),
            const SizedBox(
              width: 4,
            ),
            Text(
              nameOrSummary.toUpperCase(),
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 12),
            )
          ],
        ));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: vibrantGreen, // Dark background color
          borderRadius: BorderRadius.circular(5.0), // Rounded corners
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 12),
        ));
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color titleColor;
  final Color subTitleColor;

  const _RowItem({
    required this.title,
    required this.subTitle,
    required this.titleColor,
    required this.subTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.ubuntu(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subTitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              color: subTitleColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
