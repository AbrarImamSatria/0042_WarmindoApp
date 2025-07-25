part of 'backup_bloc.dart';

@immutable
sealed class BackupState {}

// Initial state
final class BackupInitial extends BackupState {}

// Loading state
final class BackupLoading extends BackupState {}

// Backup success
final class BackupSuccess extends BackupState {
  final String backupPath;
  final String message;

  BackupSuccess({
    required this.backupPath,
    required this.message,
  });
}

// Backup history loaded
final class BackupLoaded extends BackupState {
  final List<Map<String, dynamic>> backupHistory;

  BackupLoaded({required this.backupHistory});
}

// Restore success
final class BackupRestoreSuccess extends BackupState {
  final String message;

  BackupRestoreSuccess({required this.message});
}

// Share success
final class BackupShareSuccess extends BackupState {}

// Delete success
final class BackupDeleteSuccess extends BackupState {
  final String message;

  BackupDeleteSuccess({required this.message});
}

// Failure state
final class BackupFailure extends BackupState {
  final String error;

  BackupFailure({required this.error});
}