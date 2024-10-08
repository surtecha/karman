import 'package:flutter/cupertino.dart';

class RollingMenu extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onItemSelected;
  final String? currentSound;

  const RollingMenu({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.currentSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: null,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.map((item) {
              final isSelected = item['file'] == currentSound;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: GestureDetector(
                  onTap: () => onItemSelected(item),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item['color']
                          : CupertinoColors.darkBackgroundGray,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'],
                      color: CupertinoColors.white,
                      size: 32,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
