import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class CompletionCircle extends StatefulWidget {
  final int currentStreak;
  final VoidCallback onComplete;
  final bool isCompleting;
  final double completeProgress;

  const CompletionCircle({
    super.key,
    required this.currentStreak,
    required this.onComplete,
    required this.isCompleting,
    required this.completeProgress,
  });

  @override
  State<CompletionCircle> createState() => CompletionCircleState();
}

class CompletionCircleState extends State<CompletionCircle> with TickerProviderStateMixin {
  double _holdProgress = 0.0;
  bool _isHolding = false;
  bool _isSnappingBack = false;
  late AnimationController _snapBackController;
  late AnimationController _pulseController;
  late Animation<double> _snapBackAnimation;

  @override
  void initState() {
    super.initState();
    
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _snapBackAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _snapBackController, curve: Curves.easeOut),
    );

    _snapBackAnimation.addListener(() {
      if (_isSnappingBack && mounted) {
        setState(() {
          _holdProgress = _snapBackAnimation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _snapBackController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void startHold() {
    if (widget.isCompleting) return;
    setState(() {
      _isHolding = true;
      _isSnappingBack = false;
      _snapBackController.stop();
    });
    HapticFeedback.selectionClick();
    _animateProgress();
  }

  void endHold() {
    if (widget.isCompleting) return;
    setState(() => _isHolding = false);

    if (_holdProgress >= 1.0) {
      widget.onComplete();
    } else {
      setState(() => _isSnappingBack = true);
      _snapBackAnimation = Tween<double>(
        begin: _holdProgress,
        end: 0.0,
      ).animate(
        CurvedAnimation(parent: _snapBackController, curve: Curves.easeOut),
      );
      
      _snapBackController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _holdProgress = 0.0;
            _isSnappingBack = false;
          });
        }
      });
    }
  }

  void _animateProgress() async {
    const frameRate = 60;
    const increment = 1.0 / (1.5 * frameRate);

    while (_isHolding && _holdProgress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 1000 ~/ frameRate));
      if (!_isHolding || !mounted) break;
      
      setState(() => _holdProgress = math.min(1.0, _holdProgress + increment));

      if (_holdProgress >= 0.25 && _holdProgress < 0.3 ||
          _holdProgress >= 0.5 && _holdProgress < 0.55 ||
          _holdProgress >= 0.75 && _holdProgress < 0.8) {
        HapticFeedback.selectionClick();
      }

      if (_holdProgress >= 1.0) {
        HapticFeedback.mediumImpact();
        widget.onComplete();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        final accentColor = AppColorScheme.accentColors['pink']!.resolveFrom(context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulseOpacity = _isHolding ? 0.0 : (math.sin(_pulseController.value * 2 * math.pi) + 1) / 2 * 0.15;
                    return CustomPaint(
                      size: const Size(260, 260),
                      painter: CircleProgressPainter(
                        progress: _holdProgress,
                        completeProgress: widget.completeProgress,
                        color: accentColor,
                        backgroundColor: AppColorScheme.surfaceElevated(theme),
                        isCompleting: widget.isCompleting,
                        pulseOpacity: pulseOpacity,
                      ),
                    );
                  },
                ),
                
                AnimatedScale(
                  scale: _isHolding ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: Text(
                          '${widget.currentStreak}',
                          key: ValueKey(widget.currentStreak),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w700,
                            color: AppColorScheme.textPrimary(theme),
                            height: 1,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        widget.currentStreak == 1 ? 'day' : 'days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColorScheme.textSecondary(theme),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final double completeProgress;
  final Color color;
  final Color backgroundColor;
  final bool isCompleting;
  final double pulseOpacity;

  CircleProgressPainter({
    required this.progress,
    required this.completeProgress,
    required this.color,
    required this.backgroundColor,
    required this.isCompleting,
    required this.pulseOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (!isCompleting && pulseOpacity > 0) {
      final pulsePaint = Paint()
        ..color = color.withOpacity(pulseOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15;
      canvas.drawCircle(center, radius, pulsePaint);
    }

    if (progress > 0 || isCompleting) {
      final effectiveProgress = isCompleting ? 1.0 : progress;
      
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.5
        ..strokeCap = StrokeCap.round;

      final progressPath = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * effectiveProgress,
        );

      canvas.drawPath(progressPath, progressPaint);

      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawPath(progressPath, glowPaint);
    }

    if (isCompleting && completeProgress > 0) {
      for (int i = 0; i < 3; i++) {
        final delay = i * 0.15;
        final adjustedProgress = math.max(0.0, math.min(1.0, (completeProgress - delay) / (1 - delay)));
        
        if (adjustedProgress <= 0) continue;
        
        final easeProgress = Curves.easeOut.transform(adjustedProgress);
        final burstRadius = radius + (easeProgress * 50);
        final opacity = (1 - easeProgress) * 0.4;
        
        final burstPaint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(center, burstRadius, burstPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.completeProgress != completeProgress ||
           oldDelegate.isCompleting != isCompleting ||
           oldDelegate.pulseOpacity != pulseOpacity;
  }
}
