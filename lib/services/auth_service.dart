import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _authEnabledKey = 'auth_enabled';
  static const String _pinCodeKey = 'pin_code';

  // Check if device supports biometric authentication
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
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
    if (!isEnabled) return true; // Skip authentication if not enabled
    
    // First try biometric authentication if available
    if (await isBiometricAvailable()) {
      final authenticated = await authenticateWithBiometrics(reason);
      if (authenticated) return true;
    }

    // If biometric fails or not available, fall back to PIN
    if (await isPINSet()) {
      // Show PIN dialog
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PINDialog(reason: reason),
      );
      return result ?? false;
    }

    // If no authentication method is available, return false
    return false;
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