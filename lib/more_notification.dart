import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';
import 'plugin.dart';
import 'secod_screen.dart';

class MoreNotification extends StatefulWidget {
  const MoreNotification({super.key});

  @override
  State<MoreNotification> createState() => _MoreNotificationState();
}

class _MoreNotificationState extends State<MoreNotification> {
  bool _notificationsEnabled = false;

  @override
  void dispose() {
    // TODO: implement dispose
    selectNotificationStream.close();
    super.dispose();
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  void _showImageNotification() {
    // Implement image notification logic here
    print('Image notification triggered');
  }

  void _showBigTextNotification() {
    // Implement big text notification logic here
    print('Big text notification triggered');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Types'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showNotification,
              child: const Text('Simple Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showImageNotification,
              child: const Text('Image Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showBigTextNotification,
              child: const Text('Big Text Notification'),
            ),
          ],
        ),
      ),
    );
  }

// This method checks if the Android permission for notifications is granted
  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  //check if the iOS/Android/Mac permission for notifications is granted

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  // This method checks if the iOS/Mac permission for critical notifications is granted
  Future<void> _requestPermissionsWithCriticalAlert() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    }
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream
        .listen((NotificationResponse? response) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => SecondPage(response?.payload,
            data: response?.payload != null
                ? <String, dynamic>{'payload': response?.payload}
                : null),
      ));
    });
  }
}
