import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:warmindo_app/bloc/report/report_bloc.dart';
import 'package:warmindo_app/presentation/pages/report/base_report_page.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

// Halaman laporan performa menu dengan chart dan tabel
class MenuPerformanceReportPage extends StatefulWidget {
  final DateTime period;

  const MenuPerformanceReportPage({Key? key, required this.period}) : super(key: key);

  @override
  State<MenuPerformanceReportPage> createState() => _MenuPerformanceReportPageState();
}

class _MenuPerformanceReportPageState extends State<MenuPerformanceReportPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data best selling menu untuk periode yang dipilih
  void _loadData() {
    final startDate = DateTime(widget.period.year, widget.period.month, 1);
    final endDate = DateTime(widget.period.year, widget.period.month + 1, 0);

    context.read<ReportBloc>().add(
      ReportLoadBestSelling(
        limit: 20,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseReportPage(
      title: 'Performa Menu',
      period: widget.period,
      onRefresh: _loadData,
      builder: (context, viewMode) {
        // Gunakan BlocBuilder karena export listener sudah ada di BaseReportPage
        return BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportBestSellingLoaded) {
              return _buildContent(state.items, viewMode);
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> items, String viewMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(items),
          const SizedBox(height: 24),
          if (viewMode == 'chart')
            _buildMenuPerformanceChart(items)
          else
            _buildMenuPerformanceTable(items),
        ],
      ),
    );
  }

  // Summary card menampilkan total menu terjual
  Widget _buildSummaryCard(List<Map<String, dynamic>> items) {
    return Card(
      color: AppTheme.foodColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.restaurant_menu, size: 24, color: AppTheme.foodColor),
            const SizedBox(width: 12),
            Text(
              'Total ${items.length} menu terjual',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Bar chart untuk menampilkan top 10 menu terlaris
  Widget _buildMenuPerformanceChart(List<Map<String, dynamic>> items) {
    final topItems = items.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 10 Menu Terlaris',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topItems.map((e) => (e['total_quantity'] ?? 0).toDouble())
                      .reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppTheme.black.withOpacity(0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = topItems[group.x.toInt()];
                        return BarTooltipItem(
                          '${item['nama_menu']}\n',
                          const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '${item['total_quantity']} porsi\n',
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: CurrencyFormatter.formatRupiah(item['total_revenue'] ?? 0),
                              style: const TextStyle(
                                color: AppTheme.primaryYellow,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < topItems.length) {
                            final name = topItems[value.toInt()]['nama_menu'].toString();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  name.length > 10 ? '${name.substring(0, 10)}...' : name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: topItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final quantity = (item['total_quantity'] ?? 0).toDouble();

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: quantity,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.foodColor,
                              AppTheme.foodColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tabel detail performa semua menu
  Widget _buildMenuPerformanceTable(List<Map<String, dynamic>> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performa Menu Detail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Menu')),
                  DataColumn(label: Text('Terjual')),
                  DataColumn(label: Text('Pendapatan')),
                ],
                rows: items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text(index.toString())),
                      DataCell(Text(item['nama_menu'] ?? '')),
                      DataCell(Text('${item['total_quantity'] ?? 0} porsi')),
                      DataCell(
                        Text(
                          CurrencyFormatter.formatRupiah(item['total_revenue'] ?? 0),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
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
}