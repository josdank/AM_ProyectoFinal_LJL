import '../../domain/entities/place.dart';
import '../../domain/entities/location_point.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.type,
    required super.location,
    super.description,
    super.address,
    super.userId,
  });

  // Helpers para acceder a las coordenadas directamente
  double get latitude => location.latitude;
  double get longitude => location.longitude;

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: LocationPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        name: json['name'] as String?,
      ),
      description: json['description'] as String?,
      address: json['address'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': location.latitude,
      'longitude': location.longitude,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (userId != null) 'user_id': userId,
    };
  }

  Place toEntity() => Place(
        id: id,
        name: name,
        type: type,
        location: location,
        description: description,
        address: address,
        userId: userId,
      );
}