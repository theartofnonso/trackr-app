import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sahha_flutter/sahha_flutter.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/models/RoutineUser.dart';
import 'package:tracker_app/sahha_credentials.dart';
import 'package:tracker_app/screens/home_tab_screen.dart';
import 'package:tracker_app/screens/notifications/onboarding_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../controllers/routine_user_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../models/RoutineLog.dart';
import '../models/RoutinePlan.dart';
import '../models/RoutineTemplate.dart';
import '../utils/navigation_utils.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<QuerySnapshot<RoutineUser>>? _routineUserStream;
  StreamSubscription<QuerySnapshot<RoutineLog>>? _routineLogStream;
  StreamSubscription<QuerySnapshot<RoutineTemplate>>? _routineTemplateStream;
  StreamSubscription<QuerySnapshot<RoutinePlan>>? _routinePlanStream;
  StreamSubscription<QuerySnapshot<Exercise>>? _exerciseStream;

  @override
  Widget build(BuildContext context) {
    if (SharedPrefs().firstLaunch) {
      return OnboardingScreen(onComplete: () {
        setState(() {
          SharedPrefs().firstLaunch = false;
        });
      });
    }

    return HomeTabScreen();
  }

  void _loadAppData() {
    _observeRoutineUserQuery();
    _observeExerciseQuery();
    _observeRoutineLogQuery();
    _observeRoutineTemplateQuery();
    _observeRoutinePlanQuery();
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

  void _observeRoutinePlanQuery() {
    _routinePlanStream = Amplify.DataStore.observeQuery(
      RoutinePlan.classType,
      sortBy: [RoutinePlan.CREATEDAT.descending()],
    ).listen((QuerySnapshot<RoutinePlan> snapshot) {
      if (mounted) {
        Provider.of<ExerciseAndRoutineController>(context, listen: false).streamPlans(plans: snapshot.items);
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

  ///add user stuff here for analytics instead
  void _cacheUser() async {
    final authUser = await Amplify.Auth.getCurrentUser();
    final signInDetails = authUser.signInDetails.toJson();
    SharedPrefs().userId = authUser.userId;
    SharedPrefs().userEmail = (signInDetails["username"]?.toString() ?? '');
    Posthog().identify(userId: SharedPrefs().userId);
  }

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RoutineLogDto? routineLog;
      final cache = SharedPrefs().routineLog;
      if (cache.isNotEmpty) {
        final json = jsonDecode(cache);
        routineLog = RoutineLogDto.fromCachedLog(json: json);
      }
      if (routineLog != null) {
        final arguments = RoutineLogArguments(log: routineLog, editorMode: RoutineEditorMode.log, cached: true);
        navigateToRoutineLogEditor(context: context, arguments: arguments);
      }
    });
  }

  void _authenticateSahhaUser() {
    final userId = SharedPrefs().userId;
    SahhaFlutter.authenticate(appId: sahhaAppId, appSecret: sahhaAppSecret, externalId: userId)
        .then((success) => {debugPrint('Sahha user authenticated: $success')})
        .catchError((error, stackTrace) => {debugPrint('Sahha user authentication error: $error')});
  }

  @override
  void initState() {
    super.initState();
    if (SharedPrefs().firstLaunch) {
      _cacheUser();
    } else {
      Posthog().identify(userId: SharedPrefs().userId);
      _authenticateSahhaUser();
    }

    _loadAppData();

    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin()
          .cancelAll(); // Cancel all notifications including pending workout sessions and regular training reminders
    }
    _loadCachedLog();
  }

  @override
  void dispose() {
    _exerciseStream?.cancel();
    _routineTemplateStream?.cancel();
    _routinePlanStream?.cancel();
    _routineLogStream?.cancel();
    _routineUserStream?.cancel();
    super.dispose();
  }
}
