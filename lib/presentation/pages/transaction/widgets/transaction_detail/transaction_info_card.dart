import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class TransactionInfoCard extends StatelessWidget {
  final TransaksiModel transaction;

  const TransactionInfoCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateInfo(),
            const Divider(height: 24),
            _buildPaymentMethodInfo(),
            const Divider(height: 24),
            _buildCashierInfo(),
          ],
        ),
      ),
    );
  }

  // Membangun informasi tanggal
  Widget _buildDateInfo() {
    return _InfoRow(
      label: 'Tanggal',
      value: '${transaction.formattedDate} • ${transaction.formattedTime}',
      icon: Icons.calendar_today,
    );
  }

  // Membangun informasi metode pembayaran
  Widget _buildPaymentMethodInfo() {
    return _InfoRow(
      label: 'Metode Pembayaran',
      value: transaction.metodeBayar.toUpperCase(),
      icon: transaction.isCash ? Icons.money : Icons.qr_code,
    );
  }

  // Membangun informasi kasir
  Widget _buildCashierInfo() {
    return _InfoRow(
      label: 'Kasir',
      value: 'User ${transaction.idPengguna}',
      icon: Icons.person,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}