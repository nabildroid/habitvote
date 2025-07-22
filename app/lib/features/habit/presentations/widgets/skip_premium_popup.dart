import 'package:flutter/material.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';

/// A popup that informs the user about their remaining skips and offers a
/// premium upgrade.
class SkipPremiumPopup extends StatelessWidget {
  final int skipsLeft;

  const SkipPremiumPopup({
    super.key,
    required this.skipsLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = true;
    final theme = Theme.of(context);
    final title = skipsLeft < 1 ? 'No Skips Left' : 'Use a Skip?';
    final content = skipsLeft < 1
        ? 'You have used all your skips for this week. Upgrade to Premium for unlimited skips!'
        : 'You have $skipsLeft skips left for this week.';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              content,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24.0),
            if (!isPremium)
              _GoPremiumButton(onPressed: () => {})
            else if (skipsLeft > 0)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Skip',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
              ),
            const SizedBox(height: 8.0),
            if (isPremium)
              BrilliantOkButton(
                text: "Cancel",
                onPressed: () => {},
              )
            else
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoPremiumButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoPremiumButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Color.lerp(Theme.of(context).primaryColor, Colors.blue, 0.5)!,
              Colors.black,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Center(
            child: Text(
              'Go Premium',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
