import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

// Widget untuk menampilkan statistik metode pembayaran di dashboard
class PaymentStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const PaymentStatsWidget({Key? key, required this.stats}) : super(key: key);

  // Helper untuk konversi data ke integer dengan null safety
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper untuk konversi data ke double dengan null safety
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox();

    final tunaiData = stats['tunai'] ?? {'count': 0, 'total': 0};
    final qrisData = stats['qris'] ?? {'count': 0, 'total': 0};
    
    final tunaiCount = _toInt(tunaiData['count']);
    final qrisCount = _toInt(qrisData['count']);
    final totalCount = tunaiCount + qrisCount;
    
    final tunaiPercentage = totalCount > 0 ? tunaiCount / totalCount : 0.0;
    final qrisPercentage = totalCount > 0 ? qrisCount / totalCount : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Tampilkan pie chart jika ada data
            if (totalCount > 0) ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (tunaiCount > 0)
                        PieChartSectionData(
                          value: tunaiPercentage * 100,
                          title: '${(tunaiPercentage * 100).toStringAsFixed(1)}%',
                          color: AppTheme.cashColor,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                      if (qrisCount > 0)
                        PieChartSectionData(
                          value: qrisPercentage * 100,
                          title: '${(qrisPercentage * 100).toStringAsFixed(1)}%',
                          color: AppTheme.qrisColor,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              // Empty state untuk belum ada data
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.greyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada data transaksi',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Legend dengan detail transaksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PaymentMethodLegend(
                  color: AppTheme.cashColor,
                  title: 'Tunai',
                  count: tunaiCount,
                  total: _toDouble(tunaiData['total']),
                ),
                _PaymentMethodLegend(
                  color: AppTheme.qrisColor,
                  title: 'QRIS',
                  count: qrisCount,
                  total: _toDouble(qrisData['total']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget legend untuk metode pembayaran
class _PaymentMethodLegend extends StatelessWidget {
  final Color color;
  final String title;
  final int count;
  final double total;

  const _PaymentMethodLegend({
    required this.color,
    required this.title,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
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
    );
  }
}