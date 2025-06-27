part of 'backup_bloc.dart';

@immutable
sealed class BackupEvent {}

// Create backup
final class BackupCreate extends BackupEvent {}

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

// Export to JSON
final class BackupExportJSON extends BackupEvent {}