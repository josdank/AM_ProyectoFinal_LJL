// lib/features/geolocation/presentation/widgets/distance_info_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/location_point.dart';

class DistanceInfoWidget extends StatelessWidget {
  final LocationPoint from;
  final LocationPoint to;
  final bool showIcon;

  const DistanceInfoWidget({
    super.key,
    required this.from,
    required this.to,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final distance = from.distanceTo(to);
    final formattedDistance = from.formatDistance(to);

    Color distanceColor;
    IconData distanceIcon;

    // Determinar color según distancia
    if (distance < 1000) {
      distanceColor = Colors.green;
      distanceIcon = Icons.directions_walk;
    } else if (distance < 3000) {
      distanceColor = Colors.orange;
      distanceIcon = Icons.directions_bike;
    } else {
      distanceColor = Colors.red;
      distanceIcon = Icons.directions_car;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: distanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: distanceColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(distanceIcon, size: 20, color: distanceColor),
            const SizedBox(width: 8),
          ],
          Icon(Icons.location_on, size: 16, color: distanceColor),
          const SizedBox(width: 4),
          Text(
            formattedDistance,
            style: TextStyle(
              color: distanceColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getDistanceLabel(distance),
            style: TextStyle(
              color: distanceColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getDistanceLabel(double meters) {
    if (meters < 1000) return 'Muy cerca';
    if (meters < 3000) return 'Cerca';
    if (meters < 5000) return 'Moderado';
    return 'Lejos';
  }
}