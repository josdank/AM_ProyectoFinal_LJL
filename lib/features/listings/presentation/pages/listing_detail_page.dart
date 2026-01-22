import 'package:flutter/material.dart';
import '../../domain/entities/listing.dart';
import '../widgets/listing_images_carousel_widget.dart';

class ListingDetailPage extends StatelessWidget {
  final Listing listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con imágenes
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: listing.imageUrls.isNotEmpty
                  ? ListingImagesCarouselWidget(imageUrls: listing.imageUrls)
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.home, size: 100),
                    ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio y título
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${listing.price.toStringAsFixed(0)}/mes',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              listing.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      if (listing.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Destacado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Ubicación
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing.city}, ${listing.state}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Detalles rápidos
                  _buildQuickDetails(context),
                  const SizedBox(height: 24),

                  // Descripción
                  Text('Descripción',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(listing.description),
                  const SizedBox(height: 24),

                  // Servicios incluidos
                  if (listing.utilitiesIncluded ||
                      listing.wifiIncluded ||
                      listing.parkingIncluded ||
                      listing.furnished) ...[
                    Text('Servicios Incluidos',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _buildServicesGrid(context),
                    const SizedBox(height: 24),
                  ],

                  // Amenidades
                  if (listing.amenities.isNotEmpty) ...[
                    Text('Amenidades',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: listing.amenities
                          .map((amenity) => Chip(label: Text(amenity)))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reglas
                  Text('Reglas de la Casa',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildRulesList(context),
                  const SizedBox(height: 24),

                  // Ubicación
                  Text('Ubicación',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(listing.address),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implementar solicitud de interés
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad próximamente'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Contactar'),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildDetailItem(
              context,
              Icons.meeting_room,
              listing.roomType == 'private' ? 'Privada' : 'Compartida',
            ),
            _buildDetailItem(
              context,
              Icons.bathtub,
              '${listing.bathroomsCount} baño${listing.bathroomsCount > 1 ? 's' : ''}',
            ),
            _buildDetailItem(
              context,
              Icons.people,
              '${listing.maxOccupants} persona${listing.maxOccupants > 1 ? 's' : ''}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = <Map<String, dynamic>>[];

    if (listing.utilitiesIncluded) {
      services.add({'icon': Icons.lightbulb, 'label': 'Servicios'});
    }
    if (listing.wifiIncluded) {
      services.add({'icon': Icons.wifi, 'label': 'WiFi'});
    }
    if (listing.parkingIncluded) {
      services.add({'icon': Icons.local_parking, 'label': 'Parking'});
    }
    if (listing.furnished) {
      services.add({'icon': Icons.chair, 'label': 'Amueblado'});
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: services
          .map((service) => _buildServiceItem(
                context,
                service['icon'] as IconData,
                service['label'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildServiceItem(BuildContext context, IconData icon, String label) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList(BuildContext context) {
    return Column(
      children: [
        _buildRuleItem(
          context,
          listing.petsAllowed,
          'Mascotas',
          Icons.pets,
        ),
        _buildRuleItem(
          context,
          listing.smokingAllowed,
          'Fumar',
          Icons.smoking_rooms,
        ),
        _buildRuleItem(
          context,
          listing.guestsAllowed,
          'Invitados',
          Icons.people,
        ),
      ],
    );
  }

  Widget _buildRuleItem(
    BuildContext context,
    bool allowed,
    String label,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: allowed ? Colors.green : Colors.red,
      ),
      title: Text(label),
      trailing: Icon(
        allowed ? Icons.check_circle : Icons.cancel,
        color: allowed ? Colors.green : Colors.red,
      ),
    );
  }
}