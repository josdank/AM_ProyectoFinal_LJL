import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ============================================
// ANALYTICS SERVICE IMPORT (AGREGAR ESTO)
// ============================================
import '../../core/analytics/analytics_service.dart';

// ============================================
// TENANT FEATURE IMPORTS
// ============================================
import '../../features/tenant/data/datasources/tenant_datasource.dart';
import '../../features/tenant/data/repositories/tenant_repository_impl.dart';
import '../../features/tenant/domain/repositories/tenant_repository.dart';
import '../../features/tenant/presentation/cubit/tenant_cubit.dart';

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

// VISITS FEATURE
import '../../features/visits/data/datasources/visit_datasource.dart';
import '../../features/visits/data/repositories/visit_repository_impl.dart';
import '../../features/visits/domain/repositories/visit_repository.dart';
import '../../features/visits/domain/usecases/get_visits.dart';
import '../../features/visits/domain/usecases/schedule_visit.dart';
import '../../features/visits/domain/usecases/confirm_visit.dart';
import '../../features/visits/domain/usecases/cancel_visit.dart';
import '../../features/visits/domain/usecases/complete_visit.dart';
import '../../features/visits/presentation/bloc/visit_bloc.dart';


// GEOLOCALIZACIÓN FEATURE 
import '../../features/geolocation/data/datasources/location_datasource.dart';
import '../../features/geolocation/data/repositories/geolocation_repository_impl.dart';
import '../../features/geolocation/domain/repositories/geolocation_repository.dart';
import '../../features/geolocation/domain/usecases/get_current_location.dart';
import '../../features/geolocation/domain/usecases/calculate_distance.dart';
import '../../features/geolocation/domain/usecases/search_nearby_places.dart';
import '../../features/geolocation/presentation/bloc/map_bloc.dart';

import '../../features/security/domain/usecases/add_reference.dart';
import '../../features/security/domain/usecases/get_user_references.dart';
import '../../features/security/domain/usecases/update_reference.dart';
import '../../features/security/domain/usecases/delete_reference.dart';
import '../../features/security/domain/usecases/send_verification_code.dart';
import '../../features/security/domain/usecases/verify_reference.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================
  // EXTERNAL
  // ============================================
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // ============================================
  // ANALYTICS SERVICE (SOLO UNA VEZ)
  // ============================================
  sl.registerLazySingleton<AnalyticsService>(
    () => DebugAnalyticsService(),
  );

  // ============================================
  // CONNECTIONS FEATURE
  // ============================================
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

  // ============================================
  // SECURITY FEATURE
  // ============================================
// ===== Verification & Security (Actividad 5) =====
  sl.registerLazySingleton<SecurityDatasource>(
    () => SecurityDatasourceImpl(client: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<SecurityRepository>(
    () => SecurityRepositoryImpl(datasource: sl<SecurityDatasource>()),
  );
  
  // UseCases de verificación y seguridad
  sl.registerLazySingleton(() => GetVerificationStatus(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => SubmitVerification(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => ReportUser(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => BlockUser(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => GetBlockedUsers(sl<SecurityRepository>()));
  
  // NUEVO: UseCases de referencias
  sl.registerLazySingleton(() => GetUserReferences(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => AddReference(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => UpdateReference(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => DeleteReference(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => SendVerificationCode(sl<SecurityRepository>()));
  sl.registerLazySingleton(() => VerifyReference(sl<SecurityRepository>()));

  sl.registerFactory(
    () => SecurityBloc(
      getVerificationStatus: sl<GetVerificationStatus>(),
      submitVerification: sl<SubmitVerification>(),
      reportUser: sl<ReportUser>(),
      blockUser: sl<BlockUser>(),
      getBlockedUsers: sl<GetBlockedUsers>(),
      // NUEVO: Inyección de use cases de referencias
      getUserReferences: sl<GetUserReferences>(),
      addReference: sl<AddReference>(),
      updateReference: sl<UpdateReference>(),
      deleteReference: sl<DeleteReference>(),
      sendVerificationCode: sl<SendVerificationCode>(),
      verifyReference: sl<VerifyReference>(),
    ),
  );

  // ============================================
  // NOTIFICATIONS FEATURE
  // ============================================
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

  // ============================================
  // AUTH FEATURE
  // ============================================
  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(datasource: sl<AuthDatasource>()),
  );

  sl.registerLazySingleton(() => RegisterUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUser(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));

  sl.registerFactory(
    () => AuthBloc(
      registerUser: sl<RegisterUser>(),
      loginUser: sl<LoginUser>(),
      logoutUser: sl<LogoutUser>(),
      getCurrentUser: sl<GetCurrentUser>(),
      authRepository: sl<AuthRepository>(),
    ),
  );

  // ============================================
  // PROFILE FEATURE
  // ============================================
  sl.registerLazySingleton<ProfileDatasource>(
    () => ProfileDatasourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(datasource: sl<ProfileDatasource>()),
  );

  sl.registerLazySingleton(() => GetProfile(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfile(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UploadProfilePhoto(sl<ProfileRepository>()));

  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl<GetProfile>(),
      updateProfile: sl<UpdateProfile>(),
      uploadProfilePhoto: sl<UploadProfilePhoto>(),
    ),
  );

  // ============================================
  // COMPATIBILITY FEATURE
  // ============================================
  sl.registerLazySingleton<QuestionnaireDatasource>(
    () => QuestionnaireDatasourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<CompatibilityRepository>(
    () => CompatibilityRepositoryImpl(datasource: sl<QuestionnaireDatasource>()),
  );

  sl.registerLazySingleton(() => GetUserHabits(sl<CompatibilityRepository>()));
  sl.registerLazySingleton(() => SaveQuestionnaire(sl<CompatibilityRepository>()));
  sl.registerLazySingleton(() => CalculateCompatibility(sl<CompatibilityRepository>()));

  sl.registerFactory(
    () => CompatibilityBloc(
      getUserHabits: sl<GetUserHabits>(),
      saveQuestionnaire: sl<SaveQuestionnaire>(),
      calculateCompatibility: sl<CalculateCompatibility>(),
    ),
  );

  // ============================================
  // LISTINGS FEATURE
  // ============================================
  sl.registerLazySingleton<ListingDatasource>(
    () => ListingDatasourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<ListingRepository>(
    () => ListingRepositoryImpl(datasource: sl<ListingDatasource>()),
  );

  sl.registerLazySingleton(() => GetListings(sl<ListingRepository>()));
  sl.registerLazySingleton(() => CreateListing(sl<ListingRepository>()));
  sl.registerLazySingleton(() => UpdateListing(sl<ListingRepository>()));
  sl.registerLazySingleton(() => DeleteListing(sl<ListingRepository>()));
  sl.registerLazySingleton(() => SearchListings(sl<ListingRepository>()));

  sl.registerFactory(
    () => ListingBloc(
      getListings: sl<GetListings>(),
      createListing: sl<CreateListing>(),
      updateListing: sl<UpdateListing>(),
      deleteListing: sl<DeleteListing>(),
      searchListings: sl<SearchListings>(),
    ),
  );

  // ============================================
  // CHAT FEATURE
  // ============================================
  sl.registerLazySingleton<ChatDatasource>(
    () => ChatDatasourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(datasource: sl<ChatDatasource>()),
  );

  sl.registerLazySingleton(() => GetChatRooms(sl<ChatRepository>()));
  sl.registerLazySingleton(() => GetMessages(sl<ChatRepository>()));
  sl.registerLazySingleton(() => SendMessage(sl<ChatRepository>()));
  sl.registerLazySingleton(() => ListenToMessages(sl<ChatRepository>()));
  sl.registerLazySingleton(() => MarkAsRead(sl<ChatRepository>()));

  sl.registerFactory(
    () => ChatBloc(
      getChatRooms: sl<GetChatRooms>(),
      getMessages: sl<GetMessages>(),
      sendMessage: sl<SendMessage>(),
      listenToMessages: sl<ListenToMessages>(),
      markAsRead: sl<MarkAsRead>(),
    ),
  );

  // ============================================
  // VISITS FEATURE
  // ============================================
  sl.registerLazySingleton<VisitDatasource>(
    () => VisitDatasourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<VisitRepository>(
    () => VisitRepositoryImpl(datasource: sl<VisitDatasource>()),
  );

  sl.registerLazySingleton(() => GetVisits(sl<VisitRepository>()));
  sl.registerLazySingleton(() => ScheduleVisit(sl<VisitRepository>()));
  sl.registerLazySingleton(() => ConfirmVisit(sl<VisitRepository>()));
  sl.registerLazySingleton(() => CancelVisit(sl<VisitRepository>()));
  sl.registerLazySingleton(() => CompleteVisit(sl<VisitRepository>()));

  sl.registerFactory(
    () => VisitBloc(
      getVisits: sl<GetVisits>(),
      scheduleVisit: sl<ScheduleVisit>(),
      confirmVisit: sl<ConfirmVisit>(),
      cancelVisit: sl<CancelVisit>(),
      completeVisit: sl<CompleteVisit>(),
    ),
  );

  // ============================================
  // TENANT FEATURE (ACTIVIDAD 1)
  // ============================================
  sl.registerLazySingleton<TenantDataSource>(
    () => TenantDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<TenantRepository>(
    () => TenantRepositoryImpl(dataSource: sl<TenantDataSource>()),
  );
  sl.registerFactory<TenantCubit>(
    () => TenantCubit(
      repository: sl<TenantRepository>(),
      analyticsService: sl<AnalyticsService>(),
    ),
  );

    // ============================================
  // GEOLOCATION FEATURE
  // ============================================
  sl.registerLazySingleton<LocationDatasource>(
    () => LocationDatasourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<GeolocationRepository>(
    () => GeolocationRepositoryImpl(datasource: sl<LocationDatasource>()),
  );

  sl.registerLazySingleton(() => GetCurrentLocation(sl<GeolocationRepository>()));
  sl.registerLazySingleton(() => CalculateDistance(sl<GeolocationRepository>()));
  sl.registerLazySingleton(() => SearchNearbyPlaces(sl<GeolocationRepository>()));

  sl.registerFactory(
    () => MapBloc(
      getCurrentLocation: sl<GetCurrentLocation>(),
      searchNearbyPlaces: sl<SearchNearbyPlaces>(),
    ),
  );
}