import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
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
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Last updated: June 2023',
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
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Introduction'),
            _buildParagraph(
              'LinkCrypta is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our password manager application.'
            ),
            
            _buildSectionTitle('Information We Collect'),
            _buildParagraph(
              'LinkCrypta is designed with privacy in mind. We collect minimal information necessary to provide our services:'
            ),
            _buildBulletPoint('Authentication data for account verification'),
            _buildBulletPoint('App usage analytics (optional and anonymized)'),
            _buildBulletPoint('Device information for troubleshooting'),
            
            _buildSectionTitle('How We Use Your Information'),
            _buildParagraph(
              'We use the collected information for the following purposes:'
            ),
            _buildBulletPoint('To provide and maintain our service'),
            _buildBulletPoint('To notify you about changes to our service'),
            _buildBulletPoint('To provide customer support'),
            _buildBulletPoint('To improve our application'),
            
            _buildSectionTitle('Data Security'),
            _buildParagraph(
              'Your passwords and sensitive data are encrypted using AES-256 encryption and stored locally on your device. We do not have access to your stored passwords or encryption keys.'
            ),
            _buildParagraph(
              'We implement appropriate security measures to protect against unauthorized access, alteration, disclosure, or destruction of your data.'
            ),
            
            _buildSectionTitle('Third-Party Services'),
            _buildParagraph(
              'LinkCrypta may use third-party services for analytics and crash reporting. These services may collect information sent by your device. Third-party services have their own privacy policies addressing how they use such information.'
            ),
            
            _buildSectionTitle('Your Rights'),
            _buildParagraph(
              'You have the right to:'
            ),
            _buildBulletPoint('Access your personal data'),
            _buildBulletPoint('Correct inaccurate data'),
            _buildBulletPoint('Delete your data'),
            _buildBulletPoint('Opt-out of analytics collection'),
            
            _buildSectionTitle('Changes to This Privacy Policy'),
            _buildParagraph(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.'
            ),
            
            _buildSectionTitle('Contact Us'),
            _buildParagraph(
              'If you have any questions about this Privacy Policy, please contact us at:'
            ),
            _buildParagraph(
              'support@LinkCrypta.example.com',
              isBold: true,
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
      ),
    );
  }
  
  Widget _buildParagraph(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: const Color(0xFF212121),
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }
}