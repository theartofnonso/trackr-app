import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';

import '../../controllers/chat_controller.dart';
import '../../dtos/chat_message_dto.dart';
import '../../services/response_handler_service.dart';
import '../../widgets/chat/chat_bubble_widget.dart';
import '../../widgets/chat/loading_message_widget.dart';

class CoachChatScreen extends StatefulWidget {
  static const routeName = '/routine_ai_context_screen';

  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  bool _loading = false;
  late TextEditingController _textEditingController;
  late final ResponseHandlerService _responseHandler;
  Completer<void>? _cancelCompleter;
  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        return Scaffold(
            body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? darkBackground : Colors.white,
              ),
              child: SafeArea(
                bottom: false,
                minimum: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat Messages
                    Expanded(
                      child: chatController.messages.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                              ),
                              child: const NoListEmptyState(
                                  message:
                                      "Please describe your workout or plan to get started with your Coach."),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top,
                                bottom: 8,
                              ),
                              itemCount: chatController.messages.length +
                                  (_loading ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Show loading message at the end if loading
                                if (index == chatController.messages.length &&
                                    _loading) {
                                  return const LoadingMessageWidget();
                                }

                                final message = chatController.messages[index];
                                return ChatBubbleWidget(
                                  message: message,
                                  onTap: () => _handleMessageTap(message),
                                );
                              },
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
                                hintText: "What do you want to train?",
                                hintStyle: GoogleFonts.ubuntu(
                                  color: (isDarkMode
                                      ? Colors.white70
                                      : Colors.grey.shade600),
                                ),
                              ),
                              cursorColor:
                                  isDarkMode ? darkOnSurface : Colors.black,
                              maxLines: null,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          IconButton(
                            onPressed: _loading ? _cancelRequest : _runMessage,
                            icon: Container(
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _loading
                                    ? Colors.red.withValues(alpha: 0.8)
                                    : (isDarkMode
                                        ? vibrantGreen.withValues(alpha: 0.1)
                                        : vibrantGreen.withValues(alpha: 0.4)),
                                borderRadius: BorderRadius.circular(radiusMD),
                              ),
                              child: Center(
                                child: FaIcon(
                                  _loading
                                      ? FontAwesomeIcons.stop
                                      : FontAwesomeIcons.rocket,
                                  size: 20,
                                  color: _loading ? Colors.white : null,
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
            ),
            // Overlay close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? darkSurface.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.squareXmark,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ));
      },
    );
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _loading = loading;
      });
    }
  }

  void _cancelRequest() {
    if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
      _cancelCompleter!.complete();
    }
    _setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _responseHandler = ResponseHandlerService();
    _scrollController = ScrollController();

    // Load existing messages from ChatController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatController =
          Provider.of<ChatController>(context, listen: false);
      chatController.loadMessages();
      chatController.startListening();
    });
  }

  void _runMessage() async {
    final userPrompt = _textEditingController.text;

    if (userPrompt.isNotEmpty) {
      _dismissKeyboard();
      _clearTextEditing();

      // Add user message to chat
      final chatController =
          Provider.of<ChatController>(context, listen: false);
      final userMessage = ChatMessageDto.user(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: userPrompt,
      );
      await chatController.addMessage(userMessage);

      // Scroll to bottom after adding user message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Create cancel completer for this request
      _cancelCompleter = Completer<void>();
      _setLoading(true);

      try {
        final message = await _responseHandler.processApiCall(
          userPrompt,
          cancelCompleter: _cancelCompleter,
        );
        _handleApiResponse(message);
      } catch (e) {
        _handleError(e.toString());
      } finally {
        _cancelCompleter = null;
      }
    }
  }

  void _handleApiResponse(ChatMessageDto message) async {
    _setLoading(false);

    final chatController = Provider.of<ChatController>(context, listen: false);
    await chatController.addMessage(message);

    // Scroll to bottom after adding message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _handleError(String errorMessage) async {
    _setLoading(false);

    final chatController = Provider.of<ChatController>(context, listen: false);
    final errorMessageDto = ChatMessageDto.general(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: "Something went wrong.",
    );
    await chatController.addMessage(errorMessageDto);

    // Scroll to bottom after adding error message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _handleMessageTap(ChatMessageDto message) {
    final workout = message.workout;
    final plan = message.plan;
    if (message.type == ChatMessageType.workout && workout != null) {
      // Navigate to RoutineTemplateScreen for workouts
      navigateToRoutineTemplatePreview(context: context, template: workout);
    } else if (message.type == ChatMessageType.plan && plan != null) {
      // Navigate to RoutineTemplateScreen for plans (using first template)
      navigateToRoutinePlanPreview(context: context, plan: plan);
    }
  }

  void _clearTextEditing() {
    setState(() {
      _textEditingController.clear();
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _responseHandler.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
