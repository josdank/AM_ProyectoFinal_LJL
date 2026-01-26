// ============================================
// EVENTS - ACTUALIZADO
// ============================================

part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapLoadRequested extends MapEvent {
  const MapLoadRequested();
}

class MapSearchNearbyPlacesRequested extends MapEvent {
  final LocationPoint center;
  final double radiusMeters;
  final String? type;

  const MapSearchNearbyPlacesRequested({
    required this.center,
    this.radiusMeters = 5000,
    this.type,
  });

  @override
  List<Object?> get props => [center, radiusMeters, type];
}

// NUEVO EVENTO
class MapSearchNearbyUserPropertiesRequested extends MapEvent {
  final LocationPoint center;
  final double radiusMeters;
  final int limit;

  const MapSearchNearbyUserPropertiesRequested({
    required this.center,
    this.radiusMeters = 5000,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [center, radiusMeters, limit];
}

class MapFilterListingsByRadius extends MapEvent {
  final List<Listing> listings;
  final double radiusMeters;

  const MapFilterListingsByRadius({
    required this.listings,
    this.radiusMeters = 5000,
  });

  @override
  List<Object?> get props => [listings, radiusMeters];
}

class MapUpdateUserLocation extends MapEvent {
  final LocationPoint location;

  const MapUpdateUserLocation({required this.location});

  @override
  List<Object?> get props => [location];
}

