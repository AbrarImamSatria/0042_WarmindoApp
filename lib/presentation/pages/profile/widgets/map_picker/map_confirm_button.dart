import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class MapConfirmButton extends StatelessWidget {
  final LatLng? selectedLocation;
  final String? selectedAddress;
  final Animation<Offset> slideAnimation;
  final VoidCallback onConfirm;

  const MapConfirmButton({
    Key? key,
    required this.selectedLocation,
    required this.selectedAddress,
    required this.slideAnimation,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (selectedLocation != null && selectedAddress != null)
                    ? AppTheme.primaryRed.withOpacity(0.3)
                    : Colors.transparent,
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: PrimaryButton(
            text: 'Pilih Lokasi Ini',
            onPressed: selectedLocation != null && selectedAddress != null
                ? onConfirm
                : null,
            isFullWidth: true,
            size: ButtonSize.large,
            icon: Icons.check_rounded,
          ),
        ),
      ),
    );
  }
}