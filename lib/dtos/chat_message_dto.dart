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
  final Map<String, dynamic>? metadata;

  ChatMessageDto({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.workout,
    this.plan,
    this.metadata,
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

  /// Convert from Supabase row format
  factory ChatMessageDto.fromSupabaseRow(Map<String, dynamic> row) {
    final metadata = row['metadata'] != null
        ? Map<String, dynamic>.from(row['metadata'] as Map)
        : null;

    RoutineTemplateDto? workout;
    RoutinePlanDto? plan;

    if (metadata != null) {
      if (metadata['workout'] != null) {
        workout = RoutineTemplateDto.fromJson(metadata['workout']);
      }
      if (metadata['plan'] != null) {
        plan = RoutinePlanDto.fromJson(metadata['plan']);
      }
    }

    return ChatMessageDto(
      id: row['id'] as String,
      type: ChatMessageType.values.firstWhere(
        (e) => e.name == row['type'] as String,
      ),
      content: row['content'] as String,
      timestamp: DateTime.parse(row['created_at'] as String),
      workout: workout,
      plan: plan,
      metadata: metadata,
    );
  }

  /// Convert to Supabase row format
  Map<String, dynamic> toSupabaseRow() {
    final metadata = <String, dynamic>{};

    if (workout != null) {
      metadata['workout'] = workout!.toJson();
    }
    if (plan != null) {
      metadata['plan'] = plan!.toJson();
    }
    if (this.metadata != null) {
      metadata.addAll(this.metadata!);
    }

    return {
      'id': id,
      'content': content,
      'type': type.name,
      'created_at': timestamp.toIso8601String(),
      'metadata': metadata.isNotEmpty ? metadata : null,
    };
  }
}
