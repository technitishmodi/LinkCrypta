import 'package:flutter/material.dart';

class LinkCryptaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? primaryColor;
  final Color? secondaryColor;

  const LinkCryptaLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primary = primaryColor ?? const Color(0xFF6C63FF);
    final secondary = secondaryColor ?? const Color(0xFF4D8AF0);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, secondary],
              stops: const [0.0, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: size * 0.15,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Encrypted pattern background
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size * 0.25),
                  child: CustomPaint(
                    painter: EncryptedPatternPainter(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              // Main Link Icon
              Center(
                child: Icon(
                  Icons.link,
                  size: size * 0.4,
                  color: Colors.white,
                ),
              ),
              // Security/Lock overlay
              Positioned(
                right: size * 0.08,
                top: size * 0.08,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock,
                    size: size * 0.16,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // App Name
        if (showText) ...[
          SizedBox(height: size * 0.15),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primary, secondary],
            ).createShader(bounds),
            child: Text(
              'LinkCrypta',
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Text(
            'Secure Link Management',
            style: TextStyle(
              fontSize: size * 0.12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class EncryptedPatternPainter extends CustomPainter {
  final Color color;

  EncryptedPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Create encrypted/binary pattern
    final path = Path();
    
    // Draw chain-like pattern representing linked encryption
    for (double x = size.width * 0.2; x < size.width * 0.8; x += size.width * 0.15) {
      for (double y = size.height * 0.2; y < size.height * 0.8; y += size.height * 0.15) {
        // Draw small chain links
        final linkRect = Rect.fromCenter(
          center: Offset(x, y),
          width: size.width * 0.08,
          height: size.height * 0.04,
        );
        path.addOval(linkRect);
        
        // Connect with lines
        if (x < size.width * 0.65) {
          path.moveTo(x + size.width * 0.04, y);
          path.lineTo(x + size.width * 0.11, y);
        }
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated version for splash screens
class AnimatedLinkCryptaLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Duration animationDuration;

  const AnimatedLinkCryptaLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.animationDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<AnimatedLinkCryptaLogo> createState() => _AnimatedLinkCryptaLogoState();
}

class _AnimatedLinkCryptaLogoState extends State<AnimatedLinkCryptaLogo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _lockAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _lockAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.bounceOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              LinkCryptaLogo(
                size: widget.size,
                showText: widget.showText,
              ),
              // Animated lock effect
              Positioned(
                right: widget.size * 0.08,
                top: widget.size * 0.08,
                child: Transform.scale(
                  scale: _lockAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: widget.size * 0.28,
                      height: widget.size * 0.28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(widget.size * 0.06),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock,
                        size: widget.size * 0.16,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Compact logo for navigation bars
class LinkCryptaCompactLogo extends StatelessWidget {
  final double size;

  const LinkCryptaCompactLogo({
    super.key,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF4D8AF0)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.link,
              size: size * 0.5,
              color: Colors.white,
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Icon(
                Icons.lock,
                size: size * 0.22,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
