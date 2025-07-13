import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

// Widget untuk menampilkan daftar menu terlaris di dashboard
class BestSellingWidget extends StatelessWidget {
  final List<dynamic> items;
  final VoidCallback? onNavigationReturn; // Callback untuk refresh setelah navigasi

  const BestSellingWidget({
    Key? key, 
    required this.items,
    this.onNavigationReturn, // Callback untuk refresh setelah navigasi
  }) : super(key: key);

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

  // Navigasi ke detail dengan callback untuk refresh
  Future<void> _navigateToDetailAndReturn(BuildContext context) async {
    print('Navigating to best-selling detail from widget...');
    
    // Navigate dan tunggu hasil
    final result = await Navigator.pushNamed(
      context,
      '/report/best-selling', // Konsisten dengan app_router
      arguments: {
        'type': 'best-selling',
        'period': DateTime.now(),
      },
    );
    
    print('Returned from best-selling detail, result: $result');
    
    // Panggil callback untuk reload data setelah kembali
    if (onNavigationReturn != null) {
      print('Calling onNavigationReturn callback from BestSellingWidget');
      onNavigationReturn!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menu Terlaris',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _navigateToDetailAndReturn(context), // Use callback method
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tampilkan top 5 menu terlaris
            ...items.take(5).map((item) {
              final index = items.indexOf(item) + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _BestSellingItem(
                  rank: index,
                  name: item['nama_menu']?.toString() ?? '',
                  quantity: _toInt(item['total_quantity']),
                  revenue: _toDouble(item['total_revenue']),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Item widget untuk setiap menu terlaris
class _BestSellingItem extends StatelessWidget {
  final int rank;
  final String name;
  final int quantity;
  final double revenue;

  const _BestSellingItem({
    required this.rank,
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Badge ranking dengan warna khusus untuk top 3
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rank <= 3 ? AppTheme.primaryYellow : AppTheme.greyLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? AppTheme.black : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '$quantity porsi',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        // Revenue dengan styling khusus
        Text(
          CurrencyFormatter.formatRupiah(revenue),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }
}