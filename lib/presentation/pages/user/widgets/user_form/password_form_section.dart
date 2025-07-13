import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_text_field.dart';

class PasswordFormSection extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onEditingComplete;

  const PasswordFormSection({
    Key? key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onEditingComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Field password
        _buildPasswordField(),
        const SizedBox(height: 16),
        
        // Field konfirmasi password
        _buildConfirmPasswordField(),
        const SizedBox(height: 16),
        
        // Info card
        _buildPasswordInfoCard(),
      ],
    );
  }

  // Membangun field password
  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hint: 'Masukkan password',
      controller: passwordController,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: _validatePassword,
      textInputAction: TextInputAction.next,
    );
  }

  // Membangun field konfirmasi password
  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      label: 'Konfirmasi Password',
      hint: 'Ulangi password',
      controller: confirmPasswordController,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: _validateConfirmPassword,
      textInputAction: TextInputAction.done,
      onEditingComplete: onEditingComplete,
    );
  }

  // Membangun kartu informasi password
  Widget _buildPasswordInfoCard() {
    return Card(
      color: AppTheme.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: AppTheme.info, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Password',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Password minimal 6 karakter\n'
                    '• Simpan password dengan aman\n'
                    '• Password dapat direset oleh pemilik',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // Validasi konfirmasi password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }
}