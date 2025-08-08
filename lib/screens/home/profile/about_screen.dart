import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'About VaultMate',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF212121),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'VaultMate',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build 2023.06.01',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // About Section
            _buildSectionTitle('About'),
            _buildParagraph(
              'VaultMate is a secure password manager designed to help you store and manage your passwords with ease. Our mission is to provide a simple, secure, and user-friendly solution for password management.'
            ),
            
            _buildSectionTitle('Features'),
            _buildFeatureItem('Secure Password Storage', 'AES-256 encryption for all your sensitive data'),
            _buildFeatureItem('Biometric Authentication', 'Quick access using fingerprint or face recognition'),
            _buildFeatureItem('Password Generator', 'Create strong, unique passwords with ease'),
            _buildFeatureItem('Auto-Fill', 'Quickly fill login forms in your browser'),
            _buildFeatureItem('Cross-Platform', 'Access your passwords on all your devices'),
            
            _buildSectionTitle('Security'),
            _buildParagraph(
              'VaultMate uses industry-standard AES-256 encryption to protect your data. Your master password and encryption keys never leave your device, ensuring that only you can access your passwords.'
            ),
            
            _buildSectionTitle('Development Team'),
            _buildParagraph(
              'VaultMate is developed by a team of security experts and software engineers dedicated to creating the most secure and user-friendly password manager available.'
            ),
            
            // Developer Information
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'JD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lead Developer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cybersecurity expert with over 10 years of experience in developing secure applications. Passionate about creating user-friendly solutions that don\'t compromise on security.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSocialIcon(Icons.language, () => _launchUrl('https://johndoe.example.com')),
                            _buildSocialIcon(Icons.email, () => _launchUrl('mailto:john@vaultmate.example.com')),
                            _buildSocialIcon(Icons.link, () => _launchUrl('https://github.com/johndoe')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact and Links
            _buildSectionTitle('Contact & Support'),
            _buildLinkButton(
              context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@vaultmate.example.com',
              onTap: () => _launchUrl('mailto:support@vaultmate.example.com'),
            ),
            
            _buildLinkButton(
              context,
              icon: Icons.language_rounded,
              title: 'Website',
              subtitle: 'www.vaultmate.example.com',
              onTap: () => _launchUrl('https://www.vaultmate.example.com'),
            ),
            
            _buildLinkButton(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              subtitle: 'View tutorials and FAQs',
              onTap: () => _launchUrl('https://www.vaultmate.example.com/help'),
            ),
            
            const SizedBox(height: 24),
            
            // Legal
            _buildSectionTitle('Legal'),
            _buildLinkButton(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {
                Navigator.of(context).pushNamed('/privacy-policy');
              },
            ),
            
            _buildLinkButton(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              onTap: () {
                Navigator.of(context).pushNamed('/terms-of-service');
              },
            ),
            
            const SizedBox(height: 32),
            
            // Copyright
            Center(
              child: Text(
                '© 2023 VaultMate. All rights reserved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
      ),
    );
  }
  
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xFF212121),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF2196F3),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFF5F5F5),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF2196F3).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Color(0xFF2196F3),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF757575),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
  
  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF2196F3).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Color(0xFF2196F3),
          ),
        ),
      ),
    );
  }
}