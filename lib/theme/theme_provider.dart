import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color_scheme.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  AppThemeMode _themeMode = AppThemeMode.system;
  String _accentColorName = 'orange';
  bool _isInitialized = false;
  Brightness? _systemBrightness;

  AppThemeMode get themeMode => _themeMode;
  String get accentColorName => _accentColorName;
  bool get isInitialized => _isInitialized;

  bool get isDark {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return _systemBrightness == Brightness.dark;
    }
  }

  CupertinoDynamicColor get accentColor => AppColorScheme.accentColors[_accentColorName] ?? CupertinoColors.systemOrange;

  void updateSystemBrightness(Brightness brightness) {
    if (_systemBrightness != brightness) {
      _systemBrightness = brightness;
      if (_themeMode == AppThemeMode.system) {
        notifyListeners();
      }
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode = AppThemeMode.light;
          break;
        case 'dark':
          _themeMode = AppThemeMode.dark;
          break;
        case 'system':
          _themeMode = AppThemeMode.system;
          break;
      }
    }

    final savedAccent = prefs.getString(_accentColorKey);
    if (savedAccent != null && AppColorScheme.accentColors.containsKey(savedAccent)) {
      _accentColorName = savedAccent;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  Future<void> setAccentColor(String colorName) async {
    if (_accentColorName == colorName || !AppColorScheme.accentColors.containsKey(colorName)) return;

    _accentColorName = colorName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentColorKey, colorName);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = isDark ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }
}