import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/pages/home/widgets/quick_actions_grid.dart';

class QuickActionCard extends StatelessWidget {
  final QuickActionModel action;

  const QuickActionCard({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionIcon(),
              const SizedBox(height: 8),
              _buildActionTitle(),
            ],
          ),
        ),
      ),
    );
  }

  // Membangun ikon aksi dengan background berwarna
  Widget _buildActionIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: action.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        action.icon,
        size: 24,
        color: action.color,
      ),
    );
  }

  // Membangun judul aksi
  Widget _buildActionTitle() {
    return Text(
      action.title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
}