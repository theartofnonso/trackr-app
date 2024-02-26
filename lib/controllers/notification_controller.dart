import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../dtos/notification_dto.dart';
import '../shared_prefs.dart';

class NotificationController extends ChangeNotifier {
  void cacheNotification({required String key, required NotificationDto dto}) {
    if (key == SharedPrefs().cachedUntrainedMGFNotification) {
      SharedPrefs().cachedUntrainedMGFNotification = jsonEncode(dto);
    }
    notifyListeners();
  }

  NotificationDto? cachedNotification({required String key}) {
    NotificationDto? dto;
    String cache = "";
    if (key == SharedPrefs().cachedUntrainedMGFNotification) {
      cache = SharedPrefs().cachedUntrainedMGFNotification;
    }
    if (cache.isNotEmpty) {
      final json = jsonDecode(cache);
      dto = NotificationDto.fromJson(json);
    }
    return dto;
  }
}
