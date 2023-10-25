import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/screens/home_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefs().init();

  await initializeDateFormatting();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ExerciseProvider>(
      create: (BuildContext context) => ExerciseProvider(),
    ),
    ChangeNotifierProvider<RoutineProvider>(
      create: (BuildContext context) => RoutineProvider(),
    ),
    ChangeNotifierProvider<RoutineLogProvider>(
      create: (BuildContext context) => RoutineLogProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugin(AmplifyAPI(modelProvider: ModelProvider.instance));
      await Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance));
      await Amplify.configure(amplifyconfig);
      setState(() {
        _isLoading = false; // important to set the state!
      });
    } on Exception catch (e) {
      print('Could not configure Amplify: $e');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarBrightness: Brightness.dark));
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: tealBlueDark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: tealBlueLighter,
          onPrimary: Colors.white,
          secondary: Colors.white,
          onSecondary: Colors.white,
          error: Colors.white,
          onError: Colors.black,
          background: tealBlueDark,
          onBackground: Colors.white,
          surface: Colors.white,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: _isLoading
          ? const Center(child: CupertinoActivityIndicator(color: CupertinoColors.white, radius: 16))
          : const HomeScreen(),
    );
  }
}
