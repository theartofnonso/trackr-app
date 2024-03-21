import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/controllers/notification_controller.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/controllers/settings_controller.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/dtos/viewmodels/exercise_editor_arguments.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/repositories/achievement_repository.dart';
import 'package:tracker_app/repositories/amplify_exercise_repository.dart';
import 'package:tracker_app/repositories/amplify_log_repository.dart';
import 'package:tracker_app/repositories/amplify_template_repository.dart';
import 'package:tracker_app/repositories/exercise_log_repository.dart';
import 'package:tracker_app/screens/achievements/achievements_screen.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';
import 'package:tracker_app/screens/editors/routine_log_editor_screen.dart';
import 'package:tracker_app/screens/editors/routine_template_editor_screen.dart';
import 'package:tracker_app/screens/home_screen.dart';
import 'package:tracker_app/screens/insights/leaderboard/home_screen.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';
import 'package:tracker_app/screens/insights/streak_screen.dart';
import 'package:tracker_app/screens/intro_screen.dart';
import 'package:tracker_app/screens/logs/routine_logs_screen.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/screens/template/routines_home.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tracker_app/utils/app_analytics.dart';

import 'amplifyconfiguration.dart';
import 'dtos/viewmodels/routine_log_arguments.dart';
import 'dtos/viewmodels/routine_template_arguments.dart';
import 'models/ModelProvider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SharedPrefs().init();

  await initializeDateFormatting();

  const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const initializationSettings = InitializationSettings(iOS: initializationSettingsDarwin);

  await FlutterLocalNotificationsPlugin().initialize(initializationSettings);

  tz.initializeTimeZones();

  await SentryFlutter.init(
    (options) {
      options.dsn = kReleaseMode
          ? 'https://45d4468d9e461dc80082807aea326bd7@o4506338359377920.ingest.sentry.io/4506338360754176'
          : "";
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MultiProvider(providers: [
      ChangeNotifierProvider<SettingsController>(
        create: (BuildContext context) => SettingsController(),
      ),
      ChangeNotifierProvider<NotificationController>(
        create: (BuildContext context) => NotificationController(),
      ),
      ChangeNotifierProvider<ExerciseController>(
        create: (BuildContext context) => ExerciseController(AmplifyExerciseRepository()),
      ),
      ChangeNotifierProvider<RoutineTemplateController>(
        create: (BuildContext context) => RoutineTemplateController(AmplifyTemplateRepository()),
      ),
      ChangeNotifierProvider<RoutineLogController>(
        create: (BuildContext context) => RoutineLogController(AmplifyLogRepository(), AchievementRepository()),
      ),
      ChangeNotifierProvider<ExerciseLogController>(
          create: (BuildContext context) => ExerciseLogController(ExerciseLogRepository())),
    ], child: const MyApp())),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstLaunch = SharedPrefs().firstLaunch;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    /// Only sync data for this year
    final range = DateTime.now().dateTimeRange();
    final startOfCurrentYear = range.start.toIso8601String();
    final endOfCurrentYear = range.end.toIso8601String();
    try {
      await Amplify.addPlugin(AmplifyAnalyticsPinpoint());
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.addPlugin(AmplifyAPI(modelProvider: ModelProvider.instance));
      await Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance, syncExpressions: [
        DataStoreSyncExpression(
            RoutineLog.classType, () => RoutineLog.CREATEDAT.between(startOfCurrentYear, endOfCurrentYear)),
      ]));
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      debugPrint('Could not configure Amplify: $e');
    }
  }

  void _completeIntro() {
    setState(() {
      _isFirstLaunch = false;
    });
  }

  final _themeData = ThemeData(
    scaffoldBackgroundColor: sapphireDark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.white,
      error: Colors.white,
      onError: Colors.black,
      background: sapphireDark,
      onBackground: Colors.white,
      surface: sapphireLighter,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: sapphireDark,
      surfaceTintColor: sapphireDark,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(Colors.green),
      trackColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
    ),
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: sapphireDark,
        actionBackgroundColor: sapphireLighter,
        contentTextStyle: TextStyle(color: sapphireDark)),
    tabBarTheme: const TabBarTheme(labelColor: Colors.white, unselectedLabelColor: Colors.white70),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sapphireLight)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Colors.black)),
      filled: true,
      fillColor: sapphireLighter,
      hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor: MaterialStateProperty.all(sapphireLight),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
    ),
    useMaterial3: true,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarBrightness: Brightness.dark));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Lock orientation to portrait up
    ]);

    return _isFirstLaunch
        ? IntroScreen(themeData: _themeData, onComplete: _completeIntro)
        : Authenticator(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              builder: Authenticator.builder(),
              theme: _themeData,
              home: const HomeScreen(),
              onGenerateRoute: (settings) {
                if (settings.name == RoutineLogEditorScreen.routeName) {
                  final args = settings.arguments as RoutineLogArguments;
                  if (args.editorMode == RoutineEditorMode.log && args.emptySession) {
                    recordEmptySessionEvent();
                  } else {
                    recordTemplateSessionEvent();
                  }
                  return MaterialPageRoute(
                    builder: (context) => RoutineLogEditorScreen(
                      log: args.log,
                      mode: args.editorMode,
                    ),
                  );
                }

                if (settings.name == RoutineTemplateEditorScreen.routeName) {
                  final args = settings.arguments as RoutineTemplateArguments?;
                  recordVisitTemplateEditorEvent();
                  return MaterialPageRoute(
                    builder: (context) => RoutineTemplateEditorScreen(
                      template: args?.template,
                    ),
                  );
                }

                if (settings.name == RoutineLogsScreen.routeName) {
                  final args = settings.arguments as List<RoutineLogDto>?;
                  return MaterialPageRoute(
                    builder: (context) => RoutineLogsScreen(
                      logs: args,
                    ),
                  );
                }

                if (settings.name == ExerciseEditorScreen.routeName) {
                  final args = settings.arguments as ExerciseEditorArguments?;
                  recordCreateExerciseEvent();
                  return MaterialPageRoute(
                    builder: (context) => ExerciseEditorScreen(
                      exercise: args?.exercise,
                    ),
                  );
                }

                return null;
              },
              routes: {
                OverviewScreen.routeName: (context) => const OverviewScreen(),
                RoutinesHome.routeName: (context) => const RoutinesHome(),
                AchievementsScreen.routeName: (context) => const AchievementsScreen(),
                SettingsScreen.routeName: (context) => const SettingsScreen(),
                HomeScreen.routeName: (context) => const HomeScreen(),
                SetsAndRepsVolumeInsightsScreen.routeName: (context) => const SetsAndRepsVolumeInsightsScreen(),
                StreakScreen.routeName: (context) => const StreakScreen(),
                LeaderBoardScreen.routeName: (context) => const LeaderBoardScreen(),
              },
            ),
          );
  }
}
