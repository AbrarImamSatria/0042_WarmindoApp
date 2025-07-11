part of 'backup_bloc.dart';

@immutable
sealed class BackupEvent {}

// Create backup
final class BackupCreate extends BackupEvent {}

// Load backup history
final class BackupLoadHistory extends BackupEvent {}

// Restore from backup
final class BackupRestore extends BackupEvent {
  final String backupPath;

  BackupRestore({required this.backupPath});
}

// Share backup file
final class BackupShare extends BackupEvent {
  final String backupPath;

  BackupShare({required this.backupPath});
}

// Delete backup file
final class BackupDelete extends BackupEvent {
  final String backupPath;

  BackupDelete({required this.backupPath});
}