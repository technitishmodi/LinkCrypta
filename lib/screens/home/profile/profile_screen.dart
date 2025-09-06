import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../utils/helpers.dart';
import '../../../providers/data_provider.dart';
import 'security_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'about_screen.dart';
import 'password_activity_screen.dart';
import 'password_activity_json_screen.dart';

// Modern Light Blue Color Scheme
class ModernColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FirebaseAuthService.signOut();
      
      if (result.success && mounted) {
        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } else if (mounted) {
        AppHelpers.showSnackBar(
          context,
          result.message,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Error during logout: ${e.toString()}',
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

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: ModernColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out? You\'ll need to sign in again to access your vault.',
          style: TextStyle(
            color: ModernColors.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ModernColors.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.white,
      appBar: AppBar(
        backgroundColor: ModernColors.white,
        elevation: 0,
        title: const Text(
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
                  decoration: const BoxDecoration(
                    color: ModernColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: _currentUser?.photoURL != null
                      ? ClipOval(
                          child: Image.network(
                            _currentUser!.photoURL!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person_rounded,
                              color: ModernColors.white,
                              size: 30,
                            ),
                          ),
                        )
                      : const Icon(
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
                        _currentUser?.displayName ?? 'LinkCrypta User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ModernColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentUser?.email ?? 'Secure Password Manager',
                        style: const TextStyle(
                          fontSize: 14,
                          color: ModernColors.textLight,
                        ),
                      ),
                      if (_currentUser != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Google Account',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Settings Section
          const Text(
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
            icon: Icons.history_rounded,
            title: 'Password Activity',
            subtitle: 'View your password usage history',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PasswordActivityScreen(),
                ),
              );
            },
          ),
          
          _buildSettingsItem(
            context,
            icon: Icons.data_object_rounded,
            title: 'Password Activity JSON',
            subtitle: 'View activity logs in JSON format',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PasswordActivityJsonAuthWrapper(),
                ),
              );
            },
          ),
          
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
          
          if (_currentUser != null)
            _buildSettingsItem(
              context,
              icon: Icons.cloud_upload_rounded,
              title: 'Sync All to Firebase',
              subtitle: 'Upload all passwords and links to cloud',
              onTap: () => _syncAllToFirebase(),
            ),
          
          const SizedBox(height: 24),
          
          // Account Section
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernColors.textDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          if (_currentUser == null)
            _buildSettingsItem(
              context,
              icon: Icons.login_rounded,
              title: 'Sign In',
              subtitle: 'Sign in to sync your data across devices',
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          
          const SizedBox(height: 24),
          
          // About Section
          const Text(
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
            title: 'About LinkCrypta',
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
          const Text(
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
              onPressed: _isLoading ? null : _handleLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : Text(
                      _currentUser != null ? 'Sign Out' : 'Not Signed In',
                      style: const TextStyle(
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
            color: ModernColors.primaryBlue.withValues(alpha: 0.1),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ModernColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: ModernColors.textLight,
          ),
        ),
        trailing: const Icon(
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
        title: const Text(
          'Reset Onboarding',
          style: TextStyle(
            color: ModernColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This will show the onboarding screens again when you restart the app. Are you sure?',
          style: TextStyle(
            color: ModernColors.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
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

  /// Sync all data to Firebase
  Future<void> _syncAllToFirebase() async {
    if (_currentUser == null) {
      AppHelpers.showSnackBar(
        context,
        'Please sign in to sync with Firebase',
        backgroundColor: Colors.orange,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showSyncConfirmationDialog(
      'Sync All to Firebase',
      'This will upload all your passwords and links to Firebase. Continue?',
    );
    if (!confirmed) return;

    try {
      // Show loading indicator
      AppHelpers.showSnackBar(
        context,
        'Syncing all data to Firebase...',
        backgroundColor: Colors.blue,
      );

      final dataProvider = context.read<DataProvider>();
      final success = await dataProvider.syncAllToFirebase();

      if (success) {
        AppHelpers.showSnackBar(
          context,
          'All data synced to Firebase successfully!',
          backgroundColor: Colors.green,
        );
      } else {
        AppHelpers.showSnackBar(
          context,
          'Failed to sync all data to Firebase',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'Sync error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Show sync confirmation dialog
  Future<bool> _showSyncConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: ModernColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: ModernColors.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
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
            child: const Text('Continue'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ) ?? false;
  }
}