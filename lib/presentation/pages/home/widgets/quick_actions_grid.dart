import 'package:flutter/material.dart';
import 'package:warmindo_app/presentation/pages/home/widgets/quick_action_card.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';

class QuickActionsGrid extends StatelessWidget {
  final bool isOwner;

  const QuickActionsGrid({
    Key? key,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actions = _buildActionsList(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: actions.map((action) => QuickActionCard(action: action)).toList(),
    );
  }

  // Membangun daftar aksi berdasarkan role pengguna
  List<QuickActionModel> _buildActionsList(BuildContext context) {
    final actions = <QuickActionModel>[
      // Aksi yang tersedia untuk semua pengguna
      QuickActionModel(
        title: 'Kasir',
        icon: Icons.point_of_sale,
        color: AppTheme.primaryRed,
        onTap: () => Navigator.pushNamed(context, AppRouter.pos),
      ),
      QuickActionModel(
        title: 'Riwayat',
        icon: Icons.history,
        color: AppTheme.primaryGreen,
        onTap: () => Navigator.pushNamed(context, AppRouter.transactionHistory),
      ),
    ];

    // Aksi khusus untuk owner
    if (isOwner) {
      actions.addAll([
        QuickActionModel(
          title: 'Menu',
          icon: Icons.restaurant_menu,
          color: AppTheme.foodColor,
          onTap: () => Navigator.pushNamed(context, AppRouter.menuManagement),
        ),
        QuickActionModel(
          title: 'Laporan',
          icon: Icons.analytics,
          color: AppTheme.info,
          onTap: () => Navigator.pushNamed(context, AppRouter.report),
        ),
        QuickActionModel(
          title: 'Pengguna',
          icon: Icons.people,
          color: AppTheme.warning,
          onTap: () => Navigator.pushNamed(context, AppRouter.userManagement),
        ),
      ]);
    }

    return actions;
  }
}

// Model untuk data aksi cepat
class QuickActionModel {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickActionModel({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}