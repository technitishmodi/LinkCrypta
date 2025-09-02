import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../../widgets/animated_lock_widget.dart';
import 'pin_setup_screen.dart';

class ModernColors {
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF3A0CA3);
  static const Color accent = Color(0xFF7209B7);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

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

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _buttonPulseController;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to LinkCrypta',
      subtitle: 'Secure passwords & links — beautifully simple',
      description:
          'Store, organize, and access your passwords and bookmarks with military-grade encryption and an intuitive interface.',
      icon: Icons.lock_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1639762681057-408e52192e55?q=80&w=2232&auto=format&fit=crop',
      gradientColors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
    ),
    OnboardingPage(
      title: 'Local & Encrypted',
      subtitle: 'Privacy-first by design',
      description:
          'Your data is encrypted locally with AES-256. Choose to backup encrypted copies — we never read your vault.',
      icon: Icons.security_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070&auto=format&fit=crop',
      gradientColors: [Color(0xFF3A0CA3), Color(0xFF7209B7)],
    ),
    OnboardingPage(
      title: 'Fast Access',
      subtitle: 'Copy & Open with one tap',
      description:
          'Generate strong passwords, group entries by category, and quickly open saved links with one tap.',
      icon: Icons.copy_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1581291518633-83b4ebd1d83e?q=80&w=2070&auto=format&fit=crop',
      gradientColors: [Color(0xFF7209B7), Color(0xFF4361EE)],
    ),
    OnboardingPage(
      title: 'Ready to secure',
      subtitle: 'Let\'s set up your vault',
      description:
          'Create a master PIN and optional biometric unlock to get started. Your vault is ready when you are.',
      icon: Icons.check_circle_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=2070&auto=format&fit=crop',
      gradientColors: [Color(0xFF4361EE), Color(0xFF7209B7)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 0.06,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await _navigateToPinSetup();
  }

  Future<void> _navigateToPinSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PinSetupScreen()),
    );

    await OnboardingService.markOnboardingCompleted();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Widget _topSkipButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _completeOnboarding,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _bottomControls() {
    final gradient = _pages[_currentPage].gradientColors;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final bool active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          active ? Colors.white : Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Next button with subtle scale (pulse)
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.02)
                    .animate(_buttonPulseController),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gradient[0],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Get started'
                              : 'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: gradient[0],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check_circle_outline_rounded
                              : Icons.arrow_forward_rounded,
                          color: gradient[0],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          page.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: page.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: page.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.08),
                Colors.black.withOpacity(0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Center(
                child: AnimatedLockWidget(
                  size: 120,
                  color: page.gradientColors[0],
                  accent: page.gradientColors.length > 1
                      ? page.gradientColors[1]
                      : ModernColors.secondary,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.94),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, idx) {
              return _buildPage(_pages[idx]);
            },
          ),
          _topSkipButton(),
          _bottomControls(),
        ],
      ),
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
