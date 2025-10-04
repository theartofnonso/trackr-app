import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../dtos/chat_message_dto.dart';
import '../../services/response_handler_service.dart';
import 'chat_bubble_widget.dart';
import 'loading_message_widget.dart';

class CoachChatWidget extends StatefulWidget {
  const CoachChatWidget({super.key});

  @override
  State<CoachChatWidget> createState() => _CoachChatWidgetState();
}

class _CoachChatWidgetState extends State<CoachChatWidget> {
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
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chat Messages
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? darkBackground : Colors.white,
                  ),
                  child: chatController.messages.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: const NoListEmptyState(
                            showIcon: false,
                            message:
                                "Ask your coach anything about training, nutrition, or fitness goals.",
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
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
                              onAccept: () => _handleMessageAccept(message),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Input Container
              Container(
                constraints: const BoxConstraints(
                  minHeight: 56,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? darkSurface : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: "Ask anything",
                          hintStyle: GoogleFonts.ubuntu(
                            color: isDarkMode
                                ? Colors.white60
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          filled: false,
                        ),
                        cursorColor: isDarkMode ? Colors.white : Colors.black,
                        maxLines: null,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        enabled: !_loading,
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _loading
                            ? Colors.red.withValues(alpha: 0.8)
                            : (isDarkMode
                                ? vibrantGreen.withValues(alpha: 0.1)
                                : vibrantGreen.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: IconButton(
                        onPressed: _loading ? _cancelRequest : _runMessage,
                        icon: FaIcon(
                          _loading
                              ? FontAwesomeIcons.stop
                              : FontAwesomeIcons.rocket,
                          size: 20,
                          color: _loading ? Colors.white : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
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

  void _handleMessageAccept(ChatMessageDto message) async {
    final workout = message.workout;
    final plan = message.plan;
    final controller =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);

    try {
      if (message.type == ChatMessageType.workout && workout != null) {
        // Save workout using controller
        final savedTemplate =
            await controller.saveTemplate(templateDto: workout);
        if (savedTemplate != null) {
          if (mounted) {
            showSnackbar(
                context: context, message: "Workout saved successfully!");
          }
        } else {
          if (mounted) {
            showSnackbar(context: context, message: "Failed to save workout");
          }
        }
      } else if (message.type == ChatMessageType.plan && plan != null) {
        // Save plan using controller
        final savedPlan = await controller.savePlan(planDto: plan);
        if (savedPlan != null) {
          if (mounted) {
            showSnackbar(context: context, message: "Plan saved successfully!");
          }
        } else {
          if (mounted) {
            showSnackbar(context: context, message: "Failed to save plan");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(
            context: context, message: "Error saving: ${e.toString()}");
      }
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
