import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/models/ActivityLog.dart';
import 'package:tracker_app/models/RoutineUser.dart';
import 'package:tracker_app/screens/home_tab_screen.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/screens/templates/templates_and_plans_home.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../controllers/activity_log_controller.dart';
import '../controllers/routine_user_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../models/RoutineLog.dart';
import '../models/RoutineTemplate.dart';
import '../models/RoutineTemplatePlan.dart';
import '../utils/app_analytics.dart';
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
  StreamSubscription<QuerySnapshot<RoutineTemplatePlan>>? _routineTemplatePlanStream;
  StreamSubscription<QuerySnapshot<ActivityLog>>? _activityLogStream;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeTabScreen(
        scrollController: _scrollController,
      ),
      const TemplatesAndPlansHome(),
      const MilestonesHomeScreen(),
      const SettingsScreen()
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
          const NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.trophy, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.trophy, color: Colors.white),
            label: 'Challenges',
          ),
          const NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.gear, color: Colors.grey),
            selectedIcon: FaIcon(FontAwesomeIcons.gear, color: Colors.white),
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
    Provider.of<ExerciseAndRoutineController>(context, listen: false).loadExercises();
    _observeRoutineUserQuery();
    _observeRoutineLogQuery();
    _observeRoutineTemplateQuery();
    _observeRoutineTemplatePlanQuery();
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

  void _observeRoutineTemplateQuery() async {
    _routineTemplateStream = Amplify.DataStore.observeQuery(
      RoutineTemplate.classType,
      sortBy: [RoutineTemplate.CREATEDAT.descending()],
    ).listen((QuerySnapshot<RoutineTemplate> snapshot) {
      if (mounted) {
        Provider.of<ExerciseAndRoutineController>(context, listen: false).streamTemplates(templates: snapshot.items);
      }
    });
  }

  void _observeRoutineTemplatePlanQuery() {
    _routineTemplatePlanStream = Amplify.DataStore.observeQuery(
      RoutineTemplatePlan.classType,
      sortBy: [RoutineTemplatePlan.CREATEDAT.descending()],
    ).listen((QuerySnapshot<RoutineTemplatePlan> snapshot) {
      if (mounted) {
        Provider.of<ExerciseAndRoutineController>(context, listen: false)
            .streamTemplatePlans(templatePlans: snapshot.items);
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
    _routineTemplateStream?.cancel();
    _routineTemplatePlanStream?.cancel();
    _routineLogStream?.cancel();
    _activityLogStream?.cancel();
    _routineUserStream?.cancel();
    super.dispose();
  }
}
