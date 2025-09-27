import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../services/autofill_framework_service.dart';

class AutofillFrameworkScreen extends StatefulWidget {
  const AutofillFrameworkScreen({super.key});

  @override
  State<AutofillFrameworkScreen> createState() => _AutofillFrameworkScreenState();
}

class _AutofillFrameworkScreenState extends State<AutofillFrameworkScreen> {
  bool _isAutofillEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic> _autofillStats = {};
  List<Map<String, dynamic>> _autofillApps = [];

  @override
  void initState() {
    super.initState();
    _initializeAutofillService();
    _loadAutofillStatus();
  }

  Future<void> _initializeAutofillService() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await AutofillFrameworkService.instance.initialize(dataProvider);
  }

  Future<void> _loadAutofillStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final isEnabled = await AutofillFrameworkService.instance.isAutofillServiceEnabled();
      final stats = await AutofillFrameworkService.instance.getAutofillStats();
      final apps = await AutofillFrameworkService.instance.getAutofillApps();
      
      setState(() {
        _isAutofillEnabled = isEnabled;
        _autofillStats = stats;
        _autofillApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load autofill status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofill Framework'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4D8AF0)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE3F2FD)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildSetupCard(),
                    const SizedBox(height: 16),
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    if (_autofillApps.isNotEmpty) _buildAppsCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_isAutofillEnabled ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isAutofillEnabled ? Icons.check_circle : Icons.warning,
                    color: _isAutofillEnabled ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Autofill Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _isAutofillEnabled ? Icons.check_circle : Icons.cancel,
                  color: _isAutofillEnabled ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isAutofillEnabled ? 'Autofill Service Enabled' : 'Autofill Service Disabled',
                  style: TextStyle(
                    color: _isAutofillEnabled ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isAutofillEnabled
                  ? 'LinkCrypta can now autofill passwords across Android apps and websites.'
                  : 'Enable autofill service to automatically fill passwords in apps and websites.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Text(
                  'Setup & Configuration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isAutofillEnabled) ...[
              const Text(
                'To enable autofill functionality:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('1. Tap "Open Autofill Settings" below'),
              const Text('2. Select "LinkCrypta" from the list'),
              const Text('3. Toggle the switch to enable the service'),
              const Text('4. Grant necessary permissions'),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAutofillSettings,
                icon: const Icon(Icons.settings),
                label: Text(_isAutofillEnabled ? 'Manage Autofill Settings' : 'Open Autofill Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadAutofillStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                Text(
                  'System Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Android Version', 'API ${_autofillStats['androidVersion'] ?? 'Unknown'}'),
            _buildStatRow('Autofill Supported', _autofillStats['isSupported'] == true ? 'Yes' : 'No'),
            _buildStatRow('Service Enabled', _autofillStats['isEnabled'] == true ? 'Yes' : 'No'),
            _buildStatRow('Package Name', _autofillStats['packageName'] ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.apps, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Text(
                  'Apps with Autofill Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _autofillApps.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final app = _autofillApps[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.android),
                  ),
                  title: Text(app['name'] ?? 'Unknown App'),
                  subtitle: Text(app['packageName'] ?? ''),
                  trailing: Switch(
                    value: app['enabled'] ?? false,
                    onChanged: (enabled) => _toggleAppAutofill(
                      app['packageName'] ?? '',
                      enabled,
                      index,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAutofillSettings() async {
    try {
      await AutofillFrameworkService.instance.openAutofillSettings();
      // Refresh status after a delay to allow user to make changes
      Future.delayed(const Duration(seconds: 2), _loadAutofillStatus);
    } catch (e) {
      _showErrorSnackBar('Failed to open autofill settings: $e');
    }
  }

  Future<void> _toggleAppAutofill(String packageName, bool enabled, int index) async {
    try {
      await AutofillFrameworkService.instance.setAppAutofillEnabled(packageName, enabled);
      setState(() {
        _autofillApps[index]['enabled'] = enabled;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Autofill ${enabled ? 'enabled' : 'disabled'} for ${_autofillApps[index]['name']}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update app autofill setting: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Dialog to show when saving new credentials from autofill
class SaveCredentialsDialog extends StatefulWidget {
  final String url;
  final String username;
  final String password;

  const SaveCredentialsDialog({
    super.key,
    required this.url,
    required this.username,
    required this.password,
  });

  @override
  State<SaveCredentialsDialog> createState() => _SaveCredentialsDialogState();
}

class _SaveCredentialsDialogState extends State<SaveCredentialsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _generateNameFromUrl(widget.url));
    _usernameController = TextEditingController(text: widget.username);
    _urlController = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  String _generateNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host;
      
      String name = domain
          .replaceFirst(RegExp(r'^www\.'), '')
          .replaceFirst(RegExp(r'\.com$'), '')
          .replaceFirst(RegExp(r'\.org$'), '')
          .replaceFirst(RegExp(r'\.net$'), '');
      
      if (name.isNotEmpty) {
        name = name[0].toUpperCase() + name.substring(1);
      }
      
      return name.isEmpty ? 'New Account' : name;
    } catch (e) {
      return 'New Account';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.save, color: Colors.blue),
          SizedBox(width: 8),
          Text('Save New Password'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LinkCrypta detected a new login. Would you like to save these credentials?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username/Email',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Website/App',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Password: '),
                  Text('•' * widget.password.length),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'save': true,
              'name': _nameController.text,
              'username': _usernameController.text,
              'url': _urlController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
