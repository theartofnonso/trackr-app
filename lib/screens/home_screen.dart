import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/routine_logs_screen.dart';
import 'package:tracker_app/screens/routines_screen.dart';

import '../providers/exercises_provider.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [const RoutineLogsScreen(), const RoutinesScreen()];
    return Scaffold(
      body: screens[_currentScreenIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 60,
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.history, color: Colors.grey, size: 24),
            selectedIcon: Icon(Icons.history, color: Colors.white, size: 24),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add, color: Colors.grey, size: 24),
            selectedIcon: Icon(Icons.add, color: Colors.white, size: 24),
            label: 'Home',
          ),
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

  void _loadData() async {
    await Provider.of<ExerciseProvider>(context, listen: false).listExercises();
    if (mounted) {
      Provider.of<RoutineLogProvider>(context, listen: false).listRoutineLogs(context);
      Provider.of<RoutineProvider>(context, listen: false).listRoutines(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
