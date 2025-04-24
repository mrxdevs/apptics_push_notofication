import 'dart:async';
import 'dart:io';

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:apptics_push_notofication/home_screen.dart';
import 'package:apptics_push_notofication/promotion_screen.dart';
import 'package:apptics_push_notofication/secod_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'plugin.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // you can do any stuffs that should work when notification comes in
  print('Background message: ${message.messageId}');
  print('Background message data: ${message.data}');
  print('Background message notification: ${message.notification?.title}');
  print('Background message notification body: ${message.notification?.body}');
  print('Background message category: ${message.category}');
  print('Background message contentAvailable: ${message.contentAvailable}');
  print('Background message from: ${message.from}');
  print('Background message messageType: ${message.messageType}');
  print('Background message sentTime: ${message.sentTime}');

  //Notitfication data is from android

  print('Background message data: ${message.notification?.android}');
  print(
      'Background message data ImageURL: ${message.notification?.android?.imageUrl}');
  print(
      'Background message data Channel ID: ${message.notification?.android?.channelId}');
  print(
      'Background message data Click action: ${message.notification?.android?.clickAction}');
  print(
      'Background message data Color: ${message.notification?.android?.color}');
  print(
      'Background message data Count: ${message.notification?.android?.count}');
  print('Background message data Link: ${message.notification?.android?.link}');
  print(
      'Background message data Priority: ${message.notification?.android?.priority}');
  print(
      'Background message data SmallIcon: ${message.notification?.android?.smallIcon}');
  print(
      'Background message data Sound: ${message.notification?.android?.sound}');
  print('Background message data Tag: ${message.notification?.android?.tag}');
  print(
      'Background message data Ticker: ${message.notification?.android?..ticker}');
  print(
      'Background message data Visiblity: ${message.notification?.android?.visibility}');

  // iOS notification data

  print('Background message data: ${message.notification?.apple}');
  print('Background message data: ${message.notification?.apple?.badge}');
  print('Background message data: ${message.notification?.apple?.imageUrl}');
  print('Background message data: ${message.notification?.apple?.sound?.name}');
  print('Background message data: ${message.notification?.apple?.subtitle}');
  print(
      'Background message data: ${message.notification?.apple?.subtitleLocArgs.toString()}');

  // Be aware that this task should not take too much time, unless it would be skipped in OS
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? count = prefs.getInt('notif-count');
  await prefs.setInt('notif-count', (count ?? 0) + 1);
}
// If using other Firebase services, initialize them before use.

// Configure top level notification settings

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();
String? selectedNotificationPayload;

const String navigationActionId = 'id_3'; //Notification category id

const String darwinNotificationCategoryText =
    'textCategory'; //Notification category id

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain =
    'plainCategory'; //Notification category

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> _showNotification(
    String title, String body, String payload) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true,
          icon: "ic_launcher",
          largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin
      .show(id++, title, body, notificationDetails, payload: payload);
}

Future<void> main() async {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String initialRoute = MyHomePage.routeName;
  WidgetsFlutterBinding.ensureInitialized();
  // await AndroidAlarmManager.initialize();
  // Set the background messaging handler early on
  await Firebase.initializeApp();
  String? token = await FirebaseMessaging.instance.getToken();
  print("Firebase token: $token");
  await FirebaseMessaging.instance.requestPermission();
  if (Platform.isAndroid) {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle the message when the app is opened from a notification
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification body: ${message.notification?.body}');
    print('Message category: ${message.category}');
    print('Message contentAvailable: ${message.contentAvailable}');
    print('Message from: ${message.from}');
    print('Message messageType: ${message.messageType}');
    print('Message sentTime: ${message.sentTime}');

    //Write the redirect logic
    if (message.data.isNotEmpty) {
      // Handle the data message
      print('Message data : Route Assign: ${message.data}');
      if (message.data['route'] == '/promotion') {
        // Navigate to the second page

        // If app is terminated it would redirect to the promotion screen bcoz the whole main will be executed
        // But if app is in background  or foreground it will no do any thing since only onMessage will be executed

        navigatorKey.currentState?.pushNamed(PromotionScreen.routeName);
      } else {
        // Handle other routes or data
        initialRoute = MyHomePage.routeName;
      }
    }

    // Handle the message here
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle the message when the app is in foreground
    print('A new onMessage event was published!');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification body: ${message.notification?.body}');
    print('Message category: ${message.category}');
    print('Message contentAvailable: ${message.contentAvailable}');
    print('Message from: ${message.from}');
    print('Message messageType: ${message.messageType}');
    print('Message sentTime: ${message.sentTime}');

    //Write the redirect logic

    // Handle the message as local notification since the app is in foreground(not terminated or background)
    _showNotification(
        message.notification?.title ?? "No Title",
        message.notification?.body ?? "No body",
        message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl ??
            "");
  });

  // Setting up new configuration push

  //Initialize Timezone configuration
  await _configureLocalTimeZone();

  //Configure Android Notification settings

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  // Configure iOS Notification settings
  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  //Setup iOS/MacOS specific settings also do persmission request

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    notificationCategories: darwinNotificationCategories,
  );

  //Setup initialization settings for both Android and iOS

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  //Using the plugin on global

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: selectNotificationStream.add,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  //TODO: Handle the uri here to check if app is launched from a notification or not

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    print(
        'Notification launched the app: ${notificationAppLaunchDetails?.notificationResponse?.payload}');
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    initialRoute = SecondPage.routeName;
  }

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        MyHomePage.routeName: (_) => MyHomePage(
              notificationAppLaunchDetails: notificationAppLaunchDetails,
            ),
        SecondPage.routeName: (_) => SecondPage(selectedNotificationPayload),
        PromotionScreen.routeName: (_) => const PromotionScreen(),
      },
    ),
  );
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}
