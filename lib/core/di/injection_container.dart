import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================
// AUTH FEATURE
// ============================================
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// ============================================
// PROFILE FEATURE
// ============================================
import '../../features/profile/data/datasources/profile_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/domain/usecases/upload_profile_photo.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

// ============================================
// COMPATIBILITY FEATURE
// ============================================
import '../../features/compatibility/data/datasources/questionnaire_datasource.dart';
import '../../features/compatibility/data/repositories/compatibility_repository_impl.dart';
import '../../features/compatibility/domain/repositories/compatibility_repository.dart';
import '../../features/compatibility/domain/usecases/calculate_compatibility.dart';
import '../../features/compatibility/domain/usecases/get_user_habits.dart';
import '../../features/compatibility/domain/usecases/save_questionnaire.dart';
import '../../features/compatibility/presentation/bloc/compatibility_bloc.dart';

// ============================================
// LISTINGS FEATURE
// ============================================
import '../../features/listings/data/datasources/listing_datasource.dart';
import '../../features/listings/data/repositories/listing_repository_impl.dart';
import '../../features/listings/domain/repositories/listing_repository.dart';
import '../../features/listings/domain/usecases/create_listing.dart';
import '../../features/listings/domain/usecases/delete_listing.dart';
import '../../features/listings/domain/usecases/get_listings.dart';
import '../../features/listings/domain/usecases/search_listings.dart';
import '../../features/listings/domain/usecases/update_listing.dart';
import '../../features/listings/presentation/bloc/listing_bloc.dart';

// ============================================
// AGREGAR ESTOS IMPORTS AL ARCHIVO EXISTENTE
// ============================================

// CHAT FEATURE
import '../../features/chat/data/datasources/chat_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_chat_rooms.dart';
import '../../features/chat/domain/usecases/get_messages.dart';
import '../../features/chat/domain/usecases/send_message.dart';
import '../../features/chat/domain/usecases/listen_to_messages.dart';
import '../../features/chat/domain/usecases/mark_as_read.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

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
  sl.registerFactory(
    () => AuthBloc(
      registerUser: sl(),
      loginUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasourceImpl(client: sl()),
  );

  // ============================================
  // PROFILE FEATURE
  // ============================================
  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(),
      updateProfile: sl(),
      uploadProfilePhoto: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => UploadProfilePhoto(sl()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<ProfileDatasource>(
    () => ProfileDatasourceImpl(client: sl()),
  );

  // ============================================
  // COMPATIBILITY FEATURE
  // ============================================
  sl.registerFactory(
    () => CompatibilityBloc(
      getUserHabits: sl(),
      saveQuestionnaire: sl(),
      calculateCompatibility: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUserHabits(sl()));
  sl.registerLazySingleton(() => SaveQuestionnaire(sl()));
  sl.registerLazySingleton(() => CalculateCompatibility(sl()));

  sl.registerLazySingleton<CompatibilityRepository>(
    () => CompatibilityRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<QuestionnaireDatasource>(
    () => QuestionnaireDatasourceImpl(client: sl()),
  );

  // ============================================
  // LISTINGS FEATURE
  // ============================================
  sl.registerFactory(
    () => ListingBloc(
      getListings: sl(),
      createListing: sl(),
      updateListing: sl(),
      deleteListing: sl(),
      searchListings: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetListings(sl()));
  sl.registerLazySingleton(() => CreateListing(sl()));
  sl.registerLazySingleton(() => UpdateListing(sl()));
  sl.registerLazySingleton(() => DeleteListing(sl()));
  sl.registerLazySingleton(() => SearchListings(sl()));

  sl.registerLazySingleton<ListingRepository>(
    () => ListingRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<ListingDatasource>(
    () => ListingDatasourceImpl(client: sl()),
  );

  // ============================================
  // CHAT FEATURE
  // ============================================
  sl.registerFactory(
    () => ChatBloc(
      getChatRooms: sl(),
      getMessages: sl(),
      sendMessage: sl(),
      listenToMessages: sl(),
      markAsRead: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetChatRooms(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => ListenToMessages(sl()));
  sl.registerLazySingleton(() => MarkAsRead(sl()));

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<ChatDatasource>(
    () => ChatDatasourceImpl(client: sl()),
  );
}
