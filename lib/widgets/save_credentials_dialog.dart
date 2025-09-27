import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class SaveCredentialsDialog extends StatefulWidget {
  final String url;
  final String username;
  final String password;
  final String? appName;

  const SaveCredentialsDialog({
    super.key,
    required this.url,
    required this.username,
    required this.password,
    this.appName,
  });

  static Future<bool> show({
    required BuildContext context,
    required String url,
    required String username,
    required String password,
    String? appName,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaveCredentialsDialog(
        url: url,
        username: username,
        password: password,
        appName: appName,
      ),
    );

    if (result != null && result['save'] == true) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      
      try {
        await dataProvider.addPassword(
          name: result['name'] ?? 'New Account',
          username: result['username'] ?? username,
          password: password,
          url: result['url'] ?? url,
          category: result['category'] ?? 'General',
          notes: result['notes'] ?? '',
        );
        return true;
      } catch (e) {
        // Show error but still return true since user wanted to save
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save credentials: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return false;
  }

  @override
  State<SaveCredentialsDialog> createState() => _SaveCredentialsDialogState();
}

class _SaveCredentialsDialogState extends State<SaveCredentialsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _urlController;
  late TextEditingController _notesController;
  String _selectedCategory = 'General';
  bool _showPassword = false;

  final List<String> _categories = [
    'General',
    'Social Media',
    'Banking',
    'Email',
    'Shopping',
    'Work',
    'Entertainment',
    'Gaming',
    'Education',
    'Health',
    'Travel',
    'Utilities',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _generateNameFromUrl(widget.url));
    _usernameController = TextEditingController(text: widget.username);
    _urlController = TextEditingController(text: widget.url);
    _notesController = TextEditingController(
      text: widget.appName != null ? 'Saved from ${widget.appName}' : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateNameFromUrl(String url) {
    try {
      // Handle app package names
      if (url.contains('.') && !url.startsWith('http')) {
        final parts = url.split('.');
        if (parts.length >= 2) {
          return parts.last.replaceAll('_', ' ').split(' ')
              .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
              .join(' ');
        }
      }

      // Handle URLs
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
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
      return widget.appName ?? 'New Account';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.save, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Save New Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'LinkCrypta detected new login credentials. Save them securely?',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Name field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Account Name',
                  hintText: 'e.g., Gmail, Facebook, Work Email',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Username field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username/Email',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password field (read-only, showing masked)
              TextField(
                readOnly: true,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: _showPassword ? widget.password : '•' * widget.password.length,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // URL field
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Website/App',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Notes field
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional information about this account',
                  prefixIcon: const Icon(Icons.note_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Security info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your password will be encrypted and stored securely on your device.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop({'save': false}),
          child: const Text('Not Now'),
        ),
        ElevatedButton.icon(
          onPressed: _saveCredentials,
          icon: const Icon(Icons.save),
          label: const Text('Save Password'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _saveCredentials() {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showValidationError('Please enter an account name');
      return;
    }
    
    if (_usernameController.text.trim().isEmpty) {
      _showValidationError('Please enter a username or email');
      return;
    }

    Navigator.of(context).pop({
      'save': true,
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'url': _urlController.text.trim(),
      'category': _selectedCategory,
      'notes': _notesController.text.trim(),
    });
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
