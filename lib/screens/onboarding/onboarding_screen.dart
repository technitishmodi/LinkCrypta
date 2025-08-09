import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/onboarding_service.dart';
import 'pin_setup_screen.dart';

class ModernColors {
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF3A0CA3);
  static const Color accent = Color(0xFF7209B7);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Gradient colors
  static const List<Color> gradientColors = [
    Color(0xFF4361EE),
    Color(0xFF3A0CA3),
    Color(0xFF7209B7),
  ];
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to VaultMate',
      subtitle: 'Your secure password manager',
      description: 'Store, organize, and access your passwords with military-grade encryption.',
      icon: Icons.lock_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1639762681057-408e52192e55?q=80&w=2232&auto=format&fit=crop',
      gradientColors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
    ),
    OnboardingPage(
      title: 'Secure Storage',
      subtitle: 'Your data is protected',
      description: 'All your passwords are encrypted using AES-256 encryption and stored locally on your device.',
      icon: Icons.security_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070&auto=format&fit=crop',
      gradientColors: [Color(0xFF3A0CA3), Color(0xFF7209B7)],
    ),
    OnboardingPage(
      title: 'Easy Access',
      subtitle: 'Quick and convenient',
      description: 'Copy passwords with one tap and organize them by categories for easy management.',
      icon: Icons.copy_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1581291518633-83b4ebd1d83e?q=80&w=2070&auto=format&fit=crop',
      gradientColors: [Color(0xFF7209B7), Color(0xFF4361EE)],
    ),
    OnboardingPage(
      title: 'Ready to Start',
      subtitle: 'Let\'s get you set up',
      description: 'Create your first password entry and start managing your digital life securely.',
      icon: Icons.check_circle_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=2070&auto=format&fit=crop',
      gradientColors: [Color(0xFF4361EE), Color(0xFF7209B7)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    // Navigate to PIN setup screen before completing onboarding
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PinSetupScreen(),
      ),
    );
    
    // Mark onboarding as completed and navigate to home screen
    await OnboardingService.markOnboardingCompleted();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.background,
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _buildPage(_pages[index]),
          ),
          
          // Top controls - Skip button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Next/Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _pages[_currentPage].gradientColors[0],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1 
                                  ? 'Get Started' 
                                  : 'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _pages[_currentPage].gradientColors[0],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _pages.length - 1 
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.arrow_forward_rounded,
                              color: _pages[_currentPage].gradientColors[0],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Stack(
      children: [
        // Background image with gradient overlay
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: page.gradientColors,
                stops: const [0.1, 0.9],
              ).createShader(rect);
            },
            blendMode: BlendMode.overlay,
            child: Image.network(
              page.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: page.gradientColors,
                  ),
                ),
                child: Center(
                  child: Icon(
                    page.icon,
                    size: 100,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: page.gradientColors,
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Dark overlay for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        
        // Content overlay
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  page.icon,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                page.subtitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Flexible(
                child: Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 100), // Space for bottom controls
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String imageUrl;
  final List<Color> gradientColors;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.imageUrl,
    this.gradientColors = const [Color(0xFF4361EE), Color(0xFF3A0CA3)],
  });
}