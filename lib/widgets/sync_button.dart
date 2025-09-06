import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/password_entry.dart';
import '../models/link_entry.dart';

class SyncButton extends StatefulWidget {
  final PasswordEntry? password;
  final LinkEntry? link;
  final VoidCallback? onSyncComplete;

  const SyncButton({
    Key? key,
    this.password,
    this.link,
    this.onSyncComplete,
  }) : super(key: key);

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    
    if (!dataProvider.canSyncWithFirebase()) {
      return const SizedBox.shrink(); // Hide if user can't sync
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : _handleSync,
        icon: _isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload, size: 18),
        label: Text(_isSyncing ? 'Syncing...' : 'Sync to Firebase'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    bool success = false;

    try {
      if (widget.password != null) {
        success = await dataProvider.syncPasswordToFirebase(widget.password!);
        if (success) {
          _showSnackBar('Password synced to Firebase successfully!', Colors.green);
        } else {
          _showSnackBar('Failed to sync password to Firebase', Colors.red);
        }
      } else if (widget.link != null) {
        success = await dataProvider.syncLinkToFirebase(widget.link!);
        if (success) {
          _showSnackBar('Link synced to Firebase successfully!', Colors.green);
        } else {
          _showSnackBar('Failed to sync link to Firebase', Colors.red);
        }
      }

      if (success && widget.onSyncComplete != null) {
        widget.onSyncComplete!();
      }
    } catch (e) {
      _showSnackBar('Sync error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class FullSyncButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool syncToFirebase; // true for upload, false for download

  const FullSyncButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.syncToFirebase,
  }) : super(key: key);

  @override
  State<FullSyncButton> createState() => _FullSyncButtonState();
}

class _FullSyncButtonState extends State<FullSyncButton> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    
    if (!dataProvider.canSyncWithFirebase()) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off, color: Colors.grey),
          title: const Text('Firebase Sync'),
          subtitle: const Text('Sign in to enable cloud sync'),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: _isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(widget.icon, color: Colors.blue),
        title: Text(widget.label),
        subtitle: Text(widget.syncToFirebase 
            ? 'Upload all data to Firebase' 
            : 'Download data from Firebase'),
        trailing: _isSyncing 
            ? null 
            : const Icon(Icons.arrow_forward_ios),
        onTap: _isSyncing ? null : _handleFullSync,
      ),
    );
  }

  Future<void> _handleFullSync() async {
    setState(() {
      _isSyncing = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    bool success = false;

    try {
      if (widget.syncToFirebase) {
        success = await dataProvider.syncAllToFirebase();
        if (success) {
          _showSnackBar('All data synced to Firebase successfully!', Colors.green);
        } else {
          _showSnackBar('Failed to sync data to Firebase', Colors.red);
        }
      } else {
        success = await dataProvider.syncFromFirebase();
        if (success) {
          _showSnackBar('Data synced from Firebase successfully!', Colors.green);
        } else {
          _showSnackBar('No new data found in Firebase', Colors.orange);
        }
      }
    } catch (e) {
      _showSnackBar('Sync error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: dataProvider.getSyncStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Checking sync status...'),
            ),
          );
        }

        final status = snapshot.data ?? {};
        final canSync = status['canSync'] ?? false;
        final localPasswords = status['localPasswords'] ?? 0;
        final localLinks = status['localLinks'] ?? 0;
        final firebasePasswords = status['firebasePasswords'] ?? 0;
        final firebaseLinks = status['firebaseLinks'] ?? 0;
        final message = status['message'] ?? 'Unknown status';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      canSync ? Icons.cloud_done : Icons.cloud_off,
                      color: canSync ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sync Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(message),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Local Storage', 
                            style: Theme.of(context).textTheme.labelMedium),
                        Text('$localPasswords passwords'),
                        Text('$localLinks links'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Firebase', 
                            style: Theme.of(context).textTheme.labelMedium),
                        Text('$firebasePasswords passwords'),
                        Text('$firebaseLinks links'),
                      ],
                    ),
                  ],
                ),
                if (dataProvider.getCurrentUserEmail() != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Signed in as: ${dataProvider.getCurrentUserEmail()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
