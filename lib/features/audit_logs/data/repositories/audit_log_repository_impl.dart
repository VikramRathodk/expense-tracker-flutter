import '../../../../network/page_response.dart';
import '../../domain/models/audit_log_model.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../datasources/audit_log_remote_datasource.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  const AuditLogRepositoryImpl(this._dataSource);

  final AuditLogRemoteDataSource _dataSource;

  @override
  Future<PageResponse<AuditLogModel>> getLogs({
    required int page,
    int size = 20,
    bool myOnly = false,
  }) =>
      _dataSource.getLogs(page: page, size: size, myOnly: myOnly);
}