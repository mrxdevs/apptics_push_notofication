import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:apptics_push_notofication/home_screen.dart';
import 'package:apptics_push_notofication/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // you can do any stuffs that should work when notification comes in background

  // Be aware that this task should not take too much time, unless it would be skipped in OS
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? count = prefs.getInt('notif-count');
  await prefs.setInt('notif-count', (count ?? 0) + 1);
}
// If using other Firebase services, initialize them before use.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  // Set the background messaging handler early on
  await Firebase.initializeApp();
  String? token = await FirebaseMessaging.instance.getToken();
  print("Firebase token: $token");
  await FirebaseMessaging.instance.requestPermission();
  if (Platform.isAndroid) {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.init(); // initialize notifications
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}
