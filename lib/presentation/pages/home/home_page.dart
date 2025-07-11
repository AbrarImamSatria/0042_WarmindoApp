import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/pages/home/widgets/dashboard_stats.dart';
import 'package:warmindo_app/presentation/pages/home/widgets/quick_actions_grid.dart';
import 'package:warmindo_app/presentation/pages/home/widgets/welcome_card.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Muat ulang data otomatis saat kembali ke halaman ini
    if (_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshData();
      });
    } else {
      _isInitialized = true;
    }
  }

  // Memuat data dashboard dari repository
  void _loadDashboardData() {
    context.read<ReportBloc>().add(ReportLoadDashboard());
  }

  // Refresh data halaman home
  void _refreshData() {
    if (!mounted) return;
    _loadDashboardData();
  }

  // Menangani proses logout pengguna
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return const Center(child: LoadingWidget());
            }

            return _buildHomeContent(authState.user);
          },
        ),
      ),
    );
  }

  // Membangun AppBar dengan tombol refresh dan logout
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Warmindo POS'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  // Membangun konten utama halaman home
  Widget _buildHomeContent(dynamic user) {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu selamat datang
            WelcomeCard(user: user),
            const SizedBox(height: 20),

            // Statistik dashboard untuk owner
            if (user.isOwner) ...[
              _buildStatsSection(),
              const SizedBox(height: 24),
            ],

            // Menu aksi cepat
            _buildQuickActionsSection(user.isOwner),
          ],
        ),
      ),
    );
  }

  // Membangun bagian statistik dashboard
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            return _buildStatsContent(state);
          },
        ),
      ],
    );
  }

  // Membangun konten statistik berdasarkan state
  Widget _buildStatsContent(ReportState state) {
    if (state is ReportLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: LoadingWidget(),
        ),
      );
    } else if (state is ReportDashboardLoaded) {
      return DashboardStats(data: state.data);
    } else if (state is ReportFailure) {
      return _buildErrorCard();
    }
    
    // Fallback untuk state initial
    if (state is ReportInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshData();
      });
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: LoadingWidget(),
        ),
      );
    }
    
    return const SizedBox();
  }

  // Membangun kartu error ketika gagal memuat data
  Widget _buildErrorCard() {
    return Card(
      color: AppTheme.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error, color: AppTheme.error, size: 32),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat data',
              style: TextStyle(color: AppTheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // Membangun bagian menu aksi cepat
  Widget _buildQuickActionsSection(bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        QuickActionsGrid(isOwner: isOwner),
      ],
    );
  }
}