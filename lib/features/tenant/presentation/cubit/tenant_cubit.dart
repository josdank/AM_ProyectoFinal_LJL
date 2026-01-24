import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../listings/domain/entities/listing.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/tenant_repository.dart';

class TenantState {
  final bool loading;
  final String? error;
  final List<Favorite> favorites;
  final List<Application> applications;

  const TenantState({
    required this.loading,
    required this.favorites,
    required this.applications,
    this.error,
  });

  factory TenantState.initial() => const TenantState(
        loading: false,
        favorites: [],
        applications: [],
      );

  TenantState copyWith({
    bool? loading,
    String? error,
    List<Favorite>? favorites,
    List<Application>? applications,
  }) {
    return TenantState(
      loading: loading ?? this.loading,
      error: error,
      favorites: favorites ?? this.favorites,
      applications: applications ?? this.applications,
    );
  }
}

class TenantCubit extends Cubit<TenantState> {
  final TenantRepository repository;

  TenantCubit(this.repository) : super(TenantState.initial());

  Future<void> loadAll({required String tenantId}) async {
    emit(state.copyWith(loading: true, error: null));

    final favRes = await repository.getFavorites(userId: tenantId);
    final appRes = await repository.getMyApplications(tenantId: tenantId);

    final err = <String>[];

    final favs = favRes.fold((l) {
      err.add(l.message);
      return <Favorite>[];
    }, (r) => r);

    final apps = appRes.fold((l) {
      err.add(l.message);
      return <Application>[];
    }, (r) => r);

    emit(state.copyWith(
      loading: false,
      favorites: favs,
      applications: apps,
      error: err.isEmpty ? null : err.join('\n'),
    ));
  }

  Future<void> toggleFavorite({
    required String tenantId,
    required Listing listing,
  }) async {
    final res = await repository.toggleFavorite(userId: tenantId, listingId: listing.id);
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => loadAll(tenantId: tenantId),
    );
  }

  Future<void> applyToListing({
    required String tenantId,
    required Listing listing,
    String? message,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    final res = await repository.createApplication(tenantId: tenantId, listingId: listing.id, message: message);
    res.fold(
      (l) => emit(state.copyWith(loading: false, error: l.message)),
      (_) => loadAll(tenantId: tenantId),
    );
  }

  Future<void> cancelApplication({
    required String tenantId,
    required String applicationId,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    final res = await repository.cancelApplication(applicationId: applicationId);
    res.fold(
      (l) => emit(state.copyWith(loading: false, error: l.message)),
      (_) => loadAll(tenantId: tenantId),
    );
  }
}
