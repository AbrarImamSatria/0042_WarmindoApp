import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/pages/home/widgets/stat_card.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

class DashboardStats extends StatelessWidget {
  final Map<String, dynamic> data;

  const DashboardStats({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Baris pertama: Pendapatan hari ini dan Jumlah transaksi
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Pendapatan Hari Ini',
                value: CurrencyFormatter.formatRupiah(
                  data['pendapatanHariIni'] ?? 0,
                ),
                icon: Icons.attach_money,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Transaksi',
                value: '${data['jumlahTransaksiHariIni'] ?? 0}',
                icon: Icons.receipt,
                color: AppTheme.primaryRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Baris kedua: Pendapatan bulan ini (full width)
        StatCard(
          title: 'Pendapatan Bulan Ini',
          value: CurrencyFormatter.formatRupiah(
            data['pendapatanBulanIni'] ?? 0,
          ),
          icon: Icons.calendar_month,
          color: AppTheme.drinkColor,
          isFullWidth: true,
        ),
      ],
    );
  }
}