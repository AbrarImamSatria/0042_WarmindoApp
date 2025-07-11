import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warmindo_app/data/datasource/database_helper.dart';
import '../auth/auth_bloc.dart';

part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final AuthBloc _authBloc;

  BackupBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(BackupInitial()) {
    on<BackupCreate>(_onCreate);
    on<BackupRestore>(_onRestore);
    on<BackupShare>(_onShare);
    on<BackupLoadHistory>(_onLoadHistory);
    on<BackupDelete>(_onDelete);
  }

  // Check owner permission
  bool _checkOwnerPermission() {
    return _authBloc.isOwner;
  }

  // Create backup
  Future<void> _onCreate(BackupCreate event, Emitter<BackupState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(BackupFailure(error: 'Hanya pemilik yang dapat backup data'));
      return;
    }

    emit(BackupLoading());
    try {
      // Get database path
      final dbPath = await _databaseHelper.getDatabasePath();
      final dbFile = File(dbPath);
      
      if (!await dbFile.exists()) {
        throw Exception('Database tidak ditemukan');
      }

      // Get backup directory
      final backupDir = await _getBackupDirectory();
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Create backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = '${backupDir.path}/backup_warmindo_$timestamp.db';
      
      // Copy database file
      await dbFile.copy(backupPath);

      emit(BackupSuccess(
        backupPath: backupPath,
        message: 'Backup berhasil dibuat di: ${backupDir.path}',
      ));
    } catch (e) {
      emit(BackupFailure(error: 'Gagal membuat backup: ${e.toString()}'));
    }
  }

  // Load backup history
  Future<void> _onLoadHistory(BackupLoadHistory event, Emitter<BackupState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(BackupFailure(error: 'Hanya pemilik yang dapat melihat riwayat backup'));
      return;
    }

    emit(BackupLoading());
    try {
      final backupDir = await _getBackupDirectory();
      
      if (!await backupDir.exists()) {
        emit(BackupLoaded(backupHistory: []));
        return;
      }

      final backupFiles = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();

      final backupHistory = <Map<String, dynamic>>[];
      
      for (final file in backupFiles) {
        final stat = await file.stat();
        final fileName = file.path.split('/').last;
        
        backupHistory.add({
          'name': fileName,
          'path': file.path,
          'size': stat.size,
          'created': stat.modified,
          'formattedSize': _formatFileSize(stat.size),
          'formattedDate': _formatDate(stat.modified),
        });
      }

      // Sort by creation date (newest first)
      backupHistory.sort((a, b) => 
        (b['created'] as DateTime).compareTo(a['created'] as DateTime));

      emit(BackupLoaded(backupHistory: backupHistory));
    } catch (e) {
      emit(BackupFailure(error: 'Gagal memuat riwayat backup: ${e.toString()}'));
    }
  }

  // Restore backup
  Future<void> _onRestore(BackupRestore event, Emitter<BackupState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(BackupFailure(error: 'Hanya pemilik yang dapat restore data'));
      return;
    }

    emit(BackupLoading());
    try {
      // Check if backup file exists
      final backupFile = File(event.backupPath);
      if (!await backupFile.exists()) {
        throw Exception('File backup tidak ditemukan');
      }

      // Validate backup file (check if it's a valid SQLite file)
      final fileSize = await backupFile.length();
      if (fileSize < 100) { // SQLite header is at least 100 bytes
        throw Exception('File backup tidak valid atau kosong');
      }

      // Get database path
      final dbPath = await _databaseHelper.getDatabasePath();
      
      // Close current database connection
      await _databaseHelper.closeDatabase();
      
      // Create backup of current database before restore
      final currentDbFile = File(dbPath);
      if (await currentDbFile.exists()) {
        final tempBackupPath = '${dbPath}.temp_backup';
        await currentDbFile.copy(tempBackupPath);
        
        try {
          // Replace with backup
          await backupFile.copy(dbPath);
          
          // Test if restored database is valid by opening it
          await _databaseHelper.database;
          
          // If successful, delete temp backup
          await File(tempBackupPath).delete();
          
        } catch (e) {
          // If restore failed, restore from temp backup
          await File(tempBackupPath).copy(dbPath);
          await File(tempBackupPath).delete();
          throw Exception('File backup tidak kompatibel: ${e.toString()}');
        }
      } else {
        // No existing database, just copy the backup
        await backupFile.copy(dbPath);
        await _databaseHelper.database;
      }

      emit(BackupRestoreSuccess(
        message: 'Data berhasil direstore. Silakan login kembali.',
      ));
    } catch (e) {
      emit(BackupFailure(error: 'Gagal restore backup: ${e.toString()}'));
    }
  }

  // Share backup file
  Future<void> _onShare(BackupShare event, Emitter<BackupState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(BackupFailure(error: 'Hanya pemilik yang dapat share backup'));
      return;
    }

    emit(BackupLoading());
    try {
      final file = File(event.backupPath);
      if (!await file.exists()) {
        throw Exception('File backup tidak ditemukan');
      }

      await Share.shareXFiles(
        [XFile(event.backupPath)],
        subject: 'Backup WarmindoApp Database',
        text: 'Backup database WarmindoApp dari ${_formatDate(DateTime.now())}',
      );

      emit(BackupShareSuccess());
    } catch (e) {
      emit(BackupFailure(error: 'Gagal share backup: ${e.toString()}'));
    }
  }

  // Delete backup file
  Future<void> _onDelete(BackupDelete event, Emitter<BackupState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(BackupFailure(error: 'Hanya pemilik yang dapat menghapus backup'));
      return;
    }

    emit(BackupLoading());
    try {
      final file = File(event.backupPath);
      if (await file.exists()) {
        await file.delete();
        emit(BackupDeleteSuccess(message: 'Backup berhasil dihapus'));
      } else {
        emit(BackupFailure(error: 'File backup tidak ditemukan'));
      }
    } catch (e) {
      emit(BackupFailure(error: 'Gagal menghapus backup: ${e.toString()}'));
    }
  }

  // Get backup directory
  Future<Directory> _getBackupDirectory() async {
    if (Platform.isAndroid) {
      // Try to use external storage first
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final documentsPath = externalDir.path.split('Android')[0];
          return Directory('${documentsPath}Documents/WarmindoApp/Backups');
        }
      } catch (e) {
        // Fallback to app directory
      }
      
      // Fallback to application documents directory
      final directory = await getApplicationDocumentsDirectory();
      return Directory('${directory.path}/backups');
    } else {
      // iOS: Use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      return Directory('${directory.path}/backups');
    }
  }

  // Helper method to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}