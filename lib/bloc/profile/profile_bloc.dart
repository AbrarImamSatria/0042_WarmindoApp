// profile_bloc.dart - Versi tanpa permission checking
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:warmindo_app/data/model/pengguna_model.dart';
import 'package:warmindo_app/data/repository/pengguna_repository.dart';
import '../auth/auth_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final PenggunaRepository _penggunaRepository = PenggunaRepository();
  final AuthBloc _authBloc;

  ProfileBloc({required AuthBloc authBloc}) 
    : _authBloc = authBloc,
      super(ProfileInitial()) {
    
    // Register event handlers
    on<ProfileLoad>(_onLoadProfile);
    on<ProfileGetCurrentLocation>(_onGetCurrentLocation);
    on<ProfileUpdateLocation>(_onUpdateLocation);
    on<ProfileSaveAlamat>(_onSaveAlamat);
  }

  // Handler 1: Load user profile
  Future<void> _onLoadProfile(ProfileLoad event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Get current user from AuthBloc
      final user = _authBloc.currentUser;
      if (user == null) {
        emit(ProfileError(error: 'User tidak login'));
        return;
      }

      // Ambil data terbaru dari database untuk memastikan alamat up-to-date
      final updatedUser = await _penggunaRepository.getPenggunaById(user.id!);
      if (updatedUser != null) {
        // Update AuthBloc dengan data terbaru
        _authBloc.add(AuthUpdateUser(user: updatedUser));
        emit(ProfileLoaded(user: updatedUser));
      } else {
        emit(ProfileLoaded(user: user));
      }
    } catch (e) {
      emit(ProfileError(error: 'Gagal memuat profil: ${e.toString()}'));
    }
  }

  // Handler 2: Get current GPS location (CLEANED - no permission check)
  Future<void> _onGetCurrentLocation(ProfileGetCurrentLocation event, Emitter<ProfileState> emit) async {
    emit(ProfileLocationLoading());
    
    try {
      // 1. Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(ProfileError(error: 'GPS tidak aktif. Silakan aktifkan GPS.'));
        return;
      }

      // 2. Langsung ambil posisi (permission sudah dicek di UI)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // 3. Convert coordinates to address
      final address = await _getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );

      // 4. Emit location loaded
      emit(ProfileLocationLoaded(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      ));

    } catch (e) {
      emit(ProfileError(error: 'Gagal mendapatkan lokasi: ${e.toString()}'));
    }
  }

  // Handler 3: Update location from map selection
  Future<void> _onUpdateLocation(ProfileUpdateLocation event, Emitter<ProfileState> emit) async {
    emit(ProfileLocationLoading());
    
    try {
      // Convert coordinates to address
      final address = await _getAddressFromCoordinates(
        event.latitude, 
        event.longitude
      );

      // Emit location loaded
      emit(ProfileLocationLoaded(
        latitude: event.latitude,
        longitude: event.longitude,
        address: address,
      ));

    } catch (e) {
      emit(ProfileError(error: 'Gagal mendapatkan alamat: ${e.toString()}'));
    }
  }

  // Handler 4: Save alamat to database
  Future<void> _onSaveAlamat(ProfileSaveAlamat event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    try {
      // Get current user
      final user = _authBloc.currentUser;
      if (user == null) {
        emit(ProfileError(error: 'User tidak login'));
        return;
      }

      // Format alamat: "address|latitude,longitude"
      final formattedAddress = '${event.address}|${event.latitude},${event.longitude}';
      
      // Save to database
      final success = await _penggunaRepository.updateAlamat(user.id!, formattedAddress);
      
      if (success) {
        // Update user di AuthBloc dengan alamat baru
        final updatedUser = user.copyWith(alamat: formattedAddress);
        _authBloc.add(AuthUpdateUser(user: updatedUser));
        
        emit(ProfileAlamatSaved(message: 'Alamat berhasil disimpan'));
      } else {
        emit(ProfileError(error: 'Gagal menyimpan alamat'));
      }

    } catch (e) {
      emit(ProfileError(error: 'Gagal menyimpan alamat: ${e.toString()}'));
    }
  }

  // Helper method: Convert coordinates to readable address
  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) {
        return 'Alamat tidak ditemukan';
      }

      final place = placemarks.first;
      
      // Build address string
      List<String> addressParts = [];
      
      if (place.street?.isNotEmpty == true) {
        addressParts.add(place.street!);
      }
      if (place.subLocality?.isNotEmpty == true) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality?.isNotEmpty == true) {
        addressParts.add(place.locality!);
      }
      if (place.administrativeArea?.isNotEmpty == true) {
        addressParts.add(place.administrativeArea!);
      }
      if (place.postalCode?.isNotEmpty == true) {
        addressParts.add(place.postalCode!);
      }
      
      if (addressParts.isEmpty) {
        return 'Alamat tidak ditemukan';
      }
      
      return addressParts.join(', ');
      
    } catch (e) {
      return 'Gagal mendapatkan alamat';
    }
  }

  // Helper method: Parse saved address from user
  Map<String, dynamic>? parseSavedAddress(String? alamat) {
    if (alamat == null || alamat.isEmpty) return null;
    
    try {
      final parts = alamat.split('|');
      if (parts.length != 2) return null;
      
      final address = parts[0];
      final coords = parts[1].split(',');
      if (coords.length != 2) return null;
      
      final latitude = double.tryParse(coords[0]);
      final longitude = double.tryParse(coords[1]);
      
      if (latitude == null || longitude == null) return null;
      
      return {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };
    } catch (e) {
      return null;
    }
  }
}