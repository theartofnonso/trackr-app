import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/dividers/label_container_divider.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../dtos/open_ai_response_schema_dtos/exercise_performance_report.dart';

class RoutineLogReportScreen extends StatelessWidget {
  final RoutineLogDto routineLog;
  final ExercisePerformanceReport report;

  const RoutineLogReportScreen({super.key, required this.routineLog, required this.report});

  @override
  Widget build(BuildContext context) {
    final totalExercises = completedExercises(exerciseLogs: routineLog.exerciseLogs);

    final totalSets = totalExercises.expand((log) => log.sets);

    final totalDuration = routineLog.duration();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
          title: Text("${routineLog.name} Review".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
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
                        ListTile(
                          leading: TRKRCoachWidget(),
                          titleAlignment: ListTileTitleAlignment.top,
                          title: Text(report.introduction,
                              style:
                                  GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
                        ),
                        ListTile(
                          leading: TRKRCoachWidget(),
                          titleAlignment: ListTileTitleAlignment.top,
                          title: Text(
                              "You completed ${totalExercises.length} exercises with a total of ${totalSets.length} sets in ${routineLog.name} for a total of ${totalDuration.hmsAnalog()}.",
                              style:
                                  GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                          child: LabelContainerDivider(
                              labelAlignment: LabelAlignment.left,
                              label: "training and performance".toUpperCase(),
                              description: "Review your performance in comparison to previous sessions.",
                              labelStyle:
                                  GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                              descriptionStyle: GoogleFonts.ubuntu(
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              dividerColor: sapphireLighter),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final exerciseReport = report.exerciseReports[index];
                                final sets = exerciseReport.currentPerformance.sets
                                    .map((set) =>
                                        WeightAndRepsSetDto(weight: set.weight, reps: set.repetitions, checked: true))
                                    .toList();
                                final exerciseLog = ExerciseLogDto(
                                    id: '',
                                    routineLogId: '',
                                    superSetId: '',
                                    exercise: ExerciseDto(
                                        id: "",
                                        name: exerciseReport.exerciseName,
                                        primaryMuscleGroup: MuscleGroup.fullBody,
                                        secondaryMuscleGroups: [],
                                        type: ExerciseType.weights,
                                        owner: ""),
                                    notes: exerciseReport.comments,
                                    sets: sets,
                                    createdAt: DateTime.now());
                                return _ExerciseReportWidget(exerciseLog: exerciseLog, exerciseReport: exerciseReport);
                              },
                              separatorBuilder: (context, index) => SizedBox(height: 20),
                              itemCount: report.exerciseReports.length),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                          child: LabelContainerDivider(
                              labelAlignment: LabelAlignment.left,
                              label: "Recommendations".toUpperCase(),
                              description:
                                  "Here are some tailored recommendations to help you optimize your future training sessions.",
                              labelStyle:
                                  GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                              descriptionStyle: GoogleFonts.ubuntu(
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                              dividerColor: sapphireLighter),
                        ),
                        ListTile(
                          leading: TRKRCoachWidget(),
                          titleAlignment: ListTileTitleAlignment.top,
                          title: MarkdownBody(
                            data: report.suggestions,
                            styleSheet: MarkdownStyleSheet(
                              h1: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              h2: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              h3: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                              h4: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              h5: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              h6: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              p: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ));
  }
}

class _ExerciseReportWidget extends StatelessWidget {
  const _ExerciseReportWidget({
    required this.exerciseLog,
    required this.exerciseReport,
  });

  final ExerciseLogDto exerciseLog;
  final ExerciseReport exerciseReport;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent, // Makes the background transparent
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: sapphireLighter, // Border color
            width: 1.0, // Border width
          ), // Adjust the radius as needed
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExerciseLogWidget(exerciseLog: exerciseLog),
            const SizedBox(height: 16),
            LabelContainerDivider(
                labelAlignment: LabelAlignment.left,
                label: "Achievements".toUpperCase(),
                description: exerciseReport.achievements,
                labelStyle: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w900, fontSize: 16),
                descriptionStyle: GoogleFonts.ubuntu(
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                dividerColor: sapphireLighter)
          ],
        ));
  }
}
