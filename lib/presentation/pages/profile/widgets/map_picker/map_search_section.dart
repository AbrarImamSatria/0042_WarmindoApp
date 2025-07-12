import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class MapSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Location> searchResults;
  final bool isSearching;
  final bool showSearchResults;
  final Function(Location) onSelectResult;
  final VoidCallback onClearSearch;

  const MapSearchSection({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.searchResults,
    required this.isSearching,
    required this.showSearchResults,
    required this.onSelectResult,
    required this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          _buildSearchInput(),
          if (showSearchResults && searchResults.isNotEmpty)
            _buildSearchResults(),
        ],
      ),
    );
  }

  // Membangun input pencarian
  Widget _buildSearchInput() {
    return Container(
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
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Cari alamat atau tempat...',
          hintStyle: TextStyle(
            color: AppTheme.grey.withOpacity(0.7),
            fontSize: 16,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.search_rounded,
              color: AppTheme.primaryRed,
              size: 24,
            ),
          ),
          suffixIcon: _buildSearchSuffix(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onTap: () {
          if (searchResults.isNotEmpty) {
            // setState dipanggil dari parent
          }
        },
      ),
    );
  }

  // Membangun suffix icon untuk search input
  Widget? _buildSearchSuffix() {
    if (isSearching) {
      return Container(
        padding: const EdgeInsets.all(14),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
        ),
      );
    }
    
    if (controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear_rounded, color: AppTheme.grey),
        onPressed: () {
          HapticFeedback.lightImpact();
          onClearSearch();
        },
      );
    }
    
    return null;
  }

  // Membangun hasil pencarian
  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchResults.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.2),
          ),
          itemBuilder: (context, index) {
            final location = searchResults[index];
            return _buildSearchResultItem(location);
          },
        ),
      ),
    );
  }

  // Membangun item hasil pencarian
  Widget _buildSearchResultItem(Location location) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onSelectResult(location);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
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
              Expanded(
                child: FutureBuilder<List<Placemark>>(
                  future: placemarkFromCoordinates(
                    location.latitude,
                    location.longitude,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final place = snapshot.data!.first;
                      return Text(
                        _formatPlacemark(place),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                    return Text(
                      '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format placemark menjadi string yang mudah dibaca
  String _formatPlacemark(Placemark place) {
    List<String> parts = [];
    if (place.street?.isNotEmpty == true) parts.add(place.street!);
    if (place.subLocality?.isNotEmpty == true) parts.add(place.subLocality!);
    if (place.locality?.isNotEmpty == true) parts.add(place.locality!);
    if (place.administrativeArea?.isNotEmpty == true) parts.add(place.administrativeArea!);
    return parts.join(', ');
  }
}