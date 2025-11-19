import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'local_notification_service.dart';

const _serviceAccountPath = 'assets/firebase-service-account.json';
const _firebaseProjectId = 'cardiac-e7644';

Future<void> sendFCMNotificationV1({
  required String title,
  required String body,
}) async {
  final serviceAccountJson = await rootBundle.loadString(_serviceAccountPath);
  final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await clientViaServiceAccount(accountCredentials, scopes);

  final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$_firebaseProjectId/messages:send');

  final messagePayload = {
    "message": {
      "topic": "all_users",
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "title": title,
        "body": body,
      },
      "android": {"priority": "high"},
      "apns": {
        "headers": {"apns-priority": "10"}
      }
    }
  };


  final response = await client.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(messagePayload),
  );

  if (response.statusCode == 200) {
    debugPrint('✅ Notification sent successfully!');
  } else {
    debugPrint('❌ Failed to send notification: ${response.statusCode}');
    debugPrint(response.body);
  }

  client.close();
}



Future<void> sendFCMToSpecificUser({
  required String title,
  required String body,
  required String userFcmToken,
}) async {
  try {

    final serviceAccountJson = await rootBundle.loadString(_serviceAccountPath);
    final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(accountCredentials, scopes);

    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$_firebaseProjectId/messages:send');

    final messagePayload = {
      "message": {
        "token": userFcmToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "title": title,
          "body": body,
        },
        "android": {"priority": "high"},
        "apns": {
          "headers": {"apns-priority": "10"}
        }
      }
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(messagePayload),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Notification sent to specific user!');
    } else {
      debugPrint('❌ Failed to send notification: ${response.statusCode}');
      debugPrint(response.body);
    }

    client.close();
  } catch (e) {
    debugPrint('🔥 Error sending FCM: $e');
  }
}



class NotificationService {
  static Future<void> initFCM() async {

    // ✅ نطلب التصريح مباشرةً
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ نطبع الحالة

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("✅ تم السماح بالإشعارات");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint("🟡 سماح مؤقت بالإشعارات");
    } else {
      debugPrint("❌ تم رفض الإشعارات");
      // 💡 ممكن تعرضي Dialog للمستخدم تقوليله يفعّلها من الإعدادات
    }

    // ✅ الاشتراك في التوبيك
    await FirebaseMessaging.instance.subscribeToTopic('all_users');

    final token = await FirebaseMessaging.instance.getToken();

    FirebaseMessaging.onMessage.listen((message) {

      final title = message.notification?.title ?? message.data['title'] ?? 'بدون عنوان';
      final body = message.notification?.body ?? message.data['body'] ?? 'بدون محتوى';


      LocalNotificationService.showNotification(
        title: title,
        body: body,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("✅ المستخدم فتح التطبيق من الإشعار");
    });
  }
}
