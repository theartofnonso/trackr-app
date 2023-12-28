import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/achievements_screen.dart';
import 'package:tracker_app/screens/overview_screen.dart';
import 'package:tracker_app/screens/template/routine_templates_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../dtos/routine_log_dto.dart';
import '../providers/exercise_provider.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_template_provider.dart';

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
            icon: FaIcon(FontAwesomeIcons.solidSquarePlus, color: Colors.grey, size: 28),
            selectedIcon: FaIcon(FontAwesomeIcons.solidSquarePlus, color: Colors.white, size: 28),
            label: 'Workouts',
          ),
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

  Future<void> _loadAppData({required BuildContext context}) async {
    await Provider.of<ExerciseProvider>(context, listen: false).listExercises();
    if(context.mounted) {
      Provider.of<RoutineTemplateProvider>(context, listen: false).listTemplates();
      Provider.of<RoutineLogProvider>(context, listen: false).listLogs();
    }
  }

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoutineLogDto? log = cachedRoutineLog();
      if (log != null) {
        navigateToRoutineLogEditor(context: context, log: log);
      }
    });
  }

  Future<void> _cacheUser() async {
    final authUser = await Amplify.Auth.getCurrentUser();
    final signInDetails = authUser.signInDetails.toJson();
    SharedPrefs().userId = authUser.userId;
    SharedPrefs().userEmail = signInDetails["username"] as String;
  }

  void _runFirstLaunchSetup() async {
    if (SharedPrefs().firstLaunch) {
      SharedPrefs().firstLaunch = false;
      await _cacheUser();
      await _restartDataStore();
      if (mounted) {
        _loadAppData(context: context);
      }
    }
  }

  Future<void> _restartDataStore() async {
    try {
      await Amplify.DataStore.stop();
    } catch (error) {
      print('Error stopping DataStore: $error');
    }

    try {
      await Amplify.DataStore.start();
    } on Exception catch (error) {
      print('Error starting DataStore: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _runFirstLaunchSetup();
    _restartDataStore();
    _loadAppData(context: context);
    _loadCachedLog();
  }
}
