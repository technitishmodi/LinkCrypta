import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';

class LogoPreviewScreen extends StatelessWidget {
  const LogoPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkCrypta Logo Preview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'LinkCrypta App Logo Variations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            
            // Main Logo
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Main Logo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    LinkCryptaLogo(size: 120),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Animated Logo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Animated Logo (for Splash)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnimatedLogoDemo(),
                          ),
                        );
                      },
                      child: const Text('View Animated Logo'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Logo without text
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Icon Only', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    LinkCryptaLogo(size: 80, showText: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Compact logo
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Compact Version (for Navigation)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LinkCryptaCompactLogo(size: 24),
                        LinkCryptaCompactLogo(size: 32),
                        LinkCryptaCompactLogo(size: 40),
                        LinkCryptaCompactLogo(size: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Custom colors
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Custom Colors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LinkCryptaLogo(
                          size: 60,
                          showText: false,
                          primaryColor: Colors.green,
                          secondaryColor: Colors.teal,
                        ),
                        LinkCryptaLogo(
                          size: 60,
                          showText: false,
                          primaryColor: Colors.orange,
                          secondaryColor: Colors.red,
                        ),
                        LinkCryptaLogo(
                          size: 60,
                          showText: false,
                          primaryColor: Colors.indigo,
                          secondaryColor: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              'Usage Examples:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• App Icon: Export as PNG/ICO files'),
                  Text('• Splash Screen: Use AnimatedLinkCryptaLogo'),
                  Text('• Navigation: Use LinkCryptaCompactLogo'),
                  Text('• Login Screen: Use main LinkCryptaLogo'),
                  Text('• About Page: Use with custom sizing'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedLogoDemo extends StatelessWidget {
  const AnimatedLogoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: const Center(
        child: AnimatedLinkCryptaLogo(size: 150),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
