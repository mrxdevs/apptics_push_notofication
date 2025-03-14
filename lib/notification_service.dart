import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'general_channel',
          'General Notifications',
          description: 'Channel for general notifications',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'promotion_channel',
          'Promotion Notifications',
          description: 'Channel for promotional notifications',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'critical_channel',
          'Critical Alerts',
          description: 'Channel for critical alerts',
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> sendLocalNotification(
    NotificationChennal channelType,
  ) async {
    String channelId;
    String channelName;
    Importance importance;
    Priority priority;

    switch (channelType) {
      case NotificationChennal.promotion:
        channelId = 'promotion_channel';
        channelName = 'Promotion Notifications';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case NotificationChennal.critical:
        channelId = 'critical_channel';
        channelName = 'Critical Alerts';
        importance = Importance.high;
        priority = Priority.high;
        break;
      case NotificationChennal.general:
        channelId = 'general_channel';
        channelName = 'General Notifications';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      default:
        channelId = 'general_channel';
        channelName = 'General Notifications';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
    }

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Channel for $channelName',
      importance: importance,
      priority: priority,
    );

    NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '$channelName Title',
      'This is a $channelType notification',
      platformDetails,
    );
  }

  Future<void> scheduleLocalNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scheduled_channel_id',
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled Title',
      'Scheduled Body',
      // Notification will trigger after 5 seconds from now.
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
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
    // Handle navigation or logic when a message is tapped.
    print('Notification clicked with data: ${message.data}');
  }
}

enum NotificationChennal {
  promotion("promo"),
  general("general"),
  critical("critical");

  final String value;
  const NotificationChennal(this.value);
}
