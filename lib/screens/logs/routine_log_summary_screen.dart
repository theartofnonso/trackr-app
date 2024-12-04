import 'package:collection/collection.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/shareables/milestone_shareable.dart';
import 'package:tracker_app/widgets/shareables/pbs_shareable.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_lite.dart';
import 'package:tracker_app/widgets/shareables/session_milestone_shareable.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../urls.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/routine_utils.dart';
import '../../utils/shareables_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/label_divider.dart';

class RoutineLogSummaryScreen extends StatefulWidget {
  static const routeName = '/routine_log_summary_screen';

  final RoutineLogDto log;

  const RoutineLogSummaryScreen({super.key, required this.log});

  @override
  State<RoutineLogSummaryScreen> createState() => _RoutineLogSummaryScreenState();
}

class _RoutineLogSummaryScreenState extends State<RoutineLogSummaryScreen> {
  bool _hasImage = false;

  Image? _image;

  final _pageController = PageController(viewportFraction: 1);

  final _confettiController = ConfettiController();

  bool isMultipleOfFive(int number) {
    return number % 5 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final updatedExerciseLogs = completedExercises(exerciseLogs: widget.log.exerciseLogs);

    final updatedLog = widget.log.copyWith(exerciseLogs: updatedExerciseLogs);

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);
    List<RoutineLogDto> routineLogsForTheYear =
        exerciseAndRoutineController.whereLogsIsSameYear(dateTime: DateTime.now().withoutTime());

    final newMilestones = exerciseAndRoutineController.newMilestones;

    final muscleGroupFamilyFrequencyData =
        muscleGroupFamilyFrequency(exerciseLogs: updatedLog.exerciseLogs, includeSecondaryMuscleGroups: false);

    List<Widget> milestoneShareAssets = [];
    final milestoneShareAssetsKeys = [];
    for (final milestone in newMilestones) {
      final key = GlobalKey();
      final shareable = MilestoneShareable(globalKey: key, milestone: milestone, image: _image);
      milestoneShareAssets.add(shareable);
      milestoneShareAssetsKeys.add(key);
    }

    List<Widget> pbShareAssets = [];
    final pbShareAssetsKeys = [];

    for (final exerciseLog in updatedLog.exerciseLogs) {
      final pastExerciseLogs = exerciseAndRoutineController.whereExerciseLogsBefore(
          exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
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
      ...milestoneShareAssets,
      if (isMultipleOfFive(routineLogsForTheYear.length))
        SessionMilestoneShareable(label: "${routineLogsForTheYear.length}th", image: _image),
      ...pbShareAssets,
      RoutineLogShareableLite(
          log: updatedLog, frequencyData: muscleGroupFamilyFrequencyData, pbs: pbShareAssets.length, image: _image),
    ];

    final pagesKeys = [
      ...milestoneShareAssetsKeys,
      if (isMultipleOfFive(routineLogsForTheYear.length)) sessionMilestoneGlobalKey,
      ...pbShareAssetsKeys,
      routineLogGlobalKey,
    ];

    return Stack(alignment: Alignment.topCenter, children: [
      Scaffold(
        floatingActionButton: FloatingActionButton(
            heroTag: "routine_log_screen",
            onPressed: _showCopyBottomSheet,
            backgroundColor: sapphireDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const FaIcon(Icons.copy)),
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
            onPressed: context.pop,
          ),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.camera, color: Colors.white, size: 24),
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
                AspectRatio(
                  aspectRatio: 1,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    itemCount: pages.length,
                    itemBuilder: (_, index) {
                      return pages[index % pages.length];
                    },
                  ),
                ),
                const Spacer(),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: pages.length,
                  effect: const ExpandingDotsEffect(activeDotColor: vibrantGreen),
                ),
                const SizedBox(height: 30),
                OpacityButtonWidget(
                    onPressed: () {
                      final index = _pageController.page!.toInt();
                      captureImage(key: pagesKeys[index], pixelRatio: 3.5).then((result) {
                        if (context.mounted) {
                          if (result.status == ShareResultStatus.success) {
                            showSnackbar(
                                context: context,
                                icon: const FaIcon(FontAwesomeIcons.solidSquareCheck),
                                message: "Content Shared");
                          }
                        }
                      });
                    },
                    label: "Share",
                    buttonColor: vibrantGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
              ],
            ),
          ),
        ),
      ),
      ConfettiWidget(
          minBlastForce: 10,
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive)
    ]);
  }

  void _showCopyBottomSheet() {
    final listOfCompletedExercises = completedExercises(exerciseLogs: widget.log.exerciseLogs);

    final updatedLog = widget.log.copyWith(exerciseLogs: listOfCompletedExercises);

    final workoutLogLink = "$shareableRoutineLogUrl/${updatedLog.id}";
    final workoutLogText = copyRoutineAsText(
        routineType: RoutinePreviewType.log,
        name: updatedLog.name,
        notes: updatedLog.notes,
        exerciseLogs: updatedLog.exerciseLogs);

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
                        Navigator.of(context).pop();
                        showSnackbar(
                            context: context,
                            icon: const FaIcon(FontAwesomeIcons.solidSquareCheck),
                            message: "Workout link copied");
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
              child:
                  Text("${workoutLogText.substring(0, workoutLogText.length >= 150 ? 150 : workoutLogText.length)}...",
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
                    Navigator.of(context).pop();
                    showSnackbar(
                        context: context,
                        icon: const FaIcon(FontAwesomeIcons.solidSquareCheck),
                        message: "Workout log copied");
                  }
                });
              },
              label: "Copy as text",
              buttonColor: vibrantGreen,
            )
          ]),
        ));
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
                const SizedBox(
                  height: 10,
                ),
                const LabelDivider(
                  label: "Don't like the vibe?",
                  labelColor: Colors.white70,
                  dividerColor: sapphireLighter,
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
    Navigator.of(context).pop();
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
    Navigator.of(context).pop();
    setState(() {
      _image = null;
      _hasImage = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}
