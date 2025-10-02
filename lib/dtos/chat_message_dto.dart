import 'package:tracker_app/dtos/db/routine_plan_dto.dart';
import 'package:tracker_app/dtos/db/routine_template_dto.dart';

enum ChatMessageType {
  user,
  assistant,
  workout,
  plan,
  general,
}

class ChatMessageDto {
  final String id;
  final ChatMessageType type;
  final String content;
  final DateTime timestamp;
  final RoutineTemplateDto? workout;
  final RoutinePlanDto? plan;

  ChatMessageDto({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.workout,
    this.plan,
  });

  ChatMessageDto.user({
    required String id,
    required String content,
  }) : this(
          id: id,
          type: ChatMessageType.user,
          content: content,
          timestamp: DateTime.now(),
        );

  ChatMessageDto.assistant({
    required String id,
    required String content,
  }) : this(
          id: id,
          type: ChatMessageType.assistant,
          content: content,
          timestamp: DateTime.now(),
        );

  ChatMessageDto.workout({
    required String id,
    required String content,
    required RoutineTemplateDto workout,
  }) : this(
          id: id,
          type: ChatMessageType.workout,
          content: content,
          timestamp: DateTime.now(),
          workout: workout,
        );

  ChatMessageDto.plan({
    required String id,
    required String content,
    required RoutinePlanDto plan,
  }) : this(
          id: id,
          type: ChatMessageType.plan,
          content: content,
          timestamp: DateTime.now(),
          plan: plan,
        );

  ChatMessageDto.general({
    required String id,
    required String content,
  }) : this(
          id: id,
          type: ChatMessageType.general,
          content: content,
          timestamp: DateTime.now(),
        );
}
