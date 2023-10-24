import 'package:flutter/cupertino.dart';
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
  @override
  Widget build(BuildContext context) {
    final screens = [const RoutineLogsScreen(), const RoutinesScreen()];
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: tealBlueLight,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_dash, size: 22),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add, size: 22),
            label: 'Templates',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return screens[index];
      },
    );
  }

  void _loadData() async {
    await Provider.of<ExerciseProvider>(context, listen: false).listExercises();
    if(mounted) {
      Provider.of<RoutineProvider>(context, listen: false).listRoutines(context);
      Provider.of<RoutineLogProvider>(context, listen: false).listRoutineLogs(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
