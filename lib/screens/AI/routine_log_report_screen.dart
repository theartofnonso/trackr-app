import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/dividers/label_container_divider.dart';

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
