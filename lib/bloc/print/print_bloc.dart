import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/data/repository/item_transaksi_repository.dart';
import 'dart:io';

import 'package:warmindo_app/data/repository/transaksi_repository.dart';

part 'print_event.dart';
part 'print_state.dart';

class PrintBloc extends Bloc<PrintEvent, PrintState> {
  final TransaksiRepository _transaksiRepository = TransaksiRepository();
  final ItemTransaksiRepository _itemTransaksiRepository = ItemTransaksiRepository();

  PrintBloc() : super(PrintInitial()) {
    on<PrintReceipt>(_onPrintReceipt);
    on<PrintDailyReport>(_onPrintDailyReport);
    on<PrintGeneratePDF>(_onGeneratePDF);
  }

  // Print receipt/nota
  Future<void> _onPrintReceipt(PrintReceipt event, Emitter<PrintState> emit) async {
    emit(PrintLoading());
    try {
      // Get transaction detail
      final detail = await _transaksiRepository.getTransaksiDetail(event.transactionId);
      if (detail == null) {
        throw Exception('Transaksi tidak ditemukan');
      }

      final transaction = detail['transaksi'] as TransaksiModel;
      final items = detail['items'] as List<ItemTransaksiModel>;

      // Generate PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (context) => _buildReceipt(transaction, items),
        ),
      );

      // Print
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Nota_${transaction.transactionCode}',
      );

      emit(PrintSuccess(message: 'Nota berhasil dicetak'));
    } catch (e) {
      emit(PrintFailure(error: e.toString()));
    }
  }

  // Print daily report
  Future<void> _onPrintDailyReport(PrintDailyReport event, Emitter<PrintState> emit) async {
    emit(PrintLoading());
    try {
      // Get today transactions
      final transactions = await _transaksiRepository.getTransaksiHariIni();
      final totalRevenue = await _transaksiRepository.getPendapatanHariIni();
      final itemsSold = await _itemTransaksiRepository.getItemsSoldToday();

      // Generate PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildDailyReportHeader(event.date),
            pw.SizedBox(height: 20),
            _buildRevenueSection(totalRevenue, transactions.length),
            pw.SizedBox(height: 20),
            _buildItemsSoldSection(itemsSold),
            pw.SizedBox(height: 20),
            _buildTransactionListSection(transactions),
          ],
        ),
      );

      // Print
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Laporan_Harian_${event.date.toIso8601String().split('T')[0]}',
      );

      emit(PrintSuccess(message: 'Laporan harian berhasil dicetak'));
    } catch (e) {
      emit(PrintFailure(error: e.toString()));
    }
  }

  // Generate PDF without printing
  Future<void> _onGeneratePDF(PrintGeneratePDF event, Emitter<PrintState> emit) async {
    emit(PrintLoading());
    try {
      // Get transaction detail
      final detail = await _transaksiRepository.getTransaksiDetail(event.transactionId);
      if (detail == null) {
        throw Exception('Transaksi tidak ditemukan');
      }

      final transaction = detail['transaksi'] as TransaksiModel;
      final items = detail['items'] as List<ItemTransaksiModel>;

      // Generate PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (context) => _buildReceipt(transaction, items),
        ),
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final notaDir = Directory('${directory.path}/nota');
      if (!await notaDir.exists()) {
        await notaDir.create(recursive: true);
      }

      final filePath = '${notaDir.path}/nota_${transaction.transactionCode}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      emit(PrintPDFGenerated(
        filePath: filePath,
        message: 'PDF berhasil dibuat',
      ));
    } catch (e) {
      emit(PrintFailure(error: e.toString()));
    }
  }

  // Build receipt layout
  pw.Widget _buildReceipt(TransaksiModel transaction, List<ItemTransaksiModel> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Center(
          child: pw.Text(
            'WARMINDO RAJA VITAMIN 3',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            'Jl. Contoh No. 123, Yogyakarta',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
        
        // Transaction info
        pw.Text('No: ${transaction.transactionCode}'),
        pw.Text('Tgl: ${transaction.formattedDate} ${transaction.formattedTime}'),
        pw.Text('Metode: ${transaction.metodeBayar.toUpperCase()}'),
        pw.Divider(),
        
        // Items
        ...items.map((item) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(item.namaMenu),
              ),
              pw.Text('${item.jumlah}x'),
              pw.Text(item.formattedSubtotal),
            ],
          ),
        )).toList(),
        
        pw.Divider(),
        
        // Total
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'TOTAL',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              transaction.formattedTotal,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'Terima Kasih',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  // Build daily report header
  pw.Widget _buildDailyReportHeader(DateTime date) {
    return pw.Column(
      children: [
        pw.Text(
          'LAPORAN HARIAN',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'WARMINDO RAJA VITAMIN 3',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Tanggal: ${date.day}/${date.month}/${date.year}',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // Build revenue section
  pw.Widget _buildRevenueSection(double totalRevenue, int transactionCount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RINGKASAN PENDAPATAN',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text('Total Transaksi: $transactionCount'),
          pw.Text('Total Pendapatan: Rp ${totalRevenue.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  // Build items sold section
  pw.Widget _buildItemsSoldSection(List<Map<String, dynamic>> items) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ITEM TERJUAL',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Menu', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...items.map((item) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(item['nama_menu'].toString()),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(item['quantity'].toString()),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Rp ${item['total']}'),
                  ),
                ],
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }

  // Build transaction list section
  pw.Widget _buildTransactionListSection(List<TransaksiModel> transactions) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DAFTAR TRANSAKSI',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('No', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Waktu', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Metode', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...transactions.asMap().entries.map((entry) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text((entry.key + 1).toString()),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(entry.value.formattedTime),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(entry.value.formattedTotal),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(entry.value.metodeBayar.toUpperCase()),
                  ),
                ],
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }
}