import 'package:flutter/material.dart';
import '../../../../core/recommendations/recommendation_service.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../../listings/presentation/widgets/listing_card_widget.dart';

class RecommendationSection extends StatefulWidget {
  final List<Listing> allListings;
  final String tenantId;

  const RecommendationSection({
    super.key,
    required this.allListings,
    required this.tenantId,
  });

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  late final RecommendationService _recommendationService;
  List<Listing> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _recommendationService = RecommendationService();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final recommendations = _recommendationService.recommend(
      widget.allListings,
      limit: 4,
    );
    setState(() {
      _recommendations = recommendations;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📌 Recomendado para ti',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _loadRecommendations,
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar recomendaciones',
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final listing = _recommendations[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            ListingCardWidget(listing: listing),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'RECOMENDADO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Basado en tus intereses',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}