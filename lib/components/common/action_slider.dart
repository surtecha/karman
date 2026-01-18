import 'package:flutter/cupertino.dart';
import 'package:action_slider/action_slider.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ActionSliderWidget extends StatelessWidget {
  final Future<void> Function() onComplete;
  final String text;

  const ActionSliderWidget({
    super.key,
    required this.onComplete,
    this.text = 'Swipe to complete',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return ActionSlider.standard(
          sliderBehavior: SliderBehavior.stretch,
          width: double.infinity,
          backgroundColor: AppColorScheme.surfaceElevated(theme),
          toggleColor: AppColorScheme.backgroundPrimary(theme),
          action: (controller) async {
            controller.loading();
            await onComplete();
            controller.success();
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColorScheme.textSecondary(theme),
            ),
          ),
        );
      },
    );
  }
}