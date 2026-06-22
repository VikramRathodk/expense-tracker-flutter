import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/notification_model.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get<List<dynamic>>(ApiConstants.notifications);
    return (response.data ?? [])
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.notificationsUnreadCount);
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int id) async {
    await _dio.patch<void>('${ApiConstants.notifications}/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.patch<void>(ApiConstants.notificationsReadAll);
  }
}