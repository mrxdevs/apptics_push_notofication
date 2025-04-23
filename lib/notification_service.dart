import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationTapCallback = void Function(String? payload);

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  NotificationTapCallback? onNotificationTap;

  DarwinNotificationDetails iOSDetails1 = DarwinNotificationDetails(
    // Sound
    presentSound: true,
    sound: 'notification_sound.aiff', // Custom sound file in iOS bundle

    // Alert settings
    presentAlert: true,
    presentBadge: true,
    badgeNumber: 1,

    // Visual appearance
    subtitle: 'Optional subtitle',
    threadIdentifier: 'thread1', // Group similar notifications

    // Interaction options
    categoryIdentifier: 'generle', // For custom actions
    interruptionLevel: InterruptionLevel.active,

    // Attachments (like images)
  );

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final AndroidNotificationChannel generalChannel =
      const AndroidNotificationChannel(
    'general_channel',
    'General Notifications',
    description: 'Channel for general notifications',
    importance: Importance.defaultImportance,
  );
  final AndroidNotificationChannel promotionChannel =
      const AndroidNotificationChannel(
    'promotion_channel',
    'Promotion Notifications',
    description: 'Channel for promotional notifications',
    importance: Importance.defaultImportance,
  );
  final AndroidNotificationChannel criticalChannel =
      const AndroidNotificationChannel(
    'critical_channel',
    'Critical Alerts',
    description: 'Channel for critical alerts',
    importance: Importance.high,
  );

  Future<void> init({NotificationTapCallback? onTap}) async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    onNotificationTap = onTap;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (onNotificationTap != null) {
          onNotificationTap!(payload);
        }
      },
    );
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    tz.initializeTimeZones();
    await _createNotificationChannels();
    _setupFCMListeners();
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(generalChannel);
      await androidPlugin.createNotificationChannel(promotionChannel);
      await androidPlugin.createNotificationChannel(criticalChannel);
    }
  }

  Future<void> sendLocalNotification({
    required NotificationChannelType channelType,
    String? title,
    String? body,
    String? payload,
    String? sound,
    Importance? importance,
    Priority? priority,
  }) async {
    AndroidNotificationChannel selectedChannel;
    Importance resolvedImportance;
    Priority resolvedPriority;

    switch (channelType) {
      case NotificationChannelType.promotion:
        selectedChannel = promotionChannel;
        resolvedImportance = importance ?? Importance.defaultImportance;
        resolvedPriority = priority ?? Priority.defaultPriority;
        break;
      case NotificationChannelType.critical:
        selectedChannel = criticalChannel;
        resolvedImportance = importance ?? Importance.high;
        resolvedPriority = priority ?? Priority.high;
        break;
      case NotificationChannelType.general:
        selectedChannel = generalChannel;
        resolvedImportance = importance ?? Importance.defaultImportance;
        resolvedPriority = priority ?? Priority.defaultPriority;
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      selectedChannel.id,
      selectedChannel.name,
      channelDescription: selectedChannel.description,
      importance: resolvedImportance,
      priority: resolvedPriority,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
    );

    final iOSDetails = DarwinNotificationDetails(
      sound: sound != null ? '$sound.aiff' : null,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title ?? "Notification",
      body,
      platformDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required NotificationChannelType channelType,
    required Duration duration,
    String? title,
    String? body,
    String? payload,
    String? sound,
    Importance? importance,
    Priority? priority,
  }) async {
    // Check and request permission first
    final hasPermission = await _requestScheduleExactAlarmPermission();
    if (!hasPermission) {
      throw PlatformException(
        code: 'permission_denied',
        message: 'Exact alarm permission not granted',
      );
    }
    AndroidNotificationChannel selectedChannel;
    Importance resolvedImportance;
    Priority resolvedPriority;

    switch (channelType) {
      case NotificationChannelType.promotion:
        selectedChannel = promotionChannel;
        resolvedImportance = importance ?? Importance.defaultImportance;
        resolvedPriority = priority ?? Priority.defaultPriority;
        break;
      case NotificationChannelType.critical:
        selectedChannel = criticalChannel;
        resolvedImportance = importance ?? Importance.high;
        resolvedPriority = priority ?? Priority.high;
        break;
      case NotificationChannelType.general:
        selectedChannel = generalChannel;
        resolvedImportance = importance ?? Importance.defaultImportance;
        resolvedPriority = priority ?? Priority.defaultPriority;
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      selectedChannel.id,
      selectedChannel.name,
      channelDescription: selectedChannel.description,
      importance: resolvedImportance,
      priority: resolvedPriority,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
    );

    final iOSDetails = DarwinNotificationDetails(
      sound: sound != null ? '$sound.aiff' : null,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime.from(
      now.add(duration),
      tz.local,
    );

    // Debug prints
    print("Local TZ time: ${scheduledDate.toString()}");
    print("Current Local time: ${DateTime.now().toLocal()}");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title ?? "Scheduled Notification",
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print("Notification scheduled for $scheduledDate");
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  Future<bool> _requestScheduleExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final hasPermission =
          await androidImplementation?.requestExactAlarmsPermission();
      return hasPermission ?? false;
    }
    return true;
  }

  void _setupFCMListeners() {
    // For messages received in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null && android != null) {
        _showLocalNotification(notification);
      }
    });

    // When app is launched via a notification tap from a terminated state.
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessageTap(message);
      }
    });

    // For messages when the app is in background and opened via a notification tap.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message);
    });
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fcm_channel', // Use a dedicated channel for FCM
      'FCM Notifications',
      channelDescription: 'Notifications received via Firebase Cloud Messaging',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    // For FCM, handle navigation if needed
    if (onNotificationTap != null) {
      onNotificationTap!(message.data['payload']);
    }
    print('Notification clicked with data: ${message.data}');
  }
}

enum NotificationChannelType {
  promotion("promo"),
  general("general"),
  critical("critical");

  final String value;
  const NotificationChannelType(this.value);
}
