import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            size: 400,
            startAngle: 120,
            angleRange: 300,
            customWidths: CustomSliderWidths(
              trackWidth: 40,
              progressBarWidth: 40,
              shadowWidth: 0,
              handlerSize: 10,
            ),
            customColors: CustomSliderColors(
              trackColor: Colors.grey[900]!,
              dynamicGradient: true,
              progressBarColor: CupertinoColors.white,
              dotColor: CupertinoColors.black,
            ),
            infoProperties: InfoProperties(
              mainLabelStyle: TextStyle(
                fontSize: 65,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
                letterSpacing: 1.5,
              ),
              modifier: (double value) {
                return timeDisplay;
              },
            ),
          ),
          min: 1,
          max: 60,
          initialValue: isTimerRunning
              ? (progress * 59 + 1)
              : currentValue.toDouble().clamp(1, 60),
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
              size: 64,
            ),
          ),
        ),
      ],
    );
  }
}
