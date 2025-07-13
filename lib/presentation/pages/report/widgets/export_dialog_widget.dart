import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/permission_service.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';

// Widget untuk dialog export laporan ke Excel dan PDF
class ExportDialogWidget {
  static bool _isSharing = false; // Flag untuk prevent duplicate sharing

  // Tampilkan dialog pilihan export
  static void show(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Export Laporan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.table_chart, color: AppTheme.primaryGreen),
              title: const Text('Excel (.xlsx)'),
              subtitle: const Text('Laporan lengkap dalam spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                _exportToExcel(context, selectedDate);
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: AppTheme.error),
              title: const Text('PDF'),
              subtitle: const Text('Laporan untuk dicetak'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF(context, selectedDate);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  // Export ke Excel dengan permission check
  static void _exportToExcel(BuildContext context, DateTime selectedDate) async {
    bool hasPermission = await PermissionService.requestStorage(context);
    if (!hasPermission) return;
    
    final startDate = DateTime(selectedDate.year, selectedDate.month, 1);
    final endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    
    _isSharing = false;
    
    // Trigger export dengan semua data
    context.read<ReportBloc>().add(ReportGenerateExcel(
      startDate: startDate,
      endDate: endDate,
      includeTransactions: true,
      includeSalesByMenu: true,
      includeDailyRevenue: true,
      includePaymentStats: true,
    ));
  }

  // Export ke PDF dengan permission check
  static void _exportToPDF(BuildContext context, DateTime selectedDate) async {
    bool hasPermission = await PermissionService.requestStorage(context);
    if (!hasPermission) return;
    
    final startDate = DateTime(selectedDate.year, selectedDate.month, 1);
    final endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    
    _isSharing = false;
    
    // Trigger export PDF
    context.read<ReportBloc>().add(ReportGeneratePDF(
      startDate: startDate,
      endDate: endDate,
      includeTransactions: true,
      includeSalesByMenu: true,
      includePaymentStats: true,
    ));
  }

  // Dialog sukses dengan opsi share dan navigasi
  static void showSuccessDialog(BuildContext context, dynamic state) {
    if (_isSharing) {
      print('Already sharing, skipping duplicate share dialog');
      return;
    }

    String filePath = '';
    String message = '';
    
    if (state is ReportExcelGenerated) {
      filePath = state.filePath;
      message = state.message;
    } else if (state is ReportPDFGenerated) {
      filePath = state.filePath;
      message = state.message;
    }

    // Custom dialog dengan 2 pilihan: Bagikan & Oke
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.check_circle,
          color: AppTheme.primaryGreen,
          size: 48,
        ),
        title: const Text(
          'Export Berhasil!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // Button BAGIKAN - Share file tanpa navigate
          TextButton.icon(
            onPressed: () {
              _shareFile(filePath);
              // Tidak navigate, biarkan user tetap di halaman ini
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Bagikan'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
            ),
          ),
          // Button OKE - Navigate ke Report Page
          ElevatedButton(
            onPressed: () {
              // Close dialog
              Navigator.of(dialogContext).pop();
              
              // Navigate ke Report Page utama
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/report', // Route ke ReportPage utama
                (route) => route.settings.name == '/main' || route.isFirst,
              );
              
              print('Successfully navigated back to Report Page (/report)');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

  // Share file dengan error handling
  static Future<void> _shareFile(String filePath) async {
    if (_isSharing) {
      print('Already sharing, preventing duplicate share');
      return;
    }

    try {
      _isSharing = true;
      print('Starting share for: $filePath');

      await Share.shareXFiles([XFile(filePath)]);
      
      print('Share completed successfully');

    } catch (e) {
      print('Share error: $e');
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isSharing = false;
        print('Share flag reset');
      });
    }
  }

  // Reset sharing flag untuk debugging
  static void resetSharingFlag() {
    _isSharing = false;
    print('Sharing flag manually reset');
  }
}