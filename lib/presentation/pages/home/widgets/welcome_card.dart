import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class WelcomeCard extends StatelessWidget {
  final dynamic user;

  const WelcomeCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryRed,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            _buildUserAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: _buildUserInfo(),
            ),
          ],
        ),
      ),
    );
  }

  // Membangun avatar pengguna dengan ikon yang sesuai role
  Widget _buildUserAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        user.isOwner ? Icons.admin_panel_settings : Icons.person,
        size: 30,
        color: AppTheme.white,
      ),
    );
  }

  // Membangun informasi pengguna
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Teks sambutan
        Text(
          'Selamat Datang,',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        
        // Nama pengguna
        Text(
          user.nama,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 4),
        
        // Badge role pengguna
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
        color: AppTheme.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.role.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.white,
        ),
      ),
    );
  }
}