import 'package:flutter/material.dart';
import '../../../services/autofill_framework_service.dart';
import '../../../utils/helpers.dart';
import '../../../utils/responsive.dart';

class AutofillServiceScreen extends StatefulWidget {
  const AutofillServiceScreen({super.key});

  @override
  State<AutofillServiceScreen> createState() => _AutofillServiceScreenState();
}

class _AutofillServiceScreenState extends State<AutofillServiceScreen> {
  bool _isEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    setState(() => _loading = true);
    try {
      final enabled = await AutofillFrameworkService.instance.isAutofillServiceEnabled();
      if (mounted) setState(() => _isEnabled = enabled);
    } catch (e) {
      print('AutofillServiceScreen: Error checking status: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSettings() async {
    try {
      await AutofillFrameworkService.instance.openAutofillSettings();
      // allow time for user to change setting then refresh
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshStatus();
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          _isEnabled ? 'LinkCrypta is enabled as autofill service.' : 'Returned from settings.',
          backgroundColor: Colors.blue,
        );
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Unable to open autofill settings: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Autofill Service',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ResponsiveLayout(
        child: Padding(
          padding: ResponsiveBreakpoints.responsivePadding(
            context,
            mobile: const EdgeInsets.all(16),
            tablet: const EdgeInsets.all(20),
            desktop: const EdgeInsets.all(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Autofill Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Prominent status badge
              Center(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_loading)
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            _isEnabled ? Icons.check_circle : Icons.cancel,
                            color: _isEnabled ? Colors.green : Colors.red,
                            size: 28,
                          ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEnabled ? 'Enabled' : 'Disabled',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _isEnabled ? Colors.green[800] : Colors.red[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isEnabled
                                    ? 'LinkCrypta is selected as the device autofill service.'
                                    : 'LinkCrypta is not the selected autofill service.',
                                style: Theme.of(context).textTheme.bodySmall,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Autofill Settings'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _refreshStatus,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh Status'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      AppHelpers.showSnackBar(
                        context,
                        'To enable LinkCrypta: open Android Autofill settings and choose LinkCrypta as the autofill service.',
                        backgroundColor: Colors.blue,
                      );
                    },
                    child: const Text('How to enable'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
