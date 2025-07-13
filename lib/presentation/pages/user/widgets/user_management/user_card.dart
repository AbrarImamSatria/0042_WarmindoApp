import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class UserCard extends StatelessWidget {
  final PenggunaModel user;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onEditPassword;
  final VoidCallback? onDelete;
  final VoidCallback? onResetPassword;

  const UserCard({
    Key? key,
    required this.user,
    required this.isCurrentUser,
    this.onEdit,
    this.onEditPassword,
    this.onDelete,
    this.onResetPassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            if (user.alamat != null && user.alamat!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildAddressInfo(),
            ],
          ],
        ),
      ),
    );
  }

  // Membangun header user dengan avatar dan info
  Widget _buildUserHeader() {
    return Row(
      children: [
        _buildUserAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUserInfo(),
        ),
        if (!isCurrentUser) _buildActionMenu(),
      ],
    );
  }

  // Membangun avatar user
  Widget _buildUserAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Icon(
        Icons.person,
        color: AppTheme.textPrimary,
        size: 24,
      ),
    );
  }

  // Membangun informasi user
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isCurrentUser) _buildCurrentUserBadge(),
          ],
        ),
        const SizedBox(height: 6),
        _buildRoleBadge(),
      ],
    );
  }

  // Membangun badge untuk user saat ini
  Widget _buildCurrentUserBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info),
      ),
      child: const Text(
        'Anda',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.info,
        ),
      ),
    );
  }

  // Membangun badge role
  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.drinkColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'KARYAWAN',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // Membangun informasi alamat
  Widget _buildAddressInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: AppTheme.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            user.alamat!.split('|')[0],
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Membangun menu aksi
  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppTheme.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: _handleMenuAction,
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  // Menangani aksi menu
  void _handleMenuAction(String value) {
    switch (value) {
      case 'edit':
        onEdit?.call();
        break;
      case 'edit_password':
        onEditPassword?.call();
        break;
      case 'reset':
        onResetPassword?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  // Membangun item menu
  List<PopupMenuEntry<String>> _buildMenuItems() {
    final menuItems = <PopupMenuEntry<String>>[];

    if (onEdit != null) {
      menuItems.add(
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: AppTheme.info),
              SizedBox(width: 8),
              Text('Edit Profil'),
            ],
          ),
        ),
      );
    }

    if (onEditPassword != null) {
      menuItems.add(
        const PopupMenuItem(
          value: 'edit_password',
          child: Row(
            children: [
              Icon(Icons.lock_reset, size: 20, color: AppTheme.warning),
              SizedBox(width: 8),
              Text('Edit Password'),
            ],
          ),
        ),
      );
    }

    if (onResetPassword != null) {
      menuItems.add(
        const PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 20, color: AppTheme.textPrimary),
              SizedBox(width: 8),
              Text('Reset Password'),
            ],
          ),
        ),
      );
    }

    if (onDelete != null) {
      menuItems.add(
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: AppTheme.error),
              SizedBox(width: 8),
              Text('Hapus', style: TextStyle(color: AppTheme.error)),
            ],
          ),
        ),
      );
    }

    return menuItems;
  }
}