import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:warmindo_app/data/model/item_transaksi_model.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/data/model/transaksi_model.dart';
import 'package:warmindo_app/data/repository/menu_repository.dart';
import 'package:warmindo_app/data/repository/transaksi_repository.dart';
import '../auth/auth_bloc.dart';

part 'pos_event.dart';
part 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final MenuRepository _menuRepository = MenuRepository();
  final TransaksiRepository _transaksiRepository = TransaksiRepository();
  final AuthBloc _authBloc;

  // Cart items
  final Map<MenuModel, int> _cartItems = {};

  PosBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(PosInitial()) {
    on<PosLoadMenu>(_onLoadMenu);
    on<PosAddToCart>(_onAddToCart);
    on<PosUpdateCartQuantity>(_onUpdateCartQuantity);
    on<PosRemoveFromCart>(_onRemoveFromCart);
    on<PosClearCart>(_onClearCart);
    on<PosCheckout>(_onCheckout);
  }

  // Load menu for POS
  Future<void> _onLoadMenu(PosLoadMenu event, Emitter<PosState> emit) async {
    emit(PosLoading());
    try {
      final menuGrouped = await _menuRepository.getMenuGroupedByCategory();
      emit(PosMenuLoaded(
        menuByCategory: menuGrouped,
        cartItems: Map.from(_cartItems),
        totalAmount: _calculateTotal(),
      ));
    } catch (e) {
      emit(PosFailure(error: e.toString()));
    }
  }

  // Add item to cart
  Future<void> _onAddToCart(PosAddToCart event, Emitter<PosState> emit) async {
    if (state is PosMenuLoaded) {
      final currentState = state as PosMenuLoaded;
      
      // Add or update quantity
      if (_cartItems.containsKey(event.menu)) {
        _cartItems[event.menu] = _cartItems[event.menu]! + 1;
      } else {
        _cartItems[event.menu] = 1;
      }

      emit(PosMenuLoaded(
        menuByCategory: currentState.menuByCategory,
        cartItems: Map.from(_cartItems),
        totalAmount: _calculateTotal(),
      ));
    }
  }

  // Update cart quantity
  Future<void> _onUpdateCartQuantity(PosUpdateCartQuantity event, Emitter<PosState> emit) async {
    if (state is PosMenuLoaded) {
      final currentState = state as PosMenuLoaded;
      
      if (event.quantity > 0) {
        _cartItems[event.menu] = event.quantity;
      } else {
        _cartItems.remove(event.menu);
      }

      emit(PosMenuLoaded(
        menuByCategory: currentState.menuByCategory,
        cartItems: Map.from(_cartItems),
        totalAmount: _calculateTotal(),
      ));
    }
  }

  // Remove from cart
  Future<void> _onRemoveFromCart(PosRemoveFromCart event, Emitter<PosState> emit) async {
    if (state is PosMenuLoaded) {
      final currentState = state as PosMenuLoaded;
      
      _cartItems.remove(event.menu);

      emit(PosMenuLoaded(
        menuByCategory: currentState.menuByCategory,
        cartItems: Map.from(_cartItems),
        totalAmount: _calculateTotal(),
      ));
    }
  }

  // Clear cart
  Future<void> _onClearCart(PosClearCart event, Emitter<PosState> emit) async {
    if (state is PosMenuLoaded) {
      final currentState = state as PosMenuLoaded;
      
      _cartItems.clear();

      emit(PosMenuLoaded(
        menuByCategory: currentState.menuByCategory,
        cartItems: Map.from(_cartItems),
        totalAmount: 0,
      ));
    }
  }

  // ✅ IMPROVED Checkout method
  Future<void> _onCheckout(PosCheckout event, Emitter<PosState> emit) async {
    if (_cartItems.isEmpty) {
      emit(PosFailure(error: 'Keranjang belanja kosong'));
      return;
    }

    emit(PosCheckoutLoading());
    try {
      // Get current user
      final currentUser = _authBloc.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Create transaction model
      final transaksi = TransaksiModel(
        tanggal: DateTime.now(),
        totalBayar: _calculateTotal(),
        metodeBayar: event.paymentMethod,
        idPengguna: currentUser.id!,
      );

      // Create transaction items
      final items = _cartItems.entries.map((entry) {
        return ItemTransaksiModel(
          idTransaksi: 0, // Will be set by repository
          namaMenu: entry.key.nama,
          harga: entry.key.harga,
          jumlah: entry.value,
        );
      }).toList();

      // Save transaction
      final transaksiId = await _transaksiRepository.createTransaksi(transaksi, items);

      // ✅ EMIT checkout success dengan navigation flag (JANGAN clear cart dulu)
      emit(PosCheckoutSuccess(
        transaksiId: transaksiId,
        totalAmount: transaksi.totalBayar,
        shouldNavigateToDetail: true, // ✅ Flag untuk navigate ke detail
      ));

      // ✅ JANGAN add(PosLoadMenu()) di sini, biarkan Cart Page yang handle
      
    } catch (e) {
      emit(PosFailure(error: e.toString()));
      
      // Return to menu loaded state with current cart (DON'T clear cart on error)
      try {
        final menuGrouped = await _menuRepository.getMenuGroupedByCategory();
        emit(PosMenuLoaded(
          menuByCategory: menuGrouped,
          cartItems: Map.from(_cartItems),
          totalAmount: _calculateTotal(),
        ));
      } catch (menuError) {
        emit(PosFailure(error: 'Gagal memuat menu: $menuError'));
      }
    }
  }

  // ✅ ADD method untuk clear cart setelah navigation berhasil
  void clearCartAfterCheckout() {
    _cartItems.clear();
    add(PosLoadMenu()); // Reload menu state dengan cart kosong
  }

  // Calculate total
  double _calculateTotal() {
    double total = 0;
    _cartItems.forEach((menu, quantity) {
      total += menu.harga * quantity;
    });
    return total;
  }
}