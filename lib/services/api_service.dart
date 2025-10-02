import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _productionUrl = 'https://api.trainer.ware.health';
  static const String _debugUrl = 'http://localhost:3000';
  static const String _userId = '2108b800-02ca-4cb8-a4e3-15409ef810ed';
  static const String _vectorStoreId = 'vs_68d8713caf748191ba6a790c5388631f';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Makes an API call to the chat endpoint
  /// Returns the response as a Map&lt;String, dynamic&gt;
  Future<Map<String, dynamic>> makeChatCall(String prompt,
      {Completer<void>? cancelCompleter}) async {
    final String baseUrl = kDebugMode ? _debugUrl : _productionUrl;

    if (kDebugMode) {
      print('🔧 Debug Mode: Using API URL: $baseUrl');
    }

    final Map<String, dynamic> requestBody = {
      'prompt': prompt,
      'userId': _userId,
      'vectorStoreId': _vectorStoreId,
    };

    try {
      // Check for cancellation before making the request
      if (cancelCompleter?.isCompleted == true) {
        throw ApiException('Request cancelled by user');
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Check for cancellation after the request
      if (cancelCompleter?.isCompleted == true) {
        throw ApiException('Request cancelled by user');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Something went wrong');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Something went wrong');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
