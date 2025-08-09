import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/data_provider.dart';
import '../../../models/password_activity_log.dart';

class PasswordActivityScreen extends StatefulWidget {
  const PasswordActivityScreen({super.key});

  @override
  State<PasswordActivityScreen> createState() => _PasswordActivityScreenState();
}

class _PasswordActivityScreenState extends State<PasswordActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPasswordId;
  ActivityType? _selectedActivityType;
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Set default date range to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Activity'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Viewed'),
            Tab(text: 'Created'),
            Tab(text: 'Modified'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedActivityType = null; // All
                  break;
                case 1:
                  _selectedActivityType = ActivityType.viewed;
                  break;
                case 2:
                  _selectedActivityType = ActivityType.created;
                  break;
                case 3:
                  // Both updated and deleted are considered modifications
                  _selectedActivityType = ActivityType.updated;
                  break;
              }
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Date range filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate != null 
                      ? DateFormat('MMM d, yyyy').format(_startDate!) 
                      : 'Start Date'),
                    onPressed: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate != null 
                      ? DateFormat('MMM d, yyyy').format(_endDate!) 
                      : 'End Date'),
                    onPressed: () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ),
          
          // Activity logs list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActivityLogsList(null),
                _buildActivityLogsList(ActivityType.viewed),
                _buildActivityLogsList(ActivityType.created),
                _buildActivityLogsList(ActivityType.updated), // Shows both updated and deleted
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityLogsList(ActivityType? activityType) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        List<PasswordActivityLog> logs = [];
        
        // Apply filters
        if (_selectedPasswordId != null) {
          logs = dataProvider.getPasswordLogsForPassword(_selectedPasswordId!);
        } else if (_startDate != null && _endDate != null) {
          logs = dataProvider.getPasswordLogsInDateRange(_startDate!, _endDate!);
        } else if (activityType != null) {
          logs = dataProvider.getPasswordLogsByActivityType(activityType);
        } else {
          logs = dataProvider.getAllPasswordLogs();
        }
        
        // Apply activity type filter if on a specific tab
        if (activityType != null) {
          logs = logs.where((log) => log.activityType == activityType).toList();
        } else if (_selectedActivityType != null) {
          if (_selectedActivityType == ActivityType.updated) {
            // For the "Modified" tab, show both updated and deleted
            logs = logs.where((log) => 
              log.activityType == ActivityType.updated || 
              log.activityType == ActivityType.deleted
            ).toList();
          } else {
            logs = logs.where((log) => log.activityType == _selectedActivityType).toList();
          }
        }
        
        if (logs.isEmpty) {
          return const Center(
            child: Text('No activity logs found'),
          );
        }
        
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildActivityLogItem(log);
          },
        );
      },
    );
  }
  
  Widget _buildActivityLogItem(PasswordActivityLog log) {
    IconData icon;
    Color iconColor;
    String action;
    
    switch (log.activityType) {
      case ActivityType.viewed:
        icon = Icons.visibility;
        iconColor = Colors.blue;
        action = 'Viewed';
        break;
      case ActivityType.created:
        icon = Icons.add_circle;
        iconColor = Colors.green;
        action = 'Created';
        break;
      case ActivityType.updated:
        icon = Icons.edit;
        iconColor = Colors.orange;
        action = 'Updated';
        break;
      case ActivityType.deleted:
        icon = Icons.delete;
        iconColor = Colors.red;
        action = 'Deleted';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(log.passwordName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action),
            Text(
              DateFormat('MMM d, yyyy - h:mm a').format(log.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: log.activityType == ActivityType.updated
            ? IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showPasswordChangeDetails(log),
              )
            : null,
      ),
    );
  }
  
  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  void _showPasswordChangeDetails(PasswordActivityLog log) {
    if (log.activityType != ActivityType.updated || log.oldValue == null || log.newValue == null) {
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Change Details'),
        content: const Text(
          'The password was changed at this time. For security reasons, '  
          'we don\'t display the actual password values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}