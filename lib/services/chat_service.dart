import 'package:tracker_app/dtos/chat_message_dto.dart';
import 'package:tracker_app/services/supabase_service.dart';
import 'package:tracker_app/logger.dart';

/// Chat service for cloud-only, read-only message persistence
/// Messages can only be created and read - no updates or deletions allowed
class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ChatService._();

  final SupabaseService _supabase = SupabaseService.instance;
  final logger = getLogger(className: "ChatService");

  /// Save a chat message to the cloud
  Future<void> saveMessage(ChatMessageDto message) async {
    if (!_supabase.isAuthenticated) {
      logger.w('Cannot save message: User not authenticated');
      return;
    }

    try {
      await _supabase.client.from('chat_messages').insert({
        'id': message.id,
        'owner': _supabase.currentUser!.id,
        'content': message.content,
        'type': message.type.name,
        'created_at': message.timestamp.toIso8601String(),
        'metadata': message.metadata,
      });

      logger.i('Message saved to cloud: ${message.id}');
    } catch (e) {
      logger.e('Failed to save message: $e');
      rethrow;
    }
  }

  /// Get all chat messages from the cloud
  Future<List<ChatMessageDto>> getMessages() async {
    if (!_supabase.isAuthenticated) {
      logger.w('Cannot fetch messages: User not authenticated');
      return [];
    }

    try {
      final response = await _supabase.client
          .from('chat_messages')
          .select()
          .eq('owner', _supabase.currentUser!.id)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((row) => ChatMessageDto.fromSupabaseRow(row))
          .toList();

      logger.i('Fetched ${messages.length} messages from cloud');
      return messages;
    } catch (e) {
      logger.e('Failed to fetch messages: $e');
      return [];
    }
  }

  /// Listen to real-time chat message changes
  Stream<List<ChatMessageDto>> watchMessages() {
    if (!_supabase.isAuthenticated) {
      return Stream.value([]);
    }

    return _supabase.client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('owner', _supabase.currentUser!.id)
        .order('created_at', ascending: true)
        .map((data) =>
            data.map((row) => ChatMessageDto.fromSupabaseRow(row)).toList());
  }
}
