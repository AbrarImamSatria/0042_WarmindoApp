import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
    on<ReportGeneratePDF>(_onGeneratePDF); // ✅ TAMBAHAN
  }

  // Check owner permission
  bool _checkOwnerPermission() {
    return _authBloc.isOwner;
  }

  // Check and request storage permission
  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final permission = await Permission.manageExternalStorage.status;
      if (permission.isDenied) {
        final result = await Permission.manageExternalStorage.request();
        return result.isGranted;
      }
      return permission.isGranted;
    }
    return true; // iOS doesn't need explicit permission for app documents
  }

  // Get external storage directory for reports
  Future<Directory> _getReportsDirectory() async {
    Directory reportsDir;
    if (Platform.isAndroid) {
      // Android: /storage/emulated/0/Documents/WarmindoApp/Reports
      final externalDir = await getExternalStorageDirectory();
      final documentsPath = externalDir!.path.split('Android')[0];
      reportsDir = Directory('${documentsPath}Documents/WarmindoApp/Reports');
    } else {
      // iOS: Use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      reportsDir = Directory('${directory.path}/reports');
    }
    
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    return reportsDir;
  }

  // ✅ HELPER METHOD untuk safe double conversion
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ✅ HELPER METHOD untuk safe int conversion
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
      
      // ✅ PERBAIKI: Pastikan semua nilai adalah double
      final fixedSummary = <String, dynamic>{};
      summary.forEach((key, value) {
        if (key.contains('pendapatan') || key.contains('total')) {
          fixedSummary[key] = _toDouble(value);
        } else {
          fixedSummary[key] = value;
        }
      });
      
      emit(ReportDashboardLoaded(data: fixedSummary));
    } catch (e) {
      emit(ReportFailure(error: 'Gagal memuat dashboard: ${e.toString()}'));
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
          revenue = _toDouble(await _transaksiRepository.getPendapatanHariIni());
          break;
        case RevenuePeriod.month:
          revenue = _toDouble(await _transaksiRepository.getPendapatanBulanIni());
          break;
        case RevenuePeriod.custom:
          if (event.startDate != null && event.endDate != null) {
            revenue = _toDouble(await _transaksiRepository.getPendapatanByDateRange(
              event.startDate!,
              event.endDate!,
            ));
          } else {
            throw Exception('Tanggal harus diisi untuk periode custom');
          }
          break;
      }

      // Get daily revenue if needed
      List<Map<String, dynamic>>? dailyRevenue;
      if (event.includeDailyBreakdown && event.startDate != null && event.endDate != null) {
        final rawDailyRevenue = await _transaksiRepository.getDailyRevenueReport(
          event.startDate!,
          event.endDate!,
        );
        
        // ✅ PERBAIKI: Convert semua nilai ke tipe yang benar
        dailyRevenue = rawDailyRevenue.map((day) => <String, dynamic>{
          'date': day['date'],
          'transaction_count': _toInt(day['transaction_count']),
          'total': _toDouble(day['total']),
        }).toList();
      }

      emit(ReportRevenueLoaded(
        totalRevenue: revenue,
        period: event.period,
        dailyRevenue: dailyRevenue,
      ));
    } catch (e) {
      emit(ReportFailure(error: 'Gagal memuat laporan pendapatan: ${e.toString()}'));
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
      final rawBestSelling = await _itemTransaksiRepository.getBestSellingItems(
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      // ✅ PERBAIKI: Convert semua nilai ke tipe yang benar
      final bestSelling = rawBestSelling.map((item) => <String, dynamic>{
        'nama_menu': item['nama_menu'],
        'total_quantity': _toInt(item['total_quantity']),
        'total_revenue': _toDouble(item['total_revenue']),
        'average_price': _toDouble(item['average_price']),
      }).toList();
      
      emit(ReportBestSellingLoaded(items: bestSelling));
    } catch (e) {
      emit(ReportFailure(error: 'Gagal memuat menu terlaris: ${e.toString()}'));
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
      final rawStats = await _transaksiRepository.getPaymentMethodStatistics();
      
      // ✅ PERBAIKI: Convert semua nilai ke tipe yang benar
      final stats = <String, dynamic>{};
      rawStats.forEach((method, data) {
        stats[method] = {
          'count': _toInt(data['count']),
          'total': _toDouble(data['total']),
        };
      });
      
      emit(ReportPaymentStatsLoaded(stats: stats));
    } catch (e) {
      emit(ReportFailure(error: 'Gagal memuat statistik pembayaran: ${e.toString()}'));
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
      emit(ReportFailure(error: 'Gagal menyiapkan data export: ${e.toString()}'));
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
      // Check storage permission
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        emit(ReportFailure(error: 'Izin akses storage diperlukan untuk menyimpan laporan'));
        return;
      }

      // Create Excel workbook
      var excel = Excel.createExcel();
      
      // Remove default sheet
      excel.delete('Sheet1');

      // 1. Summary Sheet
      var summarySheet = excel['Ringkasan'];
      summarySheet.appendRow([
        TextCellValue('LAPORAN WARMINDO APP'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
      summarySheet.appendRow([
        TextCellValue('Periode: ${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
      summarySheet.appendRow([
        TextCellValue('Dibuat: ${_formatDate(DateTime.now())}'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
      ]);
      summarySheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue('')]);

      // 2. Transactions Sheet
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
            DoubleCellValue(_toDouble(trans.totalBayar)), // ✅ PERBAIKI
            TextCellValue(trans.metodeBayar.toUpperCase()),
            TextCellValue('User ${trans.idPengguna}'),
          ]);
        }

        // Add summary row
        transSheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        transSheet.appendRow([
          TextCellValue('TOTAL'),
          TextCellValue(''),
          TextCellValue(''),
          TextCellValue(''),
          DoubleCellValue(transactions.fold(0.0, (sum, t) => sum + _toDouble(t.totalBayar))), // ✅ PERBAIKI
          TextCellValue(''),
          TextCellValue(''),
        ]);
      }

      // 3. Sales by Menu Sheet
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
            IntCellValue(_toInt(item['total_quantity'])), // ✅ PERBAIKI
            DoubleCellValue(_toDouble(item['total_revenue'])), // ✅ PERBAIKI
            DoubleCellValue(_toDouble(item['average_price'])), // ✅ PERBAIKI
          ]);
        }

        // Add summary row
        menuSheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        menuSheet.appendRow([
          TextCellValue('TOTAL'),
          TextCellValue(''),
          IntCellValue(salesData.fold(0, (sum, item) => sum + _toInt(item['total_quantity']))), // ✅ PERBAIKI
          DoubleCellValue(salesData.fold(0.0, (sum, item) => sum + _toDouble(item['total_revenue']))), // ✅ PERBAIKI
          TextCellValue(''),
        ]);
      }

      // 4. Daily Revenue Sheet
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
            IntCellValue(_toInt(day['transaction_count'])), // ✅ PERBAIKI
            DoubleCellValue(_toDouble(day['total'])), // ✅ PERBAIKI
          ]);
        }

        // Add summary row
        revenueSheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        revenueSheet.appendRow([
          TextCellValue('TOTAL'),
          TextCellValue(''),
          IntCellValue(dailyRevenue.fold(0, (sum, day) => sum + _toInt(day['transaction_count']))), // ✅ PERBAIKI
          DoubleCellValue(dailyRevenue.fold(0.0, (sum, day) => sum + _toDouble(day['total']))), // ✅ PERBAIKI
        ]);
      }

      // 5. Payment Stats Sheet
      if (event.includePaymentStats) {
        var paymentSheet = excel['Statistik Pembayaran'];
        
        // Headers
        paymentSheet.appendRow([
          TextCellValue('Metode Pembayaran'), 
          TextCellValue('Jumlah Transaksi'), 
          TextCellValue('Total Pendapatan'),
          TextCellValue('Persentase')
        ]);

        // Get payment stats
        final paymentStats = await _transaksiRepository.getPaymentMethodStatistics();
        final totalTransactions = paymentStats.values.fold(0, (sum, data) => sum + _toInt(data['count'])); // ✅ PERBAIKI
        final totalRevenue = paymentStats.values.fold(0.0, (sum, data) => sum + _toDouble(data['total'])); // ✅ PERBAIKI

        // Data rows
        paymentStats.forEach((method, data) {
          final percentage = totalTransactions > 0 ? (_toInt(data['count']) / totalTransactions * 100) : 0.0; // ✅ PERBAIKI
          paymentSheet.appendRow([
            TextCellValue(method.toUpperCase()),
            IntCellValue(_toInt(data['count'])), // ✅ PERBAIKI
            DoubleCellValue(_toDouble(data['total'])), // ✅ PERBAIKI
            TextCellValue('${percentage.toStringAsFixed(1)}%'),
          ]);
        });

        // Add summary row
        paymentSheet.appendRow([TextCellValue(''), TextCellValue(''), TextCellValue(''), TextCellValue('')]);
        paymentSheet.appendRow([
          TextCellValue('TOTAL'),
          IntCellValue(totalTransactions),
          DoubleCellValue(totalRevenue),
          TextCellValue('100.0%'),
        ]);
      }

      // Get reports directory
      final reportsDir = await _getReportsDirectory();

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'Laporan_Warmindo_${_formatDateForFile(event.startDate)}_to_${_formatDateForFile(event.endDate)}_$timestamp.xlsx';
      final filePath = '${reportsDir.path}/$fileName';
      
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      emit(ReportExcelGenerated(
        filePath: filePath,
        message: 'File Excel berhasil dibuat!\nLokasi: ${reportsDir.path}\nFile: $fileName',
      ));
    } catch (e) {
      emit(ReportFailure(error: 'Gagal generate Excel: ${e.toString()}'));
    }
  }

  // ✅ TAMBAHAN: Generate PDF file
  Future<void> _onGeneratePDF(ReportGeneratePDF event, Emitter<ReportState> emit) async {
    if (!_checkOwnerPermission()) {
      emit(ReportFailure(error: 'Hanya pemilik yang dapat generate PDF'));
      return;
    }

    emit(ReportLoading());
    try {
      // Check storage permission
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        emit(ReportFailure(error: 'Izin akses storage diperlukan untuk menyimpan laporan'));
        return;
      }

      final pdf = pw.Document();

      // Get data
      final transactions = await _transaksiRepository.getTransaksiByDateRange(
        event.startDate,
        event.endDate,
      );
      
      final salesData = await _itemTransaksiRepository.getSalesReportByMenuItem(
        event.startDate,
        event.endDate,
      );
      
      final paymentStats = await _transaksiRepository.getPaymentMethodStatistics();

      // Calculate totals
      final totalRevenue = transactions.fold(0.0, (sum, t) => sum + _toDouble(t.totalBayar));
      final totalTransactions = transactions.length;

      // ✅ PAGE 1: Summary
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red700,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LAPORAN WARMINDO APP',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Periode: ${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        'Dibuat: ${_formatDate(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 30),
                
                // Summary Cards
                pw.Text(
                  'RINGKASAN PENDAPATAN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPDFSummaryCard(
                      'Total Transaksi',
                      totalTransactions.toString(),
                      PdfColors.blue700,
                    ),
                    _buildPDFSummaryCard(
                      'Total Pendapatan',
                      _formatCurrency(totalRevenue),
                      PdfColors.green700,
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Payment Method Statistics
                pw.Text(
                  'STATISTIK METODE PEMBAYARAN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                
                ...paymentStats.entries.map((entry) {
                  final method = entry.key;
                  final data = entry.value;
                  final count = _toInt(data['count']);
                  final total = _toDouble(data['total']);
                  final percentage = totalTransactions > 0 ? (count / totalTransactions * 100) : 0.0;
                  
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          method.toUpperCase(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('$count transaksi (${percentage.toStringAsFixed(1)}%)'),
                            pw.Text(_formatCurrency(total)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      );

      // ✅ PAGE 2: Best Selling Items
      if (salesData.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'MENU TERLARIS',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _buildPDFTableCell('No', isHeader: true),
                          _buildPDFTableCell('Nama Menu', isHeader: true),
                          _buildPDFTableCell('Terjual', isHeader: true),
                          _buildPDFTableCell('Pendapatan', isHeader: true),
                        ],
                      ),
                      
                      // Data rows
                      ...salesData.take(15).map((item) {
                        final index = salesData.indexOf(item) + 1;
                        return pw.TableRow(
                          children: [
                            _buildPDFTableCell(index.toString()),
                            _buildPDFTableCell(item['nama_menu'].toString()),
                            _buildPDFTableCell('${_toInt(item['total_quantity'])} porsi'),
                            _buildPDFTableCell(_formatCurrency(_toDouble(item['total_revenue']))),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      // ✅ PAGE 3: Transactions (if not too many)
      if (event.includeTransactions && transactions.length <= 50) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DAFTAR TRANSAKSI',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(30),
                      1: const pw.FixedColumnWidth(80),
                      2: const pw.FixedColumnWidth(80),
                      3: const pw.FixedColumnWidth(100),
                      4: const pw.FixedColumnWidth(80),
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _buildPDFTableCell('No', isHeader: true),
                          _buildPDFTableCell('Tanggal', isHeader: true),
                          _buildPDFTableCell('Kode', isHeader: true),
                          _buildPDFTableCell('Total', isHeader: true),
                          _buildPDFTableCell('Bayar', isHeader: true),
                        ],
                      ),
                      
                      // Data rows
                      ...transactions.take(40).map((trans) {
                        final index = transactions.indexOf(trans) + 1;
                        return pw.TableRow(
                          children: [
                            _buildPDFTableCell(index.toString()),
                            _buildPDFTableCell(trans.formattedDate),
                            _buildPDFTableCell(trans.transactionCode),
                            _buildPDFTableCell(_formatCurrency(_toDouble(trans.totalBayar))),
                            _buildPDFTableCell(trans.metodeBayar.toUpperCase()),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      // Save PDF
      final reportsDir = await _getReportsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'Laporan_Warmindo_${_formatDateForFile(event.startDate)}_to_${_formatDateForFile(event.endDate)}_$timestamp.pdf';
      final filePath = '${reportsDir.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      emit(ReportPDFGenerated(
        filePath: filePath,
        message: 'File PDF berhasil dibuat!\nLokasi: ${reportsDir.path}\nFile: $fileName',
      ));

    } catch (e) {
      emit(ReportFailure(error: 'Gagal generate PDF: ${e.toString()}'));
    }
  }

  // ✅ PDF Helper methods
  pw.Widget _buildPDFSummaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: color.shade(0.1),
        border: pw.Border.all(color: color),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // Helper functions
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForFile(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}