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
        _buildPriorityOption(1, Colors.green),
        _buildPriorityOption(2, Colors.yellow),
        _buildPriorityOption(3, Colors.red),
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
                color: isSelected ? color : Colors.white,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.flag_fill,
                color: isSelected ? Colors.black : color,
                size: 20,
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