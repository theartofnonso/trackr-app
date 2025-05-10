import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sahha_flutter/sahha_flutter.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/revenuecat_utils.dart';

import '../colors.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../models/RoutineLog.dart';
import '../models/RoutinePlan.dart';
import '../models/RoutineTemplate.dart';
import '../utils/general_utils.dart';
import '../utils/navigation_utils.dart';
import '../utils/sahha_utils.dart';
import 'notifications/notifications_screen.dart';
import 'overview_screen.dart';

class Home extends StatefulWidget {
  static const routeName = '/home_screen';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  SahhaSensorStatus _sensorStatus = SahhaSensorStatus.pending;

  StreamSubscription<QuerySnapshot<RoutineLog>>? _routineLogStream;
  StreamSubscription<QuerySnapshot<RoutineTemplate>>? _routineTemplateStream;
  StreamSubscription<QuerySnapshot<RoutinePlan>>? _routinePlanStream;
  StreamSubscription<QuerySnapshot<Exercise>>? _exerciseStream;

  @override
  Widget build(BuildContext context) {
    final hasPendingActions = _sensorStatus == SahhaSensorStatus.pending;

    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: _navigateToNotificationHome,
          icon: Badge(
              smallSize: 8,
              backgroundColor: hasPendingActions ? vibrantGreen : Colors.transparent,
              child: FaIcon(FontAwesomeIcons.solidBell)),
        ),
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
          onRefresh: _pullRefresh,
          child: SafeArea(
            minimum: const EdgeInsets.all(10),
            bottom: false,
            child: OverviewScreen(),
          ),
        ),
      ),
    );
  }

  void _loadAppData() {
    _observeExerciseQuery();
    _observeRoutineLogQuery();
    _observeRoutineTemplateQuery();
    _observeRoutinePlanQuery();
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

  Future<void> _userSetup() async {
    try {
      // ── 1. Get the signed-in Amplify user ────────────────────────────────
      final authUser = await Amplify.Auth.getCurrentUser();
      final userId = authUser.userId;
      final email = authUser.signInDetails.toJson()['username']?.toString() ?? '';

      // ── 2. Persist to SharedPrefs & analytics ─────────────────────────────
      final prefs = SharedPrefs();
      prefs
        ..userId = userId
        ..userEmail = email;

      Posthog().identify(userId: userId);

      _authSahhaUser(userId: userId);

      logInUserForAppPurchases(userId: userId);

      _loadAppData();
    }

    // Amplify-specific failures
    on AuthException catch (e, st) {
      debugPrint('[UserSetup] Amplify Auth error: ${e.message}');
      debugPrintStack(stackTrace: st);
    }

    // Anything else
    catch (e, st) {
      debugPrint('[UserSetup] unexpected error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// Wrapper that authenticates with Sahha and, if successful,
  /// immediately fetches the readiness score.
  Future<void> _authSahhaUser({required String userId}) async {
    final isSubscribed = await _checkSubscriptionStatus();
    print(isSubscribed);
    if (isSubscribed) {
      final ok = await authenticateSahhaUser(userId: userId);
      if (ok) {
        _getSahhaReadinessScore();
      }
    } else {
      deAuthenticateSahhaUser();
    }
  }

  void _loadCachedLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ;
      final cache = SharedPrefs().routineLog;
      if (cache.isNotEmpty) {
        final json = jsonDecode(cache);
        final routineLog = RoutineLogDto.fromCachedLog(json: json);
        final arguments = RoutineLogArguments(log: routineLog, editorMode: RoutineEditorMode.log, cached: true);
        navigateToRoutineLogEditor(context: context, arguments: arguments);
      }
    });
  }

  void _getSahhaReadinessScore() {
    Provider.of<ExerciseAndRoutineController>(context, listen: false).getSahhaReadinessScore();
  }

  void _checkSahhaSensors() {
    SahhaFlutter.getSensorStatus(sahhaSensors).then((value) {
      setState(() {
        _sensorStatus = value;
      });
    }).catchError((error, stackTrace) {
      debugPrint(error.toString());
    });
  }

  Future<bool> _checkSubscriptionStatus() async {
    bool isSubscribed = false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      isSubscribed = customerInfo.entitlements.all["pro"]?.isActive ?? false;
    } on PlatformException catch (_) {
      // Error fetching customer info
    }
    return isSubscribed;
  }

  void _navigateToNotificationHome() {
    navigateWithSlideTransition(
        context: context,
        child: NotificationsScreen(
          onSahhaSensorStatusUpdate: (SahhaSensorStatus sensorStatus) {
            setState(() {
              _sensorStatus = sensorStatus;
            });
          },
        ));
  }

  Future<void> _pullRefresh() async {
    _getSahhaReadinessScore();
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

    _checkSahhaSensors();

    _loadCachedLog();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exerciseStream?.cancel();
    _routineTemplateStream?.cancel();
    _routinePlanStream?.cancel();
    _routineLogStream?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// Uncomment this to enable notifications
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkSahhaSensors();
        _getSahhaReadinessScore();
      });
    }
  }
}
