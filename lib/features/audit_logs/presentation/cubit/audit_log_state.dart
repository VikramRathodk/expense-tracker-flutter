part of 'audit_log_cubit.dart';

sealed class AuditLogState {
  const AuditLogState();
}

class AuditLogInitial extends AuditLogState {
  const AuditLogInitial();
}

class AuditLogLoading extends AuditLogState {
  const AuditLogLoading();
}

class AuditLogLoaded extends AuditLogState {
  const AuditLogLoaded({
    required this.logs,
    required this.currentPage,
    required this.hasMore,
    required this.myOnly,
  });

  final List<AuditLogModel> logs;
  final int currentPage;
  final bool hasMore;
  final bool myOnly;
}

class AuditLogError extends AuditLogState {
  const AuditLogError(this.message);
  final String message;
}