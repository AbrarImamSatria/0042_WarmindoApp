import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/pages/report/widgets/export_dialog_widget.dart';

// Widget menu navigasi untuk halaman-halaman laporan detail
class ReportMenuWidget extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback? onNavigationReturn;

  const ReportMenuWidget({
    Key? key, 
    required this.selectedDate,
    this.onNavigationReturn,
  }) : super(key: key);

  // Helper method untuk navigasi dengan callback
  Future<void> _navigateAndReturn(BuildContext context, String route, Map<String, dynamic> arguments) async {
    print('Navigating to: $route');
    
    // Navigate dan tunggu hasil
    final result = await Navigator.pushNamed(
      context,
      route,
      arguments: arguments,
    );
    
    print('Returned from: $route, result: $result');
    
    // Panggil callback untuk reload data setelah kembali
    if (onNavigationReturn != null) {
      print('Calling onNavigationReturn callback');
      onNavigationReturn!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildReportMenuItems(context),
      ],
    );
  }

  // Build semua menu items laporan
  Widget _buildReportMenuItems(BuildContext context) {
    return Column(
      children: [
        _ReportMenuItem(
          icon: Icons.show_chart,
          title: 'Laporan Penjualan',
          subtitle: 'Grafik dan detail penjualan',
          color: AppTheme.primaryGreen,
          onTap: () => _navigateAndReturn(
            context,
            '/report/sales',
            {'type': 'sales', 'period': selectedDate},
          ),
        ),
        _ReportMenuItem(
          icon: Icons.restaurant_menu,
          title: 'Laporan Menu',
          subtitle: 'Performa setiap menu',
          color: AppTheme.foodColor,
          onTap: () => _navigateAndReturn(
            context,
            '/report/menu-performance',
            {'type': 'menu-performance', 'period': selectedDate},
          ),
        ),
        _ReportMenuItem(
          icon: Icons.star,
          title: 'Menu Terlaris',
          subtitle: 'Daftar menu terlaris',
          color: AppTheme.primaryYellow,
          onTap: () => _navigateAndReturn(
            context,
            '/report/best-selling',
            {'type': 'best-selling', 'period': selectedDate},
          ),
        ),
        _ReportMenuItem(
          icon: Icons.payment,
          title: 'Laporan Pembayaran',
          subtitle: 'Analisis metode pembayaran',
          color: AppTheme.qrisColor,
          onTap: () => _navigateAndReturn(
            context,
            '/report/payment',
            {'type': 'payment', 'period': selectedDate},
          ),
        ),
        _ReportMenuItem(
          icon: Icons.file_download,
          title: 'Export Laporan',
          subtitle: 'Download Excel atau PDF',
          color: AppTheme.info,
          onTap: () => ExportDialogWidget.show(context, selectedDate),
        ),
      ],
    );
  }
}

// Widget item menu laporan individual
class _ReportMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReportMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.grey),
        onTap: () {
          print('ListTile tapped: $title');
          onTap();
        },
      ),
    );
  }
}