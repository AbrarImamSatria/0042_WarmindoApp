import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/password/password_strength_indicator.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/password/password_warning_card.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/password/security_info_card.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/custom_text_field.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class ChangePasswordPage extends StatefulWidget {
  final int? userId;
  final String? currentPassword;
  
  const ChangePasswordPage({
    Key? key, 
    this.userId, 
    this.currentPassword,
  }) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _setupPasswordListener();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Inisialisasi form dengan data yang tersedia
  void _initializeForm() {
    if (widget.currentPassword != null) {
      _currentPasswordController.text = widget.currentPassword!;
    }
  }

  // Setup listener untuk indikator kekuatan password
  void _setupPasswordListener() {
    _newPasswordController.addListener(() {
      setState(() {
        // Trigger rebuild untuk password strength indicator
      });
    });
  }

  // Menangani proses perubahan password
  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      final userId = _getUserId();
      if (userId == null) {
        CustomDialog.showError(
          context: context, 
          message: 'Gagal mendapatkan informasi pengguna'
        );
        return;
      }
      
      context.read<AuthBloc>().add(
        AuthChangePassword(
          userId: userId,
          passwordLama: _currentPasswordController.text,
          passwordBaru: _newPasswordController.text,
        ),
      );
    }
  }

  // Mendapatkan user ID dari parameter atau AuthBloc
  int? _getUserId() {
    if (widget.userId != null) {
      return widget.userId!;
    }
    
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.user.id!;
    }
    
    return null;
  }

  // Validasi password baru
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password baru tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (value == _currentPasswordController.text) {
      return 'Password baru tidak boleh sama dengan password lama';
    }
    return null;
  }

  // Validasi konfirmasi password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _newPasswordController.text) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: _handleBlocListener,
          builder: _buildContent,
        ),
      ),
    );
  }

  // Menangani perubahan state dari AuthBloc
  void _handleBlocListener(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      CustomDialog.showLoading(
        context: context,
        message: 'Mengubah password...',
      );
    } else if (state is AuthSuccess && state.message != null) {
      CustomDialog.hideLoading(context);
      CustomDialog.showSuccess(
        context: context,
        message: state.message!,
        onPressed: () => Navigator.pop(context),
      );
    } else if (state is AuthFailure) {
      CustomDialog.hideLoading(context);
      CustomDialog.showError(
        context: context,
        message: state.error,
      );
    }
  }

  // Membangun konten utama halaman
  Widget _buildContent(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu informasi keamanan
            const SecurityInfoCard(),
            const SizedBox(height: 24),
            
            // Field password lama
            _buildCurrentPasswordField(),
            const SizedBox(height: 16),
            
            // Field password baru
            _buildNewPasswordField(),
            const SizedBox(height: 16),
            
            // Field konfirmasi password
            _buildConfirmPasswordField(),
            const SizedBox(height: 8),
            
            // Indikator kekuatan password
            _buildPasswordStrengthSection(),
            const SizedBox(height: 32),
            
            // Tombol submit
            _buildSubmitButton(isLoading),
            const SizedBox(height: 16),
            
            // Kartu peringatan
            const PasswordWarningCard(),
          ],
        ),
      ),
    );
  }

  // Membangun field password lama
  Widget _buildCurrentPasswordField() {
    return CustomTextField(
      label: 'Password Lama',
      hint: widget.currentPassword != null 
          ? 'Password saat ini (otomatis terisi)'
          : 'Masukkan password saat ini',
      controller: _currentPasswordController,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password lama tidak boleh kosong';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  // Membangun field password baru
  Widget _buildNewPasswordField() {
    return CustomTextField(
      label: 'Password Baru',
      hint: 'Masukkan password baru',
      controller: _newPasswordController,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: _validateNewPassword,
      textInputAction: TextInputAction.next,
    );
  }

  // Membangun field konfirmasi password
  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      label: 'Konfirmasi Password Baru',
      hint: 'Ulangi password baru',
      controller: _confirmPasswordController,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: _validateConfirmPassword,
      textInputAction: TextInputAction.done,
      onEditingComplete: _handleChangePassword,
    );
  }

  // Membangun section indikator kekuatan password
  Widget _buildPasswordStrengthSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _newPasswordController.text.isNotEmpty ? null : 0,
      child: _newPasswordController.text.isNotEmpty
          ? PasswordStrengthIndicator(password: _newPasswordController.text)
          : const SizedBox(),
    );
  }

  // Membangun tombol submit
  Widget _buildSubmitButton(bool isLoading) {
    return PrimaryButton(
      text: 'Ganti Password',
      onPressed: isLoading ? null : _handleChangePassword,
      isLoading: isLoading,
      isFullWidth: true,
      size: ButtonSize.large,
      icon: Icons.lock_outline,
    );
  }
}