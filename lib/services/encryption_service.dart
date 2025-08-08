import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _keyName = 'vaultmate_encryption_key';
  static const String _ivName = 'vaultmate_encryption_iv';
  
  static late Encrypter _encrypter;
  static late IV _iv;
  static bool _initialized = false;

  // Private constructor to prevent instantiation
  EncryptionService._();

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get or generate encryption key
      String? keyString = await _storage.read(key: _keyName);
      if (keyString == null) {
        final key = Key.fromSecureRandom(32); // 256-bit key
        keyString = key.base64;
        await _storage.write(key: _keyName, value: keyString);
      }

      // Get or generate IV
      String? ivString = await _storage.read(key: _ivName);
      if (ivString == null) {
        final iv = IV.fromSecureRandom(16); // 128-bit IV
        ivString = iv.base64;
        await _storage.write(key: _ivName, value: ivString);
      }

      _iv = IV.fromBase64(ivString);
      final key = Key.fromBase64(keyString);
      _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      _initialized = true;
    } catch (e) {
      _initialized = false;
      throw Exception('Failed to initialize EncryptionService: $e');
    }
  }

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
      chars = lowercase + numbers; // Default character set
    }

    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static String hashPassword(String password) {
    try {
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Password hashing failed: $e');
    }
  }

  static Future<void> clearEncryptionKeys() async {
    try {
      await _storage.delete(key: _keyName);
      await _storage.delete(key: _ivName);
      _initialized = false;
    } catch (e) {
      throw Exception('Failed to clear encryption keys: $e');
    }
  }

  static Future<bool> isInitialized() async {
    if (!_initialized) return false;
    
    // Verify keys actually exist in storage
    try {
      final keyExists = await _storage.containsKey(key: _keyName);
      final ivExists = await _storage.containsKey(key: _ivName);
      return keyExists && ivExists;
    } catch (e) {
      return false;
    }
  }
}