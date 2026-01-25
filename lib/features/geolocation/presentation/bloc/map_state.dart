part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final LocationPoint userLocation;
  final List<Place> nearbyPlaces;
  final List<Listing> filteredListings;
  final double currentRadius;
  final bool isSearching;
  final String? searchError;

  const MapLoaded({
    required this.userLocation,
    this.nearbyPlaces = const [],
    this.filteredListings = const [],
    this.currentRadius = 5000, // 5 km por defecto
    this.isSearching = false,
    this.searchError,
  });

  MapLoaded copyWith({
    LocationPoint? userLocation,
    List<Place>? nearbyPlaces,
    List<Listing>? filteredListings,
    double? currentRadius,
    bool? isSearching,
    String? searchError,
  }) {
    return MapLoaded(
      userLocation: userLocation ?? this.userLocation,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      filteredListings: filteredListings ?? this.filteredListings,
      currentRadius: currentRadius ?? this.currentRadius,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
    );
  }

  @override
  List<Object?> get props => [
        userLocation,
        nearbyPlaces,
        filteredListings,
        currentRadius,
        isSearching,
        searchError,
      ];
}

class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object?> get props => [message];
}