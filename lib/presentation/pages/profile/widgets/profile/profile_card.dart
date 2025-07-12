import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final PenggunaModel user;

  const ProfileCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildUserInfo(),
            
            // Catatan untuk karyawan
            if (user.isEmployee) ...[
              const SizedBox(height: 16),
              _buildEmployeeNote(),
            ],
          ],
        ),
      ),
    );
  }

  // Membangun informasi pengguna
  Widget _buildUserInfo() {
    return Row(
      children: [
        // Avatar pengguna
        _buildUserAvatar(),
        const SizedBox(width: 16),

        // Nama dan role
        Expanded(
          child: _buildUserDetails(),
        ),
      ],
    );
  }

  // Membangun avatar pengguna
  Widget _buildUserAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryRed, width: 3),
      ),
      child: Icon(
        user.isOwner ? Icons.admin_panel_settings : Icons.person,
        size: 40,
        color: AppTheme.primaryRed,
      ),
    );
  }

  // Membangun detail pengguna (nama dan role)
  Widget _buildUserDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama pengguna
        Text(
          user.nama,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Badge role
        _buildRoleBadge(),
      ],
    );
  }

  // Membangun badge role pengguna
  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: user.isOwner ? AppTheme.primaryRed : AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        user.role.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Membangun catatan untuk karyawan
  Widget _buildEmployeeNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Untuk mengubah password atau data lainnya, hubungi pemilik.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}