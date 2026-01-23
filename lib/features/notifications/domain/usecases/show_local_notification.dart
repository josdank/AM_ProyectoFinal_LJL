import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class ShowLocalNotification implements UseCase<void, ShowLocalNotificationParams> {
  final NotificationRepository repository;
  ShowLocalNotification(this.repository);

  @override
  Future<Either<Failure, void>> call(ShowLocalNotificationParams params) {
    return repository.showLocal(id: params.id, title: params.title, body: params.body, payload: params.payload);
  }
}

class ShowLocalNotificationParams extends Equatable {
  final int id;
  final String title;
  final String body;
  final String? payload;

  const ShowLocalNotificationParams({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });

  @override
  List<Object?> get props => [id, title, body, payload];
}
