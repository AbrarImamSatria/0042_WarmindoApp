import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class CategorySelection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelection({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CategoryOption(
                label: 'Makanan',
                value: 'makanan',
                groupValue: selectedCategory,
                icon: Icons.restaurant,
                color: AppTheme.foodColor,
                onChanged: (value) => onCategoryChanged(value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CategoryOption(
                label: 'Minuman',
                value: 'minuman',
                groupValue: selectedCategory,
                icon: Icons.local_drink,
                color: AppTheme.drinkColor,
                onChanged: (value) => onCategoryChanged(value!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final IconData icon;
  final Color color;
  final ValueChanged<String?> onChanged;

  const _CategoryOption({
    Key? key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.color,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppTheme.greyLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.greyLight,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppTheme.grey,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppTheme.textPrimary,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}