import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class BackupInfoCard extends StatelessWidget {
  const BackupInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info),
      ),
      child: Row(
        children: [
          // Ikon informasi
          Icon(Icons.info_outline, color: AppTheme.info, size: 24),
          const SizedBox(width: 12),
          
          // Konten informasi
          Expanded(
            child: _buildInfoContent(),
          ),
        ],
      ),
    );
  }

  // Membangun konten informasi backup
  Widget _buildInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul
        const Text(
          'Informasi Backup',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        
        // Deskripsi lokasi penyimpanan
        Text(
          'Backup database akan disimpan di:\nDocuments/WarmindoApp/Backups',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}