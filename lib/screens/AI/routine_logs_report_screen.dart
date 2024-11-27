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

class RoutineLogsReportScreen extends StatelessWidget {
  final MuscleGroup muscleGroup;
  final List<ExerciseLogDto> exerciseLogs;
  final RoutineLogsReportDto report;

  const RoutineLogsReportScreen(
      {super.key, required this.muscleGroup, required this.report, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {
    final exerciseLogsByDay = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.createdAt.withoutTime());

    return Scaffold(
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
                Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
                      onPressed: Navigator.of(context).pop,
                    ),
                    Expanded(
                      child: Text("${muscleGroup.name} Report".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
                    ),
                    IconButton(
                      icon: const SizedBox.shrink(),
                      onPressed: () {},
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: TRKRCoachWidget(),
                          titleAlignment: ListTileTitleAlignment.top,
                          title: Text(report.introduction,
                              style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
                        ),
                        ListTile(
                          leading: TRKRCoachWidget(),
                          titleAlignment: ListTileTitleAlignment.top,
                          title: Text(
                              "You trained ${muscleGroup.name} for a total of ${exerciseLogsByDay.length} sessions.",
                              style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                          child: LabelContainerDivider(
                              labelAlignment: LabelAlignment.left,
                              label: "training and performance".toUpperCase(),
                              description:
                              "See training and personal best achievements across all logged sessions.",
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
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.arrowRightLong,
                                          size: 16,
                                          color: Colors.white70,
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
                                          color: Colors.white70,
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
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: exerciseReport.dropsInPerformance
                                            .map((content) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.arrowRightLong,
                                                size: 16,
                                                color: Colors.white70,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(content,
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.deepOrange,
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 16)),
                                              ),
                                            ],
                                          ),
                                        ))
                                            .toList()),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(exerciseReport.comments,
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 16)),
                                  ]),
                                );
                              },
                              separatorBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(height: 1, color: Colors.transparent),
                              ),
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
                )
              ],
            ),
          ),
        ));
  }
}