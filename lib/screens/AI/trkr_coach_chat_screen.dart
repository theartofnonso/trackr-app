import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';

import '../../dtos/db/routine_template_dto.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';

class TRKRCoachChatScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  const TRKRCoachChatScreen({super.key});

  @override
  State<TRKRCoachChatScreen> createState() => _TRKRCoachChatScreenState();
}

class _TRKRCoachChatScreenState extends State<TRKRCoachChatScreen> {
  bool _loading = false;

  late TextEditingController _textEditingController;

  RoutineTemplateDto? _routineTemplate;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final routineTemplate = _routineTemplate;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
            onPressed: Navigator.of(context).pop,
          ),
          title: Text("TRNR Coach".toUpperCase()),
          actions: [
            routineTemplate != null
                ? IconButton(
                    icon: const FaIcon(FontAwesomeIcons.solidSquareCheck,
                        size: 28),
                    onPressed: _navigateBack,
                  )
                : const IconButton(
                    icon: SizedBox.shrink(),
                    onPressed: null,
                  )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? darkBackground : Colors.white,
          ),
          child: SafeArea(
            bottom: false,
            minimum: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                routineTemplate != null
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: ExerciseLogListView(
                              exerciseLogs: exerciseLogsToViewModels(
                                  exerciseLogs:
                                      routineTemplate.exerciseTemplates)),
                        ),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const NoListEmptyState(
                              message:
                                  "Please describe your workout or plan to get started with your Coach."),
                        ),
                      ),
                const SizedBox(height: 10),
                SafeArea(
                  minimum: EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                              hintText: "What do you want to train?"),
                          cursorColor:
                              isDarkMode ? darkOnSurface : Colors.black,
                          maxLines: null,
                          showCursor: true,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      IconButton(
                        onPressed: _runMessage,
                        icon: Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? vibrantGreen.withValues(alpha: 0.1)
                                : vibrantGreen.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(radiusMD),
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.rocket,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, message: message);
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  void _runMessage() async {
    final userPrompt = _textEditingController.text;

    if (userPrompt.isNotEmpty) {
      _dismissKeyboard();
      _showLoadingScreen();
      _clearTextEditing();

      // AI functionality has been removed
      _handleError();
    }
  }

  void _handleError() {
    _hideLoadingScreen();
    _showSnackbar(
      "Oops, I can only assist you with workouts.",
    );
  }

  void _clearTextEditing() {
    setState(() {
      _textEditingController.clear();
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _navigateBack() {
    context.pop(_routineTemplate);
  }
}
