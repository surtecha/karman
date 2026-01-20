import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:karman/components/habits/completion_circle.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class HabitCompletionOverlay extends StatefulWidget {
  final Habit habit;

  const HabitCompletionOverlay({
    super.key,
    required this.habit,
  });

  @override
  State<HabitCompletionOverlay> createState() => _HabitCompletionOverlayState();
}

class _HabitCompletionOverlayState extends State<HabitCompletionOverlay> with TickerProviderStateMixin {
  late AnimationController _enterController;
  late AnimationController _completeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isCompleting = false;
  int _displayStreak = 0;
  final GlobalKey<CompletionCircleState> _circleKey = GlobalKey<CompletionCircleState>();

  @override
  void initState() {
    super.initState();
    _displayStreak = widget.habit.currentStreak;
    
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _completeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOut),
    );

    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  String _getStreakMessage() {
    final streak = widget.habit.currentStreak;
    if (streak == 0) return 'Tap and hold start your journey';
    if (streak < 7) return 'Building momentum';
    if (streak < 30) return 'Strong consistency';
    if (streak < 100) return 'Incredible dedication';
    return 'Legendary streak';
  }

  Future<void> _handleComplete() async {
    if (_isCompleting) return;
    
    setState(() => _isCompleting = true);
    HapticFeedback.mediumImpact();
    
    await _completeController.forward();
    
    if (!mounted) return;
    
    setState(() => _displayStreak = widget.habit.currentStreak + 1);
    
    await context.read<HabitProvider>().completeHabit(widget.habit.id!);
    
    if (!mounted) return;
    
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) Navigator.of(context).pop();
  }

  void _startHold() {
    _circleKey.currentState?.startHold();
  }

  void _endHold() {
    _circleKey.currentState?.endHold();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return AnimatedBuilder(
          animation: Listenable.merge([_enterController, _completeController]),
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColorScheme.backgroundPrimary(theme),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColorScheme.surfaceElevated(theme),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.habit.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColorScheme.textPrimary(theme),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      CompletionCircle(
                        key: _circleKey,
                        currentStreak: _displayStreak,
                        onComplete: _handleComplete,
                        isCompleting: _isCompleting,
                        completeProgress: _completeController.value,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      GestureDetector(
                        onTapDown: (_) => _startHold(),
                        onTapUp: (_) => _endHold(),
                        onTapCancel: _endHold,
                        child: Container(
                          height: 48,
                          color: CupertinoColors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            _getStreakMessage(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColorScheme.textSecondary(theme),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
