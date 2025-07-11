part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

// Login event
final class AuthLogin extends AuthEvent {
  final String nama;
  final String password;

  AuthLogin({
    required this.nama,
    required this.password,
  });
}

// Logout event
final class AuthLogout extends AuthEvent {}

// Check auth status
final class AuthCheckStatus extends AuthEvent {}

// Update profile event
final class AuthUpdateProfile extends AuthEvent {
  final PenggunaModel user;

  AuthUpdateProfile({required this.user});
}

// Update alamat event
final class AuthUpdateAlamat extends AuthEvent {
  final int userId;
  final String alamat;

  AuthUpdateAlamat({
    required this.userId,
    required this.alamat,
  });
}

// Change password event
final class AuthChangePassword extends AuthEvent {
  final int userId;
  final String passwordLama;
  final String passwordBaru;

  AuthChangePassword({
    required this.userId,
    required this.passwordLama,
    required this.passwordBaru,
  });
}

class AuthUpdateUser extends AuthEvent {
  final PenggunaModel user;

  AuthUpdateUser({required this.user});
}