import 'package:flutter/cupertino.dart';
import 'package:karman_app/features/more/ui/pages/badges/focus_badges_page.dart';
import 'package:karman_app/features/more/ui/pages/badges/habit_badges_page.dart';
import 'package:karman_app/features/more/ui/pages/details/community_page.dart';
import 'package:karman_app/features/more/ui/pages/details/contribution_page.dart';
import 'package:karman_app/features/more/ui/pages/details/support_page.dart';
import 'package:karman_app/features/more/ui/pages/details/tutorial_selector.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    'Focus',
                    'lib/assets/images/badges/focus_badge.png',
                    () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => FocusBadgesPage(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildActionTile(
                    context,
                    'Habits',
                    'lib/assets/images/badges/habit_badge.png',
                    () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => HabitBadgesPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              'Make karman Better',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            SizedBox(height: 16),
            _buildNavigationTile(
              context,
              'Contribute on GitHub',
              CupertinoIcons.cube_box,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => contributionPage,
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildNavigationTile(
              context,
              'Join the Community',
              CupertinoIcons.group,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => communityPage,
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildNavigationTile(
              context,
              'Support the Project',
              CupertinoIcons.heart,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => supportPage,
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Help',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
            SizedBox(height: 16),
            _buildNavigationTile(
              context,
              'Repeat Tutorial',
              CupertinoIcons.refresh,
              () => showTutorialOptions(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String imagePath,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.darkBackgroundGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: CupertinoColors.white),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
            Spacer(),
            Icon(CupertinoIcons.right_chevron, color: CupertinoColors.white),
          ],
        ),
      ),
    );
  }
}
