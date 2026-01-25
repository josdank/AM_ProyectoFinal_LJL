import 'dart:math';
import '../../features/listings/domain/entities/listing.dart';

class RecommendationService {
  final Map<String, List<String>> _userHistory = {};
  final Map<String, int> _viewCounts = {};

  /// Registrar vista de un listing
  Future<void> trackView(Listing listing) async {
    final now = DateTime.now().toIso8601String();
    
    // Incrementar contador de vistas
    _viewCounts[listing.id] = (_viewCounts[listing.id] ?? 0) + 1;
    
    // Guardar en historial (simulado - en producción usarías Supabase)
    _userHistory['viewed'] ??= [];
    if (!_userHistory['viewed']!.contains(listing.id)) {
      _userHistory['viewed']!.add(listing.id);
    }
    
    // Guardar preferencias basadas en características
    _updatePreferences(listing);
  }

  void _updatePreferences(Listing listing) {
    // Aquí puedes extraer características y actualizar preferencias del usuario
    // Por ejemplo: precio preferido, ubicación, tipo de habitación, etc.
  }

  /// Generar recomendaciones basadas en historial
  List<Listing> recommend(List<Listing> allListings, {int limit = 10}) {
    if (_viewCounts.isEmpty) {
      // Si no hay historial, mostrar listings populares
      return _getPopularListings(allListings, limit: limit);
    }

    // 1. Obtener listings vistos recientemente
    final viewedIds = _userHistory['viewed'] ?? [];
    
    // 2. Extraer características de listings vistos
    final preferences = _extractPreferences(
      allListings.where((l) => viewedIds.contains(l.id)).toList(),
    );
    
    // 3. Calcular similitud con otros listings
    final scoredListings = allListings.map((listing) {
      final score = _calculateSimilarityScore(listing, preferences);
      return _ScoredListing(listing: listing, score: score);
    }).toList();
    
    // 4. Ordenar por score y excluir ya vistos
    scoredListings.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredListings
        .where((scored) => !viewedIds.contains(scored.listing.id))
        .take(limit)
        .map((scored) => scored.listing)
        .toList();
  }

  List<Listing> _getPopularListings(List<Listing> listings, {int limit = 10}) {
    // Ordenar por alguna métrica de popularidad (precio, rating, etc.)
    return listings
        .where((l) => l.price != null)
        .toList()
      ..sort((a, b) {
        // Priorizar listings con mejor relación precio/ubicación
        final scoreA = _calculateListingScore(a);
        final scoreB = _calculateListingScore(b);
        return scoreB.compareTo(scoreA);
      })
        .take(limit)
        .toList();
  }

  double _calculateListingScore(Listing listing) {
    double score = 0;
    
    // Precio bajo es mejor
    if (listing.price != null) {
      score += (1000 - listing.price!) / 10;
    }
    
    // Si tiene imágenes
    if (listing.images != null && listing.images!.isNotEmpty) {
      score += 20;
    }
    
    // Si está verificado
    if (listing.isVerified == true) {
      score += 30;
    }
    
    return score;
  }

  Map<String, dynamic> _extractPreferences(List<Listing> viewedListings) {
    if (viewedListings.isEmpty) return {};
    
    final preferences = <String, dynamic>{};
    
    // Calcular precio promedio preferido
    final validPrices = viewedListings
        .where((l) => l.price != null)
        .map((l) => l.price!)
        .toList();
    
    if (validPrices.isNotEmpty) {
      preferences['avg_price'] = validPrices.reduce((a, b) => a + b) / validPrices.length;
      preferences['min_price'] = validPrices.reduce(min);
      preferences['max_price'] = validPrices.reduce(max);
    }
    
    // Extraer tipos de habitación preferidos
    final roomTypes = viewedListings
        .where((l) => l.roomType != null)
        .map((l) => l.roomType!)
        .toList();
    
    if (roomTypes.isNotEmpty) {
      final typeCounts = <String, int>{};
      for (final type in roomTypes) {
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }
      
      final mostCommonType = typeCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      preferences['preferred_room_type'] = mostCommonType;
    }
    
    return preferences;
  }

  double _calculateSimilarityScore(Listing listing, Map<String, dynamic> preferences) {
    double score = 0;
    
    // Comparar precio
    if (listing.price != null && preferences['avg_price'] != null) {
      final priceDiff = (listing.price! - preferences['avg_price']!).abs();
      score += max(0, 100 - priceDiff / 10);
    }
    
    // Comparar tipo de habitación
    if (listing.roomType != null && preferences['preferred_room_type'] != null) {
      if (listing.roomType == preferences['preferred_room_type']) {
        score += 50;
      }
    }
    
    // Bonus por características adicionales
    if (listing.petsAllowed == true) {
      score += 10;
    }
    
    if (listing.hasParking == true) {
      score += 15;
    }
    
    if (listing.isFurnished == true) {
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