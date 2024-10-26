import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/amplify_models/routine_log_extension.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../colors.dart';
import '../dtos/routine_log_dto.dart';
import '../models/RoutineLog.dart';
import '../utils/date_utils.dart';
import '../utils/exercise_logs_utils.dart';
import '../utils/https_utils.dart';
import '../widgets/backgrounds/trkr_loading_screen.dart';
import '../widgets/chart/muscle_group_family_chart.dart';

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({super.key});

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  bool _loading = false;

  List<RoutineLogDto> _routineLogs = [];

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            sapphireDark60,
            sapphireDark,
          ],
        ),
      ),
      child: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: ListView.separated(
              itemCount: _routineLogs.length,
              itemBuilder: (BuildContext context, int index) {
                final routineLog = _routineLogs[index];
                return _FeedListItem(log: routineLog);
              },
              separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)))),
    );
  }

  void _loadData() {
    _showLoadingScreen();
    final dateRange = yearToDateTimeRange();
    final startOfCurrentYear = dateRange.start.toIso8601String();
    final endOfCurrentYear = dateRange.end.toIso8601String();

    getAPI(endpoint: "/routine-logs", queryParameters: {"start": startOfCurrentYear, "end": endOfCurrentYear})
        .then((response) {
      if (response.isNotEmpty) {
        final json = jsonDecode(response);
        final data = json["data"];
        final body = data["listRoutineLogs"];
        final items = body["items"] as List<dynamic>;
       setState(() {
         _routineLogs = items.map((item) => RoutineLog.fromJson(item).dto()).sorted((a, b) => b.createdAt.compareTo(a.createdAt));
       });
      }
      _hideLoadingScreen();
    }).catchError((onError, _) {
      print(onError);
    });
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
}

class _FeedListItem extends StatelessWidget {
  final RoutineLogDto log;

  const _FeedListItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs);
    final updatedLog = log.copyWith(exerciseLogs: completedExerciseLogsAndSets);

    final muscleGroupFamilyFrequencyData =
        muscleGroupFamilyFrequency(exerciseLogs: updatedLog.exerciseLogs, includeSecondaryMuscleGroups: false);

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(log.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 1),
                Text(log.createdAt.formattedDayAndMonth(),
                    style: GoogleFonts.ubuntu(
                        color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                const SizedBox(width: 10),
                const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 1),
                Text(log.duration().hmsAnalog(),
                    style: GoogleFonts.ubuntu(
                        color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            ),
            trailing: Container(
                width: 40, // Width and height should be equal to make a perfect circle
                height: 40,
                decoration: BoxDecoration(
                  color: sapphireDark80,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5), // Optional border
                  boxShadow: [
                    BoxShadow(
                      color: sapphireDark.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: const Center(child: FaIcon(FontAwesomeIcons.solidUser, color: Colors.white54, size: 12))),
          ),
          RichText(
              text: TextSpan(
                  text: "${log.exerciseLogs.length} ${pluralize(word: "Exercise", count: log.exerciseLogs.length)}",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                  children: [
                const TextSpan(text: " "),
                TextSpan(
                    text:
                        "x${log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length)} ${pluralize(word: "Set", count: log.exerciseLogs.fold(0, (sum, e) => sum + e.sets.length))}",
                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 12))
              ])),
          const SizedBox(height: 8),
          MuscleGroupFamilyChart(frequencyData: muscleGroupFamilyFrequencyData),
        ]));
  }
}
