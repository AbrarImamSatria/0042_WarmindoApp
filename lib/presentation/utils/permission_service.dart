import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestAllPermissions(BuildContext context) async {
    if (!context.mounted) return;

    if (Platform.isAndroid || Platform.isIOS) {
      final isCameraGranted = await requestCamera(context);
      if (!isCameraGranted) return;

      final isLocationGranted = await requestLocation(context);
      if (!isLocationGranted) return;

      final isStorageGranted = await requestStorage(context);
      if (!isStorageGranted) return;
    }
  }

  static Future<bool> requestCamera(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(context, 'Kamera');
      return false;
    }

    return status.isGranted;
  }

  static Future<bool> requestLocation(BuildContext context) async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog(context, 'Lokasi');
      return false;
    }

    return status.isGranted;
  }

  static Future<bool> requestStorage(BuildContext context) async {
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      // Untuk Android 11+ (API 30+), gunakan manageExternalStorage
      var status = await Permission.manageExternalStorage.status;

      if (status.isDenied || status.isRestricted) {
        status = await Permission.manageExternalStorage.request();
      }

      if (status.isPermanentlyDenied) {
        // Langsung buka ke pengaturan jika ditolak permanen
        await openAppSettings();
        return false;
      }

      return status.isGranted;
    }

    return true;
  }

  static Future<void> _showSettingsDialog(
    BuildContext context,
    String permissionName,
  ) async {
    if (!context.mounted) return;
    await Future.delayed(const Duration(milliseconds: 100));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Izin $permissionName Diperlukan'),
        content: Text(
          'Silakan buka pengaturan aplikasi dan aktifkan izin $permissionName.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Pengaturan'),
          ),
        ],
      ),
    );
  }
}
