import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../geolocation/domain/entities/location_point.dart';
import '../../domain/entities/user_property.dart';
import '../../domain/usecases/create_property.dart';
import '../../domain/usecases/delete_property.dart';
import '../../domain/usecases/get_my_properties.dart';
import '../../domain/usecases/search_nearby_user_properties.dart';
import '../../domain/usecases/toggle_property_status.dart';
import '../../domain/usecases/update_property.dart';
import '../../domain/usecases/upload_property_images.dart';

part 'user_property_event.dart';
part 'user_property_state.dart';

class UserPropertyBloc extends Bloc<UserPropertyEvent, UserPropertyState> {
  final GetMyProperties getMyProperties;
  final CreateProperty createProperty;
  final UpdateProperty updateProperty;
  final DeleteProperty deleteProperty;
  final SearchNearbyUserProperties searchNearby;
  final UploadPropertyImages uploadImages;
  final TogglePropertyStatus toggleStatus;

  UserPropertyBloc({
    required this.getMyProperties,
    required this.createProperty,
    required this.updateProperty,
    required this.deleteProperty,
    required this.searchNearby,
    required this.uploadImages,
    required this.toggleStatus,
  }) : super(const UserPropertyInitial()) {
    on<UserPropertyLoadMyPropertiesRequested>(_onLoadMyProperties);
    on<UserPropertyCreateRequested>(_onCreateProperty);
    on<UserPropertyUpdateRequested>(_onUpdateProperty);
    on<UserPropertyDeleteRequested>(_onDeleteProperty);
    on<UserPropertySearchNearbyRequested>(_onSearchNearby);
    on<UserPropertyUploadImagesRequested>(_onUploadImages);
    on<UserPropertyToggleStatusRequested>(_onToggleStatus);
  }

  Future<void> _onLoadMyProperties(
    UserPropertyLoadMyPropertiesRequested event,
    Emitter<UserPropertyState> emit,
  ) async {
    emit(const UserPropertyLoading());

    final result = await getMyProperties(
      GetMyPropertiesParams(ownerId: event.ownerId),
    );

    result.fold(
      (failure) => emit(UserPropertyError(message: failure.message)),
      (properties) => emit(UserPropertyLoaded(properties: properties)),
    );
  }

  Future<void> _onCreateProperty(
    UserPropertyCreateRequested event,
    Emitter<UserPropertyState> emit,
  ) async {
    emit(const UserPropertyCreating());

    final result = await createProperty(
      CreatePropertyParams(property: event.property),
    );

    result.fold(
      (failure) => emit(UserPropertyError(message: failure.message)),
      (property) => emit(UserPropertyCreated(property: property)),
    );
  }

  Future<void> _onUpdateProperty(
    UserPropertyUpdateRequested event,
    Emitter<UserPropertyState> emit,
  ) async {
    emit(const UserPropertyUpdating());

    final result = await updateProperty(
      UpdatePropertyParams(property: event.property),
    );

    result.fold(
      (failure) => emit(UserPropertyError(message: failure.message)),
      (property) => emit(UserPropertyUpdated(property: property)),
    );
  }

  Future<void> _onDeleteProperty(
    UserPropertyDeleteRequested event,
    Emitter<UserPropertyState> emit,
  ) async {
    emit(const UserPropertyDeleting());

    final result = await deleteProperty(
      DeletePropertyParams(propertyId: event.propertyId),
    );

    result.fold(
      (failure) => emit(UserPropertyError(message: failure.message)),
      (_) => emit(const UserPropertyDeleted()),
    );
  }

  Future<void> _onSearchNearby(
    UserPropertySearchNearbyRequested event,
    Emitter<UserPropertyState> emit,
  ) async {
    emit(const UserPropertySearching());

    final result = await searchNearby(
      SearchNearbyUserPropertiesParams(
        center: event.center,
        radiusMeters: event.radiusMeters,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(UserPropertyError(message: failure.message)),
      (properties) => emit(UserPropertySearchResults(properties: properties)),
    );
  }

  Future<void> _onUploadImages(
    UserPropertyUploadImagesRequested event,
    Emitter<UserPropertyState> emit,
  ) async {
    emit(const UserPropertyUploadingImages());

    final result = await uploadImages(
      UploadPropertyImagesParams(
        propertyId: event.propertyId,
        ownerId: event.ownerId,
        imagePaths: event.imagePaths,
      ),
    );

    result.fold(
      (failure) => emit(UserPropertyError(message: failure.message)),
      (urls) => emit(UserPropertyImagesUploaded(imageUrls: urls)),
    );
  }

  Future<void> _onToggleStatus(
    UserPropertyToggleStatusRequested event,
    Emitter<UserPropertyState> emit,
  ) async {
    final result = await toggleStatus(
      TogglePropertyStatusParams(
        propertyId: event.propertyId,
        isActive: event.isActive,
      ),
    );

    result.fold(
      (failure) => emit(UserPropertyError(message: failure.message)),
      (_) {
        // Recargar propiedades si estamos en estado loaded
        if (state is UserPropertyLoaded) {
          final currentState = state as UserPropertyLoaded;
          final updatedProperties = currentState.properties.map((p) {
            if (p.id == event.propertyId) {
              return p.copyWith(isActive: event.isActive);
            }
            return p;
          }).toList();
          emit(UserPropertyLoaded(properties: updatedProperties));
        }
      },
    );
  }
}