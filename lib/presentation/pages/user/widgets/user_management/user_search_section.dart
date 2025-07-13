import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class UserSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const UserSearchSection({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppTheme.white,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Cari karyawan...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged();
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}