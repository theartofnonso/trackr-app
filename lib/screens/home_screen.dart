import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/screens/achievements/achievements_screen.dart';
import 'package:tracker_app/screens/overview_screen.dart';
import 'package:tracker_app/screens/template/routine_templates_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../controllers/routine_template_controller.dart';
import '../dtos/routine_log_dto.dart';
import '../controllers/exercise_controller.dart';
import '../enums/routine_editor_type_enums.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [const OverviewScreen(), const RoutinesScreen(), const AchievementsScreen()];
    return Scaffold(
      body: screens[_currentScreenIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 60,
        indicatorColor: Colors.transparent,
        backgroundColor: tealBlueDark,
        surfaceTintColor: tealBlueLighter,
        overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.house, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.dumbbell, color: Colors.grey, size: 24),
            selectedIcon: FaIcon(FontAwesomeIcons.dumbbell, color: Colors.white, size: 28),
            label: 'Workouts',
          ),

          /// Uncomment this to enable achievements
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.gamepad, color: Colors.grey, size: 28),
            selectedIcon: FaIcon(FontAwesomeIcons.gamepad, color: Colors.white, size: 28),
            label: 'Achievements',
          )
        ],
        onDestinationSelected: (int index) {
          setState(() {
            _currentScreenIndex = index;
          });
        },
        selectedIndex: _currentScreenIndex,
      ),
    );
  }

  void _loadAppData() {
    Provider.of<RoutineLogController>(context, listen: false).fetchLogs();
    Provider.of<ExerciseController>(context, listen: false).fetchExercises();
    Provider.of<RoutineTemplateController>(context, listen: false).fetchTemplates();
  }

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoutineLogDto? log = Provider.of<RoutineLogController>(context, listen: false).cachedLog();
      if (log != null) {
        navigateToRoutineLogEditor(context: context, log: log, editorMode: RoutineEditorMode.log);
      }
    });
  }

  void _cacheUser() async {
    final authUser = await Amplify.Auth.getCurrentUser();
    final signInDetails = authUser.signInDetails.toJson();
    SharedPrefs().userId = authUser.userId;
    SharedPrefs().userEmail = signInDetails["username"] as String;
  }

  void _runSetup() async {
    if (SharedPrefs().firstLaunch) {
      SharedPrefs().firstLaunch = false;
      _cacheUser();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppData();
      _loadCachedLog();
      _checkAndRequestNotificationPermission();
    });
  }

  void _requestIosNotificationPermission() async {
    final isEnabled = await requestIosNotificationPermission();
    if (isEnabled) {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()));
      }
    }
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    final result = await checkIosNotificationPermission();
    if (!result.isEnabled) {
      if (mounted) {
        displayBottomSheet(
            context: context,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Remind me to train weekly",
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  textAlign: TextAlign.start),
              Text("Training regularly can be hard. Trackr can help you stay on track.",
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
                  textAlign: TextAlign.start),
              const SizedBox(height: 16),
              CTextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _requestIosNotificationPermission();
                  },
                  label: "Always remind me",
                  textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  buttonColor: vibrantGreen),
            ]));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _runSetup();
  }
}
