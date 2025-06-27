import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'primary_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? AppTheme.greyLight,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                size: ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Factory constructors for common empty states
  factory EmptyStateWidget.noData({
    String title = 'Tidak Ada Data',
    String? subtitle = 'Data yang Anda cari tidak ditemukan',
  }) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: title,
      subtitle: subtitle,
    );
  }

  factory EmptyStateWidget.noMenu({
    required VoidCallback onAddMenu,
  }) {
    return EmptyStateWidget(
      icon: Icons.restaurant_menu_outlined,
      title: 'Belum Ada Menu',
      subtitle: 'Tambahkan menu untuk mulai berjualan',
      buttonText: 'Tambah Menu',
      onButtonPressed: onAddMenu,
      iconColor: AppTheme.primaryYellow,
    );
  }

  factory EmptyStateWidget.noTransaction() {
    return const EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'Belum Ada Transaksi',
      subtitle: 'Transaksi akan muncul di sini',
      iconColor: AppTheme.primaryGreen,
    );
  }

  factory EmptyStateWidget.emptyCart() {
    return const EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'Keranjang Kosong',
      subtitle: 'Pilih menu untuk menambahkan ke keranjang',
      iconColor: AppTheme.primaryRed,
    );
  }

  factory EmptyStateWidget.searchNotFound({
    required String query,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'Tidak Ditemukan',
      subtitle: 'Pencarian "$query" tidak menemukan hasil',
    );
  }

  factory EmptyStateWidget.error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Terjadi Kesalahan',
      subtitle: message,
      buttonText: onRetry != null ? 'Coba Lagi' : null,
      onButtonPressed: onRetry,
      iconColor: AppTheme.error,
    );
  }
}