import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/datetime_entry_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/screens/activity_overview_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefs().init();

  await initializeDateFormatting();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<DateTimeEntryProvider>(
      create: (BuildContext context) => DateTimeEntryProvider(),
    ),
    ChangeNotifierProvider<RoutineProvider>(
      create: (BuildContext context) => RoutineProvider(),
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
      //await Amplify.addPlugin(AmplifyAPI(modelProvider: ModelProvider.instance));
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
        colorScheme: const ColorScheme.light(background: tealBlueLight, primary: Colors.white),
        textTheme: const TextTheme(
            headlineSmall: TextStyle(color: CupertinoColors.white),
            titleSmall: TextStyle(color: CupertinoColors.white),
            titleLarge: TextStyle(color: CupertinoColors.white),
            titleMedium: TextStyle(color: CupertinoColors.white),
            bodySmall: TextStyle(color: CupertinoColors.white, fontSize: 14),
            bodyMedium: TextStyle(color: CupertinoColors.white, fontSize: 15),
            bodyLarge: TextStyle(color: CupertinoColors.white, fontSize: 16),
            labelLarge: TextStyle(color: CupertinoColors.white, fontSize: 15, fontWeight: FontWeight.bold),
            labelMedium: TextStyle(color: CupertinoColors.white, fontSize: 15, fontWeight: FontWeight.w500)
        ),

        useMaterial3: true,
      ),
      home: _isLoading ? const Center(child: CircularProgressIndicator()) : const ActivityOverviewScreen(),
    );
  }
}
