import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/tenant_repository.dart';

class TenantCubit extends Cubit<TenantState> {
  final TenantRepository repository;
  final AnalyticsService analyticsService;
  
  TenantCubit({
    required this.repository,
    required this.analyticsService,
  }) : super(TenantInitial());

  Future<void> loadAll({required String tenantId}) async {
    emit(TenantLoading());
    try {
      final favoritesResult = await repository.getFavorites(userId: tenantId);
      final applicationsResult = await repository.getApplications(tenantId: tenantId);
      
      favoritesResult.fold(
        (failure) => emit(TenantError('Error cargando favoritos: ${failure.message}')),
        (favorites) {
          applicationsResult.fold(
            (failure) => emit(TenantError('Error cargando aplicaciones: ${failure.message}')),
            (applications) {
              emit(TenantLoaded(
                favorites: favorites,
                applications: applications,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(TenantError('Error al cargar datos: $e'));
    }
  }

  Future<void> toggleFavorite({
    required String tenantId,
    required Listing listing,
  }) async {
    try {
      final isFavResult = await repository.isFavorite(
        userId: tenantId,
        listingId: listing.id,
      );
      
      isFavResult.fold(
        (failure) => emit(TenantError(failure.message)),
        (isCurrentlyFavorite) async {
          final result = await repository.toggleFavorite(
            userId: tenantId,
            listingId: listing.id,
            isCurrentlyFavorite: isCurrentlyFavorite,
          );
          
          result.fold(
            (failure) => emit(TenantError(failure.message)),
            (_) {
              final eventName = isCurrentlyFavorite ? 'favorite_removed' : 'favorite_added';
              analyticsService.logEvent(eventName, parameters: {
                'listing_id': listing.id,
                'tenant_id': tenantId,
              });
              _reloadData(tenantId);
            },
          );
        },
      );
    } catch (e) {
      emit(TenantError('Error al actualizar favorito: $e'));
    }
  }

  Future<void> applyToListing({
    required String tenantId,
    required Listing listing,
    String? message,
  }) async {
    emit(TenantLoading());
    try {
      final result = await repository.createApplication(
        tenantId: tenantId,
        listingId: listing.id,
        message: message,
      );
      
      result.fold(
        (failure) => emit(TenantError(failure.message)),
        (application) {
          analyticsService.logEvent('application_created', parameters: {
            'application_id': application.id,
            'listing_id': listing.id,
            'tenant_id': tenantId,
          });
          _reloadData(tenantId);
          _notifyLandlord(application, listing);
        },
      );
    } catch (e) {
      emit(TenantError('Error al enviar solicitud: $e'));
    }
  }

  Future<void> cancelApplication(String applicationId) async {
    emit(TenantLoading());
    try {
      final result = await repository.cancelApplication(applicationId: applicationId);
      result.fold(
        (failure) => emit(TenantError(failure.message)),
        (_) {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (userId != null) {
            _reloadData(userId);
          }
        },
      );
    } catch (e) {
      emit(TenantError('Error al cancelar solicitud: $e'));
    }
  }

  void _reloadData(String tenantId) {
    loadAll(tenantId: tenantId);
  }

  void _notifyLandlord(Application application, Listing listing) {
    print('Notificar al arrendador ${listing.ownerId} sobre nueva solicitud');
  }
}

abstract class TenantState {
  const TenantState();
}

class TenantInitial extends TenantState {}

class TenantLoading extends TenantState {}

class TenantLoaded extends TenantState {
  final List<Favorite> favorites;
  final List<Application> applications;

  const TenantLoaded({
    required this.favorites,
    required this.applications,
  });
}

class TenantError extends TenantState {
  final String message;

  const TenantError(this.message);
}