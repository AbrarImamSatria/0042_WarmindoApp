part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

// Load profile
final class ProfileLoad extends ProfileEvent {}

// Get current location
final class ProfileGetCurrentLocation extends ProfileEvent {}

// Update location from map
final class ProfileUpdateLocation extends ProfileEvent {
  final double latitude;
  final double longitude;

  ProfileUpdateLocation({
    required this.latitude,
    required this.longitude,
  });
}

// Update alamat with coordinates
final class ProfileUpdateAlamat extends ProfileEvent {
  final String address;
  final double latitude;
  final double longitude;

  ProfileUpdateAlamat({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}