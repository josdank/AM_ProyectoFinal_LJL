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
  }) : super(const TenantState());

  Future<void> loadAll({required String tenantId}) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final favoritesResult = await repository.getFavorites(userId: tenantId);
      final applicationsResult = await repository.getApplications(tenantId: tenantId);
      
      favoritesResult.fold(
        (failure) => emit(state.copyWith(
          isLoading: false,
          error: 'Error cargando favoritos: ${failure.message}',
        )),
        (favorites) {
          applicationsResult.fold(
            (failure) => emit(state.copyWith(
              isLoading: false,
              error: 'Error cargando aplicaciones: ${failure.message}',
            )),
            (applications) {
              emit(state.copyWith(
                isLoading: false,
                favorites: favorites,
                applications: applications,
                error: null,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error al cargar datos: $e',
      ));
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
        (failure) => emit(state.copyWith(error: failure.message)),
        (isCurrentlyFavorite) async {
          final result = await repository.toggleFavorite(
            userId: tenantId,
            listingId: listing.id,
            isCurrentlyFavorite: isCurrentlyFavorite,
          );
          
          result.fold(
            (failure) => emit(state.copyWith(error: failure.message)),
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
      emit(state.copyWith(error: 'Error al actualizar favorito: $e'));
    }
  }

  Future<void> applyToListing({
    required String tenantId,
    required Listing listing,
    String? message,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final result = await repository.createApplication(
        tenantId: tenantId,
        listingId: listing.id,
        message: message,
      );
      
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
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
      emit(state.copyWith(isLoading: false, error: 'Error al enviar solicitud: $e'));
    }
  }

  Future<void> cancelApplication({
    required String tenantId,
    required String applicationId,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final result = await repository.cancelApplication(applicationId: applicationId);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) => _reloadData(tenantId),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Error al cancelar solicitud: $e'));
    }
  }

  void _reloadData(String tenantId) {
    loadAll(tenantId: tenantId);
  }

  void _notifyLandlord(Application application, Listing listing) {
    print('Notificar al arrendador ${listing.ownerId} sobre nueva solicitud');
  }
}

// ===== ESTADO =====
class TenantState {
  final bool isLoading;
  final String? error;
  final List<Favorite> favorites;
  final List<Application> applications;

  const TenantState({
    this.isLoading = false,
    this.error,
    this.favorites = const [],
    this.applications = const [],
  });

  // Getters de conveniencia
  bool get loading => isLoading;
  bool get hasError => error != null;

  TenantState copyWith({
    bool? isLoading,
    String? error,
    List<Favorite>? favorites,
    List<Application>? applications,
  }) {
    return TenantState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      favorites: favorites ?? this.favorites,
      applications: applications ?? this.applications,
    );
  }
}