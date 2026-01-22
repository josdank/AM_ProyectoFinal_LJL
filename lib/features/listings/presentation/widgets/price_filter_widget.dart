import 'package:flutter/material.dart';

class PriceFilterWidget extends StatelessWidget {
  final double? minPrice;
  final double? maxPrice;
  final ValueChanged<double?> onMinPriceChanged;
  final ValueChanged<double?> onMaxPriceChanged;

  const PriceFilterWidget({
    super.key,
    this.minPrice,
    this.maxPrice,
    required this.onMinPriceChanged,
    required this.onMaxPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de precio',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: minPrice?.toInt().toString(),
                decoration: const InputDecoration(
                  labelText: 'Precio mínimo',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  onMinPriceChanged(price);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: maxPrice?.toInt().toString(),
                decoration: const InputDecoration(
                  labelText: 'Precio máximo',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final price = double.tryParse(value);
                  onMaxPriceChanged(price);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}