import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class PillButton extends StatefulWidget {
  final List<String> options;
  final List<int> counts;
  final Function(int) onSelectionChanged;
  final int initialSelection;

  const PillButton({
    super.key,
    required this.options,
    required this.counts,
    required this.onSelectionChanged,
    this.initialSelection = 0,
  });

  @override
  _PillButtonState createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> with TickerProviderStateMixin {
  late int selectedIndex;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelection;
    _initializeAnimations();
    _controllers[selectedIndex].forward();
  }

  @override
  void didUpdateWidget(PillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.length != widget.options.length) {
      _disposeAnimations();
      _initializeAnimations();
      if (selectedIndex < widget.options.length) {
        _controllers[selectedIndex].forward();
      }
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(widget.options.length, (index) =>
        AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
    );

    _animations = _controllers.map((controller) =>
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    ).toList();
  }

  void _disposeAnimations() {
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.options.length, (index) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildPillButton(
                        index,
                        widget.options[index],
                        index < widget.counts.length ? widget.counts[index] : 0,
                        theme
                    ),
                  ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPillButton(int index, String option, int count, ThemeProvider theme) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (selectedIndex != index) {
          _controllers[selectedIndex].reverse();
          setState(() {
            selectedIndex = index;
          });
          _controllers[selectedIndex].forward();
          widget.onSelectionChanged(index);
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge(_animations),
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColorScheme.accent(theme, context) : AppColorScheme.backgroundSecondary(theme),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option,
                  style: TextStyle(
                    color: isSelected ?
                    (theme.isDark ? CupertinoColors.black : CupertinoColors.white) :
                    AppColorScheme.textPrimary(theme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizeTransition(
                  sizeFactor: _animations[index],
                  axis: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      FadeTransition(
                        opacity: _animations[index],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColorScheme.backgroundPrimary(theme),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColorScheme.accent(theme, context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}