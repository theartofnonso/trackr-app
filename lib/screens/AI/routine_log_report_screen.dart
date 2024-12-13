import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/dividers/label_container_divider.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../dtos/open_ai_response_schema_dtos/exercise_performance_report.dart';

class RoutineLogReportScreen extends StatelessWidget {
  final ExercisePerformanceReport report;

  const RoutineLogReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
          title: Text(report.title.toUpperCase(),
              textAlign: TextAlign.center),
          centerTitle: true,
        ),
        body: SafeArea(
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
                      ListTile(
                        tileColor: Colors.transparent,
                        leading: TRKRCoachWidget(),
                        titleAlignment: ListTileTitleAlignment.top,
                        title: Text(report.introduction,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
                        child: LabelContainerDivider(
                            labelAlignment: LabelAlignment.left,
                            label: "training and performance".toUpperCase(),
                            description: "Review your performance in comparison to previous sessions.",
                            labelStyle: Theme.of(context).textTheme.bodyLarge!,
                            descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
                            dividerColor: sapphireLighter),
                      ),
                      ListView.separated(
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
                      LabelContainerDivider(
                          labelAlignment: LabelAlignment.left,
                          label: "Recommendations".toUpperCase(),
                          description:
                          "Here are some tailored recommendations to help you optimize your future training sessions.",
                          labelStyle: Theme.of(context).textTheme.bodyLarge!,
                          descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
                          dividerColor: sapphireLighter),
                      ListTile(
                        tileColor: Colors.transparent,
                        leading: TRKRCoachWidget(),
                        titleAlignment: ListTileTitleAlignment.top,
                        title: MarkdownBody(
                          data: report.suggestions,
                          styleSheet: MarkdownStyleSheet(
                            h1: Theme.of(context).textTheme.bodyLarge,
                            h2: Theme.of(context).textTheme.bodyLarge,
                            h3: Theme.of(context).textTheme.bodyLarge,
                            h4: Theme.of(context).textTheme.bodyLarge,
                            h5: Theme.of(context).textTheme.bodyLarge,
                            h6: Theme.of(context).textTheme.bodyLarge,
                            p: Theme.of(context).textTheme.bodyMedium,
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
                labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: vibrantGreen),
                descriptionStyle: Theme.of(context).textTheme.bodyMedium!,
                dividerColor: sapphireLighter)
          ],
        ));
  }
}
