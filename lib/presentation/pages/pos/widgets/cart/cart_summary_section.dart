import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class CartSummarySection extends StatelessWidget {
  final int totalItems;
  final double totalAmount;
  final Function(BuildContext, String) onCheckout;

  const CartSummarySection({
    Key? key,
    required this.totalItems,
    required this.totalAmount,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.0,
        16.0,
        16.0,
        16.0 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ringkasan pesanan
          _buildOrderSummary(),
          const SizedBox(height: 16),

          // Tombol metode pembayaran
          _buildPaymentButtons(context),
        ],
      ),
    );
  }

  // Membangun ringkasan pesanan
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total item
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Item:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '$totalItems item',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          
          // Total bayar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bayar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyFormatter.formatRupiah(totalAmount),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Membangun tombol metode pembayaran
  Widget _buildPaymentButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton.cash(
            onPressed: () => _handlePaymentMethod(context, 'tunai'),
            size: ButtonSize.medium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton.qris(
            onPressed: () => _handlePaymentMethod(context, 'qris'),
            size: ButtonSize.medium,
          ),
        ),
      ],
    );
  }

  // Menangani pemilihan metode pembayaran dengan konfirmasi
  Future<void> _handlePaymentMethod(BuildContext context, String paymentMethod) async {
    final paymentName = paymentMethod == 'tunai' ? 'Tunai' : 'QRIS';

    final confirm = await CustomDialog.showConfirm(
      context: context,
      title: 'Konfirmasi Pembayaran',
      message: 'Proses pembayaran dengan $paymentName?',
      confirmText: 'Proses',
      cancelText: 'Batal',
    );

    if (confirm) {
      onCheckout(context, paymentMethod);
    }
  }
}