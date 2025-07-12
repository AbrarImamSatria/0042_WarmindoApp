import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class SecurityInfoCard extends StatelessWidget {
  const SecurityInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ikon keamanan
            Icon(
              Icons.security,
              color: AppTheme.info,
              size: 24,
            ),
            const SizedBox(width: 12),
            
            // Konten tips keamanan
            Expanded(
              child: _buildSecurityTips(),
            ),
          ],
        ),
      ),
    );
  }

  // Membangun konten tips keamanan password
  Widget _buildSecurityTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul
        const Text(
          'Tips Keamanan Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        
        // Daftar tips
        Text(
          '• Gunakan kombinasi huruf dan angka\n'
          '• Minimal 6 karakter\n'
          '• Jangan gunakan password yang mudah ditebak',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}