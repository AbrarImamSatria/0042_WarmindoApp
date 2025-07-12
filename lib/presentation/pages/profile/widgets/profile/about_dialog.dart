import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class ProfileAboutDialog extends StatelessWidget {
  const ProfileAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _buildDialogTitle(),
      content: _buildDialogContent(),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  // Membangun judul dialog dengan ikon dan nama aplikasi
  Widget _buildDialogTitle() {
    return Row(
      children: [
        _buildAppIcon(),
        const SizedBox(width: 12),
        const Text('Warmindo POS'),
      ],
    );
  }

  // Membangun ikon aplikasi
  Widget _buildAppIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppTheme.primaryRed,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.ramen_dining,
        color: AppTheme.white,
        size: 24,
      ),
    );
  }

  // Membangun konten dialog
  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Versi aplikasi
        const Text(
          'Versi 1.0.0',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        
        // Deskripsi aplikasi
        Text(
          'Aplikasi kasir digital untuk Warmindo Raja Vitamin 3',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        
        const Divider(),
        const SizedBox(height: 16),
        
        // Copyright
        Text(
          '© 2025 Warmindo Raja Vitamin 3',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}