import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

class OrderItemsSection extends StatelessWidget {
  final List<ItemTransaksiModel> items;
  final double totalAmount;

  const OrderItemsSection({
    Key? key,
    required this.items,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        const SizedBox(height: 12),
        _buildItemsCard(),
      ],
    );
  }

  // Membangun judul section
  Widget _buildSectionTitle() {
    return const Text(
      'Detail Pesanan',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Membangun card yang berisi daftar item
  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Daftar item
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _OrderItemRow(item: item),
            )).toList(),
            
            const Divider(height: 24),
            
            // Total amount
            _buildTotalRow(),
          ],
        ),
      ),
    );
  }

  // Membangun baris total
  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          CurrencyFormatter.formatRupiah(totalAmount),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final ItemTransaksiModel item;

  const _OrderItemRow({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informasi item (nama dan detail)
        Expanded(
          child: _buildItemInfo(),
        ),
        
        // Subtotal
        _buildSubtotal(),
      ],
    );
  }

  // Membangun informasi item
  Widget _buildItemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama menu
        Text(
          item.namaMenu,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        
        // Quantity dan harga satuan
        Text(
          '${item.jumlah} x ${CurrencyFormatter.formatRupiah(item.harga)}',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  // Membangun subtotal item
  Widget _buildSubtotal() {
    return Text(
      CurrencyFormatter.formatRupiah(item.subtotal),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}