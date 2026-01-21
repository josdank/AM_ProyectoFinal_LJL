// ==========================================
// lib/features/auth/presentation/bloc/auth_bloc.dart
// ==========================================

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final GetCurrentUser getCurrentUser;
  final AuthRepository authRepository;
  
  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.getCurrentUser,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    
    // Escuchar cambios en el estado de autenticación
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authStateSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(const AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verificando sesión...'));
    
    final result = await getCurrentUser(const NoParams());
    
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user: user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creando cuenta...'));
    
    final result = await registerUser(
      RegisterUserParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthRegistrationSuccess(
        email: user.email,
        requiresEmailConfirmation: !user.emailConfirmed,
      )),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Iniciando sesión...'));
    
    final result = await loginUser(
      LoginUserParams(
        email: event.email,
        password: event.password,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Cerrando sesión...'));
    
    final result = await logoutUser(const NoParams());
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}