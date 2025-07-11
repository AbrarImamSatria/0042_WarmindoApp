import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/form_validator.dart';
import 'package:warmindo_app/presentation/widgets/custom_text_field.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

/// Widget form untuk input login
class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController namaController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const LoginForm({
    Key? key,
    required this.formKey,
    required this.namaController,
    required this.passwordController,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Field nama pengguna
              CustomTextField(
                label: 'Nama Pengguna',
                hint: 'Masukkan nama pengguna',
                controller: namaController,
                prefixIcon: const Icon(Icons.person_outline),
                validator: FormValidator.username,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Field password
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password',
                controller: passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: FormValidator.password,
                textInputAction: TextInputAction.done,
                onEditingComplete: onLogin,
              ),
              const SizedBox(height: 32),

              // Tombol login
              PrimaryButton(
                text: 'MASUK',
                onPressed: onLogin,
                isFullWidth: true,
                size: ButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
