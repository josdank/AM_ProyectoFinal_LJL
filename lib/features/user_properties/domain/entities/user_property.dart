import 'package:equatable/equatable.dart';
import '../../../geolocation/domain/entities/location_point.dart';

class UserProperty extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String propertyType; // 'apartment', 'house', 'room', 'studio'
  
  // Ubicación
  final String address;
  final String city;
  final String state;
  final String country;
  final LocationPoint location;
  
  // Detalles
  final int bedrooms;
  final int bathrooms;
  final double? areaSqm;
  final int? floorNumber;
  final int? totalFloors;
  
  // Precio
  final double price;
  final String currency;
  final String pricePeriod; // 'daily', 'weekly', 'monthly', 'yearly'
  
  // Servicios
  final bool utilitiesIncluded;
  final bool wifiIncluded;
  final bool parkingIncluded;
  final bool furnished;
  
  // Amenidades
  final List<String> amenities;
  
  // Reglas
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool guestsAllowed;
  
  // Disponibilidad
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final int minStayMonths;
  final int maxOccupants;
  
  // Estado
  final bool isActive;
  final bool isVerified;
  final DateTime? verificationDate;
  
  // Imágenes
  final List<String> imageUrls;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProperty({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.address,
    required this.city,
    required this.state,
    this.country = 'Ecuador',
    required this.location,
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.areaSqm,
    this.floorNumber,
    this.totalFloors,
    required this.price,
    this.currency = 'USD',
    this.pricePeriod = 'monthly',
    this.utilitiesIncluded = false,
    this.wifiIncluded = false,
    this.parkingIncluded = false,
    this.furnished = false,
    this.amenities = const [],
    this.petsAllowed = false,
    this.smokingAllowed = false,
    this.guestsAllowed = true,
    this.availableFrom,
    this.availableTo,
    this.minStayMonths = 1,
    this.maxOccupants = 1,
    this.isActive = true,
    this.isVerified = false,
    this.verificationDate,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters de conveniencia
  double? get latitude => location.latitude;
  double? get longitude => location.longitude;
  
  String get priceDisplay => '\$${price.toStringAsFixed(2)} $currency/$pricePeriod';
  
  String get propertyTypeLabel {
    switch (propertyType) {
      case 'apartment':
        return '🏢 Apartamento';
      case 'house':
        return '🏠 Casa';
      case 'room':
        return '🚪 Habitación';
      case 'studio':
        return '🛋️ Studio';
      default:
        return propertyType;
    }
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        propertyType,
        address,
        city,
        state,
        country,
        location,
        bedrooms,
        bathrooms,
        areaSqm,
        floorNumber,
        totalFloors,
        price,
        currency,
        pricePeriod,
        utilitiesIncluded,
        wifiIncluded,
        parkingIncluded,
        furnished,
        amenities,
        petsAllowed,
        smokingAllowed,
        guestsAllowed,
        availableFrom,
        availableTo,
        minStayMonths,
        maxOccupants,
        isActive,
        isVerified,
        verificationDate,
        imageUrls,
        createdAt,
        updatedAt,
      ];

  UserProperty copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    String? propertyType,
    String? address,
    String? city,
    String? state,
    String? country,
    LocationPoint? location,
    int? bedrooms,
    int? bathrooms,
    double? areaSqm,
    int? floorNumber,
    int? totalFloors,
    double? price,
    String? currency,
    String? pricePeriod,
    bool? utilitiesIncluded,
    bool? wifiIncluded,
    bool? parkingIncluded,
    bool? furnished,
    List<String>? amenities,
    bool? petsAllowed,
    bool? smokingAllowed,
    bool? guestsAllowed,
    DateTime? availableFrom,
    DateTime? availableTo,
    int? minStayMonths,
    int? maxOccupants,
    bool? isActive,
    bool? isVerified,
    DateTime? verificationDate,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProperty(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      areaSqm: areaSqm ?? this.areaSqm,
      floorNumber: floorNumber ?? this.floorNumber,
      totalFloors: totalFloors ?? this.totalFloors,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      utilitiesIncluded: utilitiesIncluded ?? this.utilitiesIncluded,
      wifiIncluded: wifiIncluded ?? this.wifiIncluded,
      parkingIncluded: parkingIncluded ?? this.parkingIncluded,
      furnished: furnished ?? this.furnished,
      amenities: amenities ?? this.amenities,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      smokingAllowed: smokingAllowed ?? this.smokingAllowed,
      guestsAllowed: guestsAllowed ?? this.guestsAllowed,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      minStayMonths: minStayMonths ?? this.minStayMonths,
      maxOccupants: maxOccupants ?? this.maxOccupants,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      verificationDate: verificationDate ?? this.verificationDate,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}