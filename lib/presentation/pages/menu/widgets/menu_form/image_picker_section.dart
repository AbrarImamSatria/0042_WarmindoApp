import 'dart:io';
import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class ImagePickerSection extends StatelessWidget {
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onTap;

  const ImagePickerSection({
    Key? key,
    required this.imagePath,
    required this.isLoading,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container untuk image picker
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.greyLight,
                width: 2,
              ),
            ),
            child: imagePath != null
                ? _buildImagePreview()
                : _buildImagePlaceholder(),
          ),
        ),
        const SizedBox(height: 8),
        
        // Teks petunjuk
        Text(
          'Tap untuk ${imagePath != null ? 'ubah' : 'tambah'} foto',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Membangun preview gambar yang sudah dipilih
  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(imagePath!),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          ),
        ),
        // Tombol edit di pojok kanan atas
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: AppTheme.white,
                size: 20,
              ),
              onPressed: onTap,
            ),
          ),
        ),
      ],
    );
  }

  // Membangun placeholder ketika belum ada gambar
  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 64,
          color: AppTheme.grey,
        ),
        const SizedBox(height: 8),
        Text(
          'Tambah Foto Menu',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          '(Opsional)',
          style: TextStyle(
            color: AppTheme.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}