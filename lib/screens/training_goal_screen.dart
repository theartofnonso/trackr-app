import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/training_goal_enums.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../colors.dart';

class TrainingGoalScreen extends StatelessWidget {
  final TrainingGoal trainingGoal;

  const TrainingGoalScreen({super.key, required this.trainingGoal});

  /// Select an muscle group
  void _selectTrainingGoal({required BuildContext context, required TrainingGoal goal}) {
    Navigator.of(context).pop(goal);
  }

  @override
  Widget build(BuildContext context) {
    final trainingGoals = TrainingGoal.values;

    return Scaffold(
      appBar: AppBar(
        title: Text("Training Goal".toUpperCase()),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      final goal = trainingGoals[index];
                      return ListTile(
                          onTap: () => _selectTrainingGoal(context: context, goal: goal),
                          title: Text(
                            trainingGoals[index].displayName,
                            style: GoogleFonts.ubuntu(fontSize: 16),
                          ),
                          trailing: goal == trainingGoal
                              ? const FaIcon(FontAwesomeIcons.solidSquareCheck, color: vibrantGreen)
                              : const FaIcon(FontAwesomeIcons.solidSquareCheck),
                          subtitle: Text(trainingGoals[index].description,
                              style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w300, height: 1.8)));
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(color: Colors.white70.withValues(alpha: 0.1)),
                    itemCount: trainingGoals.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
