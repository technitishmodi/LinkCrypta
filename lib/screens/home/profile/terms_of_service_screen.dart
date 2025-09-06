import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Terms of Service',
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
                      Icons.description_rounded,
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
                          'Terms of Service',
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
            
            _buildSectionTitle('Agreement to Terms'),
            _buildParagraph(
              'By accessing or using LinkCrypta, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the service.'
            ),
            
            _buildSectionTitle('Use License'),
            _buildParagraph(
              'Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:'
            ),
            _buildBulletPoint('Modify or copy the materials'),
            _buildBulletPoint('Use the materials for any commercial purpose'),
            _buildBulletPoint('Attempt to decompile or reverse engineer any software contained in LinkCrypta'),
            _buildBulletPoint('Remove any copyright or other proprietary notations from the materials'),
            _buildBulletPoint('Transfer the materials to another person or "mirror" the materials on any other server'),
            
            _buildSectionTitle('Disclaimer'),
            _buildParagraph(
              'The materials on LinkCrypta are provided on an "as is" basis. LinkCrypta makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.'
            ),
            
            _buildSectionTitle('Limitations'),
            _buildParagraph(
              'In no event shall LinkCrypta or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use LinkCrypta, even if LinkCrypta or a LinkCrypta authorized representative has been notified orally or in writing of the possibility of such damage.'
            ),
            
            _buildSectionTitle('Accuracy of Materials'),
            _buildParagraph(
              'The materials appearing in LinkCrypta could include technical, typographical, or photographic errors. LinkCrypta does not warrant that any of the materials on its app are accurate, complete or current. LinkCrypta may make changes to the materials contained on its app at any time without notice.'
            ),
            
            _buildSectionTitle('Links'),
            _buildParagraph(
              'LinkCrypta has not reviewed all of the sites linked to its app and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by LinkCrypta of the site. Use of any such linked website is at the user\'s own risk.'
            ),
            
            _buildSectionTitle('Modifications'),
            _buildParagraph(
              'LinkCrypta may revise these terms of service for its app at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.'
            ),
            
            _buildSectionTitle('Governing Law'),
            _buildParagraph(
              'These terms and conditions are governed by and construed in accordance with the laws and you irrevocably submit to the exclusive jurisdiction of the courts in that location.'
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
  
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xFF212121),
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