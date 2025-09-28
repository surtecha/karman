import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'navigation_wrapper.dart';
import 'theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(Karman());
}

class Karman extends StatelessWidget {
  const Karman({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initialize(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          if (!themeProvider.isInitialized) {
            return CupertinoApp(
              home: CupertinoPageScaffold(
                child: Center(child: CupertinoActivityIndicator()),
              ),
            );
          }

          return MediaQuery(
            data: MediaQuery.of(context),
            child: Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final brightness = MediaQuery.of(context).platformBrightness;
                  themeProvider.updateSystemBrightness(brightness);
                });

                return CupertinoApp(
                  title: 'karman',
                  debugShowCheckedModeBanner: false,
                  theme: CupertinoThemeData(
                    brightness: themeProvider.isDark ? Brightness.dark : Brightness.light,
                    primaryColor: themeProvider.accentColor,
                  ),
                  home: NavigationWrapper(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}