import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/models/audit_log_model.dart';
import '../cubit/audit_log_cubit.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AuditLogCubit>().load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AuditLogCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated &&
        (authState.user.isAdmin || authState.user.isSuperAdmin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          if (isAdmin)
            BlocBuilder<AuditLogCubit, AuditLogState>(
              builder: (context, state) {
                final myOnly =
                    state is AuditLogLoaded ? state.myOnly : false;
                return TextButton.icon(
                  onPressed: () =>
                      context.read<AuditLogCubit>().toggleMyOnly(),
                  icon: Icon(
                    myOnly ? Icons.person : Icons.people_outline,
                    size: 18,
                  ),
                  label: Text(myOnly ? 'Mine' : 'All'),
                );
              },
            ),
        ],
      ),
      body: BlocBuilder<AuditLogCubit, AuditLogState>(
        builder: (context, state) {
          return switch (state) {
            AuditLogLoading() => const ShimmerList(count: 10),
            AuditLogInitial() => const ShimmerList(count: 10),
            AuditLogError(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<AuditLogCubit>().load(),
              ),
            AuditLogLoaded(:final logs, :final hasMore) => logs.isEmpty
                ? _EmptyView()
                : _LogList(
                    logs: logs,
                    hasMore: hasMore,
                    scrollController: _scrollController,
                  ),
          };
        },
      ),
    );
  }
}

class _LogList extends StatelessWidget {
  const _LogList({
    required this.logs,
    required this.hasMore,
    required this.scrollController,
  });

  final List<AuditLogModel> logs;
  final bool hasMore;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: logs.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == logs.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return _AuditLogCard(log: logs[index]);
      },
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  const _AuditLogCard({required this.log});

  final AuditLogModel log;

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(log.createdAt)?.toLocal();
    final dateStr = dt != null
        ? DateFormat('dd MMM yyyy, h:mm a').format(dt)
        : log.createdAt;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: log.actionColor.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(log.actionIcon, color: log.actionColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ActionBadge(
                          label: log.actionLabel, color: log.actionColor),
                      const SizedBox(width: 8),
                      if (log.entityType.isNotEmpty)
                        Text(
                          log.entityType.toLowerCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha:0.5),
                          ),
                        ),
                    ],
                  ),
                  if (log.performedBy != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      log.performedBy!,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (log.details != null && log.details!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      log.details!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha:0.4),
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

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
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
          Icon(Icons.history_outlined,
              size: 64,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3)),
          const SizedBox(height: 16),
          Text(
            'No activity logs',
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