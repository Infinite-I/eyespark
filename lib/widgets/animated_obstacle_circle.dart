// lib/widgets/animated_obstacle_circle.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedObstacleCircle extends StatefulWidget {
  final int? distance;
  final String? direction;
  final String? urgency;
  final bool isConnected;

  const AnimatedObstacleCircle({
    Key? key,
    this.distance,
    this.direction,
    this.urgency,
    required this.isConnected,
  }) : super(key: key);

  @override
  State<AnimatedObstacleCircle> createState() => _AnimatedObstacleCircleState();
}

class _AnimatedObstacleCircleState extends State<AnimatedObstacleCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  // SUPPRIMER: late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // SUPPRIMER: _scaleAnimation = Tween<double>(begin: 0, end: 1).animate...
  }

  @override
  void didUpdateWidget(AnimatedObstacleCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.distance != oldWidget.distance && widget.distance != null) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  Color _getColor() {
    if (!widget.isConnected) return Colors.grey;
    switch (widget.urgency) {
      case 'high': return AppTheme.dangerRed;
      case 'medium': return AppTheme.warningOrange;
      case 'low': return AppTheme.accentGreen;
      default: return AppTheme.primaryBlue;
    }
  }

  IconData _getDirectionIcon() {
    switch (widget.direction) {
      case 'front': return Icons.arrow_upward;
      case 'left': return Icons.arrow_back;
      case 'right': return Icons.arrow_forward;
      case 'behind': return Icons.arrow_downward;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.distance != null ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getColor().withValues(alpha: 0.3),
                  _getColor().withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
              border: Border.all(
                color: _getColor(),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getColor().withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(
                      begin: 0,
                      end: widget.distance?.toDouble() ?? 0,
                    ),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double value, child) {
                      return Text(
                        value > 0 ? value.toInt().toString() : '---',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  if (widget.distance != null)
                    const Text('cm', style: TextStyle(color: Colors.grey)),

                  if (widget.direction != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDirectionIcon(),
                            color: _getColor(),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.direction!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}