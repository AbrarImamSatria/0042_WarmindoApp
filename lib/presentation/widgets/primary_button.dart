import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

enum ButtonType { primary, secondary, outline, text }
enum ButtonSize { small, medium, large }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? customColor;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.customColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            height: _getLoadingSize(),
            width: _getLoadingSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary ? AppTheme.white : AppTheme.primaryRed,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize()),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    Widget button;
    
    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: customColor ?? AppTheme.primaryRed,
            padding: _getPadding(),
            minimumSize: Size(0, _getHeight()),
          ),
          child: buttonChild,
        );
        break;
        
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.black,
            padding: _getPadding(),
            minimumSize: Size(0, _getHeight()),
          ),
          child: buttonChild,
        );
        break;
        
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: customColor ?? AppTheme.primaryRed,
              width: 2,
            ),
            padding: _getPadding(),
            minimumSize: Size(0, _getHeight()),
          ),
          child: buttonChild,
        );
        break;
        
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding: _getPadding(),
            minimumSize: Size(0, _getHeight()),
          ),
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: _getHeight(),
        child: button,
      );
    }

    return button;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  // Factory constructors for common use cases
  factory PrimaryButton.icon({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return PrimaryButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  factory PrimaryButton.cash({
    required VoidCallback? onPressed,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
  }) {
    return PrimaryButton(
      text: 'Bayar Tunai',
      icon: Icons.money,
      onPressed: onPressed,
      type: ButtonType.primary,
      customColor: AppTheme.cashColor,
      isLoading: isLoading,
      size: size,
    );
  }

  factory PrimaryButton.qris({
    required VoidCallback? onPressed,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
  }) {
    return PrimaryButton(
      text: 'Bayar QRIS',
      icon: Icons.qr_code,
      onPressed: onPressed,
      type: ButtonType.primary,
      customColor: AppTheme.qrisColor,
      isLoading: isLoading,
      size: size,
    );
  }
}