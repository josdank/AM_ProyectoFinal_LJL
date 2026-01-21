import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<User, RegisterUserParams> {
  final AuthRepository repository;
  RegisterUser(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterUserParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}

class RegisterUserParams extends Equatable {
  final String email;
  final String password;
  final String? fullName;

  const RegisterUserParams({
    required this.email,
    required this.password,
    this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}