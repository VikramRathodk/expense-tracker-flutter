import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/audit_log_model.dart';
import '../../domain/repositories/audit_log_repository.dart';

part 'audit_log_state.dart';

class AuditLogCubit extends Cubit<AuditLogState> {
  AuditLogCubit(this._repository) : super(const AuditLogInitial());

  final AuditLogRepository _repository;

  bool _myOnly = false;
  bool _isLoadingMore = false;

  Future<void> load({bool myOnly = false}) async {
    _myOnly = myOnly;
    emit(const AuditLogLoading());
    try {
      final page = await _repository.getLogs(page: 0, myOnly: _myOnly);
      emit(AuditLogLoaded(
        logs: page.content,
        currentPage: page.number,
        hasMore: page.hasNextPage,
        myOnly: _myOnly,
      ));
    } catch (e) {
      emit(AuditLogError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! AuditLogLoaded || !current.hasMore || _isLoadingMore) {
      return;
    }
    _isLoadingMore = true;
    try {
      final page = await _repository.getLogs(
        page: current.currentPage + 1,
        myOnly: _myOnly,
      );
      emit(AuditLogLoaded(
        logs: [...current.logs, ...page.content],
        currentPage: page.number,
        hasMore: page.hasNextPage,
        myOnly: _myOnly,
      ));
    } catch (_) {
      // Keep current state on load-more failure
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> toggleMyOnly() async {
    final newMyOnly = !_myOnly;
    await load(myOnly: newMyOnly);
  }
}