import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class BackupItemCard extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final DateTime modifiedDate;
  final VoidCallback onRestore;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const BackupItemCard({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.modifiedDate,
    required this.onRestore,
    required this.onShare,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackupInfo(),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Membangun informasi backup (ikon, nama, ukuran, tanggal)
  Widget _buildBackupInfo() {
    return Row(
      children: [
        _buildBackupIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBackupDetails(),
        ),
      ],
    );
  }

  // Membangun ikon backup
  Widget _buildBackupIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.backup,
        color: AppTheme.primaryGreen,
        size: 24,
      ),
    );
  }

  // Membangun detail backup (nama, ukuran, tanggal)
  Widget _buildBackupDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama file dengan format yang diperbaiki
        Text(
          _formatDisplayName(fileName),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // Informasi ukuran dan tanggal
        _buildFileMetadata(),
      ],
    );
  }

  // Membangun metadata file (ukuran dan tanggal)
  Widget _buildFileMetadata() {
    return Row(
      children: [
        // Ukuran file
        Icon(Icons.storage, size: 14, color: AppTheme.grey),
        const SizedBox(width: 4),
        Text(
          fileSize,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        
        // Tanggal modifikasi
        Icon(Icons.access_time, size: 14, color: AppTheme.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _formatDate(modifiedDate),
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Membangun tombol aksi (restore, share, delete)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Tombol restore
        TextButton.icon(
          onPressed: onRestore,
          icon: const Icon(Icons.restore, size: 18),
          label: const Text('Restore'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 8),
        
        // Tombol share
        TextButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.info),
        ),
        const SizedBox(width: 8),
        
        // Tombol hapus
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Hapus'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.error),
        ),
      ],
    );
  }

  // Format nama file untuk ditampilkan dengan lebih readable
  String _formatDisplayName(String fileName) {
    String displayName = fileName;
    
    if (fileName.startsWith('backup_warmindo_')) {
      try {
        final dateStr = fileName
            .replaceAll('backup_warmindo_', '')
            .replaceAll('.db', '');

        // Parse timestamp dari nama file
        final cleanDateStr = dateStr.replaceAll('-', ':');
        final parts = cleanDateStr.split('T');
        
        if (parts.length == 2) {
          final datePart = parts[0].replaceAll(':', '-');
          final timePart = parts[1];
          displayName = 'Backup $datePart $timePart';
        }
      } catch (e) {
        // Gunakan nama asli jika parsing gagal
        displayName = fileName
            .replaceAll('backup_warmindo_', '')
            .replaceAll('.db', '');
      }
    }
    
    return displayName;
  }

  // Format tanggal untuk ditampilkan
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}