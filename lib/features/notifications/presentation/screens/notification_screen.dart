import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../domain/models/notification_model.dart';
import '../cubit/notification_cubit.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final hasUnread = state is NotificationLoaded &&
                  state.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () =>
                    context.read<NotificationCubit>().markAllRead(),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return switch (state) {
            NotificationLoading() => const ShimmerList(count: 8),
            NotificationInitial() => const ShimmerList(count: 8),
            NotificationError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<NotificationCubit>().load(),
              ),
            NotificationLoaded(:final notifications) =>
              notifications.isEmpty
                  ? _EmptyView()
                  : _NotificationList(notifications: notifications),
          };
        },
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.notifications});

  final List<NotificationModel> notifications;

  @override
  Widget build(BuildContext context) {
    final grouped = _group(notifications);
    return RefreshIndicator(
      onRefresh: () => context.read<NotificationCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final entry = grouped[index];
          if (entry is String) {
            return _DateHeader(label: entry);
          }
          return _NotificationTile(notification: entry as NotificationModel);
        },
      ),
    );
  }

  List<dynamic> _group(List<NotificationModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final result = <dynamic>[];
    String? lastLabel;

    for (final n in items) {
      final dt = DateTime.tryParse(n.createdAt)?.toLocal();
      final label = dt == null
          ? 'Earlier'
          : dt.isAfter(today)
              ? 'Today'
              : dt.isAfter(yesterday)
                  ? 'Yesterday'
                  : 'Earlier';

      if (label != lastLabel) {
        result.add(label);
        lastLabel = label;
      }
      result.add(n);
    }
    return result;
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(notification.createdAt)?.toLocal();
    final timeStr = dt != null ? DateFormat('h:mm a').format(dt) : '';

    return InkWell(
      onTap: notification.isRead
          ? null
          : () =>
              context.read<NotificationCubit>().markRead(notification.id),
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primary.withValues(alpha:0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.iconColor.withValues(alpha:0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(notification.icon,
                  color: notification.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha:0.4),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha:0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3)),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 16,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
            ),
          ),
        ],
      ),
    );
  }
}