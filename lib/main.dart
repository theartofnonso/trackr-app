import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/providers/exercise_log_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/screens/home_screen.dart';
import 'package:tracker_app/screens/intro_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefs().init();

  await initializeDateFormatting();

  await SentryFlutter.init(
    (options) {
      options.dsn = kReleaseMode ? 'https://45d4468d9e461dc80082807aea326bd7@o4506338359377920.ingest.sentry.io/4506338360754176' : "";
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MultiProvider(providers: [
      ChangeNotifierProvider<ExerciseProvider>(
        create: (BuildContext context) => ExerciseProvider(),
      ),
      ChangeNotifierProvider<RoutineProvider>(
        create: (BuildContext context) => RoutineProvider(),
      ),
      ChangeNotifierProvider<RoutineLogProvider>(
        create: (BuildContext context) => RoutineLogProvider(),
      ),
      ChangeNotifierProvider<ExerciseLogProvider>(
        create: (BuildContext context) => ExerciseLogProvider(),
      ),
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

    try {
      await Amplify.addPlugin(AmplifyAuthCognito());
      await Amplify.addPlugin(AmplifyAPI(modelProvider: ModelProvider.instance));
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      print('Could not configure Amplify: $e');
    }
  }

  void _completeIntro() {
    setState(() {
      _isFirstLaunch = false;
    });
  }

  final _themeData = ThemeData(
    scaffoldBackgroundColor: tealBlueDark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.white,
      error: Colors.white,
      onError: Colors.black,
      background: tealBlueDark,
      onBackground: Colors.white,
      surface: tealBlueLighter,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: tealBlueDark,
      surfaceTintColor: tealBlueDark,
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: tealBlueDark, actionBackgroundColor: tealBlueLighter),
    tabBarTheme: const TabBarTheme(labelColor: Colors.white, unselectedLabelColor: Colors.white70),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: tealBlueLight)),
      enabledBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Colors.black)),
      filled: true,
      fillColor: tealBlueLighter,
      hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor: MaterialStateProperty.all(tealBlueLight),
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

    return _isFirstLaunch
        ? IntroScreen(themeData: _themeData, onComplete: _completeIntro)
        : Authenticator(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              builder: Authenticator.builder(),
              theme: _themeData,
              home: const HomeScreen(),
            ),
          );
  }
}
