import 'package:flutter/material.dart';

class AmenitiesSelectorWidget extends StatelessWidget {
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onChanged;

  const AmenitiesSelectorWidget({
    super.key,
    required this.selectedAmenities,
    required this.onChanged,
  });

  static const Map<String, String> availableAmenities = {
    'wifi': '📶 WiFi',
    'kitchen': '🍳 Cocina completa',
    'washing_machine': '🧺 Lavadora',
    'air_conditioning': '❄️ Aire acondicionado',
    'heating': '🔥 Calefacción',
    'tv': '📺 TV',
    'balcony': '🏞️ Balcón',
    'gym': '💪 Gimnasio',
    'pool': '🏊 Piscina',
    'security': '🔒 Seguridad',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenidades',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableAmenities.entries.map((entry) {
                final isSelected = selectedAmenities.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newAmenities = List<String>.from(selectedAmenities);
                    if (selected) {
                      newAmenities.add(entry.key);
                    } else {
                      newAmenities.remove(entry.key);
                    }
                    onChanged(newAmenities);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}