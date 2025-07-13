import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/pages/report/widgets/best_selling_widget.dart';
import 'package:warmindo_app/presentation/pages/report/widgets/export_dialog_widget.dart';
import 'package:warmindo_app/presentation/pages/report/widgets/payment_stats_widget.dart';
import 'package:warmindo_app/presentation/pages/report/widgets/report_menu_widget.dart';
import 'package:warmindo_app/presentation/pages/report/widgets/revenue_overview_widget.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

// Halaman utama laporan dengan dashboard dan menu navigasi
class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with RouteAware {
  DateTime _selectedDate = DateTime.now();
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    print('ReportPage initState called');
    _checkPermissionAndLoadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Re-load data saat kembali ke halaman ini dari navigasi
    if (_isInitialized) {
      print('ReportPage didChangeDependencies - reloading data');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reloadData();
      });
    } else {
      _isInitialized = true;
    }
  }

  // Cek permission owner dan load data jika valid
  void _checkPermissionAndLoadData() {
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
      _loadDashboardData();
    }
  }

  // Load data dashboard utama
  void _loadDashboardData() {
    print('Loading dashboard data...');
    context.read<ReportBloc>().add(ReportLoadDashboard());
  }

  // Reload data dengan permission check
  void _reloadData() {
    // Pastikan context masih mounted
    if (!mounted) return;
    
    print('Reloading report data...');
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user.isOwner) {
      _loadDashboardData();
    }
  }

  // Date picker untuk filter periode laporan
  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryRed),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      // Load revenue data untuk periode yang dipilih
      context.read<ReportBloc>().add(ReportLoadRevenue(
        period: RevenuePeriod.custom,
        startDate: DateTime(picked.year, picked.month, 1),
        endDate: DateTime(picked.year, picked.month + 1, 0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          // Handle error states
          if (state is ReportFailure) {
            CustomDialog.showError(context: context, message: state.error);
          }
        },
        builder: (context, state) {
          print('ReportPage BlocBuilder state: ${state.runtimeType}');
          
          if (state is ReportLoading) {
            return const LoadingWidget();
          } else if (state is ReportDashboardLoaded) {
            return _buildDashboard(state.data);
          } else if (state is ReportFailure) {
            return _buildErrorState(state.error);
          }
          
          // Fallback: jika state initial, reload data
          if (state is ReportInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _reloadData();
            });
            return const LoadingWidget();
          }
          
          return const SizedBox();
        },
      ),
    );
  }

  // Dashboard layout dengan semua widget laporan
  Widget _buildDashboard(Map<String, dynamic> data) {
    return RefreshIndicator(
      onRefresh: () async {
        _reloadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateInfo(),
            const SizedBox(height: 20),
            RevenueOverviewWidget(data: data),
            const SizedBox(height: 20),
            PaymentStatsWidget(stats: data['paymentStats'] ?? {}),
            const SizedBox(height: 20),
            BestSellingWidget(
              items: data['bestSelling'] ?? [],
              onNavigationReturn: _reloadData, // Callback untuk refresh
            ),
            const SizedBox(height: 20),
            ReportMenuWidget(
              selectedDate: _selectedDate,
              onNavigationReturn: _reloadData, // Callback untuk reload data
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Info card menampilkan periode laporan yang dipilih
  Widget _buildDateInfo() {
    return Card(
      color: AppTheme.primaryRed.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryRed, size: 20),
            const SizedBox(width: 8),
            Text(
              'Laporan Bulan: ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Error state dengan retry button
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            style: TextStyle(color: AppTheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Coba Lagi',
            onPressed: _reloadData,
          ),
        ],
      ),
    );
  }

  // Helper untuk convert angka bulan ke nama
  String _getMonthName(int month) {
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return monthNames[month - 1];
  }
}