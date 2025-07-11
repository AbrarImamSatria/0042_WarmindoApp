import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/auth/auth_bloc.dart';
import 'package:warmindo_app/bloc/menu/menu_bloc.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/pages/menu/widgets/menu_management/menu_detail_dialog.dart';
import 'package:warmindo_app/presentation/pages/menu/widgets/menu_management/menu_grid_view.dart';
import 'package:warmindo_app/presentation/pages/menu/widgets/menu_management/menu_search_bar.dart';
import 'package:warmindo_app/presentation/pages/menu/widgets/menu_management/menu_stats_chips.dart';
import 'package:warmindo_app/presentation/routes/app_router.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/empty_state_widget.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({Key? key}) : super(key: key);

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializePageAccess();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Inisialisasi akses halaman dan memuat data menu
  void _initializePageAccess() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && !authState.user.isOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomDialog.showError(
          context: context,
          message: 'Hanya pemilik yang dapat mengakses halaman ini',
          onPressed: () => Navigator.pop(context),
        );
      });
    } else {
      context.read<MenuBloc>().add(MenuLoad());
    }
  }

  // Menambahkan listener untuk perubahan pencarian
  void _setupSearchListener() {
    _searchController.addListener(_onSearchChanged);
  }

  // Callback ketika teks pencarian berubah
  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild dengan term pencarian yang baru
    });
  }

  // Filter menu berdasarkan kategori dan pencarian
  List<MenuModel> _getFilteredMenus(List<MenuModel> allMenus) {
    return allMenus.where((menu) {
      final matchesCategory =
          _selectedCategory == 'semua' || menu.kategori == _selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          menu.nama.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Menangani penghapusan menu dengan konfirmasi
  void _handleDeleteMenu(MenuModel menu) async {
    final confirm = await CustomDialog.showDeleteConfirm(
      context: context,
      itemName: menu.nama,
    );

    if (confirm) {
      context.read<MenuBloc>().add(MenuDelete(menuId: menu.id!));
    }
  }

  // Callback ketika tab kategori berubah
  void _onTabChanged(int index) {
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

  // Menangani navigasi kembali dengan fallback ke main page
  void _handleBackPressed() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.main,
        (route) => false,
      );
    }
  }

  // Menampilkan dialog detail menu dengan opsi edit dan hapus
  void _showMenuDetailDialog(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) => MenuDetailDialog(
        menu: menu,
        onEdit: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRouter.menuForm,
            arguments: menu,
          );
        },
        onDelete: () {
          Navigator.pop(context);
          _handleDeleteMenu(menu);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: SafeArea(
        child: BlocConsumer<MenuBloc, MenuState>(
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
        'Kelola Menu',
        style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppTheme.primaryRed,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.white),
        onPressed: _handleBackPressed,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: AppTheme.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.main,
              (route) => false,
            );
          },
          tooltip: 'Kembali ke Beranda',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Container(
          color: AppTheme.primaryRed,
          child: TabBar(
            controller: _tabController,
            onTap: _onTabChanged,
            indicator: BoxDecoration(
              color: AppTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
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

  // Membangun floating action button untuk tambah menu
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, AppRouter.menuForm);
      },
      icon: const Icon(Icons.add),
      label: const Text('Tambah Menu'),
      backgroundColor: AppTheme.primaryRed,
      foregroundColor: AppTheme.white,
    );
  }

  // Menangani listener untuk bloc events
  void _handleBlocListener(BuildContext context, MenuState state) {
    if (state is MenuSuccess && state.message != null) {
      CustomDialog.showSuccess(
        context: context,
        message: state.message!,
      );
    } else if (state is MenuFailure) {
      CustomDialog.showError(context: context, message: state.error);
    }
  }

  // Membangun UI berdasarkan state bloc
  Widget _buildBlocBuilder(BuildContext context, MenuState state) {
    if (state is MenuLoading) {
      return const LoadingWidget();
    } else if (state is MenuSuccess) {
      return _buildSuccessContent(state.menus);
    } else if (state is MenuFailure) {
      return _buildErrorContent(state.error);
    }
    return const SizedBox();
  }

  // Membangun konten ketika data berhasil dimuat
  Widget _buildSuccessContent(List<MenuModel> allMenus) {
    final filteredMenus = _getFilteredMenus(allMenus);

    return Column(
      children: [
        // Search bar tetap di atas
        MenuSearchBar(
          controller: _searchController,
          onClear: () => _searchController.clear(),
        ),

        // Konten yang dapat di-scroll
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<MenuBloc>().add(MenuLoad());
            },
            child: CustomScrollView(
              slivers: [
                // Info note
                _buildInfoNote(),
                
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Statistik menu
                SliverToBoxAdapter(
                  child: MenuStatsChips(allMenus: allMenus),
                ),

                // Grid menu
                MenuGridView(
                  filteredMenus: filteredMenus,
                  selectedCategory: _selectedCategory,
                  searchQuery: _searchController.text,
                  onMenuTap: _showMenuDetailDialog,
                  onAddMenu: () => Navigator.pushNamed(context, AppRouter.menuForm),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Membangun konten ketika terjadi error
  Widget _buildErrorContent(String error) {
    return EmptyStateWidget.error(
      message: error,
      onRetry: () {
        context.read<MenuBloc>().add(MenuLoad());
      },
    );
  }

  // Membangun info note di bagian atas
  Widget _buildInfoNote() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppTheme.primaryRed,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.white),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 20,
              color: AppTheme.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap pada card menu untuk mengedit atau menghapus',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}