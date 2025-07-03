// lib/services/alarm_service_stub.dart

import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

/// This is a "do-nothing" stub implementation of the AlarmService for web compatibility.
/// It has the same public methods as the mobile version, but they are all empty.
/// This allows the app to compile for the web without errors from native-only plugins.
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  /// A navigator key is still needed for the MaterialApp.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Does nothing on the web. Prints a debug message.
  Future<void> initialize() async {
    debugPrint("AlarmService: Running on web. Native alarms disabled.");
  }

  /// Does nothing on the web. Prints a debug message.
  Future<void> scheduleAlarm(Alarm alarm) async {
    debugPrint("AlarmService: Scheduling is not supported on web.");
  }

  /// Does nothing on the web. Prints a debug message.
  Future<void> cancelAlarm(int alarmId) async {
    debugPrint("AlarmService: Cancelling is not supported on web.");
  }

  /// Does nothing on the web.
  Future<void> stopAudio() async {
    // This could potentially be implemented for web if needed, but for now it's a stub.
  }

  /// Does nothing on the web. Prints a debug message.
  Future<void> rescheduleAlarms() async {
    debugPrint("AlarmService: Rescheduling is not supported on web.");
  }
}
