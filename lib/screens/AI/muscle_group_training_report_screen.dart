import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/exercise_performance_report.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/dividers/label_container_divider.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../utils/general_utils.dart';
import '../../widgets/routine/preview/exercise_log_widget.dart';

class MuscleGroupTrainingReportScreen extends StatelessWidget {
  final MuscleGroup muscleGroup;
  final List<ExerciseLogDto> exerciseLogs;
  final ExercisePerformanceReport report;

  const MuscleGroupTrainingReportScreen(
      {super.key, required this.muscleGroup, required this.report, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("${muscleGroup.name} Training Report".toUpperCase()),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
            bottom: false,
            minimum: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0, bottom: 16, left: 10),
                          child: LabelContainerDivider(
                              labelAlignment: LabelAlignment.left,
                              label: "training and performance".toUpperCase(),
                              description: "Review your performance across your ${muscleGroup.name} training sessions.",
                              labelStyle: Theme.of(context).textTheme.bodyLarge!,
                              descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
                              dividerColor: sapphireLighter),
                        ),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final exerciseReport = report.exerciseReports[index];
                              final exerciseLog = exerciseLogs
                                  .lastWhere((exerciseLog) => exerciseReport.exerciseId == exerciseLog.exercise.id);
                              return _ExerciseReportWidget(exerciseLog: exerciseLog, exerciseReport: exerciseReport);
                            },
                            separatorBuilder: (context, index) => SizedBox(height: 20),
                            itemCount: report.exerciseReports.length),
                        LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Recommendations".toUpperCase(),
                            description:
                                "Here are some tailored recommendations to help you optimize your future training sessions.",
                            labelStyle: Theme.of(context).textTheme.bodyLarge!,
                            descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
                            dividerColor: sapphireLighter),
                        const SizedBox(height: 10),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final suggestion = report.suggestions[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TRKRCoachWidget(),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(suggestion,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16)))
                                ],
                              );
                            },
                            separatorBuilder: (context, index) => SizedBox(height: 20),
                            itemCount: report.suggestions.length),
                      ],
                    ),
                  ),
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
                label: "Feedback".toUpperCase(),
                description: exerciseReport.comments,
                labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 12),
                descriptionStyle: GoogleFonts.ubuntu(height: 1.5, fontSize: 16, fontWeight: FontWeight.w300),
                dividerColor: sapphireLighter)
          ],
        ));
  }
}
