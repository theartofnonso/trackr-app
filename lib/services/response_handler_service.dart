import 'dart:async';
import 'package:tracker_app/dtos/chat_message_dto.dart';
import 'package:tracker_app/services/api_service.dart';
import 'package:tracker_app/services/data_converter_service.dart';

class ResponseHandlerService {
  final ApiService _apiService;
  final DataConverterService _dataConverter;

  ResponseHandlerService({
    ApiService? apiService,
    DataConverterService? dataConverter,
  })  : _apiService = apiService ?? ApiService(),
        _dataConverter = dataConverter ?? DataConverterService();

  /// Handles API response and returns appropriate ChatMessageDto
  ChatMessageDto handleApiResponse(Map<String, dynamic> response) {
    if (response.containsKey('workout')) {
      return _handleWorkoutResponse(response['workout']);
    } else if (response.containsKey('plan')) {
      return _handlePlanResponse(response['plan']);
    } else if (response.containsKey('response')) {
      return _handleGeneralResponse(response['response']);
    } else {
      return _handleErrorResponse();
    }
  }

  /// Handles workout response
  ChatMessageDto _handleWorkoutResponse(Map<String, dynamic> workout) {
    try {
      final routineTemplate =
          _dataConverter.convertWorkoutToRoutineTemplate(workout);
      return ChatMessageDto.workout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: workout['name'] ?? 'Workout',
        workout: routineTemplate,
      );
    } catch (e) {
      return _handleErrorResponse(e.toString());
    }
  }

  /// Handles plan response
  ChatMessageDto _handlePlanResponse(Map<String, dynamic> plan) {
    try {
      final routinePlan = _dataConverter.convertPlanToRoutinePlan(plan);
      return ChatMessageDto.plan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: plan['name'] ?? 'Plan',
        plan: routinePlan,
      );
    } catch (e) {
      return _handleErrorResponse(e.toString());
    }
  }

  /// Handles general response
  ChatMessageDto _handleGeneralResponse(String response) {
    return ChatMessageDto.general(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
    );
  }

  /// Handles error response
  ChatMessageDto _handleErrorResponse([String? errorMessage]) {
    return ChatMessageDto.general(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: "Something went wrong.",
    );
  }

  /// Makes API call and handles response
  Future<ChatMessageDto> processApiCall(String prompt,
      {Completer<void>? cancelCompleter}) async {
    try {
      final response = await _apiService.makeChatCall(prompt,
          cancelCompleter: cancelCompleter);
      return handleApiResponse(response);
    } catch (e) {
      return _handleErrorResponse(e.toString());
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
