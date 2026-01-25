import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/application.dart';
import '../entities/favorite.dart';

abstract class TenantRepository {
  // Favoritos
  Future<Either<Failure, List<Favorite>>> getFavorites({required String userId});
  Future<Either<Failure, void>> addFavorite({required String userId, required String listingId});
  Future<Either<Failure, void>> removeFavorite({required String userId, required String listingId});
  Future<Either<Failure, bool>> isFavorite({required String userId, required String listingId});
  
  // Aplicaciones
  Future<Either<Failure, List<Application>>> getApplications({required String tenantId});
  Future<Either<Failure, List<Application>>> getMyApplications({required String tenantId}) {
    return getApplications(tenantId: tenantId);
  }
  
  Future<Either<Failure, Application>> createApplication({
    required String tenantId,
    required String listingId,
    String? message,
  });
  
  Future<Either<Failure, void>> cancelApplication({required String applicationId});
  
  // Método para alternar favorito (toggle)
  Future<Either<Failure, void>> toggleFavorite({
    required String userId,
    required String listingId,
    required bool isCurrentlyFavorite,
  }) async {
    if (isCurrentlyFavorite) {
      return removeFavorite(userId: userId, listingId: listingId);
    } else {
      return addFavorite(userId: userId, listingId: listingId);
    }
  }
}