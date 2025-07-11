import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warmindo_app/bloc/menu/menu_bloc.dart';
import 'package:warmindo_app/data/model/menu_model.dart';
import 'package:warmindo_app/presentation/pages/menu/widgets/menu_form/category_selection.dart';
import 'package:warmindo_app/presentation/pages/menu/widgets/menu_form/image_picker_bottom_sheet.dart';
import 'package:warmindo_app/presentation/pages/menu/widgets/menu_form/image_picker_section.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/custom_text_field.dart';
import 'package:warmindo_app/presentation/widgets/primary_button.dart';

class MenuFormPage extends StatefulWidget {
  final MenuModel? menu;

  const MenuFormPage({
    Key? key,
    this.menu,
  }) : super(key: key);

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  String _selectedKategori = 'makanan';
  String? _imagePath;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // Inisialisasi data form berdasarkan mode edit atau tambah
  void _initializeFormData() {
    _isEditMode = widget.menu != null;
    
    _namaController = TextEditingController(text: widget.menu?.nama ?? '');
    _hargaController = TextEditingController(
      text: widget.menu != null 
          ? widget.menu!.harga.toStringAsFixed(0) 
          : '',
    );
    
    if (widget.menu != null) {
      _selectedKategori = widget.menu!.kategori;
      _imagePath = widget.menu!.foto;
    }
  }

  // Menangani submit form untuk menambah atau mengubah menu
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final menu = MenuModel(
        id: widget.menu?.id,
        nama: _namaController.text.trim(),
        harga: double.parse(_hargaController.text.replaceAll('.', '')),
        kategori: _selectedKategori,
        foto: _imagePath,
      );

      if (_isEditMode) {
        context.read<MenuBloc>().add(MenuUpdate(menu: menu));
      } else {
        context.read<MenuBloc>().add(MenuAdd(menu: menu));
      }
    }
  }

  // Navigasi kembali dengan fallback ke main page
  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
    }
  }

  // Menampilkan bottom sheet untuk memilih sumber gambar
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ImagePickerBottomSheet(
        currentImagePath: _imagePath,
        isEditMode: _isEditMode,
        menuId: widget.menu?.id,
        onImageRemoved: () {
          setState(() {
            _imagePath = null;
          });
        },
      ),
    );
  }

  // Callback ketika kategori berubah
  void _onCategoryChanged(String kategori) {
    setState(() {
      _selectedKategori = kategori;
    });
  }

  // Callback ketika path gambar berubah
  void _onImagePathChanged(String? path) {
    setState(() {
      _imagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: BlocConsumer<MenuBloc, MenuState>(
          listener: _handleBlocListener,
          builder: _buildBlocBuilder,
        ),
      ),
    );
  }

  // Membangun AppBar dengan navigasi kembali
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditMode ? 'Edit Menu' : 'Tambah Menu'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      ),
    );
  }

  // Menangani listener untuk bloc events
  void _handleBlocListener(BuildContext context, MenuState state) {
    if (state is MenuSuccess && state.message != null) {
      CustomDialog.showSuccess(
        context: context,
        message: state.message!,
        onPressed: () {
          Navigator.of(context).pop(); // Tutup dialog
          _navigateBack();
        },
      );
    } else if (state is MenuFailure) {
      CustomDialog.showError(
        context: context,
        message: state.error,
      );
    } else if (state is MenuImagePicked) {
      _onImagePathChanged(state.imagePath);
    }
  }

  // Membangun UI berdasarkan state bloc
  Widget _buildBlocBuilder(BuildContext context, MenuState state) {
    final isLoading = state is MenuLoading;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian picker gambar
            ImagePickerSection(
              imagePath: _imagePath,
              isLoading: isLoading,
              onTap: _showImagePicker,
            ),
            const SizedBox(height: 24),
            
            // Input nama menu
            _buildNameField(),
            const SizedBox(height: 16),
            
            // Input harga menu
            _buildPriceField(),
            const SizedBox(height: 16),
            
            // Pilihan kategori
            CategorySelection(
              selectedCategory: _selectedKategori,
              onCategoryChanged: _onCategoryChanged,
            ),
            const SizedBox(height: 32),
            
            // Tombol submit
            _buildSubmitButton(isLoading),
          ],
        ),
      ),
    );
  }

  // Membangun field input nama menu
  Widget _buildNameField() {
    return CustomTextField(
      label: 'Nama Menu',
      hint: 'Masukkan nama menu',
      controller: _namaController,
      prefixIcon: const Icon(Icons.restaurant_menu),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama menu tidak boleh kosong';
        }
        if (value.length < 3) {
          return 'Nama menu minimal 3 karakter';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  // Membangun field input harga menu
  Widget _buildPriceField() {
    return CustomTextField.currency(
      controller: _hargaController,
      label: 'Harga',
      hint: 'Masukkan harga menu',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harga tidak boleh kosong';
        }
        final price = int.tryParse(value.replaceAll('.', ''));
        if (price == null || price <= 0) {
          return 'Harga tidak valid';
        }
        if (price < 1000) {
          return 'Harga minimal Rp 1.000';
        }
        return null;
      },
    );
  }

  // Membangun tombol submit dengan loading state
  Widget _buildSubmitButton(bool isLoading) {
    return PrimaryButton(
      text: _isEditMode ? 'Simpan Perubahan' : 'Tambah Menu',
      onPressed: isLoading ? null : _handleSubmit,
      isLoading: isLoading,
      isFullWidth: true,
      size: ButtonSize.large,
    );
  }
}