import 'package:equatable/equatable.dart';
import 'location_point.dart';

/// Entidad que representa un lugar de interés (universidad, trabajo, etc.)
class Place extends Equatable {
  final String id;
  final String name;
  final String type; // 'university', 'work', 'transport', 'custom'
  final LocationPoint location;
  final String? description;
  final String? address;
  final String? userId; // Si es un lugar personal del usuario

  const Place({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.description,
    this.address,
    this.userId,
  });

  /// Calcula distancia desde un punto
  double distanceFrom(LocationPoint point) {
    return location.distanceTo(point);
  }

  /// Formatea la distancia desde un punto
  String formatDistanceFrom(LocationPoint point) {
    return location.formatDistance(point);
  }

  /// Verifica si es un lugar personal del usuario
  bool isPersonal(String currentUserId) => userId == currentUserId;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        location,
        description,
        address,
        userId,
      ];

  Place copyWith({
    String? id,
    String? name,
    String? type,
    LocationPoint? location,
    String? description,
    String? address,
    String? userId,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      description: description ?? this.description,
      address: address ?? this.address,
      userId: userId ?? this.userId,
    );
  }
}

/// Tipos de lugares predefinidos
class PlaceTypes {
  static const String university = 'university';
  static const String work = 'work';
  static const String transport = 'transport';
  static const String custom = 'custom';

  static const Map<String, String> labels = {
    university: '🎓 Universidad',
    work: '💼 Trabajo',
    transport: '🚌 Transporte',
    custom: '📍 Personalizado',
  };

  static String getLabel(String type) => labels[type] ?? type;
}