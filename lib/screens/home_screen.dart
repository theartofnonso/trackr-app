import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/screens/achievements/achievements_screen.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/screens/template/routines_home.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/app_analytics.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../controllers/routine_template_controller.dart';
import '../dtos/routine_log_dto.dart';
import '../controllers/exercise_controller.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import 'preferences/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewScreen(scrollController: _scrollController),
      const RoutinesHome(),
      AchievementsScreen(scrollController: _scrollController),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentScreenIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 60,
        indicatorColor: Colors.transparent,
        backgroundColor: sapphireDark80,
        surfaceTintColor: Colors.black,
        overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.house, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.dumbbell, color: Colors.grey, size: 24),
            selectedIcon: FaIcon(FontAwesomeIcons.dumbbell, color: Colors.white, size: 24),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.gamepad, color: Colors.grey, size: 28),
            selectedIcon: FaIcon(FontAwesomeIcons.gamepad, color: Colors.white, size: 28),
            label: 'Achievements',
          ),

          /// Uncomment this to enable Monthly Reports
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.gear, color: Colors.grey, size: 26),
            selectedIcon: FaIcon(FontAwesomeIcons.gear, color: Colors.white, size: 26),
            label: 'Settings',
          )
        ],
        onDestinationSelected: (int index) {
          final destination = screens[index];
          setState(() {
            _currentScreenIndex = index;
          });
          if (destination is AchievementsScreen) recordViewMilestonesEvent();
          _scrollToTop(index);
        },
        selectedIndex: _currentScreenIndex,
      ),
    );
  }

  void _scrollToTop(int index) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
    );
  }

  void _loadAppData({required bool firstLaunch}) {
    Provider.of<RoutineLogController>(context, listen: false).fetchLogs(firstLaunch: firstLaunch);
    Provider.of<ExerciseController>(context, listen: false).fetchExercises(firstLaunch: firstLaunch);
    Provider.of<RoutineTemplateController>(context, listen: false).fetchTemplates(firstLaunch: firstLaunch);
  }

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoutineLogDto? log = Provider.of<RoutineLogController>(context, listen: false).cachedLog();
      if (log != null) {
        final arguments = RoutineLogArguments(log: log, editorMode: RoutineEditorMode.log);
        navigateToRoutineLogEditor(context: context, arguments: arguments);
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
      _loadAppData(firstLaunch: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppData(firstLaunch: false);
      _loadCachedLog();
    });
  }

  @override
  void initState() {
    super.initState();
    _runSetup();
  }
}
