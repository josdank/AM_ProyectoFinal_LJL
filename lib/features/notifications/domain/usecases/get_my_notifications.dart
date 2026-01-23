import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetMyNotifications implements UseCase<List<AppNotification>, GetMyNotificationsParams> {
  final NotificationRepository repository;
  GetMyNotifications(this.repository);

  @override
  Future<Either<Failure, List<AppNotification>>> call(GetMyNotificationsParams params) {
    return repository.getMyNotifications(userId: params.userId);
  }
}

class GetMyNotificationsParams extends Equatable {
  final String userId;
  const GetMyNotificationsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
