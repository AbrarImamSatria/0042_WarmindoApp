import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

class CartItemCard extends StatelessWidget {
  final MenuModel menu;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.menu,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal = menu.harga * quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Informasi menu
            Expanded(
              child: _buildMenuInfo(),
            ),

            // Kontrol kuantitas dan subtotal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Subtotal
                Text(
                  CurrencyFormatter.formatRupiah(subtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Tombol kuantitas
                _buildQuantityControls(),
              ],
            ),

            // Tombol hapus
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
              color: AppTheme.error,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  // Membangun informasi menu
  Widget _buildMenuInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama menu
        Text(
          menu.nama,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        
        // Harga satuan
        Text(
          CurrencyFormatter.formatRupiah(menu.harga),
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        
        // Badge kategori
        _buildCategoryBadge(),
      ],
    );
  }

  // Membangun badge kategori menu
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: menu.isFood
            ? AppTheme.foodColor
            : AppTheme.drinkColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        menu.isFood ? 'Makanan' : 'Minuman',
        style: TextStyle(
          fontSize: 12,
          color: menu.isFood ? AppTheme.white : AppTheme.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Membangun kontrol kuantitas
  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.greyLight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol kurang
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: onDecrease,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          
          // Tampilan kuantitas
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Tombol tambah
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: onIncrease,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}