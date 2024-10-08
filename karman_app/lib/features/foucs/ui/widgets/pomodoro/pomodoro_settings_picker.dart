import 'package:flutter/cupertino.dart';
import 'package:karman_app/features/foucs/logic/pomodoro_controller.dart';

class PomodoroSettingsPicker extends StatelessWidget {
  final PomodoroController controller;

  const PomodoroSettingsPicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSettingPicker(
          'Focus',
          controller.focusDurations,
          controller.focusDuration,
          (value) => controller.setFocusDuration(value),
        ),
        _buildSettingPicker(
          'Break',
          controller.breakDurations,
          controller.breakDuration,
          (value) => controller.setBreakDuration(value),
        ),
        _buildSettingPicker(
          'Sessions',
          controller.sessionOptions,
          controller.totalSessions,
          (value) => controller.setTotalSessions(value),
        ),
      ],
    );
  }

  Widget _buildSettingPicker(String title, List<int> options, int currentValue,
      Function(int) onChanged) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: CupertinoColors.white)),
        SizedBox(height: 10),
        SizedBox(
          height: 100,
          width: 70,
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
                initialItem: options.indexOf(currentValue)),
            onSelectedItemChanged: (index) => onChanged(options[index]),
            children: options
                .map((value) => Center(
                      child: Text('$value',
                          style: TextStyle(color: CupertinoColors.white)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
