import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';
import 'package:warmindo_app/presentation/widgets/menu_item_card.dart';

class MenuGridView extends StatelessWidget {
  final List<MenuModel> filteredMenus;
  final String selectedCategory;
  final String searchQuery;
  final Function(MenuModel) onMenuTap;
  final VoidCallback onAddMenu;

  const MenuGridView({
    Key? key,
    required this.filteredMenus,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onMenuTap,
    required this.onAddMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filteredMenus.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final menu = filteredMenus[index];
            return MenuItemCard(
              menu: menu,
              showActions: false,
              onTap: () => onMenuTap(menu),
            );
          },
          childCount: filteredMenus.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }

  // Membangun tampilan ketika tidak ada menu yang ditemukan
  Widget _buildEmptyState() {
    if (searchQuery.isNotEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget.searchNotFound(query: searchQuery),
      );
    } else if (selectedCategory != 'semua') {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.restaurant_menu_outlined,
          title: 'Belum Ada ${selectedCategory == 'makanan' ? 'Makanan' : 'Minuman'}',
          subtitle: 'Tambahkan $selectedCategory untuk mulai berjualan',
        ),
      );
    } else {
      return SliverFillRemaining(
        child: EmptyStateWidget.noMenu(onAddMenu: onAddMenu),
      );
    }
  }
}