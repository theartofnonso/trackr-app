import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';
import 'package:tracker_app/widgets/icons/custom_wordmark_icon.dart';
import 'package:tracker_app/widgets/icons/user_icon_widget.dart';

import '../../controllers/routine_user_controller.dart';
import '../../utils/date_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/training_archetype_utils.dart';

class UserProfileScreen extends StatelessWidget {
  static const routeName = '/user-profile-screen';

  const UserProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final user = Provider.of<RoutineUserController>(context, listen: true).user;

    if (user == null) {
      return Scaffold(
          appBar: AppBar(
              leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
            onPressed: context.pop,
          )),
          body: NoListEmptyState(
            message: '',
          ));
    }

    final weight = user.weight;
    final height = user.height;
    final heightConversion = heightWithConversion(value: height, unit: HeightUnit.ftIn);

    final dob = user.dateOfBirth;
    final age = _calculateAge(birthDate: dob);

    final gender = capitalizeFirstLetter(text: user.gender.display);

    final dateRange = theLastYearDateTimeRange();

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final logs = exerciseAndRoutineController.whereLogsIsWithinRange(range: dateRange).toList();

    final archetypes = TrainingArchetypeClassifier.classify(logs: logs);

    final children =
        archetypes.map((archetype) => CustomWordMarkIcon(archetype.description, color: vibrantGreen)).toList();

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
            onPressed: context.pop,
          ),
          actions: [
            IconButton(
                onPressed: () => navigateToUserEditor(context: context, user: user),
                icon: const FaIcon(FontAwesomeIcons.solidPenToSquare, size: 24)),
          ]),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 10),
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(spacing: 36, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Center(
                        child: UserIconWidget(size: 60, iconSize: 22),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(user.name.toUpperCase(),
                            style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ]),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 10,
                    children: [
                      _StatisticWidget(
                        title: "$age",
                        subtitle: "Age",
                      ),
                      _StatisticWidget(
                        title: "$weight ${weightUnit()}",
                        subtitle: "Weight",
                      ),
                      _StatisticWidget(
                        title: heightConversion,
                        subtitle: "Height",
                      ),
                      _StatisticWidget(
                        title: gender,
                        subtitle: "Gender",
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 2, // horizontal gap
                  runSpacing: 14, // vertical gap
                  children: children,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateAge({required DateTime birthDate}) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    // Adjust if birthday hasn't occurred yet this year
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

}

class _StatisticWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatisticWidget({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5), // Border radius for rounded corners
      ),
      child: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(
              height: 6,
            ),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ]),
    );
  }
}
