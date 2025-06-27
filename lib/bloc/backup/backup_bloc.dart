import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warmindo_app/data/datasource/database_helper.dart';
import 'package:warmindo_app/data/repository/menu_repository.dart';
import 'package:warmindo_app/data/repository/pengguna_repository.dart';
import 'package:warmindo_app/data/repository/transaksi_repository.dart';
import '../auth/auth_bloc.dart';

part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final MenuRepository _menuRepository = MenuRepository();
  final TransaksiRepository _transaksiRepository = TransaksiRepository();
  final PenggunaRepository _penggunaRepository = PenggunaRepository();
  final AuthBloc _authBloc;

  BackupBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(BackupInitial()) {
    on<BackupCreate>(_onCreate);
    on<BackupRestore>(_onRestore);
    on<BackupShare>(_onShare);
    on<BackupExportJSON>(_onExportJSON);
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
      
      // Get external storage directory (Documents folder)
      Directory? backupDir;
      if (Platform.isAndroid) {
        // Android: /storage/emulated/0/Documents/WarmindoApp/Backups
        final externalDir = await getExternalStorageDirectory();
        final documentsPath = externalDir!.path.split('Android')[0];
        backupDir = Directory('${documentsPath}Documents/WarmindoApp/Backups');
      } else {
        // iOS: Use application documents directory
        final directory = await getApplicationDocumentsDirectory();
        backupDir = Directory('${directory.path}/backups');
      }
      
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
      emit(BackupFailure(error: e.toString()));
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

      // Get database path
      final dbPath = await _databaseHelper.getDatabasePath();
      
      // Close current database
      await _databaseHelper.closeDatabase();
      
      // Replace with backup
      await backupFile.copy(dbPath);
      
      // Reopen database
      await _databaseHelper.database;

      emit(BackupRestoreSuccess(
        message: 'Data berhasil direstore. Silakan login kembali.',
      ));
    } catch (e) {
      emit(BackupFailure(error: e.toString()));
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
        subject: 'Backup WarmindoApp',
      );

      emit(BackupShareSuccess());
    } catch (e) {
      emit(BackupFailure(error: e.toString()));
    }
  }

  // Export to JSON
  Future<void> _onExportJSON(BackupExportJSON event, Emitter<BackupState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(BackupFailure(error: 'Hanya pemilik yang dapat export data'));
      return;
    }

    emit(BackupLoading());
    try {
      // Get all data
      final menus = await _menuRepository.getAllMenu();
      final transactions = await _transaksiRepository.getAllTransaksi();
      final users = await _penggunaRepository.getAllPengguna();

      // Create JSON structure
      final jsonData = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'data': {
          'menus': menus.map((m) => m.toMap()).toList(),
          'transactions': transactions.map((t) => t.toMap()).toList(),
          'users': users.map((u) => {
            ...u.toMap(),
            'password': '***' // Hide password in export
          }).toList(),
        }
      };

      // Get external storage directory
      Directory? exportDir;
      if (Platform.isAndroid) {
        // Android: /storage/emulated/0/Documents/WarmindoApp/Exports
        final externalDir = await getExternalStorageDirectory();
        final documentsPath = externalDir!.path.split('Android')[0];
        exportDir = Directory('${documentsPath}Documents/WarmindoApp/Exports');
      } else {
        // iOS: Use application documents directory
        final directory = await getApplicationDocumentsDirectory();
        exportDir = Directory('${directory.path}/exports');
      }
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final exportPath = '${exportDir.path}/export_warmindo_$timestamp.json';
      final exportFile = File(exportPath);
      
      await exportFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(jsonData),
      );

      emit(BackupSuccess(
        backupPath: exportPath,
        message: 'Data berhasil diexport ke: ${exportDir.path}',
      ));
    } catch (e) {
      emit(BackupFailure(error: e.toString()));
    }
  }
}