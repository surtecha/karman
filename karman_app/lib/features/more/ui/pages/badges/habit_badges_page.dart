import 'package:flutter/cupertino.dart';
import 'package:karman_app/core/constants/habit_badge_constants.dart';
import 'package:karman_app/core/services/badges/habit_badge_service.dart';
import 'package:karman_app/features/habits/logic/habit_controller.dart';
import 'package:provider/provider.dart';

class HabitBadgesPage extends StatelessWidget {
  const HabitBadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('Habit Badges'),
      ),
      child: SafeArea(
        child: Consumer<HabitController>(
          builder: (context, habitController, child) {
            return FutureBuilder<Map<String, bool>>(
              future:
                  HabitBadgeService().checkHabitBadges(habitController.habits),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final achievedBadges = snapshot.data ?? {};
                return ListView.builder(
                  itemCount: HabitBadgeConstants.habitBadges.length,
                  itemBuilder: (context, index) {
                    final badge = HabitBadgeConstants.habitBadges[index];
                    final isAchieved = achievedBadges[badge.name] ?? false;
                    return _buildBadgeTile(badge, isAchieved);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadgeTile(HabitBadge badge, bool isAchieved) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            isAchieved ? CupertinoIcons.rosette : CupertinoIcons.lock,
            size: 40,
            color:
                isAchieved ? CupertinoColors.white : CupertinoColors.systemGrey,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isAchieved
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isAchieved
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
