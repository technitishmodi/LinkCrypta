import 'package:flutter/material.dart';
import '../../../services/onboarding_service.dart';
import 'security_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'about_screen.dart';

// Modern Light Blue Color Scheme
class ModernColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.white,
      appBar: AppBar(
        backgroundColor: ModernColors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: ModernColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ModernColors.lightBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ModernColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: ModernColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VaultMate User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Secure Password Manager',
                        style: TextStyle(
                          fontSize: 14,
                          color: ModernColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Settings Section
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Settings Items
          _buildSettingsItem(
            context,
            icon: Icons.security_rounded,
            title: 'Security',
            subtitle: 'Manage encryption settings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SecuritySettingsScreen(),
                ),
              );
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.backup_rounded,
            title: 'Backup & Restore',
            subtitle: 'Export and import your data',
            onTap: () {
              // TODO: Navigate to backup settings
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Manage app notifications',
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.palette_rounded,
            title: 'Appearance',
            subtitle: 'Customize app theme',
            onTap: () {
              Navigator.of(context).pushNamed('/appearance');
            },
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsItem(
            context,
            icon: Icons.info_rounded,
            title: 'About VaultMate',
            subtitle: 'Version 1.0.0',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Developer Section
          Text(
            'Developer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildSettingsItem(
            context,
            icon: Icons.refresh_rounded,
            title: 'Reset Onboarding',
            subtitle: 'Show onboarding screens again',
            onTap: () async {
              final confirmed = await _showResetOnboardingDialog(context);
              if (confirmed) {
                await OnboardingService.resetOnboarding();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/onboarding');
                }
              }
            },
          ),
          
          const SizedBox(height: 32),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement logout
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ModernColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.lightGrey,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ModernColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: ModernColors.primaryBlue,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ModernColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: ModernColors.textLight,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: ModernColors.textLight,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Future<bool> _showResetOnboardingDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Onboarding',
          style: TextStyle(
            color: ModernColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will show the onboarding screens again when you restart the app. Are you sure?',
          style: TextStyle(
            color: ModernColors.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: ModernColors.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.primaryBlue,
              foregroundColor: ModernColors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    ) ?? false;
  }
}