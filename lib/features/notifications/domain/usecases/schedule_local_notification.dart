import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class ScheduleLocalNotification implements UseCase<void, ScheduleLocalNotificationParams> {
  final NotificationRepository repository;
  ScheduleLocalNotification(this.repository);

  @override
  Future<Either<Failure, void>> call(ScheduleLocalNotificationParams params) {
    return repository.scheduleLocal(
      id: params.id,
      title: params.title,
      body: params.body,
      dateTime: params.dateTime,
      payload: params.payload,
    );
  }
}

class ScheduleLocalNotificationParams extends Equatable {
  final int id;
  final String title;
  final String body;
  final DateTime dateTime;
  final String? payload;

  const ScheduleLocalNotificationParams({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    this.payload,
  });

  @override
  List<Object?> get props => [id, title, body, dateTime, payload];
}
