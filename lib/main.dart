import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'navigation_wrapper.dart';
import 'theme/theme_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/habit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(Karman(themeProvider: themeProvider));
}

class Karman extends StatefulWidget {
  final ThemeProvider themeProvider;

  const Karman({super.key, required this.themeProvider});

  @override
  State<Karman> createState() => _KarmanState();
}

class _KarmanState extends State<Karman> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _updateBrightness();
  }

  void _updateBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    widget.themeProvider.updateSystemBrightness(brightness);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return CupertinoApp(
            title: 'karman',
            debugShowCheckedModeBanner: false,
            theme: CupertinoThemeData(
              brightness: theme.isDark ? Brightness.dark : Brightness.light,
              primaryColor: theme.accentColor,
            ),
            home: NavigationWrapper(),
          );
        },
      ),
    );
  }
}
