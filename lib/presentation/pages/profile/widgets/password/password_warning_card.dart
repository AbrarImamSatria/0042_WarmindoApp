import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class PasswordWarningCard extends StatelessWidget {
  const PasswordWarningCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon peringatan
            Icon(
              Icons.warning_amber_outlined,
              color: AppTheme.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            
            // Konten peringatan
            Expanded(
              child: _buildWarningContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Membangun konten peringatan
  Widget _buildWarningContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul peringatan
        const Text(
          'Perhatian',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        
        // Teks peringatan
        Text(
          'Setelah password berhasil diubah, Anda akan diminta untuk login kembali menggunakan password baru.',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}