import 'package:equatable/equatable.dart';

class Listing extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double price;
  final String currency;
  
  // Ubicación
  final String address;
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;
  
  // Detalles
  final String roomType; // 'private', 'shared'
  final int bathroomsCount;
  final int maxOccupants;
  final DateTime? availableFrom;
  final String leaseDuration; // 'monthly', 'quarterly', 'yearly', 'flexible'
  
  // Servicios
  final bool utilitiesIncluded;
  final bool wifiIncluded;
  final bool parkingIncluded;
  final bool furnished;
  
  // Amenidades y reglas
  final List<String> amenities;
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool guestsAllowed;
  
  // Estado
  final bool isActive;
  final bool isFeatured;
  
  // Imágenes
  final List<String> imageUrls;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const Listing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.address,
    required this.city,
    required this.state,
    this.country = 'Ecuador',
    this.latitude,
    this.longitude,
    required this.roomType,
    this.bathroomsCount = 1,
    this.maxOccupants = 1,
    this.availableFrom,
    required this.leaseDuration,
    this.utilitiesIncluded = false,
    this.wifiIncluded = false,
    this.parkingIncluded = false,
    this.furnished = false,
    this.amenities = const [],
    this.petsAllowed = false,
    this.smokingAllowed = false,
    this.guestsAllowed = true,
    this.isActive = true,
    this.isFeatured = false,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        price,
        currency,
        address,
        city,
        state,
        country,
        latitude,
        longitude,
        roomType,
        bathroomsCount,
        maxOccupants,
        availableFrom,
        leaseDuration,
        utilitiesIncluded,
        wifiIncluded,
        parkingIncluded,
        furnished,
        amenities,
        petsAllowed,
        smokingAllowed,
        guestsAllowed,
        isActive,
        isFeatured,
        imageUrls,
        createdAt,
        updatedAt,
      ];
}