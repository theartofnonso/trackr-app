import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/screens/overview_screen.dart';
import 'package:tracker_app/screens/template/routine_templates_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';

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

  StreamSubscription<QuerySnapshot<Exercise>>? _exerciseStream;
  StreamSubscription<QuerySnapshot<RoutineTemplate>>? _routineTemplateStream;
  StreamSubscription<QuerySnapshot<RoutineLog>>? _routineLogStream;

  void _observeExerciseQuery() {
    _exerciseStream = Amplify.DataStore.observeQuery(
      Exercise.classType,
    ).listen((QuerySnapshot<Exercise> snapshot) {
      Provider.of<ExerciseProvider>(context, listen: false).listExercises(exercises: snapshot.items);
      if (snapshot.items.isNotEmpty) {
        _exerciseStream?.cancel();
      }
    });
  }

  void _observeRoutineTemplateQuery() {
    _routineTemplateStream = Amplify.DataStore.observeQuery(
      RoutineTemplate.classType,
    ).listen((QuerySnapshot<RoutineTemplate> snapshot) {
      Provider.of<RoutineTemplateProvider>(context, listen: false).listTemplates(templates: snapshot.items);
      if (snapshot.items.isNotEmpty) {
        _routineTemplateStream?.cancel();
      }
    });
  }

  void _observeRoutineLogQuery() {
    _routineLogStream = Amplify.DataStore.observeQuery(
      RoutineLog.classType,
    ).listen((QuerySnapshot<RoutineLog> snapshot) {
      Provider.of<RoutineLogProvider>(context, listen: false).listLogs(logs: snapshot.items);
      if (snapshot.items.isNotEmpty) {
        _routineLogStream?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _exerciseStream?.cancel();
    _routineTemplateStream?.cancel();
    _routineLogStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [const OverviewScreen(), const RoutinesScreen()];
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
            icon: FaIcon(FontAwesomeIcons.dumbbell, color: Colors.grey, size: 28),
            selectedIcon: FaIcon(FontAwesomeIcons.dumbbell, color: Colors.white, size: 28),
            label: 'Workouts',
          ),
          /// Uncomment this to enable achievements
          // NavigationDestination(
          //   icon: FaIcon(FontAwesomeIcons.gamepad, color: Colors.grey, size: 28),
          //   selectedIcon: FaIcon(FontAwesomeIcons.gamepad, color: Colors.white, size: 28),
          //   label: 'Achievements',
          // )
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

  void _loadAppData() async {
    await Provider.of<ExerciseProvider>(context, listen: false).listExercises();
    if (context.mounted) {
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

  void _cacheUser() async {
    final authUser = await Amplify.Auth.getCurrentUser();
    final signInDetails = authUser.signInDetails.toJson();
    SharedPrefs().userId = authUser.userId;
    SharedPrefs().userEmail = signInDetails["username"] as String;
  }

  void _observeQueries() {
    _observeExerciseQuery();
    _observeRoutineTemplateQuery();
    _observeRoutineLogQuery();
  }

  void _runSetup() async {
    if (SharedPrefs().firstLaunch) {
      SharedPrefs().firstLaunch = false;
      _observeQueries();
      _cacheUser();
    } else {
      _loadAppData();
      _loadCachedLog();
    }
    /// Uncomment this to enable notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestNotificationPermission();
    });
  }

  Future<void> _checkAndRequestNotificationPermission() async {

    final result = await checkIosNotificationPermission();
    if (!result.isEnabled) {
      if (mounted) {
        displayBottomSheet(
            context: context,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Remind me to train weekly",
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  textAlign: TextAlign.start),
              Text("Training regularly is hard. Trackr can help you stay on track.",
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
                  textAlign: TextAlign.start),
              const SizedBox(height: 16),
              CTextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    requestIosNotificationPermission();
                  },
                  label: "Always remind me",
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  buttonColor: Colors.green),
            ]));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _runSetup();
  }
}
