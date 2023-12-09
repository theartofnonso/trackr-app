import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/calendar_screen.dart';
import 'package:tracker_app/screens/overview_screen.dart';
import 'package:tracker_app/screens/template/routines_screen.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../models/RoutineLog.dart';
import '../providers/routine_log_provider.dart';
import '../shared_prefs.dart';
import 'editors/routine_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [const OverviewScreen(), const RoutinesScreen(), const CalendarScreen()];
    return Scaffold(
      body: screens[_currentScreenIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 60,
        indicatorColor: Colors.transparent,
        backgroundColor: tealBlueDark,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home, color: Colors.grey, size: 28),
            selectedIcon: Icon(Icons.home, color: Colors.white, size: 32),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add, color: Colors.grey, size: 28),
            selectedIcon: Icon(Icons.add, color: Colors.white, size: 32),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.history, color: Colors.grey, size: 28),
            selectedIcon: Icon(Icons.history, color: Colors.white, size: 32),
            label: 'Logs',
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
      navigateToRoutineEditor(
          context: context,
          routine: log?.routine,
          mode: RoutineEditorMode.log);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SharedPrefs().firstLaunch = false;
    _loadCachedLog();
    persistUserCredentials();
    loadAppData(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => Provider.of<RoutineLogProvider>(context, listen: false).listRoutineLogs());
    }
  }
}
