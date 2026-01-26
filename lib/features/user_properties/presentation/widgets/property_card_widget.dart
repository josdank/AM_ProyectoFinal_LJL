import 'package:flutter/material.dart';
import '../../../../core/theme/ljl_colors.dart';
import '../../domain/entities/user_property.dart';

class PropertyCardWidget extends StatelessWidget {
  final UserProperty property;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const PropertyCardWidget({
    super.key,
    required this.property,
    this.onTap,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            _buildImage(),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Estado
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tipo
                  Row(
                    children: [
                      Text(
                        property.propertyTypeLabel,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Detalles
                  Row(
                    children: [
                      _buildIconText(Icons.bed, '${property.bedrooms}'),
                      const SizedBox(width: 16),
                      _buildIconText(Icons.bathtub, '${property.bathrooms}'),
                      const SizedBox(width: 16),
                      _buildIconText(Icons.people, '${property.maxOccupants}'),
                      if (property.areaSqm != null) ...[
                        const SizedBox(width: 16),
                        _buildIconText(
                          Icons.square_foot,
                          '${property.areaSqm!.toStringAsFixed(0)}m²',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ubicación
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.city}, ${property.state}',
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: LjlColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LjlColors.gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${property.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: LjlColors.navy,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${_getPeriodLabel(property.pricePeriod)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Servicios
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (property.furnished)
                        _buildFeatureChip('Amueblado', Icons.chair),
                      if (property.wifiIncluded)
                        _buildFeatureChip('WiFi', Icons.wifi),
                      if (property.parkingIncluded)
                        _buildFeatureChip('Parking', Icons.local_parking),
                      if (property.petsAllowed)
                        _buildFeatureChip('Mascotas', Icons.pets),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onToggleStatus,
                          icon: Icon(
                            property.isActive
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          label: Text(
                            property.isActive ? 'Desactivar' : 'Activar',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (property.imageUrls.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.home_work, size: 64, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        Image.network(
          property.imageUrls.first,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
            ),
          ),
        ),
        if (property.imageUrls.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${property.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip() {
    final color = property.isActive ? Colors.green : Colors.grey;
    final label = property.isActive ? 'Activa' : 'Inactiva';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: LjlColors.teal),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: LjlColors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LjlColors.teal.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: LjlColors.teal),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: LjlColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'daily':
        return 'día';
      case 'weekly':
        return 'semana';
      case 'monthly':
        return 'mes';
      case 'yearly':
        return 'año';
      default:
        return period;
    }
  }
}