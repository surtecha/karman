import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'navigation_wrapper.dart';
import 'color_scheme.dart';

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
    return AppColorScheme(
      child: CupertinoApp(
        title: 'karman',
        debugShowCheckedModeBanner: false,
        home: NavigationWrapper(),
      ),
    );
  }
}