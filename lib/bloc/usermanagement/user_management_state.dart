part of 'user_management_bloc.dart';

@immutable
sealed class UserManagementState {}

// Initial state
final class UserManagementInitial extends UserManagementState {}

// Loading state
final class UserManagementLoading extends UserManagementState {}

// Success state
final class UserManagementSuccess extends UserManagementState {
  final List<PenggunaModel> users;
  final String? message;

  UserManagementSuccess({
    required this.users,
    this.message,
  });

  // Helper getters
  List<PenggunaModel> get employees => users.where((u) => u.isEmployee).toList();
  List<PenggunaModel> get owners => users.where((u) => u.isOwner).toList();
  int get totalEmployees => employees.length;
  int get totalOwners => owners.length;
}

// Failure state
final class UserManagementFailure extends UserManagementState {
  final String error;

  UserManagementFailure({required this.error});
}