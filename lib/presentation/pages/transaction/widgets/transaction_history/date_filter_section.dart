import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class DateFilterSection extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onClearFilter;
  final String Function(DateTime) formatDate;

  const DateFilterSection({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onClearFilter,
    required this.formatDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppTheme.primaryRed.withOpacity(0.1),
      child: Row(
        children: [
          _buildFilterIcon(),
          const SizedBox(width: 8),
          _buildDateRange(),
          _buildClearButton(),
        ],
      ),
    );
  }

  // Membangun ikon filter
  Widget _buildFilterIcon() {
    return const Icon(
      Icons.filter_alt,
      size: 20,
      color: AppTheme.primaryRed,
    );
  }

  // Membangun teks range tanggal
  Widget _buildDateRange() {
    return Expanded(
      child: Text(
        '${formatDate(startDate)} - ${formatDate(endDate)}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Membangun tombol clear filter
  Widget _buildClearButton() {
    return IconButton(
      icon: const Icon(Icons.clear, size: 20),
      onPressed: onClearFilter,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}