import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/password_activity_log.dart';
import '../models/password_entry.dart';

class ActivityLogService {
  static const String _activityLogBoxName = 'password_activity_logs';
  static const Uuid _uuid = Uuid();
  
  static late Box<PasswordActivityLog> _activityLogBox;
  
  static Future<void> initialize() async {
    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(ActivityTypeAdapter().typeId)) {
      Hive.registerAdapter(ActivityTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(PasswordActivityLogAdapter().typeId)) {
      Hive.registerAdapter(PasswordActivityLogAdapter());
    }
    
    // Open box only if not already open
    if (!Hive.isBoxOpen(_activityLogBoxName)) {
      _activityLogBox = await Hive.openBox<PasswordActivityLog>(_activityLogBoxName);
    } else {
      _activityLogBox = Hive.box<PasswordActivityLog>(_activityLogBoxName);
    }
    
    print('ActivityLogService: Initialized with ${_activityLogBox.length} logs');
  }
  
  // Log password viewed
  static Future<void> logPasswordViewed(PasswordEntry password) async {
    final log = PasswordActivityLog(
      id: _uuid.v4(),
      passwordId: password.id,
      passwordName: password.name,
      activityType: ActivityType.viewed,
      timestamp: DateTime.now(),
    );
    
    await _activityLogBox.add(log);
  }
  
  // Log password created
  static Future<void> logPasswordCreated(PasswordEntry password) async {
    final log = PasswordActivityLog(
      id: _uuid.v4(),
      passwordId: password.id,
      passwordName: password.name,
      activityType: ActivityType.created,
      timestamp: DateTime.now(),
      newValue: password.password, // Store encrypted password
    );
    
    await _activityLogBox.add(log);
  }
  
  // Log password updated
  static Future<void> logPasswordUpdated(
    PasswordEntry password,
    String oldEncryptedPassword,
  ) async {
    final log = PasswordActivityLog(
      id: _uuid.v4(),
      passwordId: password.id,
      passwordName: password.name,
      activityType: ActivityType.updated,
      timestamp: DateTime.now(),
      oldValue: oldEncryptedPassword,
      newValue: password.password,
    );
    
    await _activityLogBox.add(log);
  }
  
  // Log password deleted
  static Future<void> logPasswordDeleted(PasswordEntry password) async {
    final log = PasswordActivityLog(
      id: _uuid.v4(),
      passwordId: password.id,
      passwordName: password.name,
      activityType: ActivityType.deleted,
      timestamp: DateTime.now(),
      oldValue: password.password,
    );
    
    await _activityLogBox.add(log);
  }
  
  // Get all logs
  static List<PasswordActivityLog> getAllLogs() {
    return _activityLogBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by newest first
  }
  
  // Get logs for a specific password
  static List<PasswordActivityLog> getLogsForPassword(String passwordId) {
    return _activityLogBox.values
      .where((log) => log.passwordId == passwordId)
      .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by newest first
  }
  
  // Get logs by activity type
  static List<PasswordActivityLog> getLogsByActivityType(ActivityType type) {
    return _activityLogBox.values
      .where((log) => log.activityType == type)
      .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by newest first
  }
  
  // Get logs within a date range
  static List<PasswordActivityLog> getLogsInDateRange(DateTime start, DateTime end) {
    return _activityLogBox.values
      .where((log) => log.timestamp.isAfter(start) && log.timestamp.isBefore(end))
      .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by newest first
  }
  
  // Clear all logs
  static Future<void> clearAllLogs() async {
    await _activityLogBox.clear();
  }
  
  // Delete logs older than a certain date
  static Future<void> deleteOldLogs(DateTime cutoffDate) async {
    final oldLogs = _activityLogBox.values
      .where((log) => log.timestamp.isBefore(cutoffDate))
      .toList();
    
    for (final log in oldLogs) {
      await log.delete();
    }
  }
  
  // Close the box
  static Future<void> close() async {
    await _activityLogBox.close();
  }
}