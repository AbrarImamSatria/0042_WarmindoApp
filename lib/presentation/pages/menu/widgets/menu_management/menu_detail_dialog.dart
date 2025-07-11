import 'dart:io';
import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class MenuDetailDialog extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuDetailDialog({
    Key? key,
    required this.menu,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogHeader(context),
          _buildMenuImage(),
          _buildMenuDetails(),
        ],
      ),
    );
  }

  // Membangun header dialog dengan tombol close
  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Detail Menu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.grey,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  // Membangun gambar menu atau placeholder
  Widget _buildMenuImage() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: menu.isFood
            ? Colors.orange.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
      ),
      child: _getMenuImageWidget(),
    );
  }

  // Membangun detail informasi menu
  Widget _buildMenuDetails() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuName(),
          const SizedBox(height: 8),
          _buildCategoryBadge(),
          const SizedBox(height: 16),
          _buildPriceInfo(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // Membangun nama menu
  Widget _buildMenuName() {
    return Text(
      menu.nama,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Membangun badge kategori menu
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: menu.isFood ? Colors.orange : Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        menu.isFood ? 'Makanan' : 'Minuman',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Membangun informasi harga
  Widget _buildPriceInfo() {
    return Row(
      children: [
        const Icon(
          Icons.attach_money,
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 4),
        const Text(
          'Harga:',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Text(
          menu.formattedHarga,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  // Membangun tombol aksi edit dan hapus
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Mendapatkan widget gambar menu berdasarkan jenis foto
  Widget _getMenuImageWidget() {
    // Jika tidak ada foto, tampilkan ikon default
    if (menu.foto == null || menu.foto!.isEmpty) {
      return Icon(
        menu.isFood ? Icons.restaurant : Icons.local_drink,
        size: 80,
        color: menu.isFood ? Colors.orange : Colors.blue,
      );
    }

    // Cek apakah foto adalah URL
    if (menu.foto!.startsWith('http://') || menu.foto!.startsWith('https://')) {
      return ClipRRect(
        child: Image.network(
          menu.foto!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: menu.isFood ? Colors.orange : Colors.blue,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _getDefaultIcon(),
        ),
      );
    }

    // Cek apakah foto adalah file lokal
    if (menu.foto!.startsWith('/') || menu.foto!.contains('\\')) {
      return ClipRRect(
        child: Image.file(
          File(menu.foto!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _getDefaultIcon(),
        ),
      );
    }

    // Default: anggap sebagai asset
    return ClipRRect(
      child: Image.asset(
        menu.foto!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _getDefaultIcon(),
      ),
    );
  }

  // Mendapatkan ikon default berdasarkan kategori menu
  Widget _getDefaultIcon() {
    return Icon(
      menu.isFood ? Icons.restaurant : Icons.local_drink,
      size: 80,
      color: menu.isFood ? Colors.orange : Colors.blue,
    );
  }
}