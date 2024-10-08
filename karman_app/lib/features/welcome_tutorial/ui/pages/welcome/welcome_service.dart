import 'package:shared_preferences/shared_preferences.dart';

class WelcomeService {
  static Future<bool> shouldShowWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_complete') ?? false);
  }
}
