part of 'user_management_bloc.dart';

@immutable
sealed class UserManagementEvent {}

// Load all users
final class UserManagementLoad extends UserManagementEvent {}

// Add new user (employee)
final class UserManagementAdd extends UserManagementEvent {
  final String nama;
  final String password;

  UserManagementAdd({
    required this.nama,
    required this.password,
  });
}

// Update user
final class UserManagementUpdate extends UserManagementEvent {
  final PenggunaModel user;

  UserManagementUpdate({required this.user});
}

// Delete user
final class UserManagementDelete extends UserManagementEvent {
  final int userId;

  UserManagementDelete({required this.userId});
}

// Reset password to default
final class UserManagementResetPassword extends UserManagementEvent {
  final int userId;

  UserManagementResetPassword({required this.userId});
}