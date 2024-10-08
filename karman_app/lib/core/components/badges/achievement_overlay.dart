import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class AchievementOverlay extends StatelessWidget {
  final String badgeName;
  final VoidCallback onDismiss;

  const AchievementOverlay({
    super.key,
    required this.badgeName,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badgeName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            SizedBox(height: 20),
            Lottie.asset(
              'lib/assets/lottie/habits.json',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            CupertinoButton(
              onPressed: onDismiss,
              color: CupertinoColors.white,
              child: Text(
                'Great!',
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
