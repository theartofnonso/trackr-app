import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/icons/user_icon_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<RoutineUserController>(context, listen: true).user;

    final weight = user?.weight ?? 0.0;
    final height = user?.height ?? 0.0;
    final heightConversion = heightWithConversion(value: height);

    final dob = user?.dateOfBirth ?? DateTime.now();
    final age = _calculateAge(birthDate: dob);

    final gender = user?.gender ?? Gender.other;

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
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
          minimum: const EdgeInsets.only(bottom: 20),
          child: Column(
            spacing: 16,
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
                      child: Text(user!.name.toUpperCase(),
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
                      title: gender.name,
                      subtitle: "Gender",
                    ),
                  ],
                ),
              ),
            ],
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

class _AddTile extends StatelessWidget {
  const _AddTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.yellow.withValues(alpha: 0.1) : Colors.yellow,
          borderRadius: BorderRadius.circular(5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text("25", style: GoogleFonts.ubuntu(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600)),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.yellow.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: isDarkMode ? Colors.yellow : Colors.white,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      ]),
    );
  }
}

class _StatisticsInformation {
  final String title;
  final String description;

  _StatisticsInformation({required this.title, required this.description});
}

class _StatisticWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatisticWidget({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Background color of the container
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
