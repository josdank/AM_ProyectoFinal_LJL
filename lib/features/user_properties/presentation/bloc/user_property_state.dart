// ============================================
// STATES
// part of 'user_property_bloc.dart'
// ============================================

part of 'user_property_bloc.dart';

abstract class UserPropertyState extends Equatable {
  const UserPropertyState();

  @override
  List<Object?> get props => [];
}

class UserPropertyInitial extends UserPropertyState {
  const UserPropertyInitial();
}

class UserPropertyLoading extends UserPropertyState {
  const UserPropertyLoading();
}

class UserPropertyLoaded extends UserPropertyState {
  final List<UserProperty> properties;

  const UserPropertyLoaded({required this.properties});

  @override
  List<Object?> get props => [properties];
}

class UserPropertyCreating extends UserPropertyState {
  const UserPropertyCreating();
}

class UserPropertyCreated extends UserPropertyState {
  final UserProperty property;

  const UserPropertyCreated({required this.property});

  @override
  List<Object?> get props => [property];
}

class UserPropertyUpdating extends UserPropertyState {
  const UserPropertyUpdating();
}

class UserPropertyUpdated extends UserPropertyState {
  final UserProperty property;

  const UserPropertyUpdated({required this.property});

  @override
  List<Object?> get props => [property];
}

class UserPropertyDeleting extends UserPropertyState {
  const UserPropertyDeleting();
}

class UserPropertyDeleted extends UserPropertyState {
  const UserPropertyDeleted();
}

class UserPropertySearching extends UserPropertyState {
  const UserPropertySearching();
}

class UserPropertySearchResults extends UserPropertyState {
  final List<UserProperty> properties;

  const UserPropertySearchResults({required this.properties});

  @override
  List<Object?> get props => [properties];
}

class UserPropertyUploadingImages extends UserPropertyState {
  const UserPropertyUploadingImages();
}

class UserPropertyImagesUploaded extends UserPropertyState {
  final List<String> imageUrls;

  const UserPropertyImagesUploaded({required this.imageUrls});

  @override
  List<Object?> get props => [imageUrls];
}

class UserPropertyError extends UserPropertyState {
  final String message;

  const UserPropertyError({required this.message});

  @override
  List<Object?> get props => [message];
}