import 'package:flutter/cupertino.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('More'),
      ),
      child: Center(
        child: Text(
          'More Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}