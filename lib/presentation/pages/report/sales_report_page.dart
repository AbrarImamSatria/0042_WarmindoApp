import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/pages/report/base_report_page.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

// Halaman laporan penjualan dengan trend harian
class SalesReportPage extends StatefulWidget {
  final DateTime period;

  const SalesReportPage({Key? key, required this.period}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data revenue dengan breakdown harian
  void _loadData() {
    final startDate = DateTime(widget.period.year, widget.period.month, 1);
    final endDate = DateTime(widget.period.year, widget.period.month + 1, 0);

    context.read<ReportBloc>().add(
      ReportLoadRevenue(
        period: RevenuePeriod.custom,
        startDate: startDate,
        endDate: endDate,
        includeDailyBreakdown: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseReportPage(
      title: 'Laporan Penjualan',
      period: widget.period,
      onRefresh: _loadData,
      builder: (context, viewMode) {
        // Gunakan BlocBuilder karena export listener sudah ada di BaseReportPage
        return BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportRevenueLoaded) {
              return _buildContent(state, viewMode);
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildContent(ReportRevenueLoaded state, String viewMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(state.totalRevenue),
          const SizedBox(height: 24),
          if (state.dailyRevenue != null) ...[
            if (viewMode == 'chart')
              _buildDailyRevenueChart(state.dailyRevenue!)
            else
              _buildDailyRevenueTable(state.dailyRevenue!),
          ],
        ],
      ),
    );
  }

  // Summary card dengan total pendapatan periode
  Widget _buildSummaryCard(double totalRevenue) {
    return Card(
      color: AppTheme.primaryGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.attach_money, size: 48, color: AppTheme.primaryGreen),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pendapatan',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatRupiah(totalRevenue),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getMonthName(widget.period.month)} ${widget.period.year}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Line chart untuk trend pendapatan harian
  Widget _buildDailyRevenueChart(List<Map<String, dynamic>> dailyRevenue) {
    final spots = dailyRevenue.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final total = (entry.value['total'] ?? 0).toDouble();
      return FlSpot(index, total);
    }).toList();

    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grafik Pendapatan Harian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: AppTheme.greyLight, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 80,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            CurrencyFormatter.formatShort(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < dailyRevenue.length) {
                            final date = dailyRevenue[value.toInt()]['date'];
                            final day = date.toString().split('-').last;
                            return Text(day, style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.greyLight),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGreen,
                          AppTheme.primaryGreen.withOpacity(0.5),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.white,
                            strokeWidth: 2,
                            strokeColor: AppTheme.primaryGreen,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen.withOpacity(0.3),
                            AppTheme.primaryGreen.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tabel detail pendapatan harian
  Widget _buildDailyRevenueTable(List<Map<String, dynamic>> dailyRevenue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tabel Pendapatan Harian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Transaksi')),
                  DataColumn(label: Text('Pendapatan')),
                ],
                rows: dailyRevenue.map((day) {
                  return DataRow(
                    cells: [
                      DataCell(Text(day['date'].toString().split('-').last)),
                      DataCell(Text(day['transaction_count'].toString())),
                      DataCell(
                        Text(
                          CurrencyFormatter.formatRupiah(day['total'] ?? 0),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
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