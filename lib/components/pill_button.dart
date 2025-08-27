import 'package:flutter/cupertino.dart';

class PillButton extends StatefulWidget {
  final List<String> options;
  final List<int> counts;
  final Function(int) onSelectionChanged;

  const PillButton({
    super.key,
    required this.options,
    required this.counts,
    required this.onSelectionChanged,
  });

  @override
  _PillButtonState createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> with TickerProviderStateMixin {
  int selectedIndex = 0;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.options.length, (index) =>
        AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
    );

    _animations = _controllers.map((controller) =>
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    ).toList();

    _controllers[selectedIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.options.length, (index) =>
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildPillButton(index, widget.options[index], widget.counts[index]),
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillButton(int index, String option, int count) {
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
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? CupertinoColors.systemBlue : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? CupertinoColors.white : CupertinoColors.label,
                    fontWeight: FontWeight.w500,
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
                            color: CupertinoColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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