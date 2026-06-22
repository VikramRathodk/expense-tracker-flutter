import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._dataSource);

  final NotificationRemoteDataSource _dataSource;

  @override
  Future<List<NotificationModel>> getNotifications() =>
      _dataSource.getNotifications();

  @override
  Future<int> getUnreadCount() => _dataSource.getUnreadCount();

  @override
  Future<void> markRead(int id) => _dataSource.markRead(id);

  @override
  Future<void> markAllRead() => _dataSource.markAllRead();
}