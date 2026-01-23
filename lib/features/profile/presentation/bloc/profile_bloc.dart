import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_profile_photo.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadProfilePhoto uploadProfilePhoto;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadProfilePhoto,
  }) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfilePhotoUploadRequested>(_onPhotoUploadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await getProfile(
      GetProfileParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(const ProfileUpdating());

      final result = await updateProfile(
        UpdateProfileParams(profile: event.profile),
      );

      result.fold(
        (failure) => emit(ProfileError(message: failure.message)),
        (profile) => emit(ProfileLoaded(profile: profile)),
      );
    }
  }

  Future<void> _onPhotoUploadRequested(
    ProfilePhotoUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      emit(const ProfileUploadingPhoto());

      final result = await uploadProfilePhoto(
        UploadProfilePhotoParams(
          photo: event.photo,
          userId: currentProfile.id, // 🔥 AQUÍ LA CORRECCIÓN
        ),
      );

      result.fold(
        (failure) => emit(ProfileError(message: failure.message)),
        (_) {
          add(ProfileLoadRequested(userId: currentProfile.id));
        },
      );
    }
  }
}
