import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/data_provider.dart';
import '../../services/password_health_service.dart';

class PasswordHealthDashboardScreen extends StatefulWidget {
  const PasswordHealthDashboardScreen({super.key});

  @override
  State<PasswordHealthDashboardScreen> createState() => _PasswordHealthDashboardScreenState();
}

class _PasswordHealthDashboardScreenState extends State<PasswordHealthDashboardScreen> {
  PasswordHealthReport? _healthReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthReport();
  }

  Future<void> _loadHealthReport() async {
    setState(() => _isLoading = true);
    
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final passwords = dataProvider.passwords;
      
      final report = await PasswordHealthService.analyzePasswords(passwords);
      
      if (mounted) {
        setState(() {
          _healthReport = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading health report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _healthReport == null
              ? const Center(child: Text('No data available'))
              : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    final report = _healthReport!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallScoreCard(report),
          const SizedBox(height: 16),
          _buildSecurityMetrics(report),
          const SizedBox(height: 16),
          _buildStrengthDistribution(report),
          const SizedBox(height: 16),
          _buildWeakPasswordsList(report),
          const SizedBox(height: 16),
          _buildDuplicatePasswordsList(report),
          const SizedBox(height: 16),
          _buildCompromisedPasswordsList(report),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(PasswordHealthReport report) {
    final score = report.overallScore;
    final scoreColor = _getScoreColor(score);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Overall Security Score',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          color: scoreColor,
                          value: score,
                          title: '',
                          radius: 20,
                        ),
                        PieChartSectionData(
                          color: Colors.grey.shade300,
                          value: 100 - score,
                          title: '',
                          radius: 20,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${score.toInt()}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: scoreColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getScoreLabel(score),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreDescription(score),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityMetrics(PasswordHealthReport report) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Passwords',
            report.totalPasswords.toString(),
            Icons.lock,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Weak Passwords',
            report.weakPasswords.toString(),
            Icons.warning,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Duplicates',
            report.duplicatePasswords.toString(),
            Icons.content_copy,
            Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Compromised',
            report.compromisedPasswords.toString(),
            Icons.security,
            Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthDistribution(PasswordHealthReport report) {
    final strengthCounts = <String, int>{
      'Very Weak': 0,
      'Weak': 0,
      'Fair': 0,
      'Good': 0,
      'Strong': 0,
      'Very Strong': 0,
    };

    for (final analysis in report.passwordAnalyses) {
      final strengthName = PasswordHealthService.getStrengthDescription(analysis.strength);
      strengthCounts[strengthName] = (strengthCounts[strengthName] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Strength Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: strengthCounts.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = strengthCounts.keys.toList();
                          if (value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[value.toInt()].split(' ').first,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: strengthCounts.entries.map((entry) {
                    final index = strengthCounts.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: _getStrengthColor(entry.key),
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeakPasswordsList(PasswordHealthReport report) {
    final weakPasswords = report.passwordAnalyses
        .where((analysis) => analysis.strengthScore < 60)
        .toList();

    if (weakPasswords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text('No weak passwords found! Great job!'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Weak Passwords (${weakPasswords.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...weakPasswords.take(5).map((analysis) => _buildPasswordIssueItem(analysis)),
            if (weakPasswords.length > 5)
              TextButton(
                onPressed: () => _showAllIssues('Weak Passwords', weakPasswords),
                child: Text('View all ${weakPasswords.length} weak passwords'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuplicatePasswordsList(PasswordHealthReport report) {
    final duplicatePasswords = report.passwordAnalyses
        .where((analysis) => analysis.isDuplicate)
        .toList();

    if (duplicatePasswords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text('No duplicate passwords found!'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.content_copy, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Duplicate Passwords (${duplicatePasswords.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...duplicatePasswords.take(5).map((analysis) => _buildPasswordIssueItem(analysis)),
            if (duplicatePasswords.length > 5)
              TextButton(
                onPressed: () => _showAllIssues('Duplicate Passwords', duplicatePasswords),
                child: Text('View all ${duplicatePasswords.length} duplicate passwords'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompromisedPasswordsList(PasswordHealthReport report) {
    final compromisedPasswords = report.passwordAnalyses
        .where((analysis) => analysis.isCompromised)
        .toList();

    if (compromisedPasswords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text('No compromised passwords found!'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Compromised Passwords (${compromisedPasswords.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These passwords have been found in data breaches. Change them immediately!',
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...compromisedPasswords.take(5).map((analysis) => _buildPasswordIssueItem(analysis)),
            if (compromisedPasswords.length > 5)
              TextButton(
                onPressed: () => _showAllIssues('Compromised Passwords', compromisedPasswords),
                child: Text('View all ${compromisedPasswords.length} compromised passwords'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordIssueItem(PasswordAnalysis analysis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.entry.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  analysis.entry.username,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (analysis.issues.isNotEmpty)
                  Text(
                    analysis.issues.join(', '),
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStrengthColor(PasswordHealthService.getStrengthDescription(analysis.strength)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${analysis.strengthScore}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${analysis.ageInDays}d old',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllIssues(String title, List<PasswordAnalysis> issues) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: issues.length,
                  itemBuilder: (context, index) => _buildPasswordIssueItem(issues[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Your passwords are very secure! Keep up the good work.';
    if (score >= 60) return 'Your password security is good, but there\'s room for improvement.';
    if (score >= 40) return 'Your password security needs attention. Consider updating weak passwords.';
    return 'Your password security is poor. Please update your weak and compromised passwords immediately.';
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Very Strong': return Colors.green.shade700;
      case 'Strong': return Colors.green;
      case 'Good': return Colors.lightGreen;
      case 'Fair': return Colors.orange;
      case 'Weak': return Colors.deepOrange;
      case 'Very Weak': return Colors.red;
      default: return Colors.grey;
    }
  }
}
