import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alarm_model.dart';
import '../providers/theme_provider.dart';
import 'add_edit_alarm_screen.dart';
import 'settings_screen.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  // Using a placeholder list. This would typically come from a database or service.
  final List<Alarm> _alarms = [];

  static const Color _activeSwitchColor = Color(0xFF34C759);

  // Method to navigate to the Add/Edit screen
  void _navigateAndAddAlarm(BuildContext context) async {
    final newAlarm = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(builder: (context) => const AddEditAlarmScreen()),
    );

    if (newAlarm != null) {
      setState(() => _alarms.add(newAlarm));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the ThemeProvider to get the current accent color.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Alarms', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Settings icon button to navigate to the SettingsScreen
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // Add Alarm button uses the accent color from the provider
          IconButton(
            icon: Icon(Icons.add, color: themeProvider.accentColor, size: 30),
            onPressed: () => _navigateAndAddAlarm(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Colors.grey[850], thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.bed, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    const Text('Sleep | Wake Up',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('SET UP',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              if (_alarms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text('Other',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400])),
                ),
              if (_alarms.isNotEmpty)
                Divider(color: Colors.grey[850], thickness: 1),
              Expanded(
                child: _alarms.isEmpty
                    ? const Center(
                        child: Text('No Alarms',
                            style: TextStyle(color: Colors.grey, fontSize: 18)))
                    : ListView.separated(
                        itemCount: _alarms.length,
                        separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[850], thickness: 1, indent: 16),
                        itemBuilder: (context, index) {
                          final alarm = _alarms[index];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                            title: Text(
                              '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w200,
                                color: alarm.isActive
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            subtitle: Text(
                              alarm.label,
                              style: TextStyle(
                                  color: alarm.isActive
                                      ? Colors.white
                                      : Colors.grey[600]),
                            ),
                            trailing: Switch(
                              value: alarm.isActive,
                              onChanged: (bool value) =>
                                  setState(() => alarm.isActive = value),
                              activeColor: Colors.white,
                              activeTrackColor: _activeSwitchColor,
                              inactiveThumbColor: Colors.grey[700],
                              inactiveTrackColor: Colors.grey[850],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
