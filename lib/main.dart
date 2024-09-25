import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/controllers/notification_controller.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/controllers/settings_controller.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/dtos/routine_template_dto.dart';
import 'package:tracker_app/dtos/viewmodels/exercise_editor_arguments.dart';
import 'package:tracker_app/dtos/viewmodels/past_routine_log_arguments.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/repositories/amplify_exercise_repository.dart';
import 'package:tracker_app/repositories/amplify_log_repository.dart';
import 'package:tracker_app/repositories/amplify_template_repository.dart';
import 'package:tracker_app/repositories/exercise_log_repository.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';
import 'package:tracker_app/screens/editors/past_routine_log_editor_screen.dart';
import 'package:tracker_app/screens/editors/routine_log_editor_screen.dart';
import 'package:tracker_app/screens/editors/routine_template_editor_screen.dart';
import 'package:tracker_app/screens/home_screen.dart';
import 'package:tracker_app/screens/insights/overview_screen.dart';
import 'package:tracker_app/screens/insights/sets_reps_volume_insights_screen.dart';
import 'package:tracker_app/screens/intro_screen.dart';
import 'package:tracker_app/screens/logs/routine_log_screen.dart';
import 'package:tracker_app/screens/logs/routine_log_summary_screen.dart';
import 'package:tracker_app/screens/logs/routine_logs_screen.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/screens/template/routines_home.dart';
import 'package:tracker_app/screens/template/templates/routine_template_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import 'amplifyconfiguration.dart';
import 'dtos/viewmodels/routine_log_arguments.dart';
import 'dtos/viewmodels/routine_template_arguments.dart';
import 'models/ModelProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefs().init();

  await initializeDateFormatting();

  const DarwinInitializationSettings iOSInitializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("app_icon");

  const initializationSettings =
      InitializationSettings(iOS: iOSInitializationSettingsDarwin, android: androidInitializationSettings);

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
        create: (BuildContext context) => RoutineLogController(AmplifyLogRepository()),
      ),
      ChangeNotifierProvider<ExerciseLogController>(
          create: (BuildContext context) => ExerciseLogController(ExerciseLogRepository())),
    ], child: const MyApp())),
  );
}

final _router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
        path: "/", // Define the path for Home Screen
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: "shared-workout/:id",
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? "";
              return RoutineTemplateScreen(id: id);
            },
          ),
          GoRoute(
            path: "shared-workout-log/:id",
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? "";
              return RoutineLogScreen(id: id, showSummary: false);
            },
          )
        ]),
    GoRoute(
      path: OverviewScreen.routeName, // Define the path for OverviewScreen
      builder: (context, state) => const OverviewScreen(),
    ),
    GoRoute(
      path: RoutinesHome.routeName,
      builder: (context, state) => const RoutinesHome(),
    ),
    GoRoute(
      path: RoutineLogEditorScreen.routeName,
      builder: (context, state) {
        final args = state.extra as RoutineLogArguments;
        return RoutineLogEditorScreen(log: args.log, mode: args.editorMode);
      },
    ),
    GoRoute(
      path: RoutineTemplateEditorScreen.routeName,
      builder: (context, state) {
        final args = state.extra as RoutineTemplateArguments?;
        return RoutineTemplateEditorScreen(template: args?.template);
      },
    ),
    GoRoute(
      path: PastRoutineLogEditorScreen.routeName,
      builder: (context, state) {
        final args = state.extra as PastRoutineLogArguments;
        return PastRoutineLogEditorScreen(log: args.log);
      },
    ),
    GoRoute(
      path: ExerciseEditorScreen.routeName,
      builder: (context, state) {
        final args = state.extra as ExerciseEditorArguments?;
        return ExerciseEditorScreen(exercise: args?.exercise);
      },
    ),
    GoRoute(
      path: RoutineLogsScreen.routeName,
      builder: (context, state) {
        final args = state.extra as List<RoutineLogDto>?;
        return RoutineLogsScreen(logs: args);
      },
    ),
    GoRoute(
      path: RoutineTemplateScreen.routeName,
      builder: (context, state) {
        final template = state.extra as RoutineTemplateDto;
        return RoutineTemplateScreen(id: template.id);
      },
    ),
    GoRoute(
      path: RoutineLogScreen.routeName,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final log = extra["log"] as RoutineLogDto;
        final showSummary = extra["showSummary"] as bool;

        return CustomTransitionPage(
            child: RoutineLogScreen(id: log.id, showSummary: showSummary),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            });
      },
    ),
    GoRoute(
      path: SettingsScreen.routeName,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: SetsAndRepsVolumeInsightsScreen.routeName,
      builder: (context, state) => const SetsAndRepsVolumeInsightsScreen(),
    ),
    GoRoute(
      path: RoutineLogSummaryScreen.routeName,
      pageBuilder: (context, state) {
        final args = state.extra as RoutineLogDto;
        return CustomTransitionPage(
            child: RoutineLogSummaryScreen(log: args),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            });
      },
    ),
  ],
);

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
    final now = DateTime.now().withoutTime();
    final then = DateTime(now.year - 1);
    final startOfCurrentYear = then.toIso8601String();
    final endOfCurrentYear = now.toIso8601String();
    try {
      await Amplify.addPlugin(AmplifyAuthCognito());
      final apiPluginOptions = APIPluginOptions(modelProvider: ModelProvider.instance);
      await Amplify.addPlugin(AmplifyAPI(options: apiPluginOptions));
      final datastorePluginOptions = DataStorePluginOptions(syncExpressions: [
        DataStoreSyncExpression(
            RoutineLog.classType, () => RoutineLog.CREATEDAT.between(startOfCurrentYear, endOfCurrentYear)),
      ]);
      await Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance, options: datastorePluginOptions));
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
      surface: sapphireLighter,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: sapphireDark,
      surfaceTintColor: sapphireDark,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(Colors.green),
      trackColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
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
          foregroundColor: WidgetStateProperty.all(Colors.white),
          backgroundColor: WidgetStateProperty.all(sapphireLight),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
    ),
    useMaterial3: true,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Lock orientation to portrait up
    ]);

    return _isFirstLaunch
        ? IntroScreen(themeData: _themeData, onComplete: _completeIntro)
        : Authenticator(
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              builder: Authenticator.builder(),
              theme: _themeData,
              routerConfig: _router,
            ),
          );
  }
}
