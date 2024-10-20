import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/models/ActivityLog.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/screens/template/routines_home.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../controllers/activity_log_controller.dart';
import '../controllers/exercise_controller.dart';
import '../controllers/routine_template_controller.dart';
import '../dtos/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../models/RoutineLog.dart';
import '../models/RoutineTemplate.dart';
import '../utils/app_analytics.dart';
import 'communities_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  int _currentScreenIndex = 0;

  StreamSubscription<QuerySnapshot<RoutineLog>>? _routineLogStream;
  StreamSubscription<QuerySnapshot<RoutineTemplate>>? _routineTemplateStream;
  StreamSubscription<QuerySnapshot<ActivityLog>>? _activityLogStream;
  StreamSubscription<QuerySnapshot<Exercise>>? _exerciseStream;

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewScreen(scrollController: _scrollController),
      const RoutinesHome(),
      // const CommunitiesScreen(),
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
        overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
        destinations: [
          const NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.house, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Image.asset(
              'icons/dumbbells.png',
              fit: BoxFit.contain,
              color: Colors.grey,
              height: 34, // Adjust the height as needed
            ),
            selectedIcon: Image.asset(
              'icons/dumbbells.png',
              fit: BoxFit.contain,
              height: 34, // Adjust the height as needed
            ),
            label: 'Workouts',
          ),
          // NavigationDestination(
          //   icon: Image.asset(
          //     'icons/people.png',
          //     fit: BoxFit.contain,
          //     color: Colors.grey,
          //     height: 34, // Adjust the height as needed
          //   ),
          //   selectedIcon: Image.asset(
          //     'icons/people.png',
          //     fit: BoxFit.contain,
          //     height: 34, // Adjust the height as needed
          //   ),
          //   label: 'TRKD Circles',
          // ),
          const NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.gear, color: Colors.grey, size: 26),
            selectedIcon: FaIcon(FontAwesomeIcons.gear, color: Colors.white, size: 26),
            label: 'Settings',
          )
        ],
        onDestinationSelected: (int index) {
          setState(() {
            _currentScreenIndex = index;
          });
          _scrollToTop(index);
        },
        selectedIndex: _currentScreenIndex,
      ),
    );
  }

  void _observeExerciseQuery() async {
    final controller = Provider.of<ExerciseController>(context, listen: false);
    await controller.loadLocalExercises();
    _exerciseStream = Amplify.DataStore.observeQuery(
      Exercise.classType,
    ).listen((QuerySnapshot<Exercise> snapshot) {
      if (mounted) {
        Provider.of<ExerciseController>(context, listen: false).streamExercises(exercises: snapshot.items);
      }
    });
  }

  void _observeRoutineLogQuery() {
    _routineLogStream = Amplify.DataStore.observeQuery(
      RoutineLog.classType,
    ).listen((QuerySnapshot<RoutineLog> snapshot) {
      if (mounted) {
        Provider.of<RoutineLogController>(context, listen: false).streamLogs(logs: snapshot.items);
      }
    });
  }

  void _observeRoutineTemplateQuery() {
    _routineTemplateStream = Amplify.DataStore.observeQuery(
      RoutineTemplate.classType,
    ).listen((QuerySnapshot<RoutineTemplate> snapshot) {
      if (mounted) {
        Provider.of<RoutineTemplateController>(context, listen: false).streamTemplates(templates: snapshot.items);
      }
    });
  }

  void _observeActivityLogQuery() {
    _activityLogStream = Amplify.DataStore.observeQuery(
      ActivityLog.classType,
    ).listen((QuerySnapshot<ActivityLog> snapshot) {
      if (mounted) {
        Provider.of<ActivityLogController>(context, listen: false).streamLogs(logs: snapshot.items);
      }
    });
  }

  void _scrollToTop(int index) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
    );
  }

  void _loadAppData() async {
    _observeExerciseQuery();
    _observeRoutineLogQuery();
    _observeRoutineTemplateQuery();
    _observeActivityLogQuery();
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
    identifyUser(userId: SharedPrefs().userId);
  }

  void _runSetup() async {
    if (SharedPrefs().firstLaunch) {
      _cacheUser();
      _loadAppData();
      SharedPrefs().firstLaunch = false;
    } else {
      identifyUser(userId: SharedPrefs().userId);
      _loadAppData();
      _loadCachedLog();
    }
  }

  @override
  void initState() {
    super.initState();
    _runSetup();
  }

  @override
  void dispose() {
    _exerciseStream?.cancel();
    _routineLogStream?.cancel();
    _routineTemplateStream?.cancel();
    _activityLogStream?.cancel();
    super.dispose();
  }
}
