import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: _buildIconContainer(),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // Membangun container ikon dengan background
  Widget _buildIconContainer() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppTheme.primaryRed),
    );
  }
}