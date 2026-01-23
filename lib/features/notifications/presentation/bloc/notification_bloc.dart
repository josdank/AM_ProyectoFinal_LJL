import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/create_in_app_notification.dart';
import '../../domain/usecases/get_my_notifications.dart';
import '../../domain/usecases/init_notifications.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../../domain/usecases/show_local_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/usecases/usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final InitNotifications initNotifications;
  final GetMyNotifications getMyNotifications;
  final MarkNotificationRead markRead;
  final ShowLocalNotification showLocal;
  final CreateInAppNotification createInApp;
  final NotificationRepository repository;

  StreamSubscription<AppNotification>? _sub;

  NotificationBloc({
    required this.initNotifications,
    required this.getMyNotifications,
    required this.markRead,
    required this.showLocal,
    required this.createInApp,
    required this.repository,
  }) : super(const NotificationState()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<_NotificationReceived>(_onReceived);
  }

  Future<void> _onStarted(NotificationStarted event, Emitter<NotificationState> emit) async {
    await initNotifications(NoParams());
    _sub?.cancel();
    _sub = repository.streamNewNotifications(userId: event.userId).listen((n) {
      add(_NotificationReceived(notification: n));
    });
    add(NotificationLoadRequested(userId: event.userId));
  }

  Future<void> _onLoad(NotificationLoadRequested event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final res = await getMyNotifications(GetMyNotificationsParams(userId: event.userId));
    res.fold(
      (l) => emit(state.copyWith(isLoading: false, error: l.message)),
      (list) => emit(state.copyWith(isLoading: false, notifications: list)),
    );
  }

  Future<void> _onMarkRead(NotificationMarkReadRequested event, Emitter<NotificationState> emit) async {
    final res = await markRead(MarkNotificationReadParams(notificationId: event.notificationId));
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => add(NotificationLoadRequested(userId: event.userId)),
    );
  }

  Future<void> _onReceived(_NotificationReceived event, Emitter<NotificationState> emit) async {
    // Notificación local inmediata (simula push)
    await showLocal(
      ShowLocalNotificationParams(
        id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
        title: event.notification.title,
        body: event.notification.body,
        payload: event.notification.type,
      ),
    );

    // refrescar lista
    emit(state.copyWith(notifications: [event.notification, ...state.notifications]));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
