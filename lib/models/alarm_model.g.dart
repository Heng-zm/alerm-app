// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Alarm _$AlarmFromJson(Map<String, dynamic> json) => Alarm(
      id: (json['id'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      label: json['label'] as String,
      sound: json['sound'] as String,
      loopSound: json['loopSound'] as bool,
      password: json['password'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$AlarmToJson(Alarm instance) => <String, dynamic>{
      'id': instance.id,
      'time': instance.time.toIso8601String(),
      'label': instance.label,
      'sound': instance.sound,
      'loopSound': instance.loopSound,
      'password': instance.password,
      'isActive': instance.isActive,
    };
