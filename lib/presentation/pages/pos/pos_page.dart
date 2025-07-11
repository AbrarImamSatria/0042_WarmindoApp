import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/pos/pos_bloc.dart';
import 'package:warmindo_app/presentation/pages/pos/widgets/pos/pos_cart_summary.dart';
import 'package:warmindo_app/presentation/pages/pos/widgets/pos/pos_menu_grid.dart';
import 'package:warmindo_app/presentation/pages/pos/widgets/pos/pos_search_bar.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/currency_formatter.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';

class PosPage extends StatefulWidget {
  const PosPage({Key? key}) : super(key: key);

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'semua';

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadMenuData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Inisialisasi tab controller untuk kategori
  void _initializeTabController() {
    _tabController = TabController(length: 3, vsync: this);
  }

  // Memuat data menu dari bloc
  void _loadMenuData() {
    context.read<PosBloc>().add(PosLoadMenu());
  }

  // Callback ketika kategori tab berubah
  void _onCategoryChanged(int index) {
    setState(() {
      switch (index) {
        case 0:
          _selectedCategory = 'semua';
          break;
        case 1:
          _selectedCategory = 'makanan';
          break;
        case 2:
          _selectedCategory = 'minuman';
          break;
      }
    });
  }

  // Callback ketika teks pencarian berubah
  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild dengan query pencarian baru
    });
  }

  // Menangani penambahan item ke keranjang
  void _handleAddToCart(dynamic menu) {
    context.read<PosBloc>().add(PosAddToCart(menu: menu));
  }

  // Menangani pengurangan item dari keranjang
  void _handleRemoveFromCart(dynamic menu, int currentQuantity) {
    if (currentQuantity > 1) {
      context.read<PosBloc>().add(PosUpdateCartQuantity(
        menu: menu,
        quantity: currentQuantity - 1,
      ));
    } else {
      context.read<PosBloc>().add(PosRemoveFromCart(menu: menu));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocConsumer<PosBloc, PosState>(
          listener: _handleBlocListener,
          builder: _buildBlocBuilder,
        ),
      ),
    );
  }

  // Membangun AppBar dengan tab navigation
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Kasir',
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppTheme.primaryRed,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Container(
          color: AppTheme.primaryRed,
          child: TabBar(
            controller: _tabController,
            onTap: _onCategoryChanged,
            indicator: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            labelColor: AppTheme.white,
            unselectedLabelColor: AppTheme.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Makanan'),
              Tab(text: 'Minuman'),
            ],
          ),
        ),
      ),
    );
  }

  // Menangani listener untuk bloc events
  void _handleBlocListener(BuildContext context, PosState state) {
    if (state is PosCheckoutSuccess) {
      CustomDialog.showSuccess(
        context: context,
        message: 'Transaksi berhasil!\nTotal: ${CurrencyFormatter.formatRupiah(state.totalAmount)}',
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRouter.transactionDetail,
            arguments: state.transaksiId,
          );
        },
      );
    } else if (state is PosFailure) {
      CustomDialog.showError(
        context: context,
        message: state.error,
      );
    }
  }

  // Membangun UI berdasarkan state bloc
  Widget _buildBlocBuilder(BuildContext context, PosState state) {
    if (state is PosLoading) {
      return const LoadingWidget();
    } else if (state is PosMenuLoaded) {
      return _buildPosContent(state);
    } else if (state is PosFailure) {
      return _buildErrorContent(state.error);
    }
    return const SizedBox();
  }

  // Membangun konten utama POS
  Widget _buildPosContent(PosMenuLoaded state) {
    return Column(
      children: [
        // Search bar
        PosSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onClear: () {
            _searchController.clear();
            _onSearchChanged();
          },
        ),
        
        // Menu grid
        Expanded(
          child: PosMenuGrid(
            state: state,
            selectedCategory: _selectedCategory,
            searchQuery: _searchController.text,
            onAddToCart: _handleAddToCart,
            onRemoveFromCart: _handleRemoveFromCart,
            onNavigateToMenuManagement: () {
              Navigator.pushNamed(context, AppRouter.menuManagement);
            },
          ),
        ),
        
        // Bottom cart summary
        if (!state.isCartEmpty)
          PosCartSummary(
            totalItems: state.totalItems,
            totalAmount: state.totalAmount,
            onViewCart: () {
              Navigator.pushNamed(context, AppRouter.cart);
            },
          ),
      ],
    );
  }

  // Membangun konten error
  Widget _buildErrorContent(String error) {
    return EmptyStateWidget.error(
      message: error,
      onRetry: () {
        context.read<PosBloc>().add(PosLoadMenu());
      },
    );
  }
}