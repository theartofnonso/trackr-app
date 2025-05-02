import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/muscle_group_extension.dart';
import 'package:tracker_app/screens/preferences/settings_screen.dart';
import 'package:tracker_app/widgets/icons/custom_wordmark_icon.dart';

import '../colors.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../shared_prefs.dart';
import 'data_trend_utils.dart';
import 'navigation_utils.dart';

bool isDefaultWeightUnit() {
  final weightString = SharedPrefs().weightUnit;
  final weightUnit = WeightUnit.fromString(weightString);
  return weightUnit == WeightUnit.kg;
}

bool isDefaultHeightUnit() {
  final heightString = SharedPrefs().heightUnit;
  final heightUnit = HeightUnit.fromString(heightString);
  return heightUnit == HeightUnit.cm;
}

double weightWithConversion({required num value}) {
  return isDefaultWeightUnit() ? value.toDouble() : toLbs(value.toDouble());
}

String heightWithConversion({HeightUnit? unit, required num value}) {
  return unit == HeightUnit.cm ? "$value cm" : toFtInString(value.toDouble());
}

String weightUnit() {
  return SharedPrefs().weightUnit;
}

String heightUnit() {
  return SharedPrefs().heightUnit;
}

double toKg(double value) {
  final conversion = value / 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

double toLbs(double value) {
  final conversion = value * 2.205;
  return double.parse(conversion.toStringAsFixed(2));
}

String toFtInString(double value) {
  // 1 inch = 2.54 cm, 1 foot = 12 inches
  final double totalInches = value / 2.54;
  final int feet = totalInches ~/ 12; // integer division to get whole feet
  final double remainderInches = totalInches % 12;
  // Round inches to 2 decimals if desired:
  return '$feet ft ${remainderInches.round()} in';
}

Map<String, num> toFtIn(double value) {
  // 1 inch = 2.54 cm, 1 foot = 12 inches
  final double totalInches = value / 2.54;
  final int feet = totalInches ~/ 12; // integer division to get whole feet
  final double remainderInches = totalInches % 12;
  // Round inches to 2 decimals if desired:
  return {'feet': feet, 'inches': remainderInches.round()};
}

int toCm({required int feet, required int inches}) {
  // 1 foot = 30.48 cm, 1 inch = 2.54 cm
  final double conversion = (feet * 30.48) + (inches * 2.54);
  return conversion.round();
}

void toggleWeightUnit({required WeightUnit unit}) {
  SharedPrefs().weightUnit = unit.name;
}

void toggleHeightUnit({required HeightUnit unit}) {
  SharedPrefs().heightUnit = unit.name;
}

String timeOfDay({DateTime? datetime}) {
  var hour = datetime?.hour ?? DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

Future<bool> batchDeleteUserData({required String document, required String documentKey}) async {
  final operation = Amplify.API.mutate(
    request: GraphQLRequest<dynamic>(document: document),
  );
  final response = await operation.response;
  final result = jsonDecode(response.data);
  return result[documentKey];
}

Future<NotificationsEnabledOptions> checkIosNotificationPermission() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions() ??
      const NotificationsEnabledOptions(
          isEnabled: false,
          isSoundEnabled: false,
          isAlertEnabled: false,
          isBadgeEnabled: false,
          isProvisionalEnabled: false,
          isCriticalEnabled: false);
}

Future<bool> requestNotificationPermission() async {
  return Platform.isIOS ? _requestIosNotificationPermission() : _requestAndroidNotificationPermission();
}

Future<bool> _requestIosNotificationPermission() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
      false;
}

Future<bool> _requestAndroidNotificationPermission() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission() ??
      false;
}

/// Higher values now get a "better" color (green)
Color lowToHighIntensityColor(double score) {
  if (score < 0.3) {
    // Severe DOMS (0–29%)
    return Colors.red;
  } else if (score < 0.5) {
    return Colors.yellow;
  } else if (score < 0.7) {
    return vibrantBlue;
  } else {
    return vibrantGreen;
  }
}

List<Color> lowToHighIntensityColors(double score) {
  if (score < 0.3) {
    return const [
      Color(0xFFFF5722), // strong orange
      Color(0xFFFF3945), // reddish-orange
      Color(0xFFEA004E), // crimson-red
      Color(0xFFFF5722),
    ];
  } else if (score < 0.5) {
    return const [
      Color(0xFFFFC107), // sunflower
      Color(0xFFFF9F1C), // deep yellow-orange
      Color(0xFFFF7538), // orange
      Color(0xFFFFC107),
    ];
  } else if (score < 0.7) {
    return const [
      Color(0xFF3763FF), // royal blue
      vibrantBlue, // teal-green
      Color(0xFF78FF5C), // lime-green
      Color(0xFF3763FF),
    ];
  } else {
    return const [
      Color(0xFF4CAF50), // medium green
      vibrantGreen, // yellow-green
      vibrantGreen, // soft yellow
      vibrantGreen,
    ];
  }
}

/// Lower values now get a "better" color (green)
Color highToLowIntensityColor(double score) {
  if (score < 0.3) {
    return vibrantGreen;
  } else if (score < 0.5) {
    return vibrantBlue;
  } else if (score < 0.7) {
    return Colors.yellow;
  } else {
    // Higher recovery values now get a "worse" color (red)
    return Colors.red;
  }
}

String recoveryMuscleIllustration({required double recoveryPercentage, required MuscleGroup muscleGroup}) {
  if (recoveryPercentage < 0.3) {
    // Severe DOMS (0–29%)
    return 'red_muscles_illustration/${muscleGroup.illustration()}.png';
  } else if (recoveryPercentage < 0.5) {
    // High soreness (30–49%)
    return 'yellow_muscles_illustration/${muscleGroup.illustration()}.png';
  } else if (recoveryPercentage < 0.7) {
    // Moderate soreness (50–79%)
    return 'blue_muscles_illustration/${muscleGroup.illustration()}.png';
  } else {
    // Mild or no soreness (80–100%)
    return 'muscles_illustration/${muscleGroup.illustration()}.png';
  }
}

Color setsTrendColor({required int sets}) {
  if (sets >= 12) {
    return vibrantGreen;
  } else if (sets >= 6) {
    return vibrantBlue;
  } else {
    return Colors.deepOrangeAccent;
  }
}

Color setsMilestoneColor({required double progress}) {
  if (progress >= 0.7) {
    return vibrantGreen;
  } else if (progress >= 0.5) {
    return vibrantBlue;
  } else if (progress >= 0.3) {
    return Colors.yellow;
  } else {
    return Colors.deepOrangeAccent;
  }
}

Color repsTrendColor({required int reps}) {
  if (reps >= 120) {
    return vibrantGreen;
  } else if (reps >= 60) {
    return vibrantBlue;
  } else {
    return Colors.deepOrangeAccent;
  }
}

final Map<int, Color> rpeIntensityToColor = {
  1: vibrantGreen, // Bright green - very light
  2: Color(0xFF66FF66), // Light green
  3: Color(0xFF99FF99), // Soft green
  4: Color(0xFFFFFF66), // Yellow-green transition
  5: Color(0xFFFFFF33), // Yellow - moderate intensity
  6: Color(0xFFFFCC33), // Amber - challenging intensity
  7: Color(0xFFFF9933), // Orange - very hard
  8: Color(0xFFFF6633), // Deep orange - near maximal
  9: Color(0xFFFF3333), // Bright red - maximal effort
  10: Color(0xFFFF0000), // Red - absolute limit
};

LinearGradient themeGradient({required BuildContext context}) {
  Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
  final isDarkMode = systemBrightness == Brightness.dark;

  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      isDarkMode ? sapphireDark80 : Colors.white,
      isDarkMode ? sapphireDark : Colors.white12,
    ],
  );
}

Widget getTrendIcon({required Trend trend}) {
  return switch (trend) {
    Trend.up => FaIcon(
        FontAwesomeIcons.arrowTrendUp,
        color: vibrantGreen,
        size: 20,
      ),
    Trend.down => FaIcon(
        FontAwesomeIcons.arrowTrendDown,
        color: Colors.deepOrange,
        size: 20,
      ),
    Trend.stable => Container(
        width: 30,
        height: 30,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: vibrantGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.check,
            size: 14,
            color: vibrantGreen,
          ),
        ),
      ),
    Trend.none => const SizedBox.shrink(),
  };
}

void logEmptyRoutine({required BuildContext context, String? workoutVideoUrl}) {
  final readiness = SharedPrefs().readinessScore;

  final log = RoutineLogDto(
      id: "",
      templateId: "",
      name: "${timeOfDay()} Session",
      exerciseLogs: [],
      notes: "",
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      owner: "",
      readinessScore: readiness,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now());

  final arguments = RoutineLogArguments(log: log, editorMode: RoutineEditorMode.log);
  navigateToRoutineLogEditor(context: context, arguments: arguments);
}

bool isOutsideReasonableRange(List<num> numbers, num newNumber,
    {double magnitudeThreshold = 10, double iqrFactor = 1.5}) {
  if (numbers.isEmpty) return false;

  final sorted = [...numbers]..sort();

  // Basic range check
  final currentMin = sorted.first;
  final currentMax = sorted.last;

  // Magnitude jump check (for decimal errors)
  final isMagnitudeJump =
      newNumber >= currentMax * magnitudeThreshold || (currentMin > 0 && newNumber <= currentMin / magnitudeThreshold);

  // IQR-based outlier check
  final q1 = _quantile(sorted, 0.25);
  final q3 = _quantile(sorted, 0.75);
  final iqr = q3 - q1;
  final lowerBound = q1 - iqrFactor * iqr;
  final upperBound = q3 + iqrFactor * iqr;

  return isMagnitudeJump || newNumber < lowerBound || newNumber > upperBound;
}

double _quantile(List<num> sorted, double p) {
  final index = p * (sorted.length - 1);
  final lower = sorted[index.floor()];
  final upper = sorted[index.ceil()];
  return lower + (upper - lower) * (index - index.floor());
}

bool isProbablyOutOfRangeInt(List<int> numbers, int newNumber) {
  if (numbers.isEmpty) return false;

  int currentMax = numbers.reduce((a, b) => a > b ? a : b);
  int currentMin = numbers.reduce((a, b) => a < b ? a : b);

  // Check if new number is 10x higher than current max
  bool isUpperOutlier = newNumber >= 2 * currentMax;

  // Check if new number is 10x lower than current min (only if min is positive)
  bool isLowerOutlier = currentMin > 0 && newNumber <= currentMin / 2;

  return isUpperOutlier || isLowerOutlier;
}

bool allNumbersAreSame({required List<num> numbers}) {
  if (numbers.isEmpty) return true; // or false, depending on your use case

  final first = numbers.first;
  return numbers.every((n) => n == first);
}

List<int> generateNumbers({required int start, required int end}) {
  // Create a list to hold the numbers
  List<int> numbers = [];
  // Loop from start to end and add each number to the list
  for (int i = start; i <= end; i++) {
    numbers.add(i);
  }
  return numbers;
}

String getReadinessSummary({required int readinessScore}) {
  final score = readinessScore / 100;

  // Ensure the score is within 0–100.
  if (readinessScore <= 0) {
    return "Your daily readiness score gives us insight into how rested you feel, so we can suggest workouts that match your energy levels.";
  }

  if (score < 0.3) {
    return "🛑 Very poor readiness. High pain, fatigue, or soreness likely. Consider rest, gentle mobility work, or seek medical advice.";
  } else if (score < 0.5) {
    return "⚠️ Low readiness. Notable issues like pain, fatigue, or heavy soreness. Reduce intensity and focus on recovery activities.";
  } else if (score < 0.7) {
    return "👍 Generally solid readiness. Minor aches or tiredness possible. Proceed with your planned workout but remain mindful of any overstress.";
  } else {
    return "💯 Optimal readiness. Minimal pain or fatigue. Suitable for higher intensity or advanced training, if desired.";
  }
}

/// Returns a short, human-readable summary of how weights changed.
///
/// Examples:
///   [60, 62.5, 65, 67.5] ➜ "Steady increase (+7.5 kg overall)"
///   [80, 78, 77]         ➜ "Overall drop (-3 kg)"
///   [50, 51, 49, 50]     ➜ "Mixed changes (net 0 kg)"
///
///

/// --- style helpers --------------------------------------------------------

Color _deltaColor(num difference) => difference > 0 ? vibrantGreen : difference < 0 ? Colors.red : Colors.yellow;

Widget _weight(num value, String unit, BuildContext context) {
  Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
  final isDarkMode = systemBrightness == Brightness.dark;
  return CustomWordMarkIcon("${value.toStringAsFixed(1)} $unit",
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: isDarkMode ? Colors.white70 : Colors.grey.shade600);
}

Widget summarizeProgression(
    {required BuildContext context, required List<num> values, TextAlign textAlign = TextAlign.start}) {
  if (values.isEmpty) return Text("No weight data available");

  final startWeight = values.first;
  final endWeight = values.last;
  final difference = endWeight - startWeight;

  String trend;
  if (difference > 0) {
    trend = "an upward trend ↗";
  } else if (difference < 0) {
    trend = "a downward trend ↘";
  } else {
    trend = "stable with no change →";
  }

  return Semantics(
    label: 'Starting at ${startWeight.toStringAsFixed(1)} $weightUnit, '
        'currently at ${endWeight.toStringAsFixed(1)} $weightUnit. '
        '${difference.abs().toStringAsFixed(1)} $weightUnit '
        '${difference > 0 ? 'gained' : 'lost'}. Showing $trend',
    child: RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 2),
        children: [
          const TextSpan(text: 'Starting at '),
          WidgetSpan(child: _weight(startWeight, weightUnit(), context), alignment: PlaceholderAlignment.middle),
          const TextSpan(text: ', currently at '),
          WidgetSpan(child: _weight(endWeight, weightUnit(), context), alignment: PlaceholderAlignment.middle),
          const TextSpan(text: ' . '),
          TextSpan(text: difference > 0 ? "You've gained" : difference < 0 ? "You lost" : "No change at"),
          TextSpan(text: " "),
          WidgetSpan(
              child: CustomWordMarkIcon('${difference.abs().toStringAsFixed(1)} ${weightUnit()}',
                  color: _deltaColor(difference), padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2)),
              alignment: PlaceholderAlignment.middle),
        ],
      ),
    ),
  );
}
