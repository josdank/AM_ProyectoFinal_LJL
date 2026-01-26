part of 'user_property_bloc.dart';

abstract class UserPropertyEvent extends Equatable {
  const UserPropertyEvent();

  @override
  List<Object?> get props => [];
}

class UserPropertyLoadMyPropertiesRequested extends UserPropertyEvent {
  final String ownerId;

  const UserPropertyLoadMyPropertiesRequested({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

class UserPropertyCreateRequested extends UserPropertyEvent {
  final UserProperty property;

  const UserPropertyCreateRequested({required this.property});

  @override
  List<Object?> get props => [property];
}

class UserPropertyUpdateRequested extends UserPropertyEvent {
  final UserProperty property;

  const UserPropertyUpdateRequested({required this.property});

  @override
  List<Object?> get props => [property];
}

class UserPropertyDeleteRequested extends UserPropertyEvent {
  final String propertyId;

  const UserPropertyDeleteRequested({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

class UserPropertySearchNearbyRequested extends UserPropertyEvent {
  final LocationPoint center;
  final double radiusMeters;
  final int limit;

  const UserPropertySearchNearbyRequested({
    required this.center,
    this.radiusMeters = 5000,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [center, radiusMeters, limit];
}

class UserPropertyUploadImagesRequested extends UserPropertyEvent {
  final String propertyId;
  final String ownerId;
  final List<String> imagePaths;

  const UserPropertyUploadImagesRequested({
    required this.propertyId,
    required this.ownerId,
    required this.imagePaths,
  });

  @override
  List<Object?> get props => [propertyId, ownerId, imagePaths];
}

class UserPropertyToggleStatusRequested extends UserPropertyEvent {
  final String propertyId;
  final bool isActive;

  const UserPropertyToggleStatusRequested({
    required this.propertyId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [propertyId, isActive];
}

