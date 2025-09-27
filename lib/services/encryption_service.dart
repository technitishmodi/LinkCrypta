import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _keyName = 'linkcrypta_encryption_key';
  static const String _ivName = 'linkcrypta_encryption_iv';
  
  static late Encrypter _encrypter;
  static late IV _iv;
  static bool _initialized = false;

  // Private constructor to prevent instantiation
  EncryptionService._();

  /// Initialize Encryption Service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get stored encryption key and IV (may be null)
      String? keyString = await _storage.read(key: _keyName);
      String? ivString = await _storage.read(key: _ivName);

      // If missing, generate new secure random key (32 bytes) and IV (16 bytes)
      if (keyString == null || ivString == null) {
        final random = Random.secure();
        final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
        final ivBytes = List<int>.generate(16, (_) => random.nextInt(256));

        keyString = base64Encode(keyBytes);
        ivString = base64Encode(ivBytes);

        // Persist securely
        await _storage.write(key: _keyName, value: keyString);
        await _storage.write(key: _ivName, value: ivString);
      }

      final key = Key.fromBase64(keyString);
      _iv = IV.fromBase64(ivString);

      _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      _initialized = true;
    } catch (e) {
      _initialized = false;
      throw Exception('Failed to initialize EncryptionService: $e');
    }
  }

  /// Encrypt plain text
  static String encrypt(String data) {
    if (!_initialized) {
      throw Exception('EncryptionService not initialized. Call initialize() first.');
    }
    
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt encrypted text
  static String decrypt(String encryptedData) {
    if (!_initialized) {
      throw Exception('EncryptionService not initialized. Call initialize() first.');
    }
    
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Generate a strong random password
  static String generateStrongPassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    if (chars.isEmpty) {
      chars = lowercase + numbers; // fallback set
    }

    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Hash password with SHA-256
  static String hashPassword(String password) {
    try {
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Password hashing failed: $e');
    }
  }

  /// Clear stored encryption keys
  static Future<void> clearEncryptionKeys() async {
    try {
      await _storage.delete(key: _keyName);
      await _storage.delete(key: _ivName);
      _initialized = false;
    } catch (e) {
      throw Exception('Failed to clear encryption keys: $e');
    }
  }

  /// Check if service is initialized & keys exist
  static Future<bool> isInitialized() async {
    if (!_initialized) return false;
    
    try {
      final keyExists = await _storage.containsKey(key: _keyName);
      final ivExists = await _storage.containsKey(key: _ivName);
      return keyExists && ivExists;
    } catch (e) {
      return false;
    }
  }
}
