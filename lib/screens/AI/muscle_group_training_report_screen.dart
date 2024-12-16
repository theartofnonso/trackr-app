import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/dividers/label_container_divider.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/open_ai_response_schema_dtos/routine_logs_report_dto.dart';
import '../../utils/general_utils.dart';

class MuscleGroupTrainingReportScreen extends StatelessWidget {
  final MuscleGroup muscleGroup;
  final List<ExerciseLogDto> exerciseLogs;
  final RoutineLogsReportDto report;

  const MuscleGroupTrainingReportScreen(
      {super.key, required this.muscleGroup, required this.report, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {
    final exerciseLogsByDay = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.createdAt.withoutTime());

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
          title: Text("${muscleGroup.name} Report".toUpperCase(), textAlign: TextAlign.center),
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
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TRKRCoachWidget(),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(report.introduction,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16)))
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TRKRCoachWidget(),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(
                                    "You trained ${muscleGroup.name} for a total of ${exerciseLogsByDay.length} sessions.",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16)))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: LabelContainerDivider(
                              labelAlignment: LabelAlignment.left,
                              label: "training and performance".toUpperCase(),
                              description: "See training and personal best achievements across all logged sessions.",
                              labelStyle: Theme.of(context).textTheme.bodyLarge!,
                              descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
                              dividerColor: sapphireLighter),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final exerciseReport = report.exerciseReports[index];
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
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(exerciseReport.exerciseName.toUpperCase(),
                                        style: Theme.of(context).textTheme.bodyMedium),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.arrowRightLong,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text("Heaviest lift is ${exerciseReport.heaviestWeight}",
                                              style: GoogleFonts.ubuntu(
                                                  color: vibrantGreen, fontWeight: FontWeight.w400, fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.arrowRightLong,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text("Heaviest volume is ${exerciseReport.heaviestVolume}",
                                              style: GoogleFonts.ubuntu(
                                                  color: vibrantGreen, fontWeight: FontWeight.w400, fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(exerciseReport.comments,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16)),
                                  ]),
                                );
                              },
                              separatorBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Divider(height: 1, color: Colors.transparent),
                                  ),
                              itemCount: report.exerciseReports.length),
                        ),
                        LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Recommendations".toUpperCase(),
                            description:
                                "Here are some tailored recommendations to help you optimize your future training sessions.",
                            labelStyle: Theme.of(context).textTheme.bodyLarge!,
                            descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
                            dividerColor: sapphireLighter),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TRKRCoachWidget(),
                            const SizedBox(width: 10),
                            Expanded(
                                child: MarkdownBody(
                              data: report.suggestions,
                              styleSheet: MarkdownStyleSheet(
                                h1: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                h2: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                h3: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                h4: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                h5: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                h6: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                p: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                              ),
                            ))
                          ],
                        ),
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
