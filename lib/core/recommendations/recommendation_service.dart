import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/listings/domain/entities/listing.dart';

/// Recomendaciones básicas para Arrendatario.
///
/// Estrategia:
/// - Guardar 'vistas' (listingId, city, roomType, price) en un buffer local.
/// - Recomendar listados activos en la misma ciudad y roomType parecido, con precio cercano.
class RecommendationService {
  static const _kViews = 'rec_views';
  static const _maxViews = 40;

  final SharedPreferences prefs;

  RecommendationService(this.prefs);

  Future<void> trackView(Listing listing) async {
    final raw = prefs.getStringList(_kViews) ?? <String>[];
    raw.add(jsonEncode({
      'id': listing.id,
      'city': listing.city,
      'roomType': listing.roomType,
      'price': listing.price,
      'ts': DateTime.now().toIso8601String(),
    }));

    final trimmed = raw.length > _maxViews ? raw.sublist(raw.length - _maxViews) : raw;
    await prefs.setStringList(_kViews, trimmed);
  }

  List<Listing> recommend(List<Listing> candidates, {int limit = 6}) {
    final raw = prefs.getStringList(_kViews) ?? <String>[];
    if (raw.isEmpty) return _fallback(candidates, limit);

    final views = raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    final last = views.last;

    final city = (last['city'] ?? '').toString();
    final roomType = (last['roomType'] ?? '').toString();
    final price = double.tryParse(last['price'].toString()) ?? 0;

    final scored = <({Listing l, double score})>[];

    for (final l in candidates.where((x) => x.isActive)) {
      double s = 0;
      if (l.city.toLowerCase() == city.toLowerCase()) s += 3;
      if (l.roomType.toLowerCase() == roomType.toLowerCase()) s += 2;

      final diff = (l.price - price).abs();
      if (price > 0) {
        final rel = diff / price;
        if (rel < 0.15) s += 2;
        else if (rel < 0.35) s += 1;
      }

      if (l.isFeatured) s += 0.5;

      scored.add((l: l, score: s));
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final result = scored.map((e) => e.l).toList();

    // evitar duplicados por ID
    final seen = <String>{};
    final unique = <Listing>[];
    for (final l in result) {
      if (seen.add(l.id)) unique.add(l);
      if (unique.length >= limit) break;
    }
    return unique.isEmpty ? _fallback(candidates, limit) : unique;
  }

  List<Listing> _fallback(List<Listing> candidates, int limit) {
    final list = candidates.where((x) => x.isActive).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).toList();
  }
}
