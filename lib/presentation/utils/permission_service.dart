import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request all required permissions at once
  static Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.location,
    ].request();

    // Check if all permissions granted
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    // For Android 11+, request manage external storage
    if (Platform.isAndroid) {
      final sdkInt = await _getSdkInt();
      if (sdkInt >= 30) {
        final manageStorageStatus = await Permission.manageExternalStorage.request();
        if (!manageStorageStatus.isGranted) {
          allGranted = false;
        }
      }
    }

    return allGranted;
  }

  // Request storage permission specifically
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getSdkInt();
      
      // Android 11+ (API 30+)
      if (sdkInt >= 30) {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        // Android 10 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need this
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getSdkInt();
      
      if (sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return true;
  }

  // Get Android SDK version
  static Future<int> _getSdkInt() async {
    // This is a simple implementation
    // In production, you might want to use device_info_plus package
    return 30; // Default to API 30 for now
  }

  // Show permission rationale dialog
  static Future<bool> showPermissionRationale(
    BuildContext context,
    String permissionName,
    String reason,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Izin $permissionName Diperlukan'),
          content: Text(reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Izinkan'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Open app settings if permission permanently denied
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}