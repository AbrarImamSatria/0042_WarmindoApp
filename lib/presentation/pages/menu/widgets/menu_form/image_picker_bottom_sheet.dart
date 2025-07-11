import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/menu/menu_bloc.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final String? currentImagePath;
  final bool isEditMode;
  final int? menuId;
  final VoidCallback onImageRemoved;

  const ImagePickerBottomSheet({
    Key? key,
    required this.currentImagePath,
    required this.isEditMode,
    required this.menuId,
    required this.onImageRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bottom sheet
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Pilih Sumber Gambar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Opsi kamera
          _buildCameraOption(context),
          
          // Opsi galeri
          _buildGalleryOption(context),
          
          // Opsi hapus foto (jika ada foto)
          if (currentImagePath != null)
            _buildRemoveOption(context),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Membangun opsi kamera
  Widget _buildCameraOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.camera_alt, color: AppTheme.primaryRed),
      title: const Text('Kamera'),
      onTap: () {
        Navigator.pop(context);
        context.read<MenuBloc>().add(
          MenuPickImageFromCamera(menuId: menuId),
        );
      },
    );
  }

  // Membangun opsi galeri
  Widget _buildGalleryOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
      title: const Text('Galeri'),
      onTap: () {
        Navigator.pop(context);
        context.read<MenuBloc>().add(
          MenuPickImageFromGallery(menuId: menuId),
        );
      },
    );
  }

  // Membangun opsi hapus foto
  Widget _buildRemoveOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete, color: AppTheme.error),
      title: const Text('Hapus Foto'),
      onTap: () {
        Navigator.pop(context);
        onImageRemoved();
        
        // Jika dalam mode edit, update foto di database
        if (isEditMode && menuId != null) {
          context.read<MenuBloc>().add(
            MenuUpdateFoto(menuId: menuId!, fotoPath: null),
          );
        }
      },
    );
  }
}