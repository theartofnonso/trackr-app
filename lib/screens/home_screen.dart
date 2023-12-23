import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/achievements_screen.dart';
import 'package:tracker_app/screens/overview_screen.dart';
import 'package:tracker_app/screens/template/routines_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../models/RoutineLog.dart';

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
        destinations:  const [
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

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoutineLog? log = cachedRoutineLog();
      if (log != null) {
        navigateToRoutineLogEditor(context: context, log: log);
      }
    });
  }

  void _runSetUp() async {
    if(SharedPrefs().firstLaunch){
      SharedPrefs().firstLaunch = false;
    }
    await persistUserCredentials();
    if(mounted) {
      loadAppData(context);
      _loadCachedLog();
    }
  }

  @override
  void initState() {
    super.initState();
    _runSetUp();
  }
}
