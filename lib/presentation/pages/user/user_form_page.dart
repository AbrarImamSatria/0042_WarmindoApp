import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/usermanagement/user_management_bloc.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/data/repository/pengguna_repository.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_form/password_form_section.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_form/profile_avatar_section.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_form/user_info_form_section.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class UserFormPage extends StatefulWidget {
  final int? userId;
  const UserFormPage({Key? key, this.userId}) : super(key: key);

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  
  String _selectedRole = 'karyawan';
  bool _isEditMode = false;
  bool _isLoading = false;
  PenggunaModel? _existingUser;

  final PenggunaRepository _penggunaRepository = PenggunaRepository();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // Inisialisasi form dan data awal
  void _initializeForm() {
    _isEditMode = widget.userId != null;
    _namaController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    if (_isEditMode) _loadUserData();
  }

  // Dispose semua controllers
  void _disposeControllers() {
    _namaController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  // Memuat data pengguna untuk mode edit
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _penggunaRepository.getPenggunaById(widget.userId!);
      if (user != null) {
        setState(() {
          _existingUser = user;
          _namaController.text = user.nama;
          _selectedRole = user.role;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      CustomDialog.showError(
        context: context,
        message: 'Gagal memuat data pengguna',
        onPressed: () => Navigator.pop(context),
      );
    }
  }

  // Menangani submit form
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode && _existingUser != null) {
        _updateExistingUser();
      } else {
        _addNewUser();
      }
    }
  }

  // Update pengguna yang sudah ada
  void _updateExistingUser() {
    final updatedUser = _existingUser!.copyWith(
      nama: _namaController.text.trim(),
      role: _selectedRole,
    );
    context.read<UserManagementBloc>().add(UserManagementUpdate(user: updatedUser));
  }

  // Menambah pengguna baru
  void _addNewUser() {
    context.read<UserManagementBloc>().add(
      UserManagementAdd(
        nama: _namaController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  // Navigasi kembali yang aman
  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
    }
  }

  // Callback ketika role berubah
  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocConsumer<UserManagementBloc, UserManagementState>(
          listener: _handleBlocListener,
          builder: _buildContent,
        ),
      ),
    );
  }

  // Membangun AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isEditMode ? 'Edit Pengguna' : 'Tambah Karyawan',
        style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppTheme.primaryRed,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.white),
        onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      ),
    );
  }

  // Menangani listener untuk bloc events
  void _handleBlocListener(BuildContext context, UserManagementState state) {
    if (state is UserManagementSuccess && state.message != null) {
      CustomDialog.showSuccess(
        context: context,
        message: state.message!,
        onPressed: () {
          Navigator.of(context).pop(); // Tutup dialog dulu
          _navigateBack(); // Kemudian kembali ke user management
        },
      );
    } else if (state is UserManagementFailure) {
      CustomDialog.showError(context: context, message: state.error);
    }
  }

  // Membangun konten utama
  Widget _buildContent(BuildContext context, UserManagementState userState) {
    final isSubmitting = userState is UserManagementLoading;
    
    if (_isLoading) return const LoadingWidget();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar profil
            ProfileAvatarSection(selectedRole: _selectedRole),
            const SizedBox(height: 32),
            
            // Form informasi pengguna
            UserInfoFormSection(
              namaController: _namaController,
              selectedRole: _selectedRole,
              isEditMode: _isEditMode,
              canEditRole: _existingUser?.isOwner == true,
              onRoleChanged: _onRoleChanged,
            ),
            
            // Form password untuk mode tambah
            if (!_isEditMode) ...[
              const SizedBox(height: 16),
              PasswordFormSection(
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                onEditingComplete: _handleSubmit,
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Tombol submit
            PrimaryButton(
              text: _isEditMode ? 'Simpan Perubahan' : 'Tambah Karyawan',
              onPressed: isSubmitting ? null : _handleSubmit,
              isLoading: isSubmitting,
              isFullWidth: true,
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}