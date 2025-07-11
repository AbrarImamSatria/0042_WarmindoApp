// presentation/pages/auth/login_page.dart - Versi yang dioptimalkan
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/pages/auth/widgets/login_logo.dart';
import 'package:warmindo_app/presentation/pages/auth/widgets/login_form.dart';

/// Halaman login untuk autentikasi pengguna
/// Menampilkan form login dan mengelola state autentikasi
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers untuk input field
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controllers saat widget di-dispose
    _namaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Menangani proses login
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLogin(
          nama: _namaController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthStateChange,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo aplikasi
                  const LoginLogo(),
                  const SizedBox(height: 48),

                  // Form login
                  LoginForm(
                    formKey: _formKey,
                    namaController: _namaController,
                    passwordController: _passwordController,
                    onLogin: _handleLogin,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Menangani perubahan state autentikasi
  void _handleAuthStateChange(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      // Tampilkan loading dialog
      CustomDialog.showLoading(context: context, message: 'Sedang masuk...');
    } else if (state is AuthSuccess) {
      // Sembunyikan loading dan navigasi ke halaman utama
      CustomDialog.hideLoading(context);
      Navigator.pushReplacementNamed(context, AppRouter.main);
    } else if (state is AuthFailure) {
      // Sembunyikan loading dan tampilkan error
      CustomDialog.hideLoading(context);
      CustomDialog.showError(context: context, message: state.error);
    }
  }
}
