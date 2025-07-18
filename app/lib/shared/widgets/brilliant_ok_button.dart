import 'dart:math';

import 'package:flutter/material.dart';

class BrilliantOkButton extends StatelessWidget {
  final String? tag;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final String text;
  final VoidCallback? onPressed;
  final bool disabled;

  const BrilliantOkButton({
    super.key,
    this.color = const Color(0xff2D2C2D),
    this.textColor = Colors.white,
    this.borderColor = Colors.black,
    this.text = "Continue",
    this.onPressed,
    this.disabled = false,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: IgnorePointer(
          ignoring: disabled,
          child: Hero(
            tag: tag ?? Random().nextDouble().toString(),
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                //only bottom border

                foregroundBuilder: (ctx, state, child) => Padding(
                  padding: EdgeInsets.only(
                      top: state.contains(WidgetState.pressed) ? 3 : 0),
                  child: child,
                ),

                backgroundBuilder: (ctx, state, child) => Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border(
                      bottom: BorderSide(
                        color: borderColor,
                        width: state.contains(WidgetState.pressed) ? 0 : 3,
                      ),
                    ).add(Border.all(
                      color: borderColor,
                      width: 1,
                    )),
                  ),
                  child: child,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
