import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:karman/theme/color_scheme.dart';
import 'package:karman/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ContextMenuItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const ContextMenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });
}

class ContextMenu extends StatefulWidget {
  final Widget child;
  final List<ContextMenuItem> items;
  final Duration? actionDelay;
  final Alignment alignment;

  const ContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.actionDelay = const Duration(milliseconds: 250),
    this.alignment = Alignment.topLeft,
  });

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  bool _isMenuOpen = false;

  void _showMenu(BuildContext context, ThemeProvider theme) {
    setState(() => _isMenuOpen = true);

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;
    final bool isRightAligned = widget.alignment == Alignment.topRight;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: CupertinoColors.black.withOpacity(0.1),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) => GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                left: isRightAligned ? null : buttonPosition.dx + buttonSize.width / 2,
                right: isRightAligned ? overlay.size.width - buttonPosition.dx - buttonSize.width / 2 : null,
                top: buttonPosition.dy + buttonSize.height / 2,
                child: GestureDetector(
                  onTap: () {},
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    ),
                    alignment: isRightAligned ? Alignment.topRight : Alignment.topLeft,
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                        reverseCurve: Curves.easeIn,
                      ),
                      child: Transform.translate(
                        offset: isRightAligned ? const Offset(14, -14) : const Offset(-14, -14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              width: 250,
                              decoration: BoxDecoration(
                                color: AppColorScheme.backgroundSecondary(theme).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColorScheme.textSecondary(theme).withOpacity(0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var i = 0; i < widget.items.length; i++) ...[
                                    if (i > 0) _buildDivider(theme),
                                    _buildMenuItem(
                                      context: context,
                                      theme: theme,
                                      item: widget.items[i],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isMenuOpen = false);
      }
    });
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ThemeProvider theme,
    required ContextMenuItem item,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        Navigator.pop(context);
        if (widget.actionDelay != null) {
          await Future.delayed(widget.actionDelay!);
        }
        item.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 17,
                  color: AppColorScheme.textPrimary(theme),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              item.icon,
              color: item.iconColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeProvider theme) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColorScheme.textSecondary(theme).withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => _showMenu(context, theme),
      child: AnimatedOpacity(
        opacity: _isMenuOpen ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
