import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

class PosCartSummary extends StatelessWidget {
  final int totalItems;
  final double totalAmount;
  final VoidCallback onViewCart;

  const PosCartSummary({
    Key? key,
    required this.totalItems,
    required this.totalAmount,
    required this.onViewCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Row(
        children: [
          // Informasi total item dan harga
          Expanded(
            child: _buildCartInfo(),
          ),
          
          // Tombol lihat keranjang
          _buildViewCartButton(),
        ],
      ),
    );
  }

  // Membangun informasi cart (total item dan harga)
  Widget _buildCartInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Total item
        Text(
          '$totalItems item',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        
        // Total harga
        Text(
          CurrencyFormatter.formatRupiah(totalAmount),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  // Membangun tombol lihat keranjang
  Widget _buildViewCartButton() {
    return ElevatedButton.icon(
      onPressed: onViewCart,
      icon: const Icon(Icons.shopping_cart),
      label: const Text('Lihat Keranjang'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}