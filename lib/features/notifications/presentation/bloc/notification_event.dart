part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationStarted extends NotificationEvent {
  final String userId;
  const NotificationStarted({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class NotificationLoadRequested extends NotificationEvent {
  final String userId;
  const NotificationLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class NotificationMarkReadRequested extends NotificationEvent {
  final String userId;
  final String notificationId;

  const NotificationMarkReadRequested({
    required this.userId,
    required this.notificationId,
  });

  @override
  List<Object?> get props => [userId, notificationId];
}

class _NotificationReceived extends NotificationEvent {
  final AppNotification notification;
  const _NotificationReceived({required this.notification});

  @override
  List<Object?> get props => [notification];
}
