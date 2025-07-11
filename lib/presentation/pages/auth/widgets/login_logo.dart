import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

/// Widget logo dan title untuk halaman login
class LoginLogo extends StatelessWidget {
  const LoginLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo container dengan shadow
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRed.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.ramen_dining,
            size: 60,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 32),

        // Title aplikasi
        const Text(
          'WARMINDO POS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Silakan masuk untuk melanjutkan',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
