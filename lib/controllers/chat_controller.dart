import 'package:flutter/foundation.dart';
import 'package:tracker_app/dtos/chat_message_dto.dart';
import 'package:tracker_app/services/chat_service.dart';
import 'package:tracker_app/logger.dart';

/// Chat controller for managing read-only cloud messages
/// Messages can only be created and read - no updates or deletions allowed
class ChatController extends ChangeNotifier {
  final ChatService _chatService = ChatService.instance;
  final logger = getLogger(className: "ChatController");

  List<ChatMessageDto> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessageDto> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load messages from cloud
  Future<void> loadMessages() async {
    _setLoading(true);
    _clearError();

    try {
      _messages = await _chatService.getMessages();
      logger.i('Loaded ${_messages.length} messages from cloud');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load messages: $e');
      logger.e('Failed to load messages: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new message to cloud
  Future<void> addMessage(ChatMessageDto message) async {
    try {
      await _chatService.saveMessage(message);
      _messages.add(message);
      notifyListeners();
      logger.i('Message added to cloud: ${message.id}');
    } catch (e) {
      _setError('Failed to save message: $e');
      logger.e('Failed to save message: $e');
    }
  }

  /// Start listening to real-time message changes
  void startListening() {
    _chatService.watchMessages().listen(
      (messages) {
        _messages = messages;
        notifyListeners();
        logger.i('Messages updated from real-time stream: ${messages.length}');
      },
      onError: (error) {
        _setError('Real-time sync failed: $error');
        logger.e('Real-time sync failed: $error');
      },
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
