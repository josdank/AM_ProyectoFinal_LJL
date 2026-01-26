import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../geolocation/domain/entities/location_point.dart';
import '../entities/user_property.dart';

abstract class UserPropertyRepository {
  // Obtener propiedades del usuario
  Future<Either<Failure, List<UserProperty>>> getMyProperties(String ownerId);
  
  // Obtener una propiedad específica
  Future<Either<Failure, UserProperty>> getPropertyById(String propertyId);
  
  // Crear propiedad
  Future<Either<Failure, UserProperty>> createProperty(UserProperty property);
  
  // Actualizar propiedad
  Future<Either<Failure, UserProperty>> updateProperty(UserProperty property);
  
  // Eliminar propiedad
  Future<Either<Failure, void>> deleteProperty(String propertyId);
  
  // Buscar propiedades cercanas
  Future<Either<Failure, List<UserProperty>>> searchNearbyProperties({
    required LocationPoint center,
    required double radiusMeters,
    int limit = 50,
  });
  
  // Subir imágenes
  Future<Either<Failure, List<String>>> uploadPropertyImages({
    required String propertyId,
    required String ownerId,
    required List<String> imagePaths,
  });
  
  // Activar/Desactivar propiedad
  Future<Either<Failure, void>> togglePropertyStatus({
    required String propertyId,
    required bool isActive,
  });
}



