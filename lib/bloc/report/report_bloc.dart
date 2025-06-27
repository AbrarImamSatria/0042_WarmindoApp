import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/data/repository/item_transaksi_repository.dart';
import 'package:warmindo_app/data/repository/transaksi_repository.dart';
import 'dart:io';
import '../auth/auth_bloc.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final TransaksiRepository _transaksiRepository = TransaksiRepository();
  final ItemTransaksiRepository _itemTransaksiRepository = ItemTransaksiRepository();
  final AuthBloc _authBloc;

  ReportBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(ReportInitial()) {
    on<ReportLoadDashboard>(_onLoadDashboard);
    on<ReportLoadRevenue>(_onLoadRevenue);
    on<ReportLoadBestSelling>(_onLoadBestSelling);
    on<ReportLoadPaymentStats>(_onLoadPaymentStats);
    on<ReportExportData>(_onExportData);
    on<ReportGenerateExcel>(_onGenerateExcel);
  }

  // Check owner permission
  bool _checkOwnerPermission() {
    return _authBloc.isOwner;
  }

  // Load dashboard summary
  Future<void> _onLoadDashboard(ReportLoadDashboard event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat laporan'));
      return;
    }

    emit(ReportLoading());
    try {
      final summary = await _transaksiRepository.getDashboardSummary();
      emit(ReportDashboardLoaded(data: summary));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Load revenue report
  Future<void> _onLoadRevenue(ReportLoadRevenue event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat laporan pendapatan'));
      return;
    }

    emit(ReportLoading());
    try {
      double revenue;
      
      switch (event.period) {
        case RevenuePeriod.today:
          revenue = await _transaksiRepository.getPendapatanHariIni();
          break;
        case RevenuePeriod.month:
          revenue = await _transaksiRepository.getPendapatanBulanIni();
          break;
        case RevenuePeriod.custom:
          if (event.startDate != null && event.endDate != null) {
            revenue = await _transaksiRepository.getPendapatanByDateRange(
              event.startDate!,
              event.endDate!,
            );
          } else {
            throw Exception('Tanggal harus diisi untuk periode custom');
          }
          break;
      }

      // Get daily revenue if needed
      List<Map<String, dynamic>>? dailyRevenue;
      if (event.includeDailyBreakdown && event.startDate != null && event.endDate != null) {
        dailyRevenue = await _transaksiRepository.getDailyRevenueReport(
          event.startDate!,
          event.endDate!,
        );
      }

      emit(ReportRevenueLoaded(
        totalRevenue: revenue,
        period: event.period,
        dailyRevenue: dailyRevenue,
      ));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Load best selling items
  Future<void> _onLoadBestSelling(ReportLoadBestSelling event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat laporan menu terlaris'));
      return;
    }

    emit(ReportLoading());
    try {
      final bestSelling = await _itemTransaksiRepository.getBestSellingItems(
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      emit(ReportBestSellingLoaded(items: bestSelling));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Load payment method statistics
  Future<void> _onLoadPaymentStats(ReportLoadPaymentStats event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat melihat statistik pembayaran'));
      return;
    }

    emit(ReportLoading());
    try {
      final stats = await _transaksiRepository.getPaymentMethodStatistics();
      emit(ReportPaymentStatsLoaded(stats: stats));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Export data for Excel
  Future<void> _onExportData(ReportExportData event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat export data'));
      return;
    }

    emit(ReportLoading());
    try {
      // Get all required data
      final transactions = await _transaksiRepository.getTransaksiByDateRange(
        event.startDate,
        event.endDate,
      );
      
      final salesByMenu = await _itemTransaksiRepository.getItemsForExport(
        event.startDate,
        event.endDate,
      );
      
      final dailyRevenue = await _transaksiRepository.getDailyRevenueReport(
        event.startDate,
        event.endDate,
      );

      emit(ReportExportReady(
        transactions: transactions,
        salesByMenu: salesByMenu,
        dailyRevenue: dailyRevenue,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }

  // Generate Excel file
  Future<void> _onGenerateExcel(ReportGenerateExcel event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat generate Excel'));
      return;
    }

    emit(ReportLoading());
    try {
      // Create Excel workbook
      var excel = Excel.createExcel();
      
      // Remove default sheet
      excel.delete('Sheet1');

      // 1. Transactions Sheet
      if (event.includeTransactions) {
        var transSheet = excel['Transaksi'];
        
        // Headers
        transSheet.appendRow([
          TextCellValue('No'), 
          TextCellValue('Tanggal'), 
          TextCellValue('Waktu'), 
          TextCellValue('Kode Transaksi'), 
          TextCellValue('Total'), 
          TextCellValue('Metode Bayar'), 
          TextCellValue('Kasir')
        ]);

        // Get transactions
        final transactions = await _transaksiRepository.getTransaksiByDateRange(
          event.startDate,
          event.endDate,
        );

        // Data rows
        for (var i = 0; i < transactions.length; i++) {
          final trans = transactions[i];
          transSheet.appendRow([
            IntCellValue(i + 1),
            TextCellValue(trans.formattedDate),
            TextCellValue(trans.formattedTime),
            TextCellValue(trans.transactionCode),
            DoubleCellValue(trans.totalBayar),
            TextCellValue(trans.metodeBayar.toUpperCase()),
            TextCellValue('User ${trans.idPengguna}'),
          ]);
        }
      }

      // 2. Sales by Menu Sheet
      if (event.includeSalesByMenu) {
        var menuSheet = excel['Penjualan Menu'];
        
        // Headers
        menuSheet.appendRow([
          TextCellValue('No'), 
          TextCellValue('Nama Menu'), 
          TextCellValue('Jumlah Terjual'), 
          TextCellValue('Total Pendapatan'), 
          TextCellValue('Harga Rata-rata')
        ]);

        // Get sales data
        final salesData = await _itemTransaksiRepository.getSalesReportByMenuItem(
          event.startDate,
          event.endDate,
        );

        // Data rows
        for (var i = 0; i < salesData.length; i++) {
          final item = salesData[i];
          menuSheet.appendRow([
            IntCellValue(i + 1),
            TextCellValue(item['nama_menu'].toString()),
            IntCellValue(item['total_quantity'] as int),
            DoubleCellValue(item['total_revenue'] as double),
            DoubleCellValue(item['average_price'] as double),
          ]);
        }
      }

      // 3. Daily Revenue Sheet
      if (event.includeDailyRevenue) {
        var revenueSheet = excel['Pendapatan Harian'];
        
        // Headers
        revenueSheet.appendRow([
          TextCellValue('No'), 
          TextCellValue('Tanggal'), 
          TextCellValue('Jumlah Transaksi'), 
          TextCellValue('Total Pendapatan')
        ]);

        // Get daily revenue
        final dailyRevenue = await _transaksiRepository.getDailyRevenueReport(
          event.startDate,
          event.endDate,
        );

        // Data rows
        for (var i = 0; i < dailyRevenue.length; i++) {
          final day = dailyRevenue[i];
          revenueSheet.appendRow([
            IntCellValue(i + 1),
            TextCellValue(day['date'].toString()),
            IntCellValue(day['transaction_count'] as int),
            DoubleCellValue(day['total'] as double),
          ]);
        }
      }

      // 4. Payment Stats Sheet
      if (event.includePaymentStats) {
        var paymentSheet = excel['Statistik Pembayaran'];
        
        // Headers
        paymentSheet.appendRow([
          TextCellValue('Metode Pembayaran'), 
          TextCellValue('Jumlah Transaksi'), 
          TextCellValue('Total Pendapatan')
        ]);

        // Get payment stats
        final paymentStats = await _transaksiRepository.getPaymentMethodStatistics();

        // Data rows
        paymentStats.forEach((method, data) {
          paymentSheet.appendRow([
            TextCellValue(method.toUpperCase()),
            IntCellValue(data['count'] as int),
            DoubleCellValue(data['total'] as double),
          ]);
        });
      }

      // Save Excel file
      Directory? excelDir;
      if (Platform.isAndroid) {
        // Android: /storage/emulated/0/Documents/WarmindoApp/Reports
        final externalDir = await getExternalStorageDirectory();
        final documentsPath = externalDir!.path.split('Android')[0];
        excelDir = Directory('${documentsPath}Documents/WarmindoApp/Reports');
      } else {
        // iOS: Use application documents directory
        final directory = await getApplicationDocumentsDirectory();
        excelDir = Directory('${directory.path}/reports');
      }
      
      if (!await excelDir.exists()) {
        await excelDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'Laporan_Warmindo_${event.startDate.toIso8601String().split('T')[0]}_to_${event.endDate.toIso8601String().split('T')[0]}.xlsx';
      final filePath = '${excelDir.path}/$fileName';
      
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      emit(ReportExcelGenerated(
        filePath: filePath,
        message: 'File Excel berhasil dibuat di: ${excelDir.path}',
      ));
    } catch (e) {
      emit(ReportFailure(error: e.toString()));
    }
  }
}