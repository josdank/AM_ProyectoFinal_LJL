import '../entities/listing.dart';
import '../../../geolocation/domain/entities/location_point.dart';

extension ListingGeoExtensions on Listing {
  /// Convierte las coordenadas del listing a LocationPoint
  LocationPoint? get location {
    if (latitude == null || longitude == null) return null;
    return LocationPoint(
      latitude: latitude!,
      longitude: longitude!,
      address: address,
      name: title,
    );
  }

  /// Calcula la distancia a un punto en metros
  double? distanceTo(LocationPoint point) {
    final loc = location;
    if (loc == null) return null;
    return loc.distanceTo(point);
  }

  /// Formatea la distancia a un punto
  String? formatDistanceTo(LocationPoint point) {
    final loc = location;
    if (loc == null) return null;
    return loc.formatDistance(point);
  }

  /// Verifica si está dentro de un radio
  bool isWithinRadius(LocationPoint center, double radiusMeters) {
    final loc = location;
    if (loc == null) return false;
    return loc.isWithinRadius(center, radiusMeters);
  }

  /// Verifica si tiene coordenadas válidas
  bool get hasValidLocation => latitude != null && longitude != null;
}