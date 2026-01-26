import '../../../geolocation/domain/entities/location_point.dart';
import '../../domain/entities/user_property.dart';

class UserPropertyModel extends UserProperty {
  const UserPropertyModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.propertyType,
    required super.address,
    required super.city,
    required super.state,
    super.country,
    required super.location,
    super.bedrooms,
    super.bathrooms,
    super.areaSqm,
    super.floorNumber,
    super.totalFloors,
    required super.price,
    super.currency,
    super.pricePeriod,
    super.utilitiesIncluded,
    super.wifiIncluded,
    super.parkingIncluded,
    super.furnished,
    super.amenities,
    super.petsAllowed,
    super.smokingAllowed,
    super.guestsAllowed,
    super.availableFrom,
    super.availableTo,
    super.minStayMonths,
    super.maxOccupants,
    super.isActive,
    super.isVerified,
    super.verificationDate,
    super.imageUrls,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserPropertyModel.fromJson(Map<String, dynamic> json) {
    // Parsear imágenes si vienen de la relación
    List<String> imageUrls = [];
    if (json['user_property_images'] != null) {
      final images = json['user_property_images'] as List;
      imageUrls = images
          .map((img) => img['image_url'] as String)
          .toList()
        ..sort((a, b) {
          final orderA = images.firstWhere((i) => i['image_url'] == a)['display_order'] as int? ?? 0;
          final orderB = images.firstWhere((i) => i['image_url'] == b)['display_order'] as int? ?? 0;
          return orderA.compareTo(orderB);
        });
    }

    return UserPropertyModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      propertyType: json['property_type'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String? ?? 'Ecuador',
      location: LocationPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
      ),
      bedrooms: json['bedrooms'] as int? ?? 1,
      bathrooms: json['bathrooms'] as int? ?? 1,
      areaSqm: json['area_sqm'] != null ? (json['area_sqm'] as num).toDouble() : null,
      floorNumber: json['floor_number'] as int?,
      totalFloors: json['total_floors'] as int?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      pricePeriod: json['price_period'] as String? ?? 'monthly',
      utilitiesIncluded: json['utilities_included'] as bool? ?? false,
      wifiIncluded: json['wifi_included'] as bool? ?? false,
      parkingIncluded: json['parking_included'] as bool? ?? false,
      furnished: json['furnished'] as bool? ?? false,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'] as List)
          : [],
      petsAllowed: json['pets_allowed'] as bool? ?? false,
      smokingAllowed: json['smoking_allowed'] as bool? ?? false,
      guestsAllowed: json['guests_allowed'] as bool? ?? true,
      availableFrom: json['available_from'] != null
          ? DateTime.parse(json['available_from'] as String)
          : null,
      availableTo: json['available_to'] != null
          ? DateTime.parse(json['available_to'] as String)
          : null,
      minStayMonths: json['min_stay_months'] as int? ?? 1,
      maxOccupants: json['max_occupants'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      verificationDate: json['verification_date'] != null
          ? DateTime.parse(json['verification_date'] as String)
          : null,
      imageUrls: imageUrls,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'property_type': propertyType,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sqm': areaSqm,
      'floor_number': floorNumber,
      'total_floors': totalFloors,
      'price': price,
      'currency': currency,
      'price_period': pricePeriod,
      'utilities_included': utilitiesIncluded,
      'wifi_included': wifiIncluded,
      'parking_included': parkingIncluded,
      'furnished': furnished,
      'amenities': amenities,
      'pets_allowed': petsAllowed,
      'smoking_allowed': smokingAllowed,
      'guests_allowed': guestsAllowed,
      'available_from': availableFrom?.toIso8601String(),
      'available_to': availableTo?.toIso8601String(),
      'min_stay_months': minStayMonths,
      'max_occupants': maxOccupants,
      'is_active': isActive,
      'is_verified': isVerified,
      'verification_date': verificationDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProperty toEntity() => UserProperty(
        id: id,
        ownerId: ownerId,
        title: title,
        description: description,
        propertyType: propertyType,
        address: address,
        city: city,
        state: state,
        country: country,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        areaSqm: areaSqm,
        floorNumber: floorNumber,
        totalFloors: totalFloors,
        price: price,
        currency: currency,
        pricePeriod: pricePeriod,
        utilitiesIncluded: utilitiesIncluded,
        wifiIncluded: wifiIncluded,
        parkingIncluded: parkingIncluded,
        furnished: furnished,
        amenities: amenities,
        petsAllowed: petsAllowed,
        smokingAllowed: smokingAllowed,
        guestsAllowed: guestsAllowed,
        availableFrom: availableFrom,
        availableTo: availableTo,
        minStayMonths: minStayMonths,
        maxOccupants: maxOccupants,
        isActive: isActive,
        isVerified: isVerified,
        verificationDate: verificationDate,
        imageUrls: imageUrls,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory UserPropertyModel.fromEntity(UserProperty entity) {
    return UserPropertyModel(
      id: entity.id,
      ownerId: entity.ownerId,
      title: entity.title,
      description: entity.description,
      propertyType: entity.propertyType,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      location: entity.location,
      bedrooms: entity.bedrooms,
      bathrooms: entity.bathrooms,
      areaSqm: entity.areaSqm,
      floorNumber: entity.floorNumber,
      totalFloors: entity.totalFloors,
      price: entity.price,
      currency: entity.currency,
      pricePeriod: entity.pricePeriod,
      utilitiesIncluded: entity.utilitiesIncluded,
      wifiIncluded: entity.wifiIncluded,
      parkingIncluded: entity.parkingIncluded,
      furnished: entity.furnished,
      amenities: entity.amenities,
      petsAllowed: entity.petsAllowed,
      smokingAllowed: entity.smokingAllowed,
      guestsAllowed: entity.guestsAllowed,
      availableFrom: entity.availableFrom,
      availableTo: entity.availableTo,
      minStayMonths: entity.minStayMonths,
      maxOccupants: entity.maxOccupants,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
      verificationDate: entity.verificationDate,
      imageUrls: entity.imageUrls,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}