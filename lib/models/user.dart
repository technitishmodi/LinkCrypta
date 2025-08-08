import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? displayName;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime lastLoginAt;

  @HiveField(5)
  bool isBiometricEnabled;

  @HiveField(6)
  String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLoginAt,
    this.isBiometricEnabled = false,
    this.profileImageUrl,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isBiometricEnabled,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isBiometricEnabled': isBiometricEnabled,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      profileImageUrl: json['profileImageUrl'],
    );
  }
} 