import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';

class AlarmRingingScreen extends StatefulWidget {
  final Alarm alarm;

  const AlarmRingingScreen({super.key, required this.alarm});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  late final TextEditingController _passwordController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    // The sound is expected to be already playing via the AlarmService background callback.
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles stopping the sound, rescheduling the alarm for the next day, and closing the screen.
  void _dismissAlarm() {
    final alarmService = AlarmService();
    alarmService.stopAudio();

    // IMPROVEMENT: Reschedule the alarm for the next day to make it recurring.
    final nextDay = widget.alarm.time.add(const Duration(days: 1));
    final rescheduledAlarm = Alarm(
      id: widget.alarm.id,
      time: nextDay,
      label: widget.alarm.label,
      sound: widget.alarm.sound,
      loopSound: widget.alarm.loopSound,
      password: widget.alarm.password,
      isActive: widget.alarm.isActive,
    );
    alarmService.scheduleAlarm(rescheduledAlarm);

    // Close the ringing screen.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Validates the password and dismisses the alarm on success.
  void _validatePassword() {
    final enteredPassword = _passwordController.text;
    if (enteredPassword == widget.alarm.password) {
      _dismissAlarm();
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
      });
      _passwordController.clear();
    }
  }

  bool get _isPasswordRequired =>
      widget.alarm.password != null && widget.alarm.password!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                '${widget.alarm.time.hour.toString().padLeft(2, '0')}:${widget.alarm.time.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 82,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.alarm.label,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const Spacer(flex: 3),
              if (_isPasswordRequired)
                ..._buildPasswordUI()
              else
                ..._buildDismissUI(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDismissUI() {
    return [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _dismissAlarm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9F0A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Dismiss',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildPasswordUI() {
    return [
      TextField(
        controller: _passwordController,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        obscureText: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Enter Password to Stop',
          hintStyle: TextStyle(color: Colors.grey[600]),
          errorText: _errorMessage,
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 14),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) {
          if (_errorMessage != null) {
            setState(() {
              _errorMessage = null;
            });
          }
        },
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _validatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF34C759),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Unlock',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];
  }
}
