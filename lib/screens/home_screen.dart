import 'package:flutter/cupertino.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/routine_logs_screen.dart';
import 'package:tracker_app/screens/routines_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [const RoutineLogsScreen(), const RoutinesScreen()];
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: tealBlueLight,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add, size: 22),
            label: 'Workouts',
          ),
        ],
      ), tabBuilder: (BuildContext context, int index) { return screens[index]; },

    );
  }
}
