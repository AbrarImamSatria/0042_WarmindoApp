part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

// Initial state
final class AuthInitial extends AuthState {}

// Loading state
final class AuthLoading extends AuthState {}

// Success state
final class AuthSuccess extends AuthState {
  final PenggunaModel user;
  final String? message;

  AuthSuccess({
    required this.user,
    this.message,
  });
}

// Failure state
final class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});
}