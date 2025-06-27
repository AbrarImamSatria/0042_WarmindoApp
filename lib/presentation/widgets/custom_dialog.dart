import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'primary_button.dart';

enum DialogType { info, success, warning, error, confirm }

class CustomDialog {
  // Basic dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: content,
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Message dialog with icon
  static Future<void> showMessage({
    required BuildContext context,
    required String title,
    required String message,
    DialogType type = DialogType.info,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            _getIcon(type),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: PrimaryButton(
              text: buttonText,
              onPressed: () {
                Navigator.of(context).pop();
                onPressed?.call();
              },
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  // Confirmation dialog
  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Tidak',
    DialogType type = DialogType.confirm,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            _getIcon(type),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          PrimaryButton(
            text: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
            type: ButtonType.outline,
            size: ButtonSize.small,
          ),
          PrimaryButton(
            text: confirmText,
            onPressed: () => Navigator.of(context).pop(true),
            type: ButtonType.primary,
            size: ButtonSize.small,
            customColor: confirmColor ?? _getColor(type),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Loading dialog
  static Future<void> showLoading({
    required BuildContext context,
    String message = 'Memproses...',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Success dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Berhasil',
    VoidCallback? onPressed,
  }) {
    return showMessage(
      context: context,
      title: title,
      message: message,
      type: DialogType.success,
      onPressed: onPressed,
    );
  }

  // Error dialog
  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = 'Gagal',
    VoidCallback? onPressed,
  }) {
    return showMessage(
      context: context,
      title: title,
      message: message,
      type: DialogType.error,
      onPressed: onPressed,
    );
  }

  // Delete confirmation dialog
  static Future<bool> showDeleteConfirm({
    required BuildContext context,
    required String itemName,
  }) {
    return showConfirm(
      context: context,
      title: 'Hapus $itemName?',
      message: 'Data yang dihapus tidak dapat dikembalikan.',
      type: DialogType.warning,
      confirmText: 'Hapus',
      cancelText: 'Batal',
      confirmColor: AppTheme.error,
    );
  }

  // Logout confirmation dialog
  static Future<bool> showLogoutConfirm({
    required BuildContext context,
  }) {
    return showConfirm(
      context: context,
      title: 'Keluar dari Aplikasi?',
      message: 'Anda akan keluar dari sesi saat ini.',
      type: DialogType.confirm,
      confirmText: 'Keluar',
      cancelText: 'Batal',
    );
  }

  // Helper methods
  static Widget _getIcon(DialogType type) {
    switch (type) {
      case DialogType.info:
        return const Icon(
          Icons.info_outline,
          size: 48,
          color: AppTheme.info,
        );
      case DialogType.success:
        return const Icon(
          Icons.check_circle_outline,
          size: 48,
          color: AppTheme.success,
        );
      case DialogType.warning:
        return const Icon(
          Icons.warning_amber_outlined,
          size: 48,
          color: AppTheme.warning,
        );
      case DialogType.error:
        return const Icon(
          Icons.error_outline,
          size: 48,
          color: AppTheme.error,
        );
      case DialogType.confirm:
        return const Icon(
          Icons.help_outline,
          size: 48,
          color: AppTheme.primaryRed,
        );
    }
  }

  static Color _getColor(DialogType type) {
    switch (type) {
      case DialogType.info:
        return AppTheme.info;
      case DialogType.success:
        return AppTheme.success;
      case DialogType.warning:
        return AppTheme.warning;
      case DialogType.error:
        return AppTheme.error;
      case DialogType.confirm:
        return AppTheme.primaryRed;
    }
  }
}