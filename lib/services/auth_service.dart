import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _authEnabledKey = 'auth_enabled';
  static const String _pinCodeKey = 'pin_code';

  // Check if device supports biometric authentication
  static Future<bool> isBiometricAvailable() async {
    // Web platform doesn't support biometric authentication
    if (kIsWeb) {
      print('AuthService: Running on web, biometric not supported');
      return false;
    }
    
    try {
      print('AuthService: Checking biometric availability...');
      
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      print('AuthService: canCheckBiometrics: $canCheckBiometrics');
      
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      print('AuthService: isDeviceSupported: $isDeviceSupported');
      
      final bool canAuthenticate = canCheckBiometrics || isDeviceSupported;
      print('AuthService: canAuthenticate: $canAuthenticate');
      
      if (canAuthenticate) {
        // Also check if there are actually enrolled biometrics
        final availableBiometrics = await getAvailableBiometrics();
        print('AuthService: availableBiometrics: $availableBiometrics');
        return availableBiometrics.isNotEmpty;
      }
      
      return false;
    } on PlatformException catch (e) {
      print('AuthService: PlatformException checking biometric availability: $e');
      return false;
    } catch (e) {
      print('AuthService: Error checking biometric availability: $e');
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    // Web platform doesn't support biometric authentication
    if (kIsWeb) {
      print('AuthService: Running on web, no biometrics available');
      return [];
    }
    
    try {
      print('AuthService: Getting available biometrics...');
      final biometrics = await _localAuth.getAvailableBiometrics();
      print('AuthService: Found biometrics: $biometrics');
      return biometrics;
    } on PlatformException catch (e) {
      print('AuthService: PlatformException getting available biometrics: $e');
      return [];
    } catch (e) {
      print('AuthService: Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics(String reason) async {
    // Web platform doesn't support biometric authentication
    if (kIsWeb) {
      print('AuthService: Biometric not supported on web platform');
      return false;
    }
    
    try {
      print('AuthService: Attempting biometric authentication...');
      
      // Check if biometrics are available before attempting authentication
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('AuthService: Biometric authentication not available');
        return false;
      }
      
      // Get available biometrics for debugging
      final availableBiometrics = await getAvailableBiometrics();
      print('AuthService: Available biometrics: $availableBiometrics');
      
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow fallback to device PIN if needed
        ),
      );
      
      print('AuthService: Biometric authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      print('AuthService: Biometric authentication failed with PlatformException: $e');
      return false;
    } catch (e) {
      print('AuthService: Biometric authentication failed with error: $e');
      return false;
    }
  }

  // Authenticate with PIN code
  static Future<bool> authenticateWithPIN(String enteredPin) async {
    final storedPin = await _storage.read(key: _pinCodeKey);
    return storedPin == enteredPin;
  }
  
  // Verify PIN code (alias for authenticateWithPIN for compatibility)
  static Future<bool> verifyPINCode(String enteredPin) async {
    return authenticateWithPIN(enteredPin);
  }

  // Set PIN code
  static Future<void> setPINCode(String pin) async {
    await _storage.write(key: _pinCodeKey, value: pin);
  }

  // Check if PIN is set
  static Future<bool> isPINSet() async {
    final pin = await _storage.read(key: _pinCodeKey);
    return pin != null && pin.isNotEmpty;
  }

  // Enable/disable authentication
  static Future<void> setAuthEnabled(bool enabled) async {
    await _storage.write(key: _authEnabledKey, value: enabled.toString());
  }

  // Check if authentication is enabled
  static Future<bool> isAuthEnabled() async {
    final value = await _storage.read(key: _authEnabledKey);
    return value == 'true';
  }

  // Show authentication dialog
  static Future<bool> showAuthDialog(BuildContext context, {String reason = 'Authentication required'}) async {
    // Check if authentication is enabled
    final isEnabled = await isAuthEnabled();
    if (!isEnabled) {
      print('AuthService: Authentication is disabled, skipping...');
      return true; // Skip authentication if not enabled
    }
    
    final biometricAvailable = await isBiometricAvailable();
    final pinSet = await isPINSet();
    
    print('AuthService: Biometric available: $biometricAvailable, PIN set: $pinSet');
    
    // If both biometric and PIN are available, show choice dialog
    if (biometricAvailable && pinSet) {
      final authMethod = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _AuthMethodDialog(reason: reason),
      );
      
      if (authMethod == 'biometric') {
        final result = await authenticateWithBiometrics(reason);
        print('AuthService: Biometric authentication result: $result');
        return result;
      } else if (authMethod == 'pin') {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _PINDialog(reason: reason),
        );
        return result ?? false;
      }
      return false; // User cancelled
    }
    
    // If only biometric is available, try it directly
    if (biometricAvailable) {
      print('AuthService: Only biometric available, trying directly...');
      final result = await authenticateWithBiometrics(reason);
      print('AuthService: Biometric result: $result');
      return result;
    }

    // If only PIN is available, show PIN dialog
    if (pinSet) {
      print('AuthService: Only PIN available, showing PIN dialog...');
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PINDialog(reason: reason),
      );
      return result ?? false;
    }

    // If no authentication method is available, return false
    print('AuthService: No authentication methods available');
    return false;
  }
}

class _AuthMethodDialog extends StatelessWidget {
  final String reason;
  
  const _AuthMethodDialog({required this.reason});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return AlertDialog(
      title: const Text('Choose Authentication Method'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How would you like to authenticate?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop('pin'),
          icon: const Icon(Icons.pin_rounded),
          label: const Text('PIN'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop('biometric'),
          icon: const Icon(Icons.fingerprint_rounded),
          label: const Text('Biometric'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _PINDialog extends StatefulWidget {
  final String reason;
  
  const _PINDialog({this.reason = 'Authentication required'});
  
  @override
  _PINDialogState createState() => _PINDialogState();
}

class _PINDialogState extends State<_PINDialog> {
  final TextEditingController _pinController = TextEditingController();
  String _errorText = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return AlertDialog(
      title: Text('Authentication Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.reason,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'PIN',
              errorText: _errorText.isNotEmpty ? _errorText : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _verifyPIN(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _verifyPIN,
          child: const Text('Verify'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Future<void> _verifyPIN() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() {
        _errorText = 'PIN cannot be empty';
      });
      return;
    }

    final isValid = await AuthService.authenticateWithPIN(pin);
    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorText = 'Invalid PIN';
      });
    }
  }
}