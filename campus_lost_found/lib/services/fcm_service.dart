import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hanya inisialisasi basic untuk handling background message
  // tanpa context UI.
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Setup handler untuk background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permission (iOS/Web, di Android 13+ juga butuh)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Setup local notification channel (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'campus_lf_high_importance', // id
      'High Importance Notifications', // title
      description: 'Channel ini digunakan untuk notifikasi penting aplikasi.',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Inisialisasi local notifications settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle ketika notifikasi di tap
      },
    );

    // 5. Dengarkan pesan saat aplikasi berjalan di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message, channel);
      }
    });

    // 6. Dapatkan token FCM dan simpan ke server
    String? fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $fcmToken');
    if (fcmToken != null) {
      _sendTokenToServer(fcmToken);
    }

    // Update jika token berubah
    _firebaseMessaging.onTokenRefresh.listen(_sendTokenToServer);

    _isInitialized = true;
  }

  void _showLocalNotification(
      RemoteMessage message, AndroidNotificationChannel channel) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            color: const Color(0xFF1E88E5), // AppColors.primary
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<void> sendTokenToServer() async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        _sendTokenToServer(fcmToken);
      }
    } catch (e) {
      debugPrint('Error getting/sending FCM token: $e');
    }
  }

  void _sendTokenToServer(String fcmToken) async {
    final token = AuthProvider.instance?.token;
    if (token != null) {
      await NotificationService().saveFcmToken(fcmToken, token);
      debugPrint('FCM Token sent to server.');
    }
  }
}
