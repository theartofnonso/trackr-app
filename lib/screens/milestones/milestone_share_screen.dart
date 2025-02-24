import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/shareables/milestone_shareable.dart';

import '../../colors.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/shareables_utils.dart';
import '../../widgets/dividers/label_divider.dart';

class MilestoneShareScreen extends StatefulWidget {
  static const routeName = '/milestone_share_screen';

  final Milestone milestone;

  const MilestoneShareScreen({super.key, required this.milestone});

  @override
  State<MilestoneShareScreen> createState() => _MilestoneShareScreenState();
}

class _MilestoneShareScreenState extends State<MilestoneShareScreen> {
  bool _hasImage = false;

  Image? _image;

  final _confettiController = ConfettiController();

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    return Stack(alignment: Alignment.topCenter, children: [
      Scaffold(
        floatingActionButton: FloatingActionButton(
            heroTag: "milestone_share_screen",
            onPressed: () {
              _showShareAction(key: key);
            },
            child: const FaIcon(FontAwesomeIcons.rocket)),
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: context.pop,
          ),
          title: Text("Share".toUpperCase()),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.camera, size: 24),
              onPressed: _showBottomSheet,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(gradient: themeGradient(context: context)),
          child: SafeArea(
            minimum: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                AspectRatio(
                  aspectRatio: 1,
                  child: MilestoneShareable(globalKey: key, milestone: widget.milestone, image: _image),
                ),
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

  void _showShareAction({required GlobalKey key}) {
    captureImage(key: key, pixelRatio: 3.5).then((result) {
      if (context.mounted) {
        if (result.status == ShareResultStatus.success) {
          Posthog().capture(eventName: PostHogAnalyticsEvent.shareRoutineLogSummary.displayName);
          if (mounted) {
            showSnackbar(
                context: context, icon: const FaIcon(FontAwesomeIcons.solidSquareCheck), message: "Content Shared");
          }
        }
      }
    });
  }

  void _showBottomSheet() {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.camera, size: 18),
              horizontalTitleGap: 6,
              title: Text("Camera"),
              onTap: () => _pickFromLibrary(camera: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.images, size: 18),
              horizontalTitleGap: 6,
              title: Text("Library"),
              onTap: () => _pickFromLibrary(camera: false),
            ),
            if (_hasImage)
              Column(children: [
                const SizedBox(
                  height: 10,
                ),
                LabelDivider(
                  label: "Don't like the vibe?",
                  labelColor: isDarkMode ? Colors.white70 : Colors.black,
                  dividerColor: sapphireLighter,
                ),
                ListTile(
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
