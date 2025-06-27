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
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: menu.isFood ? AppTheme.foodColor.withOpacity(0.1) : AppTheme.drinkColor.withOpacity(0.1),
                ),
                child: menu.foto != null
                    ? Image.file(
                        File(menu.foto!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      menu.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    
                    // Price and Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.formatRupiah(menu.harga),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: menu.isFood ? AppTheme.foodColor : AppTheme.drinkColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            menu.isFood ? 'Makanan' : 'Minuman',
                            style: TextStyle(
                              fontSize: 10,
                              color: menu.isFood ? AppTheme.white : AppTheme.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Actions or Quantity
                    if (showActions && (onEdit != null || onDelete != null)) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: onEdit,
                              color: AppTheme.primaryRed,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: onDelete,
                              color: AppTheme.error,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                    ] else if (quantity != null) ...[
                      const SizedBox(height: 8),
                      _buildQuantityControl(),
                    ],
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
    return Center(
      child: Icon(
        menu.isFood ? Icons.restaurant : Icons.local_drink,
        size: 48,
        color: menu.isFood ? AppTheme.foodColor : AppTheme.drinkColor,
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.greyLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quantity! > 0) ...[
            IconButton(
              icon: const Icon(Icons.remove, size: 16),
              onPressed: onRemove,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 30),
              child: Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: onAdd,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}