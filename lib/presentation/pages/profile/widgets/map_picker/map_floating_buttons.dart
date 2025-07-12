import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class MapFloatingButtons extends StatelessWidget {
  final VoidCallback onGetCurrentLocation;

  const MapFloatingButtons({
    Key? key,
    required this.onGetCurrentLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 140,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: onGetCurrentLocation,
            mini: true,
            backgroundColor: AppTheme.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppTheme.primaryRed,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}