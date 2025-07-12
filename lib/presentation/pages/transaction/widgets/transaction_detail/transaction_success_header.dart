import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

class TransactionSuccessHeader extends StatelessWidget {
  final TransaksiModel transaction;

  const TransactionSuccessHeader({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      color: AppTheme.primaryRed,
      child: Column(
        children: [
          _buildSuccessIcon(),
          const SizedBox(height: 16),
          _buildSuccessTitle(),
          const SizedBox(height: 8),
          _buildTransactionCode(),
          const SizedBox(height: 16),
          _buildTotalAmount(),
        ],
      ),
    );
  }

  // Membangun ikon sukses
  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle,
        size: 48,
        color: AppTheme.white,
      ),
    );
  }

  // Membangun judul sukses
  Widget _buildSuccessTitle() {
    return const Text(
      'Transaksi Berhasil',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.white,
      ),
    );
  }

  // Membangun kode transaksi
  Widget _buildTransactionCode() {
    return Text(
      transaction.transactionCode,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.white.withOpacity(0.9),
      ),
    );
  }

  // Membangun total amount
  Widget _buildTotalAmount() {
    return Text(
      CurrencyFormatter.formatRupiah(transaction.totalBayar),
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppTheme.white,
      ),
    );
  }
}