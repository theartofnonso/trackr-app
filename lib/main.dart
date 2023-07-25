import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/activity_provider.dart';
import 'package:tracker_app/screens/activity_overview_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefs().init();

  await initializeDateFormatting();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ActivityProvider>(
      create: (BuildContext context) => ActivityProvider(),
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: const ColorScheme.dark(background: Colors.black, primary: Colors.white),
        useMaterial3: true,
      ),
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const SafeArea(child: ActivityOverviewScreen()),
    );
  }
}
