import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> init();

  Future<Either<Failure, void>> showLocal({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  Future<Either<Failure, void>> scheduleLocal({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  });

  Future<Either<Failure, void>> cancelLocal(int id);

  Future<Either<Failure, AppNotification>> createInApp({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  });

  Future<Either<Failure, List<AppNotification>>> getMyNotifications({required String userId});

  Future<Either<Failure, void>> markRead({required String notificationId});

  Stream<AppNotification> streamNewNotifications({required String userId});
}
