part of 'pos_bloc.dart';

@immutable
sealed class PosEvent {}

// Load menu for POS
final class PosLoadMenu extends PosEvent {}

// Add item to cart
final class PosAddToCart extends PosEvent {
  final MenuModel menu;

  PosAddToCart({required this.menu});
}

// Update cart quantity
final class PosUpdateCartQuantity extends PosEvent {
  final MenuModel menu;
  final int quantity;

  PosUpdateCartQuantity({
    required this.menu,
    required this.quantity,
  });
}

// Remove from cart
final class PosRemoveFromCart extends PosEvent {
  final MenuModel menu;

  PosRemoveFromCart({required this.menu});
}

// Clear cart
final class PosClearCart extends PosEvent {}

// Checkout
final class PosCheckout extends PosEvent {
  final String paymentMethod; // 'tunai' or 'qris'

  PosCheckout({required this.paymentMethod});
}