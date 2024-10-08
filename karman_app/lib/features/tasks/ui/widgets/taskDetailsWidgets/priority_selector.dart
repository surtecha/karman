import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final int selectedPriority;
  final Function(int) onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPriorityOption(1, CupertinoColors.activeGreen),
        _buildPriorityOption(2, CupertinoColors.systemYellow),
        _buildPriorityOption(3, CupertinoColors.systemRed),
      ],
    );
  }

  Widget _buildPriorityOption(int priority, Color color) {
    bool isSelected = selectedPriority == priority;
    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : CupertinoColors.darkBackgroundGray,
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.flag_circle_fill,
                color: isSelected ? Colors.black : color,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            priority == 1 ? 'Low' : (priority == 2 ? 'Medium' : 'High'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}