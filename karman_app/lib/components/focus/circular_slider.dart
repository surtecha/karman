import 'package:flutter/cupertino.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class CircularSlider extends StatelessWidget {
  final Function(int) onValueChanged;
  final int currentValue;
  final bool isTimerRunning;
  final String timeDisplay;
  final double progress;
  final VoidCallback onPlayPause;

  const CircularSlider({
    super.key,
    required this.onValueChanged,
    required this.currentValue,
    required this.isTimerRunning,
    required this.timeDisplay,
    required this.progress,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SleekCircularSlider(
          appearance: CircularSliderAppearance(
            animDurationMultiplier: 0.8,
            size: 350,
            startAngle: 120,
            angleRange: 300,
            customWidths: CustomSliderWidths(
              trackWidth: 20,
              progressBarWidth: 20,
            ),
            customColors: CustomSliderColors(
              trackColor: CupertinoColors.darkBackgroundGray,
              dynamicGradient: true,
              progressBarColor: CupertinoColors.white,
              shadowColor: CupertinoColors.systemGrey,
              dotColor: CupertinoColors.black,
            ),
            infoProperties: InfoProperties(
              mainLabelStyle: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
              modifier: (double value) {
                return timeDisplay;
              },
            ),
          ),
          min: 1,
          max: 120,
          initialValue: isTimerRunning ? progress : currentValue.toDouble(),
          onChange: isTimerRunning
              ? null
              : (double value) {
                  onValueChanged(value.round());
                },
        ),
        Positioned(
          bottom: -18,
          child: CupertinoButton(
            onPressed: onPlayPause,
            child: Icon(
              isTimerRunning
                  ? CupertinoIcons.stop_circle
                  : CupertinoIcons.play_circle,
              color: CupertinoColors.white,
              size: 48,
            ),
          ),
        ),
      ],
    );
  }
}
