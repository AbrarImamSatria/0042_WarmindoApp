// profile_state.dart
part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

// Initial state
class ProfileInitial extends ProfileState {}

// Loading user profile
class ProfileLoading extends ProfileState {}

// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  final PenggunaModel user;

  ProfileLoaded({required this.user});
}

// Loading location (GPS or geocoding)
class ProfileLocationLoading extends ProfileState {}

// Location loaded successfully with address
class ProfileLocationLoaded extends ProfileState {
  final double latitude;
  final double longitude;
  final String address;

  ProfileLocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

// Alamat saved successfully
class ProfileAlamatSaved extends ProfileState {
  final String message;

  ProfileAlamatSaved({required this.message});
}

// Error state
class ProfileError extends ProfileState {
  final String error;

  ProfileError({required this.error});
}