part of 'pos_bloc.dart';

@immutable
sealed class PosState {}

// Initial state
final class PosInitial extends PosState {}

// Loading state
final class PosLoading extends PosState {}

// Menu loaded with cart state
final class PosMenuLoaded extends PosState {
  final Map<String, List<MenuModel>> menuByCategory;
  final Map<MenuModel, int> cartItems;
  final double totalAmount;

  PosMenuLoaded({
    required this.menuByCategory,
    required this.cartItems,
    required this.totalAmount,
  });

  // Helper getters
  int get totalItems {
    int total = 0;
    cartItems.forEach((_, quantity) {
      total += quantity;
    });
    return total;
  }

  bool get isCartEmpty => cartItems.isEmpty;
}

// Checkout loading state
final class PosCheckoutLoading extends PosState {}

// Checkout success state
final class PosCheckoutSuccess extends PosState {
  final int transaksiId;
  final double totalAmount;
  final bool shouldNavigateToDetail; // ✅ TAMBAH field ini

  PosCheckoutSuccess({
    required this.transaksiId,
    required this.totalAmount,
    this.shouldNavigateToDetail = true, // ✅ Default true untuk navigate
  });
}

// Failure state
final class PosFailure extends PosState {
  final String error;

  PosFailure({required this.error});
}