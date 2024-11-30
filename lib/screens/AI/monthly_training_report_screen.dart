import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../colors.dart';
import '../../dtos/open_ai_response_schema_dtos/monthly_training_report.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/dividers/label_container_divider.dart';

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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
          title: Text("${dateTime.formattedFullMonth()} Review".toUpperCase(),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Calendar(dateTime: dateTime),
                      ),
                      ListTile(
                        leading: TRKRCoachWidget(),
                        titleAlignment: ListTileTitleAlignment.top,
                        title: Text(monthlyTrainingReport.introduction,
                            style:
                            GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Exercises".toUpperCase(),
                            description: monthlyTrainingReport.exercisesSummary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Muscle Groups Trained".toUpperCase(),
                            description: monthlyTrainingReport.musclesTrainedSummary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                              label: "Volume".toUpperCase(),
                            description: monthlyTrainingReport.volumeLiftedSummary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Personal Bests".toUpperCase(),
                            description: monthlyTrainingReport.personalBestsSummary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Calories Burned".toUpperCase(),
                            description: monthlyTrainingReport.caloriesBurnedSummary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Training Duration".toUpperCase(),
                            description: monthlyTrainingReport.workoutDurationSummary,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "Other Activities".toUpperCase(),
                            description: monthlyTrainingReport.activitiesSummary,
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
                        title: Text(monthlyTrainingReport.recommendations,
                            style:
                            GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16)),
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
}
