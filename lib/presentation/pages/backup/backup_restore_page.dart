import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/backup/backup_bloc.dart';
import 'package:warmindo_app/presentation/pages/backup/widgets/backup_action_buttons.dart';
import 'package:warmindo_app/presentation/pages/backup/widgets/backup_info_card.dart';
import 'package:warmindo_app/presentation/pages/backup/widgets/backup_list_section.dart';
import 'package:warmindo_app/presentation/pages/backup/widgets/share_backup_dialog.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/permission_service.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'dart:io';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({Key? key}) : super(key: key);

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  @override
  void initState() {
    super.initState();
    _initializePageAccess();
  }

  // Inisialisasi akses halaman dan validasi role pengguna
  void _initializePageAccess() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && !authState.user.isOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomDialog.showError(
          context: context,
          message: 'Hanya pemilik yang dapat mengakses halaman ini',
          onPressed: () => Navigator.pop(context),
        );
      });
    } else {
      // Memuat riwayat backup
      _loadBackupHistory();
    }
  }

  // Memuat riwayat backup dari bloc
  void _loadBackupHistory() {
    context.read<BackupBloc>().add(BackupLoadHistory());
  }

  // Menangani pembuatan backup dengan permission check
  Future<void> _handleCreateBackup() async {
    bool hasPermission = await PermissionService.requestStorage(context);

    if (hasPermission) {
      context.read<BackupBloc>().add(BackupCreate());
    }
  }

  // Menangani restore backup dengan konfirmasi
  Future<void> _handleRestoreBackup(String backupPath) async {
    bool hasPermission = await PermissionService.requestStorage(context);

    if (!hasPermission) return;

    final confirm = await CustomDialog.showConfirm(
      context: context,
      title: 'Restore Backup?',
      message:
          'Semua data saat ini akan diganti dengan data backup. Proses ini tidak dapat dibatalkan.',
      confirmText: 'Restore',
      cancelText: 'Batal',
      type: DialogType.warning,
    );

    if (confirm) {
      context.read<BackupBloc>().add(BackupRestore(backupPath: backupPath));
    }
  }

  // Menangani restore dari file yang dipilih pengguna
  Future<void> _handleRestoreFromFile() async {
    bool hasPermission = await PermissionService.requestStorage(context);

    if (!hasPermission) return;

    try {
      // Gunakan ANY type dan filter manual untuk menghindari masalah platform-specific
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.path != null) {
          final isValidFile = await _validateBackupFile(file);
          if (isValidFile) {
            _handleRestoreBackup(file.path!);
          }
        } else {
          _showError('Gagal membaca file yang dipilih');
        }
      }
    } catch (e) {
      _showError('Gagal memilih file: ${e.toString()}');
    }
  }

  // Validasi file backup yang dipilih
  Future<bool> _validateBackupFile(PlatformFile file) async {
    // Cek ekstensi file
    final fileName = file.name.toLowerCase();
    if (!fileName.endsWith('.db')) {
      _showError('File harus berformat .db (database backup)');
      return false;
    }

    // Cek ukuran file minimum
    final fileObj = File(file.path!);
    final fileSize = await fileObj.length();
    if (fileSize < 100) {
      _showError('File backup tidak valid atau kosong');
      return false;
    }

    return true;
  }

  // Menangani share backup file
  void _handleShareBackup(String backupPath) {
    context.read<BackupBloc>().add(BackupShare(backupPath: backupPath));
  }

  // Menangani penghapusan backup dengan konfirmasi
  Future<void> _handleDeleteBackup(String backupPath) async {
    final fileName = backupPath.split('/').last;

    final confirm = await CustomDialog.showDeleteConfirm(
      context: context,
      itemName: fileName,
    );

    if (confirm) {
      context.read<BackupBloc>().add(BackupDelete(backupPath: backupPath));
    }
  }

  // Menampilkan dialog share backup setelah backup berhasil dibuat
  void _showShareBackupDialog(String backupPath) {
    showDialog(
      context: context,
      builder: (context) => ShareBackupDialog(
        onShare: () {
          Navigator.pop(context);
          _handleShareBackup(backupPath);
        },
      ),
    );
  }

  // Helper method untuk menampilkan error
  void _showError(String message) {
    CustomDialog.showError(context: context, message: message);
  }

  // Helper method untuk menampilkan snackbar sukses
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<BackupBloc, BackupState>(
        listener: _handleBlocListener,
        builder: _buildContent,
      ),
    );
  }

  // Membangun AppBar dengan tombol refresh
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Backup & Restore'),
      actions: [
        IconButton(
          onPressed: _loadBackupHistory,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  // Menangani listener untuk backup bloc events
  void _handleBlocListener(BuildContext context, BackupState state) {
    if (state is BackupSuccess) {
      CustomDialog.showSuccess(
        context: context,
        message: state.message,
        onPressed: () {
          _loadBackupHistory();
          _showShareBackupDialog(state.backupPath);
        },
      );
    } else if (state is BackupRestoreSuccess) {
      CustomDialog.showSuccess(
        context: context,
        message: state.message,
        onPressed: () {
          // Logout dan redirect ke login setelah restore
          context.read<AuthBloc>().add(AuthLogout());
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.login,
            (route) => false,
          );
        },
      );
    } else if (state is BackupShareSuccess) {
      _showSuccessSnackBar('Backup berhasil dishare');
    } else if (state is BackupDeleteSuccess) {
      _showSuccessSnackBar(state.message);
      _loadBackupHistory();
    } else if (state is BackupFailure) {
      _showError(state.error);
    }
  }

  // Membangun konten utama halaman
  Widget _buildContent(BuildContext context, BackupState state) {
    return RefreshIndicator(
      onRefresh: () async => _loadBackupHistory(),
      child: Column(
        children: [
          // Kartu informasi backup
          const BackupInfoCard(),

          // Tombol aksi utama (create backup, restore from file)
          BackupActionButtons(
            isLoading: state is BackupLoading,
            onCreateBackup: _handleCreateBackup,
            onRestoreFromFile: _handleRestoreFromFile,
          ),
          
          const SizedBox(height: 16),

          // Daftar backup
          Expanded(
            child: BackupListSection(
              state: state,
              onRestore: _handleRestoreBackup,
              onShare: _handleShareBackup,
              onDelete: _handleDeleteBackup,
            ),
          ),
        ],
      ),
    );
  }
}