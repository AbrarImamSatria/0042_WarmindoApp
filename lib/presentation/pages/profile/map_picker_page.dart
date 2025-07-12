import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:warmindo_app/bloc/profile/profile_bloc.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/map_picker/map_confirm_button.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/map_picker/map_floating_buttons.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/map_picker/map_location_card.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/map_picker/map_search_section.dart';
import 'package:warmindo_app/presentation/pages/profile/widgets/map_picker/map_view_section.dart';
import 'package:warmindo_app/presentation/utils/app_theme.dart';
import 'package:warmindo_app/presentation/utils/permission_service.dart';
import 'package:warmindo_app/presentation/widgets/custom_dialog.dart';
import 'package:warmindo_app/presentation/widgets/loading_widget.dart';

class MapPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPickerPage({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  
  // Controllers untuk animasi
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // Controllers untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  
  // Default location (Yogyakarta)
  static const LatLng _defaultLocation = LatLng(-7.797068, 110.370529);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeMap();
    _setupSearchController();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // Inisialisasi animation controllers
  void _initializeControllers() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  // Dispose semua controllers
  void _disposeControllers() {
    _slideController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
  }

  // Inisialisasi map dengan lokasi awal jika tersedia
  void _initializeMap() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _updateMarker(_selectedLocation!);
      _loadAddressFromCoordinates(_selectedLocation!);
      _slideController.forward();
    }
  }

  // Setup controller untuk pencarian
  void _setupSearchController() {
    _searchController.addListener(_onSearchChanged);
    
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() => _showSearchResults = false);
      }
    });
  }

  // Callback ketika teks pencarian berubah
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && query.length > 2) {
      _searchAddresses(query);
    } else {
      setState(() {
        _searchResults.clear();
        _showSearchResults = false;
      });
    }
  }

  // Mencari alamat berdasarkan query
  Future<void> _searchAddresses(String query) async {
    setState(() => _isSearching = true);

    try {
      String enhancedQuery = query;
      if (!query.toLowerCase().contains('yogyakarta') && 
          !query.toLowerCase().contains('jogja')) {
        enhancedQuery = '$query, Yogyakarta, Indonesia';
      }

      final locations = await locationFromAddress(enhancedQuery);
      
      setState(() {
        _searchResults = locations.take(5).toList();
        _showSearchResults = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults.clear();
        _showSearchResults = false;
        _isSearching = false;
      });
    }
  }

  // Memilih hasil pencarian
  Future<void> _selectSearchResult(Location location) async {
    final selectedLocation = LatLng(location.latitude, location.longitude);
    
    _clearSearch();
    _updateMarker(selectedLocation);
    _moveCamera(selectedLocation);
    
    context.read<ProfileBloc>().add(
      ProfileUpdateLocation(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      ),
    );
  }

  // Membersihkan pencarian
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults.clear();
      _showSearchResults = false;
    });
  }

  // Update marker pada peta
  void _updateMarker(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Lokasi Terpilih',
            snippet: _selectedAddress ?? 'Menunggu alamat...',
          ),
        ),
      };
    });
    
    if (!_slideController.isCompleted) {
      _slideController.forward();
    }
  }

  // Callback ketika peta di-tap
  void _onMapTap(LatLng position) {
    HapticFeedback.lightImpact();
    _updateMarker(position);
    
    context.read<ProfileBloc>().add(
      ProfileUpdateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  // Mendapatkan lokasi saat ini dengan permission check
  Future<void> _getCurrentLocation() async {
    bool hasPermission = await PermissionService.requestLocation(context);
    
    if (hasPermission) {
      HapticFeedback.mediumImpact();
      context.read<ProfileBloc>().add(ProfileGetCurrentLocation());
    }
  }

  // Menggerakkan kamera ke lokasi tertentu
  void _moveCamera(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16),
    );
  }

  // Memuat alamat dari koordinat
  Future<void> _loadAddressFromCoordinates(LatLng location) async {
    context.read<ProfileBloc>().add(
      ProfileUpdateLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
  }

  // Konfirmasi pemilihan lokasi
  Future<void> _confirmLocation() async {
    if (_selectedLocation == null || _selectedAddress == null) {
      _showSnackBar(
        'Pilih lokasi dan tunggu alamat dimuat',
        AppTheme.error,
        Icons.warning_amber_rounded,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    
    final confirm = await CustomDialog.showConfirm(
      context: context,
      title: 'Konfirmasi Lokasi',
      message: 'Simpan lokasi ini?\n\n$_selectedAddress',
      confirmText: 'Simpan',
      cancelText: 'Batal',
    );

    if (confirm) {
      context.read<ProfileBloc>().add(
        ProfileSaveAlamat(
          address: _selectedAddress!,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
        ),
      );
    }
  }

  // Menampilkan snack bar dengan pesan
  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: _handleBlocListener,
          builder: (context, state) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  // Map view
                  MapViewSection(
                    selectedLocation: _selectedLocation,
                    defaultLocation: _defaultLocation,
                    markers: _markers,
                    onMapCreated: (controller) => _mapController = controller,
                    onMapTap: _onMapTap,
                  ),
                  
                  // Search section
                  MapSearchSection(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    searchResults: _searchResults,
                    isSearching: _isSearching,
                    showSearchResults: _showSearchResults,
                    onSelectResult: _selectSearchResult,
                    onClearSearch: _clearSearch,
                  ),
                  
                  // Location card
                  MapLocationCard(
                    selectedLocation: _selectedLocation,
                    selectedAddress: _selectedAddress,
                    slideAnimation: _slideAnimation,
                    showSearchResults: _showSearchResults,
                    searchResults: _searchResults,
                  ),
                  
                  // Floating buttons
                  MapFloatingButtons(
                    onGetCurrentLocation: _getCurrentLocation,
                  ),
                  
                  // Confirm button
                  MapConfirmButton(
                    selectedLocation: _selectedLocation,
                    selectedAddress: _selectedAddress,
                    slideAnimation: _slideAnimation,
                    onConfirm: _confirmLocation,
                  ),
                  
                  // Loading overlay
                  if (_isLoadingState(state)) _buildLoadingOverlay(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Membangun AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Pilih Lokasi',
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      backgroundColor: AppTheme.primaryRed,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primaryRed,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.white, size: 20),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppTheme.white, size: 22),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showHelpDialog();
          },
        ),
      ],
      toolbarHeight: 60,
    );
  }

  // Menangani perubahan state dari ProfileBloc
  void _handleBlocListener(BuildContext context, ProfileState state) {
    if (state is ProfileLocationLoaded) {
      setState(() {
        _selectedAddress = state.address;
      });
      
      final location = LatLng(state.latitude, state.longitude);
      _updateMarker(location);
      _moveCamera(location);
      
    } else if (state is ProfileAlamatSaved) {
      _showSnackBar(
        state.message,
        AppTheme.success,
        Icons.check_circle_rounded,
      );
      Navigator.pop(context, true);
      
    } else if (state is ProfileError) {
      _showSnackBar(
        state.error,
        AppTheme.error,
        Icons.error_rounded,
      );
    }
  }

  // Cek apakah dalam keadaan loading
  bool _isLoadingState(ProfileState state) {
    return state is ProfileLoading || state is ProfileLocationLoading;
  }

  // Membangun overlay loading
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: LoadingWidget(message: 'Memproses...'),
      ),
    );
  }

  // Menampilkan dialog bantuan
  void _showHelpDialog() {
    CustomDialog.showMessage(
      context: context,
      title: 'Cara Menggunakan',
      message: '1. Ketik alamat di kotak pencarian\n'
          '2. Pilih dari hasil pencarian atau tap pada peta\n'
          '3. Gunakan tombol lokasi untuk posisi saat ini\n'
          '4. Tap "Pilih Lokasi Ini" untuk menyimpan',
      type: DialogType.info,
    );
  }
}