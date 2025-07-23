import 'package:flutter/material.dart';

class SelectableOption extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onSelected;
  final int order;
  const SelectableOption({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onSelected,
    this.order = 1,
  });

  @override
  State<SelectableOption> createState() => _SelectableOptionState();
}

class _SelectableOptionState extends State<SelectableOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    Future.delayed(Duration(milliseconds: 100 * widget.order), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        alignment: Alignment.topCenter,
        scale: _scaleAnimation,
        child: Material(
          color: widget.isSelected ? Color(0xff2D2C2D) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onSelected,
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.isSelected ? Colors.white : Color(0xff2D2C2D),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
