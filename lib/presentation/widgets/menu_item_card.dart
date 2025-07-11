import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'dart:io';

import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';

class MenuItemCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final int? quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const MenuItemCard({
    Key? key,
    required this.menu,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.quantity,
    this.onAdd,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section - Fixed height
            Container(
              height: 100, // Fixed height
              decoration: BoxDecoration(
                color: menu.isFood 
                    ? AppTheme.foodColor.withOpacity(0.1) 
                    : AppTheme.drinkColor.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  // Main image
                  if (menu.foto != null)
                    Positioned.fill(
                      child: Image.file(
                        File(menu.foto!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      ),
                    )
                  else
                    Positioned.fill(child: _buildPlaceholder()),
                  
                  // Category badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: menu.isFood ? AppTheme.foodColor : AppTheme.drinkColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        menu.isFood ? 'Makanan' : 'Minuman',
                        style: TextStyle(
                          fontSize: 8,
                          color: menu.isFood ? AppTheme.white : AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content section - Flexible but constrained
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      menu.nama,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Price
                    Text(
                      CurrencyFormatter.formatRupiah(menu.harga),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Actions or Quantity Control
                    if (showActions && (onEdit != null || onDelete != null))
                      _buildActionButtons()
                    else if (quantity != null)
                      _buildQuantityControl(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: menu.isFood 
            ? AppTheme.foodColor.withOpacity(0.1) 
            : AppTheme.drinkColor.withOpacity(0.1),
      ),
      child: Center(
        child: Icon(
          menu.isFood ? Icons.restaurant : Icons.local_drink,
          size: 48,
          color: menu.isFood ? AppTheme.foodColor : AppTheme.drinkColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onEdit != null)
          IconButton(
            icon: Icon(Icons.edit, size: 16, color: AppTheme.primaryRed),
            onPressed: onEdit,
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        if (onDelete != null)
          IconButton(
            icon: Icon(Icons.delete, size: 16, color: AppTheme.error),
            onPressed: onDelete,
            padding: const EdgeInsets.all(2),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
      ],
    );
  }

  Widget _buildQuantityControl() {
    if (quantity == null || quantity == 0) {
      // Full-width add button
      return Container(
        width: double.infinity,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 16, color: AppTheme.white),
              SizedBox(width: 4),
              Text(
                'Tambah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Full-width quantity control
    return Container(
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.greyLight),
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.white,
      ),
      child: Row(
        children: [
          // Remove button
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: onRemove,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Container(
                height: 32,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Icon(
                  quantity! > 1 ? Icons.remove : Icons.delete_outline,
                  size: 16,
                  color: quantity! > 1 ? AppTheme.textSecondary : AppTheme.error,
                ),
              ),
            ),
          ),
          
          // Quantity display
          Expanded(
            flex: 1,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: AppTheme.greyLight, width: 0.5),
                ),
              ),
              child: Center(
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Add button
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: onAdd,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}