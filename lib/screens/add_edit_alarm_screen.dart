import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import 'sound_selection_screen.dart';

class AddEditAlarmScreen extends StatefulWidget {
  // Optional: Pass an existing alarm to edit it.
  final Alarm? alarmToEdit;

  const AddEditAlarmScreen({super.key, this.alarmToEdit});

  @override
  State<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends State<AddEditAlarmScreen> {
  late Duration _selectedTime;
  late String _label;
  late String _sound;
  late bool _loopSound;
  String? _password;

  @override
  void initState() {
    super.initState();
    if (widget.alarmToEdit != null) {
      // Editing an existing alarm
      final alarm = widget.alarmToEdit!;
      final time = alarm.time;
      _selectedTime = Duration(hours: time.hour, minutes: time.minute);
      _label = alarm.label;
      _sound = alarm.sound;
      _loopSound = alarm.loopSound;
      _password = alarm.password;
    } else {
      // Creating a new alarm
      _selectedTime = const Duration(hours: 7, minutes: 0);
      _label = 'Alarm';
      _sound = 'Radar'; // Default sound
      _loopSound = true; // Default loop status
      _password = null;
    }
  }

  // DIALOG FOR SETTING PASSWORD
  Future<void> _showSetPasswordDialog() async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title:
            const Text('Set Password', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: passwordController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter password to dismiss alarm',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child:
                const Text('Save', style: TextStyle(color: Color(0xFFFF9F0A))),
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context, passwordController.text);
              }
            },
          ),
        ],
      ),
    );

    if (password != null && password.isNotEmpty) {
      setState(() => _password = password);
    } else {
      setState(() => _password = null);
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();
    DateTime selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.inHours,
      _selectedTime.inMinutes % 60,
    );

    // If the selected time on the current day is in the past, schedule it for the next day.
    if (selectedDateTime.isBefore(now)) {
      selectedDateTime = selectedDateTime.add(const Duration(days: 1));
    }

    // Use existing ID if editing, otherwise create a new unique ID.
    final alarmId = widget.alarmToEdit?.id ??
        DateTime.now().millisecondsSinceEpoch % 100000;

    final newAlarm = Alarm(
      id: alarmId,
      time: selectedDateTime,
      label: _label,
      sound: _sound,
      loopSound: _loopSound,
      isActive: true,
      password: _password,
    );

    // Use the service to schedule the alarm.
    AlarmService().scheduleAlarm(newAlarm).then((_) {
      // Pop the screen after scheduling is complete.
      Navigator.pop(context, newAlarm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.alarmToEdit != null;
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Color(0xFFFF9F0A), fontSize: 16)),
        ),
        title: Text(isEditing ? 'Edit Alarm' : 'Add Alarm',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text('Save',
                style: TextStyle(
                    color: Color(0xFFFF9F0A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: _selectedTime,
              onTimerDurationChanged: (Duration newDuration) {
                setState(() => _selectedTime = newDuration);
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildSettingsRow(context, 'Label', _label, () {
                  // TODO: Implement a proper screen for text input.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Label editing not implemented yet.')),
                  );
                }),
                _buildSettingsRow(
                    context, 'Sound', _sound, _navigateToSoundScreen),
                _buildPasswordRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for navigation to the sound selection screen
  void _navigateToSoundScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SoundSelectionScreen(
          initialSound: _sound,
          initialLoopStatus: _loopSound,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _sound = result['sound'] as String;
        _loopSound = result['loop'] as bool;
      });
    }
  }

  // Helper for the password row with a Switch
  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Require Password to Stop',
              style: TextStyle(fontSize: 17, color: Colors.white)),
          Switch(
            value: _password != null,
            onChanged: (bool value) {
              if (value) {
                _showSetPasswordDialog();
              } else {
                setState(() => _password = null);
              }
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  // Reusable helper for settings list rows
  Widget _buildSettingsRow(
      BuildContext context, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontSize: 17, color: Colors.white)),
                  Row(
                    children: [
                      Text(value,
                          style:
                              TextStyle(fontSize: 17, color: Colors.grey[400])),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.grey[600], size: 16),
                    ],
                  ),
                ],
              ),
            ),
            if (title !=
                'Sound') // A small UI tweak to not have a divider after the last item in this group
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Divider(color: Colors.grey[850], height: 1),
              )
          ],
        ),
      ),
    );
  }
}
