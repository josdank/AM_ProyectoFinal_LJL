import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/place.dart';
import '../../../listings/domain/entities/listing.dart';

class MapWidget extends StatelessWidget {
  final LocationPoint userLocation;
  final List<Listing> listings;
  final List<Place> places;
  final double radiusMeters;
  final Function(Listing)? onListingTap;
  final Function(Place)? onPlaceTap;

  const MapWidget({
    super.key,
    required this.userLocation,
    this.listings = const [],
    this.places = const [],
    this.radiusMeters = 5000,
    this.onListingTap,
    this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(userLocation.latitude, userLocation.longitude),
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        // Capa de tiles (mapa base)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.busca_companero',
        ),

        // Círculo de radio de búsqueda
        CircleLayer(
          circles: [
            CircleMarker(
              point: LatLng(userLocation.latitude, userLocation.longitude),
              radius: radiusMeters,
              useRadiusInMeter: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              borderStrokeWidth: 2,
            ),
          ],
        ),

        // Marcadores
        MarkerLayer(
          markers: [
            // Marcador de usuario
            Marker(
              point: LatLng(userLocation.latitude, userLocation.longitude),
              width: 60,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.my_location, color: Colors.blue, size: 28),
                ),
              ),
            ),

            // Marcadores de listings
            ...listings.map((listing) {
              if (listing.latitude == null || listing.longitude == null) {
                return null;
              }

              return Marker(
                point: LatLng(listing.latitude!, listing.longitude!),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () => onListingTap?.call(listing),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.home,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 30,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '\$${listing.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).whereType<Marker>(),

            // Marcadores de lugares (universidades, transporte, etc.)
            ...places.map((place) {
              IconData icon;
              Color color;

              switch (place.type) {
                case 'university':
                  icon = Icons.school;
                  color = Colors.purple;
                  break;
                case 'work':
                  icon = Icons.work;
                  color = Colors.orange;
                  break;
                case 'transport':
                  icon = Icons.directions_bus;
                  color = Colors.green;
                  break;
                default:
                  icon = Icons.place;
                  color = Colors.grey;
              }

              return Marker(
                point: LatLng(place.location.latitude, place.location.longitude),
                width: 45,
                height: 45,
                child: GestureDetector(
                  onTap: () => onPlaceTap?.call(place),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}