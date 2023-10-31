import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/profile_screen.dart';
import 'package:tracker_app/screens/logs/routine_logs_screen.dart';
import 'package:tracker_app/screens/routine/routines_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [const RoutineLogsScreen(), const RoutinesScreen(), const ProfileScreen()];
    return Scaffold(
      body: screens[_currentScreenIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 60,
        indicatorColor: Colors.transparent,
        backgroundColor: tealBlueLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.history, color: Colors.grey, size: 24),
            selectedIcon: Icon(Icons.history, color: Colors.white, size: 24),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add, color: Colors.grey, size: 24),
            selectedIcon: Icon(Icons.add, color: Colors.white, size: 24),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_2_outlined, color: Colors.grey, size: 24),
            selectedIcon: Icon(Icons.person_2_outlined, color: Colors.white, size: 24),
            label: 'Profile',
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
}
