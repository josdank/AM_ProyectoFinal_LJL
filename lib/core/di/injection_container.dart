import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/connections/data/datasources/connection_datasource.dart';
import '../../features/connections/data/repositories/connection_repository_impl.dart';
import '../../features/connections/domain/repositories/connection_repository.dart';
import '../../features/connections/domain/usecases/accept_interest.dart';
import '../../features/connections/domain/usecases/get_incoming_interests.dart';
import '../../features/connections/domain/usecases/get_matches.dart';
import '../../features/connections/domain/usecases/get_outgoing_interests.dart';
import '../../features/connections/domain/usecases/reject_interest.dart';
import '../../features/connections/domain/usecases/send_interest.dart';
import '../../features/connections/presentation/bloc/connection_bloc.dart';
import '../../features/security/data/datasources/security_datasource.dart';
import '../../features/security/data/repositories/security_repository_impl.dart';
import '../../features/security/domain/repositories/security_repository.dart';
import '../../features/security/domain/usecases/block_user.dart';
import '../../features/security/domain/usecases/get_blocked_users.dart';
import '../../features/security/domain/usecases/get_verification_status.dart';
import '../../features/security/domain/usecases/report_user.dart';
import '../../features/security/domain/usecases/submit_verification.dart';
import '../../features/security/presentation/bloc/security_bloc.dart';
import '../../features/notifications/data/datasources/notification_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/create_in_app_notification.dart';
import '../../features/notifications/domain/usecases/get_my_notifications.dart';
import '../../features/notifications/domain/usecases/init_notifications.dart';
import '../../features/notifications/domain/usecases/mark_notification_read.dart';
import '../../features/notifications/domain/usecases/schedule_local_notification.dart';
import '../../features/notifications/domain/usecases/show_local_notification.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

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
  // ===== Connections (Actividad 2) =====
  sl.registerLazySingleton<ConnectionDatasource>(
    () => ConnectionDatasourceImpl(client: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(datasource: sl<ConnectionDatasource>()),
  );
  sl.registerLazySingleton(() => SendInterest(sl<ConnectionRepository>()));
  sl.registerLazySingleton(() => AcceptInterest(sl<ConnectionRepository>()));
  sl.registerLazySingleton(() => RejectInterest(sl<ConnectionRepository>()));
  sl.registerLazySingleton(() => GetIncomingInterests(sl<ConnectionRepository>()));
  sl.registerLazySingleton(() => GetOutgoingInterests(sl<ConnectionRepository>()));
  sl.registerLazySingleton(() => GetMatches(sl<ConnectionRepository>()));

  sl.registerFactory(
    () => ConnectionBloc(
      sendInterest: sl<SendInterest>(),
      acceptInterest: sl<AcceptInterest>(),
      rejectInterest: sl<RejectInterest>(),
      getIncoming: sl<GetIncomingInterests>(),
      getOutgoing: sl<GetOutgoingInterests>(),
      getMatches: sl<GetMatches>(),
    ),
  );

  // ===== Verification & Security (Actividad 5) =====
  sl.registerLazySingleton<SecurityDatasource>(
    () => SecurityDatasourceImpl(client: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<SecurityRepository>(
    () => SecurityRepositoryImpl(datasource: sl<SecurityDatasource>()),
  );
  sl.registerLazySingleton(() => GetVerificationStatus(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => SubmitVerification(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => ReportUser(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => BlockUser(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => GetBlockedUsers(sl<SecurityRepository>()));

  sl.registerFactory(
    () => SecurityBloc(
      getVerificationStatus: sl<GetVerificationStatus>(),
      submitVerification: sl<SubmitVerification>(),
      reportUser: sl<ReportUser>(),
      blockUser: sl<BlockUser>(),
      getBlockedUsers: sl<GetBlockedUsers>(),
    ),
  );

  // ===== Notifications (Actividad 7) =====
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingleton<NotificationDatasource>(
    () => NotificationDatasourceImpl(
      plugin: sl<FlutterLocalNotificationsPlugin>(),
      client: sl<SupabaseClient>(),
    ),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(datasource: sl<NotificationDatasource>()),
  );
  sl.registerLazySingleton(() => InitNotifications(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => GetMyNotifications(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => MarkNotificationRead(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => ShowLocalNotification(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => ScheduleLocalNotification(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => CreateInAppNotification(sl<NotificationRepository>()));

  sl.registerFactory(
    () => NotificationBloc(
      initNotifications: sl<InitNotifications>(),
      getMyNotifications: sl<GetMyNotifications>(),
      markRead: sl<MarkNotificationRead>(),
      showLocal: sl<ShowLocalNotification>(),
      createInApp: sl<CreateInAppNotification>(),
      repository: sl<NotificationRepository>(),
    ),
  );
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