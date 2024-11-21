import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../dtos/appsync/exercise_dto.dart';
import '../shared_prefs.dart';

class AnalyticsController extends ChangeNotifier {

  AnalyticsController._(); // Private constructor to prevent instantiation

  static Future<void> aiInteractions({required String aiModule, required String eventAction}) async {
    await FirebaseAnalytics.instance.logEvent (
      name: 'AI_interactions',
      parameters: {
        "ai_module": aiModule,
        "action": eventAction,
      },);
  }

  static Future<void> logDefaultParameters({required bool isFirstLaunch, required dynamic widget}) async {
    await FirebaseAnalytics.instance
        .setDefaultEventParameters({
          "appVersion": '1.2.3'
        });
  }

  static Future<void> calendarInteractions({required String eventAction}) async {
    await FirebaseAnalytics.instance.logEvent (
      name: 'calendar_interaction',
      parameters: {
        "action": eventAction,
      },);
  }

  static Future<void> workoutSessionEvent({required String eventAction}) async {
    await FirebaseAnalytics.instance.logEvent (
      name: 'workout_session',
      parameters: {
        "action": eventAction,
      },);
  }

    static Future<void> logPageNavigation({required String page}) async {
    await FirebaseAnalytics.instance.logEvent (
      name: 'pages_tracked',
      parameters: {
        "page": page,
      },);
  }

  static Future<void> loginAnalytics({required bool isFirstLaunch}) async {
    await FirebaseAnalytics.instance.setUserId(id: SharedPrefs().userId);
    await FirebaseAnalytics.instance.setUserProperty(name: 'email', value: SharedPrefs().userEmail);
    if(isFirstLaunch) {
      await FirebaseAnalytics.instance.logLogin(loginMethod: 'login/signup');
    }
    await FirebaseAnalytics.instance.logAppOpen();
  }

  static Future<void> logScreenView({required String screenName}) async {
    await FirebaseAnalytics.instance.logScreenView(screenName: screenName,);
  }

  static Future<void> logSelectItem({required String screenName, required AnalyticsEventItem analyticsEventItem}) async {
    await FirebaseAnalytics.instance.logSelectItem(
      items: [analyticsEventItem],
      itemListName: 't-shirt',
      itemListId: '1234',
    );
  }

  static Future<void> logShare() async {
    await FirebaseAnalytics.instance.logShare(contentType: 'test content type', itemId: 'test item id', method: 'facebook',);
  }

  static Future<void> exerciseEvents({required String eventAction, required ExerciseDto exercise}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventAction,
      parameters: Map<String, Object>.from(exercise.toJson() as Map<String, dynamic>),
    );
  }
}