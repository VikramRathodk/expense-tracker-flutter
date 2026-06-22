part of 'notification_cubit.dart';

sealed class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded(this.notifications);
  final List<NotificationModel> notifications;
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
}