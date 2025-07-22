import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitvote/core/cubits/app_cubit.dart';
import 'package:habitvote/core/utils/app_context_extension.dart';
import 'package:habitvote/features/user/application/cubits/auth_cubit.dart';

class DisabledNotificationAlert extends StatefulWidget {
  const DisabledNotificationAlert({super.key});

  @override
  State<DisabledNotificationAlert> createState() =>
      _DisabledNotificationAlertState();
}

class _DisabledNotificationAlertState extends State<DisabledNotificationAlert>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.appCubit.recheckNotifications();
    }
  }

  bool isBrandNewUser() {
    final user = context.read<AuthCubit>().state.user;
    return user != null && user.accountAge < Duration(hours: 24);
  }

  @override
  Widget build(BuildContext context) {
    if (isBrandNewUser()) {
      return TextButton.icon(
        onPressed: () {
          context.appCubit.enableNotifications();
        },
        label: Text('Please Click To Enable notifications for reminders.'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red.shade900,
          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        icon: Icon(Icons.notifications),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifications Disabled',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You will not receive reminders.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () => {
              context.appCubit.enableNotifications(),
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}
