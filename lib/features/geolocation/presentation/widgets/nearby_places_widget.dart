// lib/features/geolocation/presentation/widgets/nearby_places_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/place.dart';

class NearbyPlacesWidget extends StatelessWidget {
  final List<Place> places;
  final LocationPoint userLocation;

  const NearbyPlacesWidget({
    super.key,
    required this.places,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const SizedBox.shrink();
    }

    // Agrupar por tipo
    final grouped = <String, List<Place>>{};
    for (final place in places) {
      grouped.putIfAbsent(place.type, () => []).add(place);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lugares de Interés Cercanos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...grouped.entries.map((entry) {
          return _buildPlaceTypeSection(
            context,
            entry.key,
            entry.value,
          );
        }),
      ],
    );
  }

  Widget _buildPlaceTypeSection(
    BuildContext context,
    String type,
    List<Place> places,
  ) {
    final typeLabel = PlaceTypes.getLabel(type);
    final icon = _getPlaceIcon(type);
    final color = _getPlaceColor(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              typeLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${places.length}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final place = places[index];
              final distance = userLocation.formatDistance(place.location);

              return Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
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

  Color _getPlaceColor(String type) {
    switch (type) {
      case 'university':
        return Colors.purple;
      case 'work':
        return Colors.orange;
      case 'transport':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}