import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health/health.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/models/ActivityLog.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/models/RoutineUser.dart';
import 'package:tracker_app/screens/home_tab_screen.dart';
import 'package:tracker_app/screens/onboarding/onboarding_screen.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/screens/templates/routine_templates_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../controllers/activity_log_controller.dart';
import '../controllers/analytics_controller.dart';
import '../controllers/routine_user_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../models/RoutineLog.dart';
import '../models/RoutineTemplate.dart';
import 'milestones/milestones_home_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  int _currentScreenIndex = 0;

  StreamSubscription<QuerySnapshot<RoutineUser>>? _routineUserStream;
  StreamSubscription<QuerySnapshot<RoutineLog>>? _routineLogStream;
  StreamSubscription<QuerySnapshot<RoutineTemplate>>? _routineTemplateStream;
  StreamSubscription<QuerySnapshot<ActivityLog>>? _activityLogStream;
  StreamSubscription<QuerySnapshot<Exercise>>? _exerciseStream;

  @override
  Widget build(BuildContext context) {
    if( SharedPrefs().firstLaunch ) {
      return OnboardingScreen();
    }

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final screens = [
      HomeTabScreen(
        scrollController: _scrollController,
      ),
      const RoutineTemplatesScreen(),
      const MilestonesHomeScreen(),
      const SettingsScreen()
    ];

    return Scaffold(
      body: screens[_currentScreenIndex],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 60,
        destinations: [
           NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.house, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.house, color: isDarkMode ? Colors.white : Colors.black),
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
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            label: 'Workouts',
          ),
           NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.trophy, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.trophy, color: isDarkMode ? Colors.white : Colors.black),
            label: 'Challenges',
          ),
           NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.gear, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.gear, color: isDarkMode ? Colors.white : Colors.black),
            label: 'Challenges',
          ),
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

  void _scrollToTop(int index) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
    );
  }

  void _loadAppData() {
    _observeRoutineUserQuery();
    _observeExerciseQuery();
    _observeRoutineLogQuery();
    _observeRoutineTemplateQuery();
    _observeActivityLogQuery();
  }

  void _observeRoutineUserQuery() {
    _routineUserStream = Amplify.DataStore.observeQuery(
      RoutineUser.classType,
      sortBy: [RoutineUser.CREATEDAT.ascending()],
    ).listen((QuerySnapshot<RoutineUser> snapshot) {
      if (mounted) {
        Provider.of<RoutineUserController>(context, listen: false).streamUsers(users: snapshot.items);
      }
    });
  }

  void _observeExerciseQuery() async {
    final controller = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    await controller.loadLocalExercises();
    _exerciseStream = Amplify.DataStore.observeQuery(
      Exercise.classType,
      sortBy: [Exercise.CREATEDAT.ascending()],
    ).listen((QuerySnapshot<Exercise> snapshot) {
      if (mounted) {
        controller.streamExercises(exercises: snapshot.items);
      }
    });
  }

  void _observeRoutineTemplateQuery() {
    _routineTemplateStream = Amplify.DataStore.observeQuery(
      RoutineTemplate.classType,
      sortBy: [RoutineTemplate.CREATEDAT.descending()],
    ).listen((QuerySnapshot<RoutineTemplate> snapshot) {
      if (mounted) {
        Provider.of<ExerciseAndRoutineController>(context, listen: false).streamTemplates(templates: snapshot.items);
      }
    });
  }

  void _observeRoutineLogQuery() {
    _routineLogStream = Amplify.DataStore.observeQuery(
      RoutineLog.classType,
      sortBy: [RoutineLog.CREATEDAT.ascending()],
    ).listen((QuerySnapshot<RoutineLog> snapshot) {
      if (mounted) {
        Provider.of<ExerciseAndRoutineController>(context, listen: false).streamLogs(logs: snapshot.items);
      }
    });
  }

  void _observeActivityLogQuery() {
    _activityLogStream = Amplify.DataStore.observeQuery(
      ActivityLog.classType,
      sortBy: [ActivityLog.CREATEDAT.ascending()],
    ).listen((QuerySnapshot<ActivityLog> snapshot) {
      if (mounted) {
        Provider.of<ActivityLogController>(context, listen: false).streamLogs(logs: snapshot.items);
      }
    });
  }

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoutineLogDto? log = Provider.of<ExerciseAndRoutineController>(context, listen: false).cachedLog();
      if (log != null) {
        final arguments = RoutineLogArguments(log: log, editorMode: RoutineEditorMode.log);
        navigateToRoutineLogEditor(context: context, arguments: arguments);
      }
    });
  }

  ///add user stuff here for analytics instead
  void _cacheUser() async {
    final authUser = await Amplify.Auth.getCurrentUser();
    final signInDetails = authUser.signInDetails.toJson();
    SharedPrefs().userId = authUser.userId;
    SharedPrefs().userEmail = signInDetails["username"] as String;
    Posthog().identify(userId: SharedPrefs().userId);
    AnalyticsController.loginAnalytics(isFirstLaunch: SharedPrefs().firstLaunch);
  }

  void _runSetup() async {
    if (SharedPrefs().firstLaunch) {
      _cacheUser();
      _loadAppData();
    } else {
      Posthog().identify(userId: SharedPrefs().userId);
      AnalyticsController.loginAnalytics(isFirstLaunch: SharedPrefs().firstLaunch);
      _loadAppData();
      _loadCachedLog();
    }

    await Health().configure();

    final now = DateTime.now();

    final pastDay = now.subtract(const Duration(hours: 24));

    // fetch health data from the last 24 hours
    Health().getHealthDataFromTypes(types: [HealthDataType.SLEEP_ASLEEP], startTime: pastDay, endTime: now).then((values) {
      final uniqueValues = Health().removeDuplicates(values);
      final milliseconds = uniqueValues.map((value) => value.dateTo.difference(value.dateFrom).inMilliseconds).sum;
      print(Duration(milliseconds: milliseconds));
    });

  }

  @override
  void initState() {
    super.initState();
    _runSetup();
  }

  @override
  void dispose() {
    _exerciseStream?.cancel();
    _routineTemplateStream?.cancel();
    _routineLogStream?.cancel();
    _activityLogStream?.cancel();
    _routineUserStream?.cancel();
    super.dispose();
  }
}
