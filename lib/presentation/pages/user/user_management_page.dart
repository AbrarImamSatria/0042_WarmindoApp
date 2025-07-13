import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/usermanagement/user_management_bloc.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/presentation/pages/profile/change_password_page.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_management/employee_list_section.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_management/user_info_section.dart';
import 'package:warmindo_app/presentation/pages/user/widgets/user_management/user_search_section.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PenggunaModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _initializePageAccess();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Inisialisasi akses halaman dan validasi role
  void _initializePageAccess() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && !authState.user.isOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomDialog.showError(
          context: context,
          message: 'Hanya pemilik yang dapat mengakses halaman ini',
          onPressed: () => Navigator.pop(context),
        );
      });
    } else {
      context.read<UserManagementBloc>().add(UserManagementLoad());
    }
  }

  // Filter karyawan berdasarkan pencarian
  List<PenggunaModel> get _filteredEmployees {
    return _allUsers.where((user) {
      final isEmployee = user.role == 'karyawan';
      final matchesSearch = _searchController.text.isEmpty ||
          user.nama.toLowerCase().contains(_searchController.text.toLowerCase());
      return isEmployee && matchesSearch;
    }).toList();
  }

  // Menangani edit password pengguna
  void _handleEditPassword(PenggunaModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(
          userId: user.id,
          currentPassword: user.password, // Auto-fill password lama
        ),
      ),
    );
  }

  // Menangani penghapusan pengguna
  Future<void> _handleDeleteUser(PenggunaModel user) async {
    final currentUser = context.read<AuthBloc>().currentUser;
    if (currentUser?.id == user.id) {
      CustomDialog.showError(
        context: context,
        message: 'Tidak dapat menghapus akun sendiri',
      );
      return;
    }

    final confirm = await CustomDialog.showDeleteConfirm(
      context: context,
      itemName: user.nama,
    );
    
    if (confirm) {
      context.read<UserManagementBloc>().add(
        UserManagementDelete(userId: user.id!),
      );
    }
  }

  // Menangani reset password pengguna
  Future<void> _handleResetPassword(PenggunaModel user) async {
    final confirm = await CustomDialog.showConfirm(
      context: context,
      title: 'Reset Password?',
      message: 'Password akan direset ke default (123456) untuk ${user.nama}',
      confirmText: 'Reset',
      cancelText: 'Batal',
      type: DialogType.warning,
    );
    
    if (confirm) {
      context.read<UserManagementBloc>().add(
        UserManagementResetPassword(userId: user.id!),
      );
    }
  }

  // Menangani navigasi kembali
  void _handleBackPressed() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.main,
        (route) => false,
      );
    }
  }

  // Menangani refresh data
  void _handleRefresh() {
    context.read<UserManagementBloc>().add(UserManagementLoad());
  }

  // Callback ketika search berubah
  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild untuk filter hasil
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
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
      title: const Text(
        'Kelola Karyawan',
        style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppTheme.primaryRed,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.white),
        onPressed: _handleBackPressed,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: AppTheme.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.main,
              (route) => false,
            );
          },
          tooltip: 'Kembali ke Beranda',
        ),
      ],
    );
  }

  // Membangun floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, AppRouter.userForm),
      icon: const Icon(Icons.person_add),
      label: const Text('Tambah Karyawan'),
      backgroundColor: AppTheme.primaryRed,
      foregroundColor: AppTheme.white,
    );
  }

  // Menangani listener untuk bloc events
  void _handleBlocListener(BuildContext context, UserManagementState state) {
    if (state is UserManagementSuccess && state.message != null) {
      CustomDialog.showSuccess(context: context, message: state.message!);
    } else if (state is UserManagementFailure) {
      CustomDialog.showError(context: context, message: state.error);
    }
  }

  // Membangun konten utama
  Widget _buildContent(BuildContext context, UserManagementState state) {
    if (state is UserManagementLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is UserManagementSuccess) {
      _allUsers = state.users;
      return _buildSuccessContent();
    }
    
    if (state is UserManagementFailure) {
      return _buildErrorContent(state.error);
    }
    
    return const SizedBox();
  }

  // Membangun konten untuk state success
  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Section search bar
        UserSearchSection(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        
        // Section info note
        const UserInfoSection(),
        
        const SizedBox(height: 16),
        
        // Section daftar karyawan
        Expanded(
          child: EmployeeListSection(
            filteredEmployees: _filteredEmployees,
            searchQuery: _searchController.text,
            onRefresh: _handleRefresh,
            onEditUser: (userId) => Navigator.pushNamed(
              context, 
              AppRouter.userForm, 
              arguments: userId,
            ),
            onEditPassword: _handleEditPassword,
            onDeleteUser: _handleDeleteUser,
            onResetPassword: _handleResetPassword,
          ),
        ),
      ],
    );
  }

  // Membangun konten error
  Widget _buildErrorContent(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleRefresh,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}