part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;
  final List<String> roles;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.fullName,
    this.roles = const ['user'], // VALOR POR DEFECTO
  });

  @override
  List<Object?> get props => [email, password, fullName, roles];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}