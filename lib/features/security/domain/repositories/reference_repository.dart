import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reference.dart';

abstract class ReferenceRepository {
  /// Obtener todas las referencias del usuario
  Future<Either<Failure, List<Reference>>> getMyReferences(String userId);

  /// Crear una nueva referencia
  Future<Either<Failure, Reference>> createReference(Reference reference);

  /// Actualizar una referencia existente
  Future<Either<Failure, Reference>> updateReference(Reference reference);

  /// Eliminar una referencia
  Future<Either<Failure, void>> deleteReference(String referenceId);

  /// Enviar código de verificación al referee
  Future<Either<Failure, String>> sendVerificationCode({
    required String referenceId,
    required String refereeEmail,
  });

  /// Verificar código de verificación
  Future<Either<Failure, Reference>> verifyReference({
    required String referenceId,
    required String verificationCode,
  });
}