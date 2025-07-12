import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class MapLocationCard extends StatelessWidget {
  final LatLng? selectedLocation;
  final String? selectedAddress;
  final Animation<Offset> slideAnimation;
  final bool showSearchResults;
  final List<Location> searchResults;

  const MapLocationCard({
    Key? key,
    required this.selectedLocation,
    required this.selectedAddress,
    required this.slideAnimation,
    required this.showSearchResults,
    required this.searchResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedLocation == null) return const SizedBox.shrink();
    
    return Positioned(
      top: showSearchResults && searchResults.isNotEmpty ? 220 : 100,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCardHeader(),
                const SizedBox(height: 12),
                _buildAddressContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Membangun header kartu lokasi
  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: AppTheme.primaryRed,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Lokasi Terpilih',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Membangun konten alamat
  Widget _buildAddressContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: selectedAddress != null
          ? Text(
              selectedAddress!,
              key: ValueKey(selectedAddress),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            )
          : _buildLoadingAddress(),
    );
  }

  // Membangun indikator loading alamat
  Widget _buildLoadingAddress() {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.grey.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Mengambil alamat...',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.grey.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}