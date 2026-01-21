import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth Feature
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================
  // EXTERNAL
  // ============================================
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // ============================================
  // AUTH FEATURE
  // ============================================
  
  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      registerUser: sl(),
      loginUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
      authRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(datasource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasourceImpl(client: sl()),
  );

  // ============================================
  // AQUÍ PUEDES AGREGAR MÁS FEATURES
  // ============================================
  
  // Ejemplo para cuando implementes otros features:
  // _initChatFeature();
  // _initListingsFeature();
  // _initProfileFeature();
}

// Funciones auxiliares para organizar mejor la inyección
// void _initChatFeature() {
//   sl.registerFactory(() => ChatBloc(...));
//   sl.registerLazySingleton(() => SendMessage(sl()));
//   // etc...
// }