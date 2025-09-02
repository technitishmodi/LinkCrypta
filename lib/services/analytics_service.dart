import 'dart:math';
import '../models/password_entry.dart';
import '../models/link_entry.dart';
import '../models/password_activity_log.dart';
import 'password_health_service.dart';

class UsagePattern {
  final String category;
  final int count;
  final double percentage;
  final DateTime lastUsed;

  UsagePattern({
    required this.category,
    required this.count,
    required this.percentage,
    required this.lastUsed,
  });
}

class SecurityTrend {
  final DateTime date;
  final double securityScore;
  final int weakPasswords;
  final int strongPasswords;
  final int totalPasswords;

  SecurityTrend({
    required this.date,
    required this.securityScore,
    required this.weakPasswords,
    required this.strongPasswords,
    required this.totalPasswords,
  });
}

class ActivityInsight {
  final String title;
  final String description;
  final String type; // 'warning', 'info', 'success'
  final int priority; // 1-5, 5 being highest
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ActivityInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.metadata = const {},
  });
}

class AnalyticsSummary {
  final int totalPasswords;
  final int totalLinks;
  final double averagePasswordStrength;
  final int mostUsedCategory;
  final String mostActiveDay;
  final int passwordsCreatedThisMonth;
  final int passwordsUpdatedThisMonth;
  final double securityScoreChange;
  final List<UsagePattern> categoryUsage;
  final List<SecurityTrend> securityTrends;
  final List<ActivityInsight> insights;

  AnalyticsSummary({
    required this.totalPasswords,
    required this.totalLinks,
    required this.averagePasswordStrength,
    required this.mostUsedCategory,
    required this.mostActiveDay,
    required this.passwordsCreatedThisMonth,
    required this.passwordsUpdatedThisMonth,
    required this.securityScoreChange,
    required this.categoryUsage,
    required this.securityTrends,
    required this.insights,
  });
}

class AnalyticsService {
  /// Generates comprehensive analytics summary
  static Future<AnalyticsSummary> generateAnalytics(
    List<PasswordEntry> passwords,
    List<LinkEntry> links,
    List<PasswordActivityLog> activityLogs,
  ) async {
    final categoryUsage = _analyzeCategoryUsage(passwords, activityLogs);
    final securityTrends = await _analyzeSecurityTrends(passwords, activityLogs);
    final insights = await _generateInsights(passwords, links, activityLogs);
    
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final passwordsThisMonth = passwords.where(
      (p) => p.createdAt.isAfter(monthStart)
    ).length;
    
    final updatesThisMonth = activityLogs.where(
      (log) => log.timestamp.isAfter(monthStart) && 
               log.activityType == ActivityType.updated
    ).length;
    
    final avgStrength = passwords.isEmpty ? 0.0 : 
      passwords.map((p) => PasswordHealthService.calculatePasswordStrength(p.password))
               .reduce((a, b) => a + b) / passwords.length;
    
    return AnalyticsSummary(
      totalPasswords: passwords.length,
      totalLinks: links.length,
      averagePasswordStrength: avgStrength,
      mostUsedCategory: categoryUsage.isNotEmpty ? categoryUsage.first.count : 0,
      mostActiveDay: _getMostActiveDay(activityLogs),
      passwordsCreatedThisMonth: passwordsThisMonth,
      passwordsUpdatedThisMonth: updatesThisMonth,
      securityScoreChange: _calculateSecurityScoreChange(securityTrends),
      categoryUsage: categoryUsage,
      securityTrends: securityTrends,
      insights: insights,
    );
  }

  /// Analyzes category usage patterns
  static List<UsagePattern> _analyzeCategoryUsage(
    List<PasswordEntry> passwords,
    List<PasswordActivityLog> activityLogs,
  ) {
    final categoryCount = <String, int>{};
    final categoryLastUsed = <String, DateTime>{};
    
    // Count passwords by category
    for (final password in passwords) {
      categoryCount[password.category] = (categoryCount[password.category] ?? 0) + 1;
      
      // Find last usage from activity logs
      final passwordLogs = activityLogs.where((log) => log.passwordId == password.id);
      if (passwordLogs.isNotEmpty) {
        final lastLog = passwordLogs.reduce((a, b) => 
          a.timestamp.isAfter(b.timestamp) ? a : b);
        
        if (!categoryLastUsed.containsKey(password.category) ||
            lastLog.timestamp.isAfter(categoryLastUsed[password.category]!)) {
          categoryLastUsed[password.category] = lastLog.timestamp;
        }
      } else {
        categoryLastUsed[password.category] = password.updatedAt;
      }
    }
    
    final total = passwords.length;
    final patterns = <UsagePattern>[];
    
    for (final entry in categoryCount.entries) {
      patterns.add(UsagePattern(
        category: entry.key,
        count: entry.value,
        percentage: total > 0 ? (entry.value / total) * 100 : 0,
        lastUsed: categoryLastUsed[entry.key] ?? DateTime.now(),
      ));
    }
    
    // Sort by count descending
    patterns.sort((a, b) => b.count.compareTo(a.count));
    return patterns;
  }

  /// Analyzes security trends over time
  static Future<List<SecurityTrend>> _analyzeSecurityTrends(
    List<PasswordEntry> passwords,
    List<PasswordActivityLog> activityLogs,
  ) async {
    final trends = <SecurityTrend>[];
    final now = DateTime.now();
    
    // Generate trends for the last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      // Get passwords that existed on this day
      final passwordsOnDay = passwords.where((p) => 
        p.createdAt.isBefore(dayEnd)).toList();
      
      if (passwordsOnDay.isEmpty) {
        trends.add(SecurityTrend(
          date: dayStart,
          securityScore: 0,
          weakPasswords: 0,
          strongPasswords: 0,
          totalPasswords: 0,
        ));
        continue;
      }
      
      int weakCount = 0;
      int strongCount = 0;
      double totalScore = 0;
      
      for (final password in passwordsOnDay) {
        final strength = PasswordHealthService.calculatePasswordStrength(password.password);
        totalScore += strength;
        
        if (strength < 60) {
          weakCount++;
        } else {
          strongCount++;
        }
      }
      
      trends.add(SecurityTrend(
        date: dayStart,
        securityScore: totalScore / passwordsOnDay.length,
        weakPasswords: weakCount,
        strongPasswords: strongCount,
        totalPasswords: passwordsOnDay.length,
      ));
    }
    
    return trends;
  }

  /// Generates actionable insights
  static Future<List<ActivityInsight>> _generateInsights(
    List<PasswordEntry> passwords,
    List<LinkEntry> links,
    List<PasswordActivityLog> activityLogs,
  ) async {
    final insights = <ActivityInsight>[];
    final now = DateTime.now();
    
    // Analyze password health
    if (passwords.isNotEmpty) {
      final healthReport = await PasswordHealthService.analyzePasswords(passwords);
      
      // Weak passwords insight
      if (healthReport.weakPasswords > 0) {
        insights.add(ActivityInsight(
          title: 'Weak Passwords Detected',
          description: '${healthReport.weakPasswords} of your passwords are weak and should be updated.',
          type: 'warning',
          priority: 5,
          timestamp: now,
          metadata: {'count': healthReport.weakPasswords},
        ));
      }
      
      // Duplicate passwords insight
      if (healthReport.duplicatePasswords > 0) {
        insights.add(ActivityInsight(
          title: 'Duplicate Passwords Found',
          description: '${healthReport.duplicatePasswords} passwords are being reused across multiple accounts.',
          type: 'warning',
          priority: 4,
          timestamp: now,
          metadata: {'count': healthReport.duplicatePasswords},
        ));
      }
      
      // Compromised passwords insight
      if (healthReport.compromisedPasswords > 0) {
        insights.add(ActivityInsight(
          title: 'Compromised Passwords Alert',
          description: '${healthReport.compromisedPasswords} passwords have been found in data breaches.',
          type: 'warning',
          priority: 5,
          timestamp: now,
          metadata: {'count': healthReport.compromisedPasswords},
        ));
      }
      
      // Expired passwords insight
      if (healthReport.expiredPasswords > 0) {
        insights.add(ActivityInsight(
          title: 'Outdated Passwords',
          description: '${healthReport.expiredPasswords} passwords haven\'t been updated in over 90 days.',
          type: 'info',
          priority: 3,
          timestamp: now,
          metadata: {'count': healthReport.expiredPasswords},
        ));
      }
      
      // Overall security score insight
      if (healthReport.overallScore >= 80) {
        insights.add(ActivityInsight(
          title: 'Excellent Security Score',
          description: 'Your overall security score is ${healthReport.overallScore.toStringAsFixed(1)}%. Great job!',
          type: 'success',
          priority: 2,
          timestamp: now,
          metadata: {'score': healthReport.overallScore},
        ));
      } else if (healthReport.overallScore < 50) {
        insights.add(ActivityInsight(
          title: 'Security Score Needs Improvement',
          description: 'Your security score is ${healthReport.overallScore.toStringAsFixed(1)}%. Consider updating weak passwords.',
          type: 'warning',
          priority: 4,
          timestamp: now,
          metadata: {'score': healthReport.overallScore},
        ));
      }
    }
    
    // Activity pattern insights
    final recentActivity = activityLogs.where(
      (log) => now.difference(log.timestamp).inDays <= 7
    ).length;
    
    if (recentActivity == 0 && passwords.isNotEmpty) {
      insights.add(ActivityInsight(
        title: 'Low Recent Activity',
        description: 'No password activity in the last 7 days. Consider reviewing your passwords.',
        type: 'info',
        priority: 2,
        timestamp: now,
      ));
    }
    
    // Growth insights
    final lastMonth = now.subtract(const Duration(days: 30));
    final newPasswords = passwords.where((p) => p.createdAt.isAfter(lastMonth)).length;
    
    if (newPasswords > 5) {
      insights.add(ActivityInsight(
        title: 'Growing Password Collection',
        description: 'You\'ve added $newPasswords new passwords this month. Great job staying organized!',
        type: 'success',
        priority: 1,
        timestamp: now,
        metadata: {'count': newPasswords},
      ));
    }
    
    // Category distribution insight
    final categories = passwords.map((p) => p.category).toSet();
    if (categories.length == 1 && passwords.length > 5) {
      insights.add(ActivityInsight(
        title: 'Consider Using Categories',
        description: 'All passwords are in one category. Try organizing them into different categories.',
        type: 'info',
        priority: 2,
        timestamp: now,
      ));
    }
    
    // Sort insights by priority (highest first)
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    
    return insights.take(10).toList(); // Limit to top 10 insights
  }

  /// Gets the most active day of the week
  static String _getMostActiveDay(List<PasswordActivityLog> activityLogs) {
    if (activityLogs.isEmpty) return 'No data';
    
    final dayCount = <int, int>{};
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (final log in activityLogs) {
      final weekday = log.timestamp.weekday;
      dayCount[weekday] = (dayCount[weekday] ?? 0) + 1;
    }
    
    if (dayCount.isEmpty) return 'No data';
    
    final mostActiveDay = dayCount.entries.reduce((a, b) => 
      a.value > b.value ? a : b).key;
    
    return dayNames[mostActiveDay - 1];
  }

  /// Calculates security score change over time
  static double _calculateSecurityScoreChange(List<SecurityTrend> trends) {
    if (trends.length < 2) return 0.0;
    
    final recent = trends.length > 7 
        ? trends.skip(trends.length - 7).map((t) => t.securityScore).toList()
        : trends.map((t) => t.securityScore).toList();
    
    final older = trends.take(trends.length - 7).map((t) => t.securityScore).toList();
    
    if (recent.isEmpty || older.isEmpty) return 0.0;
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    return recentAvg - olderAvg;
  }

  /// Gets password strength distribution
  static Map<String, int> getPasswordStrengthDistribution(List<PasswordEntry> passwords) {
    final distribution = <String, int>{
      'Very Weak': 0,
      'Weak': 0,
      'Fair': 0,
      'Good': 0,
      'Strong': 0,
      'Very Strong': 0,
    };
    
    for (final password in passwords) {
      final strength = PasswordHealthService.calculatePasswordStrength(password.password);
      
      if (strength < 20) {
        distribution['Very Weak'] = distribution['Very Weak']! + 1;
      } else if (strength < 40) distribution['Weak'] = distribution['Weak']! + 1;
      else if (strength < 60) distribution['Fair'] = distribution['Fair']! + 1;
      else if (strength < 75) distribution['Good'] = distribution['Good']! + 1;
      else if (strength < 90) distribution['Strong'] = distribution['Strong']! + 1;
      else distribution['Very Strong'] = distribution['Very Strong']! + 1;
    }
    
    return distribution;
  }

  /// Gets activity timeline for charts
  static List<Map<String, dynamic>> getActivityTimeline(
    List<PasswordActivityLog> activityLogs,
    int days,
  ) {
    final timeline = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayActivity = activityLogs.where(
        (log) => log.timestamp.isAfter(dayStart) && log.timestamp.isBefore(dayEnd)
      ).length;
      
      timeline.add({
        'date': dayStart,
        'activity': dayActivity,
        'day': date.day,
        'month': date.month,
      });
    }
    
    return timeline;
  }

  /// Exports analytics data as JSON
  static Map<String, dynamic> exportAnalytics(AnalyticsSummary summary) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'summary': {
        'total_passwords': summary.totalPasswords,
        'total_links': summary.totalLinks,
        'average_password_strength': summary.averagePasswordStrength,
        'most_used_category': summary.mostUsedCategory,
        'most_active_day': summary.mostActiveDay,
        'passwords_created_this_month': summary.passwordsCreatedThisMonth,
        'passwords_updated_this_month': summary.passwordsUpdatedThisMonth,
        'security_score_change': summary.securityScoreChange,
      },
      'category_usage': summary.categoryUsage.map((usage) => {
        'category': usage.category,
        'count': usage.count,
        'percentage': usage.percentage,
        'last_used': usage.lastUsed.toIso8601String(),
      }).toList(),
      'security_trends': summary.securityTrends.map((trend) => {
        'date': trend.date.toIso8601String(),
        'security_score': trend.securityScore,
        'weak_passwords': trend.weakPasswords,
        'strong_passwords': trend.strongPasswords,
        'total_passwords': trend.totalPasswords,
      }).toList(),
      'insights': summary.insights.map((insight) => {
        'title': insight.title,
        'description': insight.description,
        'type': insight.type,
        'priority': insight.priority,
        'timestamp': insight.timestamp.toIso8601String(),
        'metadata': insight.metadata,
      }).toList(),
    };
  }
}
