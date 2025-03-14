import 'package:flutter/material.dart';
import 'package:apptics_push_notofication/notification_service.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    super.key,
    required this.title,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _logs = [];

  void _addLog(String log) {
    setState(() {
      String timeStamp = DateTime.now().toString();
      _logs.insert(0, "$timeStamp: $log");
    });
  }

  void _simulatePushNotification() {
    NotificationService.instance
        .sendLocalNotification(NotificationChennal.general); // simulate push
    _addLog("Simulated push notification sent");
  }

  void _listBackgroundNotifications() {
    _addLog("Listed background notifications");
  }

  void _scheduleNotification() {
    _addLog("Scheduled notification");
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
                child: Wrap(
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
