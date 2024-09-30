import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/enums/share_content_type_enum.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/shareables/pbs_shareable.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_lite.dart';
import 'package:tracker_app/widgets/shareables/session_milestone_shareable.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../urls.dart';
import '../../utils/app_analytics.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/shareables_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

class RoutineLogSummaryScreen extends StatefulWidget {
  static const routeName = '/shareable_screen';

  final RoutineLogDto log;

  const RoutineLogSummaryScreen({super.key, required this.log});

  @override
  State<RoutineLogSummaryScreen> createState() => _RoutineLogSummaryScreenState();
}

class _RoutineLogSummaryScreenState extends State<RoutineLogSummaryScreen> {
  bool _hasImage = false;

  Image? _image;

  final _controller = PageController(viewportFraction: 1);

  bool isMultipleOfFive(int number) {
    return number % 5 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: widget.log.exerciseLogs);
    final updatedLog = widget.log.copyWith(exerciseLogs: completedExerciseLogsAndSets);

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final logsByDay = groupBy(routineLogController.routineLogs, (log) => log.createdAt.withoutTime());

    final muscleGroupFamilyFrequencyData = muscleGroupFamilyFrequency(exerciseLogs: updatedLog.exerciseLogs);

    List<Widget> pbShareAssets = [];
    final pbShareAssetsKeys = [];

    for (final exerciseLog in updatedLog.exerciseLogs) {
      final pastExerciseLogs =
          routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
      final pbs = calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
      final setAndPBs = groupBy(pbs, (pb) => pb.set);
      for (final setAndPB in setAndPBs.entries) {
        final pbs = setAndPB.value;
        for (final pb in pbs) {
          final key = GlobalKey();
          final shareable = PBsShareable(set: setAndPB.key, pbDto: pb, globalKey: key, image: _image);
          pbShareAssets.add(shareable);
          pbShareAssetsKeys.add(key);
        }
      }
    }

    final pages = [
      if (isMultipleOfFive(logsByDay.length)) SessionMilestoneShareable(label: "${logsByDay.length}th", image: _image),
      ...pbShareAssets,
      RoutineLogShareableLite(log: updatedLog, frequencyData: muscleGroupFamilyFrequencyData, image: _image),
    ];

    final pagesKeys = [
      if (isMultipleOfFive(logsByDay.length)) sessionMilestoneShareableKey,
      ...pbShareAssetsKeys,
      routineLogShareableLiteKey,
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          heroTag: "routine_log_screen",
          onPressed: _showCopyBottomSheet,
          backgroundColor: sapphireDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: const FaIcon(Icons.copy)),
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.solidImage, color: Colors.white, size: 24),
            onPressed: _showBottomSheet,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  itemCount: pages.length,
                  itemBuilder: (_, index) {
                    return pages[index % pages.length];
                  },
                ),
              ),
              const Spacer(),
              SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: const ExpandingDotsEffect(activeDotColor: vibrantGreen),
              ),
              const SizedBox(height: 30),
              OpacityButtonWidget(
                  onPressed: () {
                    final index = _controller.page!.toInt();
                    captureImage(key: pagesKeys[index], pixelRatio: 3.5);
                    final contentType = _shareContentType(index: index);
                    contentShared(contentType: contentType);
                  },
                  label: "Share",
                  buttonColor: vibrantGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
            ],
          ),
        ),
      ),
    );
  }

  void _showCopyBottomSheet() {
    final workoutLogLink = "$shareableRoutineLogUrl/${widget.log.id}";
    final workoutLogText = _copyAsText();

    displayBottomSheet(
        context: context,
        isScrollControlled: true,
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.link, size: 14, color: Colors.white70),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(workoutLogLink,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      )),
                ),
                const SizedBox(width: 6),
                OpacityButtonWidget(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    final data = ClipboardData(text: workoutLogLink);
                    Clipboard.setData(data).then((_) {
                      if (mounted) {
                        context.pop();
                        showSnackbar(context: context, icon: const Icon(Icons.check), message: "Workout link copied");
                      }
                    });
                  },
                  label: "Copy",
                  buttonColor: vibrantGreen,
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sapphireDark80,
                border: Border.all(
                  color: sapphireDark80, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(5), // Optional: Rounded corners
              ),
              child: Text("${workoutLogText.substring(0, workoutLogText.length >= 150 ? 150 : workoutLogText.length)}...",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ubuntu(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  )),
            ),
            OpacityButtonWidget(
              onPressed: () {
                HapticFeedback.heavyImpact();
                final data = ClipboardData(text: workoutLogText);
                Clipboard.setData(data).then((_) {
                  if (mounted) {
                    context.pop();
                    showSnackbar(context: context, icon: const Icon(Icons.check), message: "Workout log copied");
                  }
                });
              },
              label: "Copy as text",
              buttonColor: vibrantGreen,
            )
          ]),
        ));
  }

  String _copyAsText() {
    final log = widget.log;
    StringBuffer workoutLogText = StringBuffer();

    workoutLogText.writeln(log.name);
    if (log.notes.isNotEmpty) {
      workoutLogText.writeln("Notes: ${log.notes}");
    }
    workoutLogText.writeln(log.createdAt.formattedDayAndMonthAndYear());

    for (var exerciseLog in log.exerciseLogs) {
      var exercise = exerciseLog.exercise;
      workoutLogText.writeln("\n- Exercise: ${exercise.name}");
      workoutLogText.writeln("  Muscle Group: ${exercise.primaryMuscleGroup.name}");

      for (var i = 0; i < exerciseLog.sets.length; i++) {
        switch (exerciseLog.exercise.type) {
          case ExerciseType.weights:
            workoutLogText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].weightsSummary()}");
            break;
          case ExerciseType.bodyWeight:
            workoutLogText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].bodyWeightSummary()}");
            break;
          case ExerciseType.duration:
            workoutLogText.writeln("   • Set ${i + 1}: ${exerciseLog.sets[i].durationSummary()}");
            break;
        }
      }
    }
    return workoutLogText.toString();
  }

  ShareContentType _shareContentType({required int index}) {
    if (index == 0) {
      return ShareContentType.milestoneAchievement;
    } else if (index == 1) {
      return ShareContentType.logMilestone;
    } else if (index == 2) {
      return ShareContentType.pbs;
    } else {
      return ShareContentType.sessionSummary;
    }
  }

  void _showBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.camera, size: 18),
              horizontalTitleGap: 6,
              title: Text("Camera",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () => _pickFromLibrary(camera: true),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.images, size: 18),
              horizontalTitleGap: 6,
              title: Text("Library",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () => _pickFromLibrary(camera: false),
            ),
            if (_hasImage)
              Column(children: [
                const Divider(
                  color: sapphireLighter,
                  thickness: 0.6,
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text("Remove Image",
                      style: GoogleFonts.ubuntu(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
                  onTap: _removeImage,
                ),
              ])
          ]),
        ));
  }

  void _pickFromLibrary({required bool camera}) async {
    context.pop();
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);
    if (xFile != null) {
      final Uint8List bytes = await xFile.readAsBytes();
      setState(() {
        _image = Image.memory(bytes);
        _hasImage = true;
      });
    }
  }

  void _removeImage() {
    context.pop();
    setState(() {
      _image = null;
      _hasImage = false;
    });
  }
}
