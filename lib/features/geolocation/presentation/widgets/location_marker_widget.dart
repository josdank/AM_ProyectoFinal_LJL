// lib/features/geolocation/presentation/widgets/location_marker_widget.dart
import 'package:flutter/material.dart';

class LocationMarkerWidget extends StatelessWidget {
  final String? label;
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const LocationMarkerWidget({
    super.key,
    this.label,
    this.icon = Icons.location_on,
    this.color = Colors.blue,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: size * 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}