import 'package:equatable/equatable.dart';

/// Entidad que representa un punto geográfico
class LocationPoint extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });

  /// Calcula la distancia a otro punto en metros
  double distanceTo(LocationPoint other) {
    return _calculateDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Fórmula de Haversine para calcular distancia entre coordenadas
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // metros
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _sqrt(double x) {
    if (x < 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  double _atan(double x) {
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }

  /// Formatea la distancia en un string legible
  String formatDistance(LocationPoint other) {
    final meters = distanceTo(other);
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Verifica si está dentro de un radio específico (en metros)
  bool isWithinRadius(LocationPoint center, double radiusMeters) {
    return distanceTo(center) <= radiusMeters;
  }

  @override
  List<Object?> get props => [latitude, longitude, address, name];

  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? name,
  }) {
    return LocationPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      name: name ?? this.name,
    );
  }
}