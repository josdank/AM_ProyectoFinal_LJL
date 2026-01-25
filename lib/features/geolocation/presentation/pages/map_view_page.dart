// lib/features/geolocation/presentation/pages/map_view_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/pages/listing_detail_page.dart';
import '../bloc/map_bloc.dart';
import '../widgets/map_widget.dart';
import '../widgets/distance_info_widget.dart';
import '../widgets/nearby_places_widget.dart';
import '../../domain/entities/place.dart';

class MapViewPage extends StatelessWidget {
  const MapViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<MapBloc>()..add(const MapLoadRequested()),
        ),
        BlocProvider(
          create: (_) => sl<ListingBloc>()..add(const ListingsLoadRequested()),
        ),
      ],
      child: const _MapViewContent(),
    );
  }
}

class _MapViewContent extends StatefulWidget {
  const _MapViewContent();

  @override
  State<_MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<_MapViewContent> {
  double _currentRadius = 5000; // 5 km por defecto
  bool _showPlaces = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Viviendas'),
        actions: [
          // Toggle para mostrar/ocultar lugares de interés
          IconButton(
            icon: Icon(_showPlaces ? Icons.location_on : Icons.location_off),
            onPressed: () {
              setState(() => _showPlaces = !_showPlaces);
            },
            tooltip: _showPlaces ? 'Ocultar lugares' : 'Mostrar lugares',
          ),
          // Selector de radio
          PopupMenuButton<double>(
            icon: const Icon(Icons.tune),
            tooltip: 'Ajustar radio de búsqueda',
            onSelected: (radius) {
              setState(() => _currentRadius = radius);
              _filterListingsByRadius(radius);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1000,
                child: Text('1 km'),
              ),
              const PopupMenuItem(
                value: 3000,
                child: Text('3 km'),
              ),
              const PopupMenuItem(
                value: 5000,
                child: Text('5 km'),
              ),
              const PopupMenuItem(
                value: 10000,
                child: Text('10 km'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          if (mapState is MapLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (mapState is MapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    mapState.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MapBloc>().add(const MapLoadRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (mapState is! MapLoaded) {
            return const SizedBox.shrink();
          }

          return BlocBuilder<ListingBloc, ListingState>(
            builder: (context, listingState) {
              if (listingState is! ListingsLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filtrar listings si no se ha hecho
              if (mapState.filteredListings.isEmpty && listingState.listings.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _filterListingsByRadius(_currentRadius);
                });
              }

              return Stack(
                children: [
                  // Mapa
                  MapWidget(
                    userLocation: mapState.userLocation,
                    listings: mapState.filteredListings,
                    places: _showPlaces ? mapState.nearbyPlaces : [],
                    radiusMeters: _currentRadius,
                    onListingTap: (listing) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListingDetailPage(listing: listing),
                        ),
                      );
                    },
                    onPlaceTap: (place) {
                      _showPlaceDetails(context, place, mapState.userLocation);
                    },
                  ),

                  // Panel de información inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${mapState.filteredListings.length} viviendas',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Text(
                                      'Radio: ${(_currentRadius / 1000).toStringAsFixed(1)} km',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                if (_showPlaces && mapState.nearbyPlaces.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  NearbyPlacesWidget(
                                    places: mapState.nearbyPlaces,
                                    userLocation: mapState.userLocation,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoaded && _showPlaces && state.nearbyPlaces.isEmpty) {
            return FloatingActionButton.extended(
              onPressed: () {
                context.read<MapBloc>().add(
                      MapSearchNearbyPlacesRequested(
                        center: state.userLocation,
                        radiusMeters: _currentRadius,
                      ),
                    );
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar lugares'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _filterListingsByRadius(double radius) {
    final mapBloc = context.read<MapBloc>();
    final listingBloc = context.read<ListingBloc>();

    final listingState = listingBloc.state;
    if (listingState is ListingsLoaded) {
      mapBloc.add(MapFilterListingsByRadius(
        listings: listingState.listings,
        radiusMeters: radius,
      ));
    }
  }

  void _showPlaceDetails(BuildContext context, Place place, userLocation) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getPlaceIcon(place.type),
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (place.address != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(place.address!)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            DistanceInfoWidget(
              from: userLocation,
              to: place.location,
            ),
            if (place.description != null) ...[
              const SizedBox(height: 16),
              Text(place.description!),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getPlaceIcon(String type) {
    switch (type) {
      case 'university':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'transport':
        return Icons.directions_bus;
      default:
        return Icons.place;
    }
  }
}