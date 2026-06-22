import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(const NotificationInitial());

  final NotificationRepository _repository;

  Future<void> load() async {
    emit(const NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> markRead(int id) async {
    final current = _current;
    if (current.isEmpty) return;

    // Optimistic update
    final updated = current
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(NotificationLoaded(updated));

    try {
      await _repository.markRead(id);
    } catch (_) {
      emit(NotificationLoaded(current));
    }
  }

  Future<void> markAllRead() async {
    final current = _current;
    if (current.isEmpty) return;

    final updated = current.map((n) => n.copyWith(isRead: true)).toList();
    emit(NotificationLoaded(updated));

    try {
      await _repository.markAllRead();
    } catch (_) {
      emit(NotificationLoaded(current));
    }
  }

  List<NotificationModel> get _current => switch (state) {
        NotificationLoaded(:final notifications) => notifications,
        _ => [],
      };

  int get unreadCount => _current.where((n) => !n.isRead).length;
}