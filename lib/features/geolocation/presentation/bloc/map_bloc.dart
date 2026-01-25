// lib/features/geolocation/presentation/bloc/map_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/place.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/search_nearby_places.dart';
import '../../../listings/domain/entities/listing.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCurrentLocation getCurrentLocation;
  final SearchNearbyPlaces searchNearbyPlaces;

  MapBloc({
    required this.getCurrentLocation,
    required this.searchNearbyPlaces,
  }) : super(const MapInitial()) {
    on<MapLoadRequested>(_onLoadRequested);
    on<MapSearchNearbyPlacesRequested>(_onSearchNearbyPlaces);
    on<MapFilterListingsByRadius>(_onFilterListingsByRadius);
    on<MapUpdateUserLocation>(_onUpdateUserLocation);
  }

  Future<void> _onLoadRequested(
    MapLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    final result = await getCurrentLocation(const NoParams());

    result.fold(
      (failure) => emit(MapError(message: failure.message)),
      (location) => emit(MapLoaded(userLocation: location)),
    );
  }

  Future<void> _onSearchNearbyPlaces(
    MapSearchNearbyPlacesRequested event,
    Emitter<MapState> emit,
  ) async {
    if (state is! MapLoaded) return;

    final currentState = state as MapLoaded;
    emit(currentState.copyWith(isSearching: true));

    final result = await searchNearbyPlaces(
      SearchNearbyPlacesParams(
        center: event.center,
        radiusMeters: event.radiusMeters,
        type: event.type,
      ),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(
        isSearching: false,
        searchError: failure.message,
      )),
      (places) => emit(currentState.copyWith(
        isSearching: false,
        nearbyPlaces: places,
        searchError: null,
      )),
    );
  }

  void _onFilterListingsByRadius(
    MapFilterListingsByRadius event,
    Emitter<MapState> emit,
  ) {
    if (state is! MapLoaded) return;

    final currentState = state as MapLoaded;

    // Filtrar listings por radio
    final filteredListings = event.listings.where((listing) {
      if (listing.latitude == null || listing.longitude == null) {
        return false;
      }

      final listingLocation = LocationPoint(
        latitude: listing.latitude!,
        longitude: listing.longitude!,
      );

      final distance = currentState.userLocation.distanceTo(listingLocation);
      return distance <= event.radiusMeters;
    }).toList();

    emit(currentState.copyWith(
      filteredListings: filteredListings,
      currentRadius: event.radiusMeters,
    ));
  }

  void _onUpdateUserLocation(
    MapUpdateUserLocation event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(userLocation: event.location));
    }
  }
}