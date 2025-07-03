// lib/models/alarm_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'alarm_model.g.dart'; // This line will now find the generated file

@JsonSerializable()
class Alarm {
  final int id;
  final DateTime time;
  final String label;
  final String sound;
  final bool loopSound;
  final String? password;
  bool isActive;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.sound,
    required this.loopSound,
    this.password,
    required this.isActive,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) =>
      _$AlarmFromJson(json); // This will now be defined
  Map<String, dynamic> toJson() =>
      _$AlarmToJson(this); // This will now be defined
}
