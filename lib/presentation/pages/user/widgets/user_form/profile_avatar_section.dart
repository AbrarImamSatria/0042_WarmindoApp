import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String selectedRole;

  const ProfileAvatarSection({
    Key? key,
    required this.selectedRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _getAvatarBackgroundColor(),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getAvatarBorderColor(),
            width: 3,
          ),
        ),
        child: Icon(
          _getAvatarIcon(),
          size: 50,
          color: _getAvatarIconColor(),
        ),
      ),
    );
  }

  // Mendapatkan warna background avatar berdasarkan role
  Color _getAvatarBackgroundColor() {
    return selectedRole == 'pemilik'
        ? AppTheme.primaryGreen.withOpacity(0.1)
        : AppTheme.white;
  }

  // Mendapatkan warna border avatar berdasarkan role
  Color _getAvatarBorderColor() {
    return selectedRole == 'pemilik' ? AppTheme.primaryGreen : AppTheme.black;
  }

  // Mendapatkan ikon avatar berdasarkan role
  IconData _getAvatarIcon() {
    return selectedRole == 'pemilik' ? Icons.admin_panel_settings : Icons.person;
  }

  // Mendapatkan warna ikon avatar berdasarkan role
  Color _getAvatarIconColor() {
    return selectedRole == 'pemilik' ? AppTheme.primaryGreen : AppTheme.black;
  }
}