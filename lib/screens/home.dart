import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Removed Amplify usage for UI-only mode
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/date_utils.dart';
import 'package:tracker_app/widgets/icons/linear_progress_bar_with_indicator.dart';

import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../utils/dialog_utils.dart';
import '../utils/general_utils.dart';
import '../utils/navigation_utils.dart';
import 'overview_screen.dart';

class Home extends StatefulWidget {
  static const routeName = '/home_screen';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final lastYearRange = yearToDateTimeRange(datetime: DateTime.now());
    final logsForTheYear =
        Provider.of<ExerciseAndRoutineController>(context, listen: true)
            .whereLogsIsWithinRange(range: lastYearRange);

    return Scaffold(
      appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              showBottomSheetWithNoAction(
                  context: context,
                  title:
                      "${logsForTheYear.length} of 144 sessions in ${DateTime.now().year}",
                  description:
                      "Your Streak counts the days you commit to strength training each month. Hit 12 sessions a month to stay on track for 144 in a year.");
            },
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: IconProgressBar(
                progress: logsForTheYear.length / 144,
                icon:
                    FaIcon(FontAwesomeIcons.personWalking, color: Colors.green),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => navigateToSettings(context: context),
              icon: FaIcon(FontAwesomeIcons.gear),
            )
          ]),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: RefreshIndicator(
          onRefresh: _loadAppData,
          child: SafeArea(
            minimum: const EdgeInsets.all(10),
            bottom: false,
            child: OverviewScreen(),
          ),
        ),
      ),
    );
  }

  Future<void> _loadAppData() async {
    // Simple one-time loads for UI-only mode
    final controller =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);
    await controller.loadLocalExercises();
    setState(() {});
  }

  Future<void> _userSetup() async {
    // Mock user setup for UI-only mode
    final prefs = SharedPrefs();
    prefs
      ..userId = prefs.userId.isNotEmpty ? prefs.userId : 'demo-user'
      ..userEmail =
          prefs.userEmail.isNotEmpty ? prefs.userEmail : 'demo@trnr.app';
    Posthog().identify(userId: prefs.userId);
    _loadAppData();
  }

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cache = SharedPrefs().routineLog;
      if (cache.isNotEmpty) {
        final json = jsonDecode(cache);
        final routineLog = RoutineLogDto.fromCachedLog(json: json);
        final arguments = RoutineLogArguments(
            log: routineLog, editorMode: RoutineEditorMode.log, cached: true);
        navigateToRoutineLogEditor(context: context, arguments: arguments);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _userSetup();

    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin()
          .cancelAll(); // Cancel all notifications including pending workout sessions and regular training reminders
    }
    _loadCachedLog();
  }

  @override
  void dispose() {
    // No stream subscriptions to cancel in UI-only mode
    super.dispose();
  }
}
