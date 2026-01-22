// lib/core/di/injection_container.dart
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

// Profile Feature
import '../../features/profile/data/datasources/profile_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/domain/usecases/upload_profile_photo.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// Compatibility Feature
import '../../features/compatibility/data/datasources/questionnaire_datasource.dart';
import '../../features/compatibility/data/repositories/compatibility_repository_impl.dart';
import '../../features/compatibility/domain/repositories/compatibility_repository.dart';
import '../../features/compatibility/domain/usecases/calculate_compatibility.dart';
import '../../features/compatibility/domain/usecases/get_user_habits.dart';
import '../../features/compatibility/domain/usecases/save_questionnaire.dart';
import '../../features/compatibility/presentation/bloc/compatibility_bloc.dart';

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
  // PROFILE FEATURE
  // ============================================
  
  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(),
      updateProfile: sl(),
      uploadProfilePhoto: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => UploadProfilePhoto(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(datasource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ProfileDatasource>(
    () => ProfileDatasourceImpl(client: sl()),
  );

  // ============================================
  // COMPATIBILITY FEATURE
  // ============================================
  
  // BLoC
  sl.registerFactory(
    () => CompatibilityBloc(
      getUserHabits: sl(),
      saveQuestionnaire: sl(),
      calculateCompatibility: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetUserHabits(sl()));
  sl.registerLazySingleton(() => SaveQuestionnaire(sl()));
  sl.registerLazySingleton(() => CalculateCompatibility(sl()));

  // Repository
  sl.registerLazySingleton<CompatibilityRepository>(
    () => CompatibilityRepositoryImpl(datasource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<QuestionnaireDatasource>(
    () => QuestionnaireDatasourceImpl(client: sl()),
  );
}