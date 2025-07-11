import 'package:flutter/material.dart';
import 'package:warmindo_app/bloc/pos/pos_bloc.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';
import 'package:warmindo_app/presentation/widgets/menu_item_card.dart';

class PosMenuGrid extends StatelessWidget {
  final PosMenuLoaded state;
  final String selectedCategory;
  final String searchQuery;
  final Function(dynamic) onAddToCart;
  final Function(dynamic, int) onRemoveFromCart;
  final VoidCallback onNavigateToMenuManagement;

  const PosMenuGrid({
    Key? key,
    required this.state,
    required this.selectedCategory,
    required this.searchQuery,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onNavigateToMenuManagement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredMenu = _getFilteredMenu();

    if (filteredMenu.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.90,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredMenu.length,
      itemBuilder: (context, index) {
        final menu = filteredMenu[index];
        final quantity = state.cartItems[menu] ?? 0;
        
        return MenuItemCard(
          menu: menu,
          quantity: quantity,
          onTap: () => onAddToCart(menu),
          onAdd: () => onAddToCart(menu),
          onRemove: () => onRemoveFromCart(menu, quantity),
        );
      },
    );
  }

  // Filter menu berdasarkan kategori dan pencarian
  List<MenuModel> _getFilteredMenu() {
    List<MenuModel> filteredMenu = [];
    
    // Filter berdasarkan kategori
    if (selectedCategory == 'semua') {
      state.menuByCategory.forEach((category, menus) {
        filteredMenu.addAll(menus);
      });
    } else {
      filteredMenu = state.menuByCategory[selectedCategory] ?? [];
    }
    
    // Filter berdasarkan pencarian
    if (searchQuery.isNotEmpty) {
      filteredMenu = filteredMenu.where((menu) {
        return menu.nama.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
      }).toList();
    }
    
    return filteredMenu;
  }

  // Membangun empty state berdasarkan kondisi
  Widget _buildEmptyState() {
    if (searchQuery.isNotEmpty) {
      return EmptyStateWidget.searchNotFound(query: searchQuery);
    } else {
      return EmptyStateWidget.noMenu(onAddMenu: onNavigateToMenuManagement);
    }
  }
}