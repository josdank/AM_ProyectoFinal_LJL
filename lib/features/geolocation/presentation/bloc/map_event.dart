part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar ubicación actual del usuario
class MapLoadRequested extends MapEvent {
  const MapLoadRequested();
}

/// Buscar lugares cercanos (universidades, transporte, etc.)
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

/// Filtrar listings por radio de distancia
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

/// Actualizar ubicación del usuario en tiempo real
class MapUpdateUserLocation extends MapEvent {
  final LocationPoint location;

  const MapUpdateUserLocation({required this.location});

  @override
  List<Object?> get props => [location];
}