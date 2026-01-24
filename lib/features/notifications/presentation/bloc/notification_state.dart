part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<AppNotification> notifications;

  const NotificationState({
    this.isLoading = false,
    this.error,
    this.notifications = const [],
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    bool? isLoading,
    String? error,
    List<AppNotification>? notifications,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, notifications];
}
