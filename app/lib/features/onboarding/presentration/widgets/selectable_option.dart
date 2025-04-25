import 'package:flutter/material.dart';

class SelectableOption extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onSelected;
  const SelectableOption({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Color(0xff2D2C2D) : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onSelected,
        child: DefaultTextStyle(
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xff2D2C2D),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
