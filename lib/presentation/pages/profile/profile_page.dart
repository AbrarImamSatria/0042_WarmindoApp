import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/profile/profile_bloc.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/profile/about_dialog.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/profile/address_card.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/profile/profile_card.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/profile/profile_menu_item.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/permission_service.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Memuat profil saat halaman dibuka
    context.read<ProfileBloc>().add(ProfileLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: _handleBlocListener,
          builder: _buildContent,
        ),
      ),
    );
  }

  // Membangun AppBar dengan styling yang konsisten
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Profil',
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.primaryRed,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primaryRed,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  // Menangani perubahan state dari ProfileBloc
  void _handleBlocListener(BuildContext context, ProfileState state) {
    if (state is ProfileAlamatSaved) {
      // Alamat berhasil disimpan, muat ulang profil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppTheme.success,
        ),
      );
      context.read<ProfileBloc>().add(ProfileLoad());
    } else if (state is ProfileError) {
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  // Membangun konten berdasarkan state bloc
  Widget _buildContent(BuildContext context, ProfileState state) {
    if (state is ProfileLoading) {
      return const LoadingWidget();
    }
    
    if (state is ProfileLoaded) {
      return _buildProfileContent(state.user);
    }
    
    // Fallback: ambil user dari AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return _buildProfileContent(authState.user);
    }
    
    return const Center(child: Text('Gagal memuat profil'));
  }

  // Membangun konten utama profil
  Widget _buildProfileContent(PenggunaModel user) {
    final profileBloc = context.read<ProfileBloc>();
    final savedAddress = profileBloc.parseSavedAddress(user.alamat);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Kartu profil pengguna
          ProfileCard(user: user),
          const SizedBox(height: 16),
          
          // Kartu alamat khusus untuk pemilik
          if (user.isOwner) ...[
            AddressCard(
              savedAddress: savedAddress,
              onSetLocation: () => _handleSetLocation(user),
            ),
            const SizedBox(height: 16),
          ],
          
          // Menu items berdasarkan role
          ..._buildMenuItems(user),
          
          const SizedBox(height: 24),
          
          // Tombol logout
          _buildLogoutButton(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Membangun daftar menu items berdasarkan role pengguna
  List<Widget> _buildMenuItems(PenggunaModel user) {
    final menuItems = <Widget>[];

    if (user.isOwner) {
      menuItems.addAll([
        ProfileMenuItem(
          icon: Icons.lock_outline,
          title: 'Ganti Password',
          subtitle: 'Ubah password akun Anda',
          onTap: () => Navigator.pushNamed(context, AppRouter.changePassword),
        ),
        ProfileMenuItem(
          icon: Icons.people_outline,
          title: 'Kelola Pengguna',
          subtitle: 'Tambah atau edit karyawan',
          onTap: () => Navigator.pushNamed(context, AppRouter.userManagement),
        ),
        ProfileMenuItem(
          icon: Icons.backup_outlined,
          title: 'Backup & Restore',
          subtitle: 'Kelola data aplikasi',
          onTap: () => Navigator.pushNamed(context, AppRouter.backupRestore),
        ),
      ]);
    }

    menuItems.add(
      ProfileMenuItem(
        icon: Icons.info_outline,
        title: 'Tentang Aplikasi',
        subtitle: 'Versi 1.0.0',
        onTap: _showAboutDialog,
      ),
    );

    return menuItems;
  }

  // Membangun tombol logout
  Widget _buildLogoutButton() {
    return PrimaryButton(
      text: 'Keluar',
      icon: Icons.logout,
      onPressed: _handleLogout,
      type: ButtonType.outline,
      customColor: AppTheme.error,
      isFullWidth: true,
    );
  }

  // Menangani pengaturan lokasi dengan permission check
  Future<void> _handleSetLocation(PenggunaModel user) async {
    // Cek permission lokasi terlebih dahulu
    bool hasPermission = await PermissionService.requestLocation(context);
    
    if (!hasPermission) return;
    
    // Parse alamat yang tersimpan untuk mendapatkan koordinat
    final profileBloc = context.read<ProfileBloc>();
    final savedAddress = profileBloc.parseSavedAddress(user.alamat);
    
    double? currentLat;
    double? currentLng;
    
    if (savedAddress != null) {
      currentLat = savedAddress['latitude'];
      currentLng = savedAddress['longitude'];
    }

    // Navigasi ke map picker
    final result = await Navigator.pushNamed(
      context,
      AppRouter.mapPicker,
      arguments: {'latitude': currentLat, 'longitude': currentLng},
    );

    // Muat ulang profil jika lokasi berhasil diperbarui
    if (result == true) {
      context.read<ProfileBloc>().add(ProfileLoad());
    }
  }

  // Menangani logout dengan konfirmasi
  Future<void> _handleLogout() async {
    final confirm = await CustomDialog.showLogoutConfirm(context: context);

    if (confirm) {
      context.read<AuthBloc>().add(AuthLogout());
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.login,
        (route) => false,
      );
    }
  }

  // Menampilkan dialog tentang aplikasi
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => const ProfileAboutDialog(),
    );
  }
}