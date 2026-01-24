import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class InitNotifications implements UseCase<void, NoParams> {
  final NotificationRepository repository;
  InitNotifications(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.init();
  }
}
