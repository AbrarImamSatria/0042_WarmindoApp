import 'package:flutter/material.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/pages/pos/widgets/cart/cart_item_card.dart';

class CartItemsList extends StatelessWidget {
  final Map<MenuModel, int> cartItems;
  final Function(MenuModel, int) onQuantityChanged;
  final Function(MenuModel) onItemRemoved;

  const CartItemsList({
    Key? key,
    required this.cartItems,
    required this.onQuantityChanged,
    required this.onItemRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final entry = cartItems.entries.elementAt(index);
        final menu = entry.key;
        final quantity = entry.value;

        return CartItemCard(
          menu: menu,
          quantity: quantity,
          onIncrease: () => onQuantityChanged(menu, quantity + 1),
          onDecrease: () {
            if (quantity > 1) {
              onQuantityChanged(menu, quantity - 1);
            } else {
              onItemRemoved(menu);
            }
          },
          onRemove: () => onItemRemoved(menu),
        );
      },
    );
  }
}