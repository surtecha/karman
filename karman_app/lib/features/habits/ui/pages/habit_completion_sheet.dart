import 'package:flutter/cupertino.dart';
import 'package:karman_app/features/habits/data/habit.dart';
import 'package:karman_app/features/habits/logic/habit_controller.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

class HabitCompletionSheet extends StatefulWidget {
  final Habit habit;

  const HabitCompletionSheet({
    super.key,
    required this.habit,
  });

  @override
  _HabitCompletionSheetState createState() => _HabitCompletionSheetState();
}

class _HabitCompletionSheetState extends State<HabitCompletionSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _logController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _logController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeHabit() async {
    final habitController = context.read<HabitController>();
    await habitController.completeHabitForToday(
        widget.habit, _logController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.habit.habitName,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildLogField(),
              SizedBox(height: 20),
              _buildSlideToAct(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log (Optional):',
          style: TextStyle(color: CupertinoColors.white, fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemBackground.darkColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoTextField(
            controller: _logController,
            style: TextStyle(color: CupertinoColors.white),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            placeholder: 'Enter your log here...',
            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.transparent),
            ),
            padding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideToAct() {
    return SlideAction(
      innerColor: CupertinoColors.darkBackgroundGray,
      outerColor: CupertinoColors.tertiarySystemBackground.darkColor,
      sliderButtonIcon: GlowingArrow(animation: _animation),
      sliderRotate: false,
      elevation: 0,
      text: '\t\t\t\t\t\t Swipe to complete',
      textStyle: TextStyle(
        color: CupertinoColors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      submittedIcon: Icon(
        CupertinoIcons.check_mark,
        color: CupertinoColors.white,
        size: 40,
      ),
      animationDuration: Duration(milliseconds: 350),
      onSubmit: _completeHabit,
    );
  }
}

class GlowingArrow extends StatelessWidget {
  final Animation<double> animation;

  const GlowingArrow({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                CupertinoColors.white.withOpacity(0.2),
                CupertinoColors.white,
                CupertinoColors.white.withOpacity(0.2),
              ],
              stops: [
                0.0,
                animation.value,
                animation.value + 0.1,
              ],
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Icon(
            CupertinoIcons.chevron_right_2,
            color: CupertinoColors.white,
            size: 32,
          ),
        );
      },
    );
  }
}
