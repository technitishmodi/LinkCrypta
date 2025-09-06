import 'package:flutter/material.dart';

/// A custom animated lock widget that displays a stylized lock icon with animations.
/// Used in the onboarding screens to provide visual appeal.
class AnimatedLockWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Color accent;

  const AnimatedLockWidget({
    super.key,
    required this.size,
    required this.color,
    required this.accent,
  });

  @override
  State<AnimatedLockWidget> createState() => _AnimatedLockWidgetState();
}

class _AnimatedLockWidgetState extends State<AnimatedLockWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lockBodyAnimation;
  late Animation<double> _lockShackleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _lockBodyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _lockShackleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              if (_glowAnimation.value > 0)
                Container(
                  width: widget.size * 1.2,
                  height: widget.size * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3 * _glowAnimation.value),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 5 * _glowAnimation.value,
                      ),
                    ],
                  ),
                ),
              
              // Lock body
              Transform.scale(
                scale: _lockBodyAnimation.value,
                child: Container(
                  width: widget.size * 0.8,
                  height: widget.size * 0.65,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(widget.size * 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: widget.size * 0.25,
                      height: widget.size * 0.25,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: widget.size * 0.12,
                          height: widget.size * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(widget.size * 0.05),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Lock shackle
              Positioned(
                top: widget.size * 0.05,
                child: Transform.scale(
                  scale: _lockShackleAnimation.value,
                  child: Container(
                    width: widget.size * 0.5,
                    height: widget.size * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        top: BorderSide(width: widget.size * 0.08, color: widget.accent),
                        left: BorderSide(width: widget.size * 0.08, color: widget.accent),
                        right: BorderSide(width: widget.size * 0.08, color: widget.accent),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(widget.size * 0.25),
                        topRight: Radius.circular(widget.size * 0.25),
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