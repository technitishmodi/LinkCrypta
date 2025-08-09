import 'package:flutter/material.dart';
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
    // Push PIN setup screen first
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
    // build a layered page with background image + gradient overlay + content
    return Stack(
      fit: StackFit.expand,
      children: [
        // background image
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
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          },
        ),

        // gradient dark overlay
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

        // centered content (upper area)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 70),
              // animated lock icon
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
              // title
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
              // subtitle
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
              // description
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
      // keep body full bleed
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

/// AnimatedLockWidget
/// - Draws a stylized lock using Containers and CustomPaint for the shackle.
/// - Animates a small unlock motion on appear and a shimmer sweep.
class AnimatedLockWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Color accent;

  const AnimatedLockWidget({
    super.key,
    this.size = 100,
    this.color = ModernColors.primary,
    this.accent = ModernColors.secondary,
  });

  @override
  State<AnimatedLockWidget> createState() => _AnimatedLockWidgetState();
}

class _AnimatedLockWidgetState extends State<AnimatedLockWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _unlockController;
  late Animation<double> _shimmerAnim;
  late Animation<double> _unlockAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // shimmer moves from -1 to 1 (used in shader transform)
    _shimmerAnim =
        Tween<double>(begin: -1.2, end: 1.2).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // unlock animation: 0 (locked) -> 1 (slightly open) -> 0
    _unlockAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _unlockController,
      curve: Curves.elasticOut,
    ));

    // play a single unlock/lock motion after build to give life
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _unlockController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      await _unlockController.reverse();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _unlockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final bodyHeight = size * 0.62;
    final shackleHeight = size * 0.38;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_shimmerController, _unlockController]),
        builder: (context, child) {
          final unlockValue = _unlockAnim.value;
          final shimmerOffset = _shimmerAnim.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // lock body with gradient and shimmer overlay
              Transform.translate(
                offset: Offset(0, unlockValue * -2), // small lift during unlock
                child: Container(
                  width: size * 0.86,
                  height: bodyHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.color, widget.accent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // shimmer shader
                      CustomPaint(
                        painter: _ShimmerPainter(shimmerOffset, Colors.white.withOpacity(0.14)),
                      ),
                      // inner keyhole / plate
                      Center(
                        child: Container(
                          width: size * 0.24,
                          height: size * 0.24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.fingerprint,
                              color: Colors.white.withOpacity(0.9),
                              size: size * 0.12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // shackle (drawn via CustomPaint, rotated a bit during unlock)
              Positioned(
                top: 0,
                child: Transform.translate(
                  offset: Offset(0, -shackleHeight * 0.18 * unlockValue),
                  child: Transform.rotate(
                    angle: -0.12 * unlockValue, // slight rotation when unlocking
                    child: CustomPaint(
                      size: Size(size * 0.62, shackleHeight),
                      painter: _ShacklePainter(
                        color: Colors.white.withOpacity(0.95),
                        strokeWidth: size * 0.08,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Paints a smooth shackle (rounded U-shape)
class _ShacklePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ShacklePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final path = Path();
    path.moveTo(w * 0.12, h * 0.9);
    path.arcToPoint(Offset(w * 0.88, h * 0.9),
        radius: Radius.elliptical(w * 0.4, h * 0.9), clockwise: false);
    // vertical stems
    path.moveTo(w * 0.12, h * 0.9);
    path.lineTo(w * 0.12, h * 0.45);
    path.moveTo(w * 0.88, h * 0.9);
    path.lineTo(w * 0.88, h * 0.45);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShacklePainter oldDelegate) => false;
}

/// Simple shimmer painter: draws a diagonal translucent white band based on offset (-1 to 1)
class _ShimmerPainter extends CustomPainter {
  final double position; // -1..1
  final Color color;

  _ShimmerPainter(this.position, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // convert position to actual x
    final double width = size.width;
    final double height = size.height;
    final double centerX = (position + 1) / 2 * (width * 1.6) - (width * 0.3);

    final rect = Rect.fromLTWH(centerX - width * 0.25, 0, width * 0.5, height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.7),
          color.withOpacity(0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..blendMode = BlendMode.lighten;

    canvas.save();
    // rotate slightly for diagonal shimmer
    canvas.translate(0, 0);
    canvas.rotate(-0.35);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.color != color;
  }
}
