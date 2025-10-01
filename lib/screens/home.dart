import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Removed Amplify usage for UI-only mode
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../colors.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
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
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    Provider.of<ExerciseAndRoutineController>(context, listen: true);

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? darkBackground : Colors.white,
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
