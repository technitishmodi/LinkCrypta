import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../utils/helpers.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _isBiometricAvailable = false;
  bool _enableBiometric = false;
  
  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }
  
  Future<void> _checkBiometricAvailability() async {
    final bool canUseBiometrics = await AuthService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = canUseBiometrics;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save PIN code
      await AuthService.setPINCode(_pinController.text);
      await AuthService.setAuthEnabled(true);
      
      // If biometric is enabled and available, try to authenticate
      if (_enableBiometric && _isBiometricAvailable) {
        final bool authenticated = await AuthService.authenticateWithBiometrics(
          'Authenticate to enable biometric login'
        );
        
        if (mounted && authenticated) {
          AppHelpers.showSnackBar(
            context,
            'Biometric authentication enabled',
            backgroundColor: Colors.green,
          );
        }
      }

      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'PIN set successfully',
          backgroundColor: Colors.green,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Failed to set PIN: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set PIN Code'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Secure Your Passwords',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create a PIN code to protect your passwords. You will need to enter this PIN when biometric authentication is not available.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // PIN Field
                TextFormField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    labelText: 'PIN Code',
                    hintText: 'Enter a 4-6 digit PIN',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePin = !_obscurePin;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: _obscurePin,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a PIN';
                    }
                    if (value.length < 4) {
                      return 'PIN must be at least 4 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm PIN Field
                TextFormField(
                  controller: _confirmPinController,
                  decoration: InputDecoration(
                    labelText: 'Confirm PIN Code',
                    hintText: 'Re-enter your PIN',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPin ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPin = !_obscureConfirmPin;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: _obscureConfirmPin,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your PIN';
                    }
                    if (value != _pinController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Biometric Option
                if (_isBiometricAvailable)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Enable Biometric Authentication',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Switch(
                              value: _enableBiometric,
                              onChanged: (value) {
                                setState(() {
                                  _enableBiometric = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use your fingerprint or face recognition to quickly access your passwords.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save PIN'),
                  ),
                ),
                const SizedBox(height: 16),

                // Skip Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop(false);
                          },
                    child: const Text('Skip for now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}