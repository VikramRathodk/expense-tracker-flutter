import '../../../../network/page_response.dart';
import '../models/audit_log_model.dart';

abstract class AuditLogRepository {
  Future<PageResponse<AuditLogModel>> getLogs({
    required int page,
    int size = 20,
    bool myOnly = false,
  });
}