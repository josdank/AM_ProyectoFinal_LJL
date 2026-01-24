import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class CreateInAppNotification implements UseCase<AppNotification, CreateInAppNotificationParams> {
  final NotificationRepository repository;
  CreateInAppNotification(this.repository);

  @override
  Future<Either<Failure, AppNotification>> call(CreateInAppNotificationParams params) {
    return repository.createInApp(
      userId: params.userId,
      title: params.title,
      body: params.body,
      type: params.type,
      data: params.data,
    );
  }
}

class CreateInAppNotificationParams extends Equatable {
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;

  const CreateInAppNotificationParams({
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
  });

  @override
  List<Object?> get props => [userId, title, body, type, data];
}
