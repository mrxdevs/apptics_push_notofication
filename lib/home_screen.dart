import 'package:flutter/material.dart';
import 'package:apptics_push_notofication/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'more_notification.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    this.notificationAppLaunchDetails,
    super.key,
  });
  // assthis is home screen
  static const String routeName = '/';

  /// The [NotificationAppLaunchDetails] is used to determine if the app was launched

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _logs = [];

  NotificationChannelType _selectedChannel = NotificationChannelType.general;
  String? _customSound;
  Priority? _priority;
  Importance? _importance;

  void _addLog(String log) {
    setState(() {
      String timeStamp = DateTime.now().toString();
      _logs.insert(0, "$timeStamp: $log");
    });
  }

  void _simulatePushNotification() {
    NotificationService.instance.sendLocalNotification(
        channelType: NotificationChannelType.general,
        title: "My title is this",
        body: "This is my body",
        payload: "https://picsum.photos/200/300"); // simulate push
    _addLog("Simulated push notification sent");
  }

  void _listBackgroundNotifications() {
    _addLog("Listed background notifications");
  }

  void _scheduleNotification() {
    NotificationService.instance.scheduleNotification(
      channelType: NotificationChannelType.general,
      duration: Duration(seconds: 3),
      title: "Scheduled Reminder",
      body: "This is a scheduled notification!",
      payload: "scheduled_payload",
    );
    print("Scedule Notification");
    _addLog("Scheduled notification");
  }

  void _scheduleCustomNotification() {
    NotificationService.instance.scheduleNotification(
      channelType: _selectedChannel,
      duration: Duration(seconds: 5),
      title: "Custom Scheduled Notification",
      body: "This is a custom scheduled notification!",
      payload: "navigate:/notificationPage",
      sound: _customSound,
      importance: _importance,
      priority: _priority,
    );
    _addLog(
        "Scheduled custom notification (channel: $_selectedChannel, sound: $_customSound, priority: $_priority, importance: $_importance)");
  }

  Future<void> _pickTiming() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      _addLog("Picked time: ${picked.format(context)}");
    } else {
      _addLog("Time picking cancelled");
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
    Color? iconColor,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blueAccent,
        foregroundColor: Colors.white, // ensures button text is clearly visible
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon,
          size: 20, color: iconColor ?? Colors.white), // updated icon color
      label: Text(label, style: const TextStyle(fontSize: 14)),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clearButtonColor = Colors.redAccent;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Dev Access"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Developer Actions Panel
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.notifications_active,
                          label: 'Simulate Push',
                          onPressed: _simulatePushNotification,
                        ),
                        _buildActionButton(
                          icon: Icons.notifications,
                          label: 'More Notifications',
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MoreNotification(),
                                ));
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.list,
                          label: 'List Background',
                          onPressed: _listBackgroundNotifications,
                        ),
                        _buildActionButton(
                          icon: Icons.schedule,
                          label: 'Schedule',
                          onPressed: _scheduleNotification,
                        ),
                        _buildActionButton(
                          icon: Icons.access_time,
                          label: 'Pick Timing',
                          onPressed: _pickTiming,
                        ),
                        _buildActionButton(
                          icon: Icons.clear,
                          label: 'Clear Logs',
                          onPressed: _clearLogs,
                          color: clearButtonColor,
                        ),
                        _buildActionButton(
                          icon: Icons.schedule_send,
                          label: 'Schedule Custom',
                          onPressed: _scheduleCustomNotification,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("Channel: "),
                        Expanded(
                          child: DropdownButton<NotificationChannelType>(
                            value: _selectedChannel,
                            items: NotificationChannelType.values
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedChannel = val!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text("Sound: "),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _customSound,
                            hint: const Text("Default"),
                            items: [
                              null,
                              "notification_sound",
                              "slow_spring_board"
                            ]
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e ?? "Default"),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _customSound = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Priority: "),
                        Expanded(
                          child: DropdownButton<Priority>(
                            value: _priority,
                            hint: const Text("Default"),
                            items: [
                              null,
                              Priority.min,
                              Priority.low,
                              Priority.defaultPriority,
                              Priority.high,
                              Priority.max,
                            ]
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                          e?.toString().split('.').last ??
                                              "Default"),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _priority = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text("Importance: "),
                        Expanded(
                          child: DropdownButton<Importance>(
                            value: _importance,
                            hint: const Text("Default"),
                            items: [
                              null,
                              Importance.min,
                              Importance.low,
                              Importance.defaultImportance,
                              Importance.high,
                              Importance.max,
                            ]
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                          e?.toString().split('.').last ??
                                              "Default"),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _importance = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Logs Panel
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade100,
                        Colors.blueGrey.shade50
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _logs.isEmpty
                      ? const Center(
                          child: Text('No logs yet',
                              style: TextStyle(fontSize: 14)))
                      : ListView.separated(
                          itemCount: _logs.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            return Text(
                              _logs[index],
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add a simple notification page for navigation demo
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Clicked")),
      body: const Center(
          child: Text("You have navigated here from a notification!")),
    );
  }
}
