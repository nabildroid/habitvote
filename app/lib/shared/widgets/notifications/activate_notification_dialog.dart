import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/cubits/app_cubit.dart';
import 'package:habitvote/core/locator.dart';
import 'package:habitvote/shared/widgets/brilliant_ok_button.dart';
import 'package:habitvote/services/notification_service.dart';

/// Shows a dialog asking the user to activate notifications.
/// Returns true if “Activate” was tapped.
Future<bool?> showActivateNotificationDialog(BuildContext context) async {
  final theme = Theme.of(context);
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 24),
      title: Column(
        children: [
          Icon(
            Icons.notifications_active,
            size: 48,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Activate Notifications',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• Stay on point—tomorrow’s check-in alert is queued just for you',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '• Never miss a thumbs-up—watch votes roll in as you conquer your goals.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        BrilliantOkButton(
          text: 'Activate',
          onPressed: () async {
            context.read<AppCubit>().enableNotifications();
            Navigator.of(context).pop(true);
          },
        )
      ],
    ),
  );
}
