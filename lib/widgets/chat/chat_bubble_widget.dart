import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/chat_message_dto.dart';
import 'package:tracker_app/widgets/chat/assistant_message_widget.dart';
import 'package:tracker_app/widgets/chat/interactive_message_widget.dart';
import 'package:tracker_app/widgets/chat/user_message_widget.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessageDto message;
  final VoidCallback? onTap;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.user:
        return UserMessageWidget(content: message.content);
      case ChatMessageType.assistant:
      case ChatMessageType.general:
        return AssistantMessageWidget(content: message.content);
      case ChatMessageType.workout:
      case ChatMessageType.plan:
        return InteractiveMessageWidget(
          title: message.content,
          subtitle: _getSubtitle(message),
          onTap: onTap,
        );
    }
  }

  String _getSubtitle(ChatMessageDto message) {
    switch (message.type) {
      case ChatMessageType.workout:
        final exerciseCount = message.workout?.exerciseTemplates.length ?? 0;
        final notes = message.workout?.notes ?? '';
        final previewNotes =
            notes.length > 50 ? '${notes.substring(0, 50)}...' : notes;
        return '$exerciseCount exercises${notes.isNotEmpty ? ' • $previewNotes' : ''}';
      case ChatMessageType.plan:
        final templateCount = message.plan?.templates.length ?? 0;
        final notes = message.plan?.notes ?? '';
        final previewNotes =
            notes.length > 50 ? '${notes.substring(0, 50)}...' : notes;
        return '$templateCount templates${notes.isNotEmpty ? ' • $previewNotes' : ''}';
      default:
        return '';
    }
  }
}
