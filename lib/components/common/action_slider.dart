import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ActionSlider extends StatefulWidget {
  final VoidCallback onComplete;
  final String text;

  const ActionSlider({
    super.key,
    required this.onComplete,
    this.text = 'Swipe to complete',
  });

  @override
  State<ActionSlider> createState() => _ActionSliderState();
}

class _ActionSliderState extends State<ActionSlider> {
  double _dragPosition = 0.0;
  bool _isCompleted = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isCompleted) return;
    
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxWidth - 60);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) {
    if (_isCompleted) return;
    
    final threshold = maxWidth * 0.8;
    
    if (_dragPosition >= threshold) {
      setState(() {
        _isCompleted = true;
        _dragPosition = maxWidth - 60;
      });
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onComplete();
      });
    } else {
      setState(() {
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            
            return Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColorScheme.surfaceElevated(theme),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      _isCompleted ? 'Completed!' : widget.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isCompleted
                            ? AppColorScheme.accent(theme, context)
                            : AppColorScheme.textSecondary(theme),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: _isCompleted
                        ? const Duration(milliseconds: 300)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    left: _dragPosition,
                    top: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) =>
                          _onHorizontalDragUpdate(details, maxWidth),
                      onHorizontalDragEnd: (details) =>
                          _onHorizontalDragEnd(details, maxWidth),
                      child: Container(
                        width: 52,
                        decoration: BoxDecoration(
                          color: _isCompleted
                              ? AppColorScheme.accent(theme, context)
                              : AppColorScheme.backgroundPrimary(theme),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isCompleted
                              ? CupertinoIcons.checkmark
                              : CupertinoIcons.chevron_right_2,
                          color: _isCompleted
                              ? AppColorScheme.backgroundPrimary(theme)
                              : AppColorScheme.textSecondary(theme),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
