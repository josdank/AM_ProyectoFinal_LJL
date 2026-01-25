// lib/features/geolocation/data/models/location_model.dart
import '../../domain/entities/location_point.dart';

class LocationModel extends LocationPoint {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.address,
    super.name,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
      if (name != null) 'name': name,
    };
  }

  LocationPoint toEntity() => LocationPoint(
        latitude: latitude,
        longitude: longitude,
        address: address,
        name: name,
      );
}