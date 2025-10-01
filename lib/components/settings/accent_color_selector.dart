import 'package:flutter/cupertino.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:provider/provider.dart';

class AccentColorSelector extends StatefulWidget {
  const AccentColorSelector({super.key});

  @override
  State<AccentColorSelector> createState() => _AccentColorSelectorState();
}

class _AccentColorSelectorState extends State<AccentColorSelector> {
  late FixedExtentScrollController _controller;
  late List<String> _colorNames;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _colorNames = AppColorScheme.accentColors.keys.toList();
    final currentColorName = context.read<ThemeProvider>().accentColorName;
    _selectedIndex = _colorNames.indexOf(currentColorName);
    if (_selectedIndex == -1) _selectedIndex = 0;
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      context.read<ThemeProvider>().setAccentColor(_colorNames[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Text(
                'ACCENT COLOR',
                style: TextStyle(
                  color: AppColorScheme.textSecondary(theme),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColorScheme.backgroundSecondary(theme),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: CupertinoPicker(
                        scrollController: _controller,
                        itemExtent: 100,
                        onSelectedItemChanged: _onSelectedItemChanged,
                        looping: true,
                        diameterRatio: 1.5,
                        children:
                            _colorNames.map((colorName) {
                              final color = AppColorScheme
                                  .accentColors[colorName]!
                                  .resolveFrom(context);
                              return Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _colorNames[_selectedIndex][0].toUpperCase() +
                        _colorNames[_selectedIndex].substring(1),
                    style: TextStyle(
                      color: AppColorScheme.textPrimary(theme),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
