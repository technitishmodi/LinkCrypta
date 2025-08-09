import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

part 'password_activity_log.g.dart';

@HiveType(typeId: 3) // Make sure this typeId is unique and not used by other models
enum ActivityType {
  @HiveField(0)
  viewed,
  
  @HiveField(1)
  created,
  
  @HiveField(2)
  updated,
  
  @HiveField(3)
  deleted
}

@HiveType(typeId: 4) // Make sure this typeId is unique and not used by other models
class PasswordActivityLog extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String passwordId;
  
  @HiveField(2)
  String passwordName;
  
  @HiveField(3)
  ActivityType activityType;
  
  @HiveField(4)
  DateTime timestamp;
  
  @HiveField(5)
  String? oldValue; // For password changes, store the old value (encrypted)
  
  @HiveField(6)
  String? newValue; // For password changes, store the new value (encrypted)
  
  PasswordActivityLog({
    required this.id,
    required this.passwordId,
    required this.passwordName,
    required this.activityType,
    required this.timestamp,
    this.oldValue,
    this.newValue,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passwordId': passwordId,
      'passwordName': passwordName,
      'activityType': activityType.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'oldValue': oldValue,
      'newValue': newValue,
    };
  }
  
  factory PasswordActivityLog.fromJson(Map<String, dynamic> json) {
    return PasswordActivityLog(
      id: json['id'],
      passwordId: json['passwordId'],
      passwordName: json['passwordName'],
      activityType: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['activityType'],
        orElse: () => ActivityType.viewed,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      oldValue: json['oldValue'],
      newValue: json['newValue'],
    );
  }
}