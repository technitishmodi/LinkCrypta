import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class AutofillSetupScreen extends StatefulWidget {
  const AutofillSetupScreen({Key? key}) : super(key: key);

  @override
  State<AutofillSetupScreen> createState() => _AutofillSetupScreenState();
}

class _AutofillSetupScreenState extends State<AutofillSetupScreen> {
  bool _isAutofillEnabled = false;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _checkAutofillStatus();
  }

  Future<void> _checkAutofillStatus() async {
    if (!Platform.isAndroid) return;
    
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      const platform = MethodChannel('com.linkcrypta.app/autofill');
      final bool isEnabled = await platform.invokeMethod('isAutofillServiceEnabled');
      setState(() {
        _isAutofillEnabled = isEnabled;
      });
    } catch (e) {
      print('Error checking autofill status: $e');
      setState(() {
        _isAutofillEnabled = false;
      });
    } finally {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  Future<void> _openAutofillSettings() async {
    if (!Platform.isAndroid) return;

    try {
      const platform = MethodChannel('com.linkcrypta.app/autofill');
      await platform.invokeMethod('openAutofillSettings');
    } catch (e) {
      _showErrorDialog('Unable to open autofill settings. Please go to Settings > System > Languages & input > Autofill service and select LinkCrypta manually.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofill Setup'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isAutofillEnabled ? Icons.check_circle : Icons.error,
                          color: _isAutofillEnabled ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Autofill Service Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isCheckingStatus)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Checking status...'),
                        ],
                      )
                    else
                      Text(
                        _isAutofillEnabled 
                          ? 'LinkCrypta Autofill is enabled and ready to use!'
                          : 'LinkCrypta Autofill is not enabled. Follow the steps below to set it up.',
                        style: TextStyle(
                          color: _isAutofillEnabled ? Colors.green : Colors.orange.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Setup Instructions
            Text(
              'Setup Instructions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            _buildInstructionCard(
              '1. Open Autofill Settings',
              'Tap the button below to open Android\'s Autofill settings.',
              Icons.settings,
              () => _openAutofillSettings(),
              'Open Settings',
            ),
            
            const SizedBox(height: 12),
            
            _buildInstructionCard(
              '2. Select LinkCrypta',
              'In the Autofill service settings, select "LinkCrypta" as your autofill service.',
              Icons.app_registration,
              null,
              null,
            ),
            
            const SizedBox(height: 12),
            
            _buildInstructionCard(
              '3. Grant Permissions',
              'Allow LinkCrypta to access your screen content for autofill functionality.',
              Icons.security,
              null,
              null,
            ),
            
            const SizedBox(height: 24),
            
            // Testing Section
            Text(
              'Testing Autofill',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Test:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Open Chrome browser on your phone'),
                    const Text('2. Go to any login page (e.g., gmail.com, facebook.com)'),
                    const Text('3. Tap on the username or password field'),
                    const Text('4. You should see "LinkCrypta" appear in the autofill suggestions'),
                    const Text('5. If you have matching credentials, they will be suggested'),
                    const SizedBox(height: 16),
                    const Text(
                      'Troubleshooting:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Make sure you have saved passwords in LinkCrypta'),
                    const Text('• Ensure the website URL matches your saved credentials'),
                    const Text('• Try restarting Chrome after enabling autofill'),
                    const Text('• Check that LinkCrypta is selected in Android Settings'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Refresh Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _checkAutofillStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Check Status Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard(
    String title,
    String description,
    IconData icon,
    VoidCallback? onPressed,
    String? buttonText,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            if (onPressed != null && buttonText != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
