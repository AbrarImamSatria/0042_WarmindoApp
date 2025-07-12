import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class AddressCard extends StatelessWidget {
  final Map<String, dynamic>? savedAddress;
  final VoidCallback onSetLocation;

  const AddressCard({
    Key? key,
    required this.savedAddress,
    required this.onSetLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            
            // Konten alamat berdasarkan apakah ada alamat tersimpan atau tidak
            savedAddress != null
                ? _buildSavedAddressContent()
                : _buildEmptyAddressContent(),
          ],
        ),
      ),
    );
  }

  // Membangun header kartu alamat
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 20, color: AppTheme.primaryRed),
        const SizedBox(width: 8),
        const Text(
          'Alamat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _buildActionButton(),
      ],
    );
  }

  // Membangun tombol aksi (tambah/ubah)
  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton.icon(
        onPressed: onSetLocation,
        icon: Icon(
          savedAddress != null ? Icons.edit_location : Icons.add_location,
          size: 18,
          color: AppTheme.primaryRed,
        ),
        label: Text(
          savedAddress != null ? 'Ubah' : 'Tambah',
          style: const TextStyle(
            color: AppTheme.primaryRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Membangun konten ketika ada alamat tersimpan
  Widget _buildSavedAddressContent() {
    return Column(
      children: [
        // Teks alamat
        _buildAddressText(),
        const SizedBox(height: 12),
        
        // Info koordinat
        _buildCoordinateInfo(),
      ],
    );
  }

  // Membangun teks alamat
  Widget _buildAddressText() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.place, size: 16, color: AppTheme.primaryRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              savedAddress!['address'],
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // Membangun info koordinat
  Widget _buildCoordinateInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, size: 16, color: AppTheme.primaryRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lat: ${savedAddress!['latitude'].toStringAsFixed(6)}\n'
              'Lng: ${savedAddress!['longitude'].toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryRed),
            ),
          ),
          TextButton(
            onPressed: onSetLocation,
            child: const Text('Lihat di Peta'),
          ),
        ],
      ),
    );
  }

  // Membangun konten ketika belum ada alamat
  Widget _buildEmptyAddressContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greyLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada alamat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap tombol "Tambah" untuk menentukan lokasi warung',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}