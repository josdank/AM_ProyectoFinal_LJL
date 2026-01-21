import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Clase base para todos los casos de uso
/// Type: tipo de dato que retorna el caso de uso
/// Params: parámetros que recibe el caso de uso
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Clase para casos de uso que no requieren parámetros
class NoParams extends Equatable {
  const NoParams();
  
  @override
  List<Object?> get props => [];
}