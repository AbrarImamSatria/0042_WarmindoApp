import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class BackupActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCreateBackup;
  final VoidCallback onRestoreFromFile;

  const BackupActionButtons({
    Key? key,
    required this.isLoading,
    required this.onCreateBackup,
    required this.onRestoreFromFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Tombol buat backup baru
          _buildCreateBackupButton(),
          const SizedBox(height: 12),
          
          // Tombol restore dari file
          _buildRestoreFromFileButton(),
        ],
      ),
    );
  }

  // Membangun tombol buat backup baru
  Widget _buildCreateBackupButton() {
    return PrimaryButton(
      text: 'Buat Backup Baru',
      icon: Icons.backup,
      onPressed: isLoading ? null : onCreateBackup,
      isFullWidth: true,
      size: ButtonSize.large,
    );
  }

  // Membangun tombol restore dari file
  Widget _buildRestoreFromFileButton() {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onRestoreFromFile,
      icon: const Icon(Icons.file_upload, size: 20),
      label: const Text('Restore dari File'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: AppTheme.primaryGreen),
        foregroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}