import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_model.dart';
import '../screens/alarm_ringing_screen.dart';

const String _notificationChannelId = 'alarm_channel';
final AudioPlayer _audioPlayer = AudioPlayer();

@pragma('vm:entry-point')
Future<void> onAlarmCallback(int id, Map<String, dynamic> params) async {
  WidgetsFlutterBinding.ensureInitialized();
  final alarm = Alarm.fromJson(params);

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();
  await notificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings, iOS: iosSettings),
  );

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    _notificationChannelId,
    'Alarms',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    ongoing: true,
    autoCancel: false,
  );
  await notificationsPlugin.show(
    alarm.id,
    '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
    alarm.label,
    const NotificationDetails(android: androidDetails),
    payload: jsonEncode(alarm.toJson()),
  );

  await _audioPlayer.setSource(AssetSource('sounds/${alarm.sound}'));
  await _audioPlayer
      .setReleaseMode(alarm.loopSound ? ReleaseMode.loop : ReleaseMode.stop);
  await _audioPlayer.resume();
}

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    await AndroidAlarmManager.initialize();
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      final alarm = Alarm.fromJson(jsonDecode(response.payload!));
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => AlarmRingingScreen(alarm: alarm)),
      );
    }
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    final int alarmId = alarm.id;
    final alarmTime = tz.TZDateTime.from(alarm.time, tz.local);
    final String payload = jsonEncode(alarm.toJson());
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      alarmId,
      onAlarmCallback,
      exact: true,
      wakeup: true,
      alarmClock: true,
      params: alarm.toJson(),
    );
    await _notifications.zonedSchedule(
      alarmId,
      'Alarm',
      alarm.label,
      alarmTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          'Alarms',
          channelDescription: 'Channel for alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(
              alarm.sound.split('.').first.toLowerCase()),
          playSound: false,
        ),
        iOS: DarwinNotificationDetails(
          sound: alarm.sound,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    await _saveAlarmToPrefs(alarm);
  }

  Future<void> cancelAlarm(int alarmId) async {
    await AndroidAlarmManager.cancel(alarmId);
    await _notifications.cancel(alarmId);
    await _removeAlarmFromPrefs(alarmId);
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<void> _saveAlarmToPrefs(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final alarms = prefs.getStringList('alarms') ?? [];
    alarms.removeWhere((a) => Alarm.fromJson(jsonDecode(a)).id == alarm.id);
    alarms.add(jsonEncode(alarm.toJson()));
    await prefs.setStringList('alarms', alarms);
  }

  Future<void> _removeAlarmFromPrefs(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    final alarms = prefs.getStringList('alarms') ?? [];
    alarms.removeWhere((a) => Alarm.fromJson(jsonDecode(a)).id == alarmId);
    await prefs.setStringList('alarms', alarms);
  }

  /// This function is now more robust and will not crash the app if it finds
  /// a single piece of corrupted data.
  Future<void> rescheduleAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList('alarms') ?? [];
    final List<Future<void>> rescheduleFutures = [];

    for (var alarmJson in alarmsJson) {
      try {
        // This is the line that could fail if data is corrupt.
        final alarm = Alarm.fromJson(jsonDecode(alarmJson));

        if (alarm.isActive) {
          DateTime alarmTime = alarm.time;
          if (alarmTime.isBefore(DateTime.now())) {
            alarmTime = alarmTime.add(const Duration(days: 1));
            final rescheduledAlarm = Alarm(
              id: alarm.id,
              time: alarmTime,
              label: alarm.label,
              sound: alarm.sound,
              loopSound: alarm.loopSound,
              password: alarm.password,
              isActive: alarm.isActive,
            );
            rescheduleFutures.add(scheduleAlarm(rescheduledAlarm));
          } else {
            rescheduleFutures.add(scheduleAlarm(alarm));
          }
        }
      } catch (e) {
        // If one alarm fails to parse, print the error and continue with the others.
        debugPrint("Failed to parse and reschedule a stored alarm: $e");
        debugPrint("Problematic Alarm JSON: $alarmJson");
      }
    }
    // Wait for all valid alarms to finish rescheduling.
    await Future.wait(rescheduleFutures);
  }
}
