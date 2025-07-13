import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/pages/report/base_report_page.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

// Halaman laporan pembayaran dengan analisis tunai vs QRIS
class PaymentReportPage extends StatefulWidget {
  final DateTime period;

  const PaymentReportPage({Key? key, required this.period}) : super(key: key);

  @override
  State<PaymentReportPage> createState() => _PaymentReportPageState();
}

class _PaymentReportPageState extends State<PaymentReportPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load statistik pembayaran
  void _loadData() {
    context.read<ReportBloc>().add(ReportLoadPaymentStats());
  }

  @override
  Widget build(BuildContext context) {
    return BaseReportPage(
      title: 'Laporan Pembayaran',
      period: widget.period,
      onRefresh: _loadData,
      builder: (context, viewMode) {
        // Gunakan BlocBuilder karena export listener sudah ada di BaseReportPage
        return BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportPaymentStatsLoaded) {
              return _buildContent(state.stats, viewMode);
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildContent(Map<String, dynamic> stats, String viewMode) {
    final tunaiData = stats['tunai'] ?? {'count': 0, 'total': 0};
    final qrisData = stats['qris'] ?? {'count': 0, 'total': 0};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(tunaiData, qrisData),
          const SizedBox(height: 24),
          if (viewMode == 'chart')
            _buildPaymentComparisonChart(tunaiData, qrisData)
          else
            _buildPaymentComparisonTable(tunaiData, qrisData),
        ],
      ),
    );
  }

  // Cards untuk summary data tunai dan QRIS
  Widget _buildSummaryCards(Map<String, dynamic> tunaiData, Map<String, dynamic> qrisData) {
    return Row(
      children: [
        Expanded(
          child: _PaymentSummaryCard(
            title: 'Tunai',
            count: tunaiData['count'] ?? 0,
            total: (tunaiData['total'] ?? 0).toDouble(),
            color: AppTheme.cashColor,
            icon: Icons.money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PaymentSummaryCard(
            title: 'QRIS',
            count: qrisData['count'] ?? 0,
            total: (qrisData['total'] ?? 0).toDouble(),
            color: AppTheme.qrisColor,
            icon: Icons.qr_code,
          ),
        ),
      ],
    );
  }

  // Pie chart untuk perbandingan metode pembayaran
  Widget _buildPaymentComparisonChart(Map<String, dynamic> tunaiData, Map<String, dynamic> qrisData) {
    final totalCount = (tunaiData['count'] ?? 0) + (qrisData['count'] ?? 0);
    final tunaiPercentage = totalCount > 0 ? (tunaiData['count'] ?? 0) / totalCount * 100 : 0.0;
    final qrisPercentage = totalCount > 0 ? (qrisData['count'] ?? 0) / totalCount * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perbandingan Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 4,
                        centerSpaceRadius: 80,
                        sections: [
                          PieChartSectionData(
                            color: AppTheme.cashColor,
                            value: tunaiPercentage,
                            title: '${tunaiPercentage.toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: AppTheme.qrisColor,
                            value: qrisPercentage,
                            title: '${qrisPercentage.toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        color: AppTheme.cashColor,
                        title: 'Tunai',
                        count: tunaiData['count'] ?? 0,
                        total: (tunaiData['total'] ?? 0).toDouble(),
                      ),
                      const SizedBox(height: 24),
                      _buildLegendItem(
                        color: AppTheme.qrisColor,
                        title: 'QRIS',
                        count: qrisData['count'] ?? 0,
                        total: (qrisData['total'] ?? 0).toDouble(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tabel detail perbandingan metode pembayaran
  Widget _buildPaymentComparisonTable(Map<String, dynamic> tunaiData, Map<String, dynamic> qrisData) {
    final totalCount = (tunaiData['count'] ?? 0) + (qrisData['count'] ?? 0);
    final totalAmount = (tunaiData['total'] ?? 0) + (qrisData['total'] ?? 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DataTable(
              columns: const [
                DataColumn(label: Text('Metode')),
                DataColumn(label: Text('Jumlah')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('%')),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(
                      Row(
                        children: [
                          Icon(Icons.money, size: 20, color: AppTheme.cashColor),
                          SizedBox(width: 8),
                          Text('Tunai'),
                        ],
                      ),
                    ),
                    DataCell(Text('${tunaiData['count'] ?? 0}')),
                    DataCell(
                      Text(
                        CurrencyFormatter.formatRupiah(tunaiData['total'] ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(
                      Text(
                        totalCount > 0
                            ? '${((tunaiData['count'] ?? 0) / totalCount * 100).toStringAsFixed(1)}%'
                            : '0%',
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(
                      Row(
                        children: [
                          Icon(Icons.qr_code, size: 20, color: AppTheme.qrisColor),
                          SizedBox(width: 8),
                          Text('QRIS'),
                        ],
                      ),
                    ),
                    DataCell(Text('${qrisData['count'] ?? 0}')),
                    DataCell(
                      Text(
                        CurrencyFormatter.formatRupiah(qrisData['total'] ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(
                      Text(
                        totalCount > 0
                            ? '${((qrisData['count'] ?? 0) / totalCount * 100).toStringAsFixed(1)}%'
                            : '0%',
                      ),
                    ),
                  ],
                ),
                // Row total dengan styling berbeda
                DataRow(
                  color: MaterialStateProperty.all(AppTheme.greyLight.withOpacity(0.3)),
                  cells: [
                    const DataCell(
                      Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataCell(
                      Text(
                        totalCount.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        CurrencyFormatter.formatRupiah(totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const DataCell(
                      Text('100%', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget legend untuk chart
  Widget _buildLegendItem({
    required Color color,
    required String title,
    required int count,
    required double total,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '$count transaksi',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            Text(
              CurrencyFormatter.formatRupiah(total),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget summary card untuk pembayaran
class _PaymentSummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final double total;
  final Color color;
  final IconData icon;

  const _PaymentSummaryCard({
    required this.title,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              '$count transaksi',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.formatRupiah(total),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}