part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

// Initial state
final class ProfileInitial extends ProfileState {}

// Loading state
final class ProfileLoading extends ProfileState {}

// Location loading state
final class ProfileLocationLoading extends ProfileState {}

// Profile loaded
final class ProfileLoaded extends ProfileState {
  final PenggunaModel user;

  ProfileLoaded({required this.user});
}

// Location loaded
final class ProfileLocationLoaded extends ProfileState {
  final double latitude;
  final double longitude;
  final String address;

  ProfileLocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

// Update success
final class ProfileUpdateSuccess extends ProfileState {
  final String message;

  ProfileUpdateSuccess({required this.message});
}

// Failure state
final class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure({required this.error});
}