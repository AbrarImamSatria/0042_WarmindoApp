// profile_event.dart
part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

// Load user profile
class ProfileLoad extends ProfileEvent {}

// Get current GPS location
class ProfileGetCurrentLocation extends ProfileEvent {}

// Update location from map coordinates (when user taps on map)
class ProfileUpdateLocation extends ProfileEvent {
  final double latitude;
  final double longitude;

  ProfileUpdateLocation({
    required this.latitude,
    required this.longitude,
  });
}

// Save alamat to database (final save action)
class ProfileSaveAlamat extends ProfileEvent {
  final String address;
  final double latitude;
  final double longitude;

  ProfileSaveAlamat({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}