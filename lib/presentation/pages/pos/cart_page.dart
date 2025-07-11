import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/pos/pos_bloc.dart';
import 'package:warmindo_app/presentation/pages/pos/widgets/cart/cart_items_list.dart';
import 'package:warmindo_app/presentation/pages/pos/widgets/cart/cart_summary_section.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocListener<PosBloc, PosState>(
          listener: _handleBlocListener,
          child: BlocBuilder<PosBloc, PosState>(
            builder: _buildBlocBuilder,
          ),
        ),
      ),
    );
  }

  // Membangun AppBar dengan tombol clear cart
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Keranjang Belanja'),
      actions: [
        BlocBuilder<PosBloc, PosState>(
          builder: (context, state) {
            if (state is PosMenuLoaded && !state.isCartEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _handleClearCart(context),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  // Menangani listener untuk bloc events
  void _handleBlocListener(BuildContext context, PosState state) {
    if (state is PosCheckoutLoading) {
      CustomDialog.showLoading(
        context: context,
        message: 'Memproses pembayaran...',
      );
    } else if (state is PosCheckoutSuccess && state.shouldNavigateToDetail) {
      _handleCheckoutSuccess(context, state);
    } else if (state is PosFailure) {
      _handleCheckoutFailure(context, state);
    }
  }

  // Menangani checkout sukses dan navigasi ke detail transaksi
  void _handleCheckoutSuccess(BuildContext context, PosCheckoutSuccess state) {
    CustomDialog.hideLoading(context);
    
    Navigator.pushNamed(
      context,
      AppRouter.transactionDetail,
      arguments: {
        'transactionId': state.transaksiId,
        'fromCart': true, // Flag bahwa datang dari cart
      },
    ).then((_) {
      // Bersihkan cart setelah kembali dari transaction detail
      context.read<PosBloc>().clearCartAfterCheckout();
    });
  }

  // Menangani checkout gagal
  void _handleCheckoutFailure(BuildContext context, PosFailure state) {
    CustomDialog.hideLoading(context);
    CustomDialog.showError(
      context: context,
      message: state.error,
    );
  }

  // Membangun UI berdasarkan state bloc
  Widget _buildBlocBuilder(BuildContext context, PosState state) {
    if (state is PosMenuLoaded) {
      if (state.isCartEmpty) {
        return EmptyStateWidget.emptyCart();
      }
      return _buildCartContent(state);
    } else if (state is PosLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PosFailure) {
      return _buildErrorContent(context, state.error);
    }
    
    return const SizedBox();
  }

  // Membangun konten utama cart
  Widget _buildCartContent(PosMenuLoaded state) {
    return Column(
      children: [
        // Daftar item dalam keranjang
        Expanded(
          child: CartItemsList(
            cartItems: state.cartItems,
            onQuantityChanged: _handleQuantityChange,
            onItemRemoved: _handleItemRemoved,
          ),
        ),

        // Ringkasan dan tombol checkout
        CartSummarySection(
          totalItems: state.totalItems,
          totalAmount: state.totalAmount,
          onCheckout: _handleCheckout,
        ),
      ],
    );
  }

  // Membangun konten error
  Widget _buildErrorContent(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PosBloc>().add(PosLoadMenu());
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // Menangani konfirmasi clear cart
  Future<void> _handleClearCart(BuildContext context) async {
    final confirm = await CustomDialog.showConfirm(
      context: context,
      title: 'Kosongkan Keranjang?',
      message: 'Semua item akan dihapus dari keranjang.',
      type: DialogType.warning,
    );
    if (confirm) {
      context.read<PosBloc>().add(PosClearCart());
    }
  }

  // Menangani perubahan kuantitas item
  void _handleQuantityChange(dynamic menu, int quantity) {
    final bloc = context.read<PosBloc>();
    
    if (quantity > 0) {
      bloc.add(PosUpdateCartQuantity(menu: menu, quantity: quantity));
    } else {
      bloc.add(PosRemoveFromCart(menu: menu));
    }
  }

  // Menangani penghapusan item dari keranjang
  void _handleItemRemoved(dynamic menu) {
    context.read<PosBloc>().add(PosRemoveFromCart(menu: menu));
  }

  // Menangani proses checkout dengan konfirmasi
  void _handleCheckout(BuildContext context, String paymentMethod) {
    // This will be called from CartSummarySection with proper context
    context.read<PosBloc>().add(PosCheckout(paymentMethod: paymentMethod));
  }
}
