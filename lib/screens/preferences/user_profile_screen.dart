
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/icons/user_icon_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../widgets/empty_states/not_found.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with WidgetsBindingObserver {
  RoutineUserDto? _user;

  double _weight = 0;

  @override
  Widget build(BuildContext context) {

    final user = _user;

    if (user == null) return const NotFound();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(right: 10, left: 10, bottom: 20),
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
                      title: "29",
                      subtitle: "Age",
                      icon: FontAwesomeIcons.personWalking,
                      information: _StatisticsInformation(
                          title: "Exercises",
                          description:
                          "The total number of different exercises you completed in a workout session."),
                    ),
                    _StatisticWidget(
                      title: "85${weightLabel()}",
                      subtitle: "Weight",
                      icon: FontAwesomeIcons.hashtag,
                      information: _StatisticsInformation(
                          title: "Sets",
                          description:
                          "The number of rounds you performed for each exercise. A “set” consists of a group of repetitions (reps)."),
                    ),
                    _StatisticWidget(
                      title: "5.9",
                      subtitle: "Height",
                      icon: FontAwesomeIcons.weightHanging,
                      information: _StatisticsInformation(
                          title: "Volume",
                          description:
                          "The total amount of work performed during a workout, typically calculated as: Volume = Sets × Reps × Weight."),
                    ),
                    _StatisticWidget(
                      title: "Male",
                      subtitle: "Gender",
                      icon: FontAwesomeIcons.solidClock,
                      information: _StatisticsInformation(
                          title: "Duration",
                          description: "The total time you spent on your workout session, from start to finish."),
                    ),
                  ],
                ),
              ),
              SafeArea(
                minimum: EdgeInsets.all(10),
                child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OpacityButtonWidget(
                      onPressed: _updateUser,
                      label: "Save Profile",
                      buttonColor: vibrantGreen,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUser() async {
    final user = _user;
    if (user != null) {
      final userToUpdate = user.copyWith(weight: _weight);
      await Provider.of<RoutineUserController>(context, listen: false).updateUser(userDto: userToUpdate);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<RoutineUserController>(context, listen: false).user;
    _weight = _user?.weight.toDouble() ?? 0.0;
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
        Text("25",
            style: GoogleFonts.ubuntu(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600)),
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
  final IconData? icon;
  final String? image;
  final String title;
  final String subtitle;
  final _StatisticsInformation information;

  const _StatisticWidget(
      {this.icon, this.image, required this.title, required this.subtitle, required this.information});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final leading = image != null
        ? Image.asset(
      'icons/$image.png',
      fit: BoxFit.contain,
      color: isDarkMode ? Colors.white : Colors.black,
      height: 14, // Adjust the height as needed
    )
        : FaIcon(icon, size: 14);

    return GestureDetector(
      onTap: () =>
          showBottomSheetWithNoAction(context: context, title: information.title, description: information.description),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Background color of the container
          borderRadius: BorderRadius.circular(5), // Border radius for rounded corners
        ),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  leading,
                  const SizedBox(
                    width: 6,
                  ),
                  Text(subtitle.toUpperCase(), style: Theme.of(context).textTheme.bodySmall)
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
          Positioned.fill(
            child: const Align(alignment: Alignment.bottomRight, child: FaIcon(FontAwesomeIcons.penToSquare, size: 10)),
          ),
        ]),
      ),
    );
  }
}

