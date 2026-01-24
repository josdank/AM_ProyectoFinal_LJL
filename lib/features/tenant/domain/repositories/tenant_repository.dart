import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/application.dart';
import '../entities/favorite.dart';

abstract class TenantRepository {
  Future<Either<Failure, void>> toggleFavorite({
    required String userId,
    required String listingId,
  });

  Future<Either<Failure, List<Favorite>>> getFavorites({
    required String userId,
  });

  Future<Either<Failure, Application>> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  });

  Future<Either<Failure, List<Application>>> getMyApplications({
    required String tenantId,
  });

  Future<Either<Failure, void>> cancelApplication({required String applicationId});
}
