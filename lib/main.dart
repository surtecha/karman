import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'navigation_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(karman());
}

class karman extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'karman',
      debugShowCheckedModeBanner: false,
      home: NavigationWrapper(),
    );
  }
}