part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final Profile profile;

  const ProfileUpdateRequested({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfilePhotoUploadRequested extends ProfileEvent {
  final XFile photo;
  final String userId;

  const ProfilePhotoUploadRequested({
    required this.photo,
    required this.userId,
  });

  @override
  List<Object?> get props => [photo, userId];
}