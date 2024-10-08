import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:karman_app/core/components/badges/achievement_overlay.dart';
import 'package:karman_app/core/constants/focus_badge_constants.dart';
import 'package:karman_app/core/services/badges/focus_badge_service.dart';
import 'package:karman_app/features/foucs/logic/focus_controller.dart';

class FocusBadgesPage extends StatefulWidget {
  const FocusBadgesPage({super.key});

  @override
  _FocusBadgesPageState createState() => _FocusBadgesPageState();
}

class _FocusBadgesPageState extends State<FocusBadgesPage> {
  final FocusBadgeService _focusBadgeService = FocusBadgeService();
  Map<String, bool> unlockedBadges = {};
  bool _isInitialLoad = true;
  Timer? _debounce;
  late StreamSubscription _achievementSubscription;

  @override
  void initState() {
    super.initState();
    _initialLoadBadges();
    _listenForAchievements();
  }

  void _listenForAchievements() {
    _achievementSubscription =
        FocusController().achievementStream.listen((achievedBadges) {
      print(
          "FocusBadgesPage: Received new achievements: $achievedBadges"); // Debug print
      for (String badgeName in achievedBadges) {
        _showAchievementOverlay(badgeName);
      }
    });
  }

  void _showAchievementOverlay(String badgeName) {
    print(
        "FocusBadgesPage: Showing achievement overlay for: $badgeName"); // Debug print
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => AchievementOverlay(
        badgeName: badgeName,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _achievementSubscription.cancel();
    super.dispose();
  }

  Future<void> _initialLoadBadges() async {
    final newUnlockedBadges = await _focusBadgeService.checkFocusBadges();
    setState(() {
      unlockedBadges = newUnlockedBadges;
      _isInitialLoad = false;
    });
  }

  Future<void> _refreshBadges() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final newUnlockedBadges = await _focusBadgeService.checkFocusBadges();
      setState(() {
        unlockedBadges = newUnlockedBadges;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text('Focus Badges'),
      ),
      child: SafeArea(
        child: _isInitialLoad
            ? Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: _refreshBadges,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < FocusBadgeConstants.focusBadges.length) {
                          final badge = FocusBadgeConstants.focusBadges[index];
                          final isUnlocked =
                              unlockedBadges[badge.name] ?? false;
                          return _buildBadgeTile(badge, isUnlocked);
                        } else {
                          return SizedBox.shrink(); // No footer
                        }
                      },
                      childCount: FocusBadgeConstants.focusBadges.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBadgeTile(FocusBadge badge, bool isUnlocked) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Container(
        key: ValueKey('${badge.name}_$isUnlocked'),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isUnlocked ? CupertinoIcons.rosette : CupertinoIcons.lock,
              size: 40,
              color: isUnlocked
                  ? CupertinoColors.white
                  : CupertinoColors.systemGrey,
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
                      color: isUnlocked
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    badge.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnlocked
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
