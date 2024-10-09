import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
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
import '../utils/app_analytics.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  int _currentScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewScreen(scrollController: _scrollController),
      const RoutinesHome(),
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
              height: 32, // Adjust the height as needed
            ),
            selectedIcon: Image.asset(
              'icons/dumbbells.png',
              fit: BoxFit.contain,
              height: 32, // Adjust the height as needed
            ),
            label: 'Workouts',
          ),
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

  void _scrollToTop(int index) {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
    );
  }

  void _loadAppData({bool firstLaunch = false}) async {
    Provider.of<ExerciseController>(context, listen: false).fetchExercises(firstLaunch: firstLaunch);
    Provider.of<RoutineLogController>(context, listen: false).fetchLogs(firstLaunch: firstLaunch);
    Provider.of<RoutineTemplateController>(context, listen: false).fetchTemplates(firstLaunch: firstLaunch);
    Provider.of<ActivityLogController>(context, listen: false).fetchLogs(firstLaunch: firstLaunch);
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
      _loadAppData(firstLaunch: SharedPrefs().firstLaunch);
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
}
