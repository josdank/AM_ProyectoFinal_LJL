import 'dart:math';
import '../../features/listings/domain/entities/listing.dart';

class RecommendationService {
  final Map<String, List<String>> _userHistory = {};
  final Map<String, int> _viewCounts = {};

  /// Registrar vista de un listing
  Future<void> trackView(Listing listing) async {
    // Incrementar contador de vistas
    _viewCounts[listing.id] = (_viewCounts[listing.id] ?? 0) + 1;

    // Guardar en historial (simulado)
    _userHistory['viewed'] ??= [];
    if (!_userHistory['viewed']!.contains(listing.id)) {
      _userHistory['viewed']!.add(listing.id);
    }

    // Actualizar preferencias
    _updatePreferences(listing);
  }

  void _updatePreferences(Listing listing) {
    // Aquí puedes guardar info más compleja en el futuro
    // (precio, ciudad, tipo de habitación, etc.)
  }

  /// Generar recomendaciones
  List<Listing> recommend(List<Listing> allListings, {int limit = 10}) {
    if (_viewCounts.isEmpty) {
      return _getPopularListings(allListings, limit: limit);
    }

    final viewedIds = _userHistory['viewed'] ?? [];

    final preferences = _extractPreferences(
      allListings.where((l) => viewedIds.contains(l.id)).toList(),
    );

    final scoredListings = allListings.map((listing) {
      final score = _calculateSimilarityScore(listing, preferences);
      return _ScoredListing(listing: listing, score: score);
    }).toList();

    scoredListings.sort((a, b) => b.score.compareTo(a.score));

    return scoredListings
        .where((scored) => !viewedIds.contains(scored.listing.id))
        .take(limit)
        .map((scored) => scored.listing)
        .toList();
  }

  List<Listing> _getPopularListings(List<Listing> listings, {int limit = 10}) {
    final sorted = listings.toList();

    sorted.sort((a, b) {
      final scoreA = _calculateListingScore(a);
      final scoreB = _calculateListingScore(b);
      return scoreB.compareTo(scoreA);
    });

    return sorted.take(limit).toList();
  }

  double _calculateListingScore(Listing listing) {
    double score = 0;

    // Precio bajo = mejor score
    score += (1000 - listing.price) / 10;

    // Si tiene imágenes
    if (listing.imageUrls.isNotEmpty) {
      score += 20;
    }

    // Si está destacado
    if (listing.isFeatured == true) {
      score += 30;
    }

    return score;
  }

  Map<String, dynamic> _extractPreferences(List<Listing> viewedListings) {
    if (viewedListings.isEmpty) return {};

    final preferences = <String, dynamic>{};

    // Precio promedio
    final prices = viewedListings.map((l) => l.price).toList();

    preferences['avg_price'] =
        prices.reduce((a, b) => a + b) / prices.length;
    preferences['min_price'] = prices.reduce(min);
    preferences['max_price'] = prices.reduce(max);

    // Tipo de habitación preferido
    final roomTypes = viewedListings.map((l) => l.roomType).toList();

    final typeCounts = <String, int>{};
    for (final type in roomTypes) {
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    final mostCommonType = typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    preferences['preferred_room_type'] = mostCommonType;

    return preferences;
  }

  double _calculateSimilarityScore(
      Listing listing, Map<String, dynamic> preferences) {
    double score = 0;

    // Comparar precio
    if (preferences['avg_price'] != null) {
      final priceDiff =
          (listing.price - preferences['avg_price']).abs();
      score += max(0, 100 - priceDiff / 10);
    }

    // Comparar tipo de habitación
    if (preferences['preferred_room_type'] != null) {
      if (listing.roomType == preferences['preferred_room_type']) {
        score += 50;
      }
    }

    // Bonos
    if (listing.petsAllowed == true) {
      score += 10;
    }

    if (listing.parkingIncluded == true) {
      score += 15;
    }

    if (listing.furnished == true) {
      score += 20;
    }

    return score;
  }
}

class _ScoredListing {
  final Listing listing;
  final double score;

  _ScoredListing({
    required this.listing,
    required this.score,
  });
}