import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/chat_message_dto.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_listview.dart';
import 'package:tracker_app/utils/routine_utils.dart';

class WorkoutPlanPreviewScreen extends StatelessWidget {
  final ChatMessageDto message;

  const WorkoutPlanPreviewScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? darkBackground : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Preview',
          style: GoogleFonts.ubuntu(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleAccept(context),
            child: Text(
              'Accept',
              style: GoogleFonts.ubuntu(
                color: vibrantGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with title and notes
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? darkSurface : Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? darkBorder : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: GoogleFonts.ubuntu(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_getNotes().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _getNotes(),
                    style: GoogleFonts.ubuntu(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    FaIcon(
                      _getIcon(),
                      color: vibrantGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getSubtitle(),
                      style: GoogleFonts.ubuntu(
                        color:
                            isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.workout:
        if (message.workout != null) {
          return ExerciseLogListView(
            exerciseLogs: exerciseLogsToViewModels(
              exerciseLogs: message.workout!.exerciseTemplates,
            ),
          );
        }
        break;
      case ChatMessageType.plan:
        if (message.plan != null) {
          return _buildPlanContent(context);
        }
        break;
      default:
        break;
    }

    return const Center(
      child: Text('No content to display'),
    );
  }

  Widget _buildPlanContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (message.plan == null) return const SizedBox.shrink();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: message.plan!.templates.length,
      itemBuilder: (context, index) {
        final template = message.plan!.templates[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? darkBorder : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.name,
                style: GoogleFonts.ubuntu(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (template.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  template.notes,
                  style: GoogleFonts.ubuntu(
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                '${template.exerciseTemplates.length} exercises',
                style: GoogleFonts.ubuntu(
                  color: vibrantGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getNotes() {
    switch (message.type) {
      case ChatMessageType.workout:
        return message.workout?.notes ?? '';
      case ChatMessageType.plan:
        return message.plan?.notes ?? '';
      default:
        return '';
    }
  }

  String _getSubtitle() {
    switch (message.type) {
      case ChatMessageType.workout:
        final exerciseCount = message.workout?.exerciseTemplates.length ?? 0;
        return '$exerciseCount exercises';
      case ChatMessageType.plan:
        final templateCount = message.plan?.templates.length ?? 0;
        return '$templateCount templates';
      default:
        return '';
    }
  }

  IconData _getIcon() {
    switch (message.type) {
      case ChatMessageType.workout:
        return FontAwesomeIcons.dumbbell;
      case ChatMessageType.plan:
        return FontAwesomeIcons.calendarDays;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  void _handleAccept(BuildContext context) {
    // TODO: Implement accept/save functionality
    // This should save the workout/plan and navigate to the appropriate screen
    Navigator.of(context).pop();
  }
}
