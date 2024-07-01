import 'package:flutter/cupertino.dart';

class ZenPage extends StatelessWidget {
  const ZenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Zen'),
      ),
      child: Center(
        child: Text('Zen Page'),
      ),
    );
  }
}
