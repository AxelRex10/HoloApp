import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Future<void>? _initializationFuture;

  static Future<void> _ensureInitialized() {
    return _initializationFuture ??= initialize();
  }

  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          handleNotificationTap(response.payload);
        },
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      return;
    }

    if (Platform.isWindows) {
      const WindowsInitializationSettings windowsSettings =
          WindowsInitializationSettings(
            appName: 'Birdle',
            appUserModelId: 'com.example.birdle',
            guid: '8d9e0f1a-2b3c-4d5e-6f7a-8b9c0d1e2f3a',
          );

      const InitializationSettings settings = InitializationSettings(
        windows: windowsSettings,
      );

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          handleNotificationTap(response.payload);
        },
      );
    }
  }

  static Future<void> showLiveNotification({
    required int id,
    required String talentName,
    required String videoId,
  }) async {
    final String youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';

    await _ensureInitialized();

    if (Platform.isAndroid) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'live_channel',
            'Directos en vivo',
            channelDescription: 'Notificaciones de talents en vivo',
            importance: Importance.high,
            priority: Priority.high,
          );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      await _plugin.show(
        id: id,
        title: '🔴 $talentName está en vivo',
        body: 'Toca para ver el directo',
        notificationDetails: details,
        payload: youtubeUrl,
      );
      return;
    }

    if (Platform.isWindows) {
      const WindowsNotificationDetails windowsDetails =
          WindowsNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        windows: windowsDetails,
      );

      await _plugin.show(
        id: id,
        title: '🔴 $talentName está en vivo',
        body: 'Toca para ver el directo',
        notificationDetails: details,
        payload: youtubeUrl,
      );
    }
  }

  static Future<void> handleNotificationTap(String? payload) async {
    if (payload == null || payload.isEmpty) return;

    final Uri uri = Uri.parse(payload);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
