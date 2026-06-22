import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../network/page_response.dart';
import '../../domain/models/audit_log_model.dart';

class AuditLogRemoteDataSource {
  const AuditLogRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PageResponse<AuditLogModel>> getLogs({
    required int page,
    int size = 20,
    bool myOnly = false,
  }) async {
    final endpoint = myOnly ? ApiConstants.auditLogsMe : ApiConstants.auditLogs;
    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data!,
      (item) => AuditLogModel.fromJson(item as Map<String, dynamic>),
    );
  }
}